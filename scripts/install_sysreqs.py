#!/usr/bin/env python3
"""Install the system libraries the packages in an renv lockfile link against.

Posit Package Manager binaries are not self-contained: V8 needs libnode, curl
needs libcurl. Asking PPM which libraries a lockfile needs keeps the workflows
from guessing, and keeps a new R dependency from silently missing its system
dependency.
"""

import argparse
import json
import os
import pathlib
import re
import shutil
import subprocess
import sys
import urllib.error
import urllib.parse
import urllib.request

sys.path.insert(0, str(pathlib.Path(__file__).resolve().parent))

import renv_ci  # noqa: E402

SYSREQS_API = "https://packagemanager.posit.co/__api__/repos/cran/sysreqs"
R_PACKAGE = re.compile(r"^[A-Za-z][A-Za-z0-9.]*$")
APT_PACKAGE = re.compile(r"^[a-z0-9][a-z0-9+.:-]*$")


def resolve_lockfile(given, profile):
    if given:
        return pathlib.Path(given)
    if profile:
        return pathlib.Path("renv/profiles") / profile / "renv.lock"
    return pathlib.Path("renv.lock")


def cran_packages(lockfile):
    """Package names in the lockfile that PPM can be asked about.

    PPM answers 500 for the whole query if it is sent a name it does not know,
    so GitHub and r-universe records must be left out.
    """
    names = sorted(renv_ci.cran_records(renv_ci.load_lockfile(lockfile)))
    unexpected = [name for name in names if not R_PACKAGE.match(name)]
    if unexpected:
        raise ValueError(f"implausible package names in {lockfile}: {unexpected}")
    return names


def host_platform():
    release = {}
    os_release = pathlib.Path("/etc/os-release")
    if os_release.is_file():
        for line in os_release.read_text().splitlines():
            key, _, value = line.partition("=")
            release[key] = value.strip('"')
    return release.get("ID", "ubuntu"), release.get("VERSION_ID", "24.04")


def fetch_json(url):
    with urllib.request.urlopen(url) as response:
        return json.load(response)


def sysreqs(names, distribution, release):
    query = urllib.parse.urlencode(
        [("all", "false"), ("distribution", distribution), ("release", release)]
        + [("pkgname", name) for name in names]
    )
    payload = fetch_json(f"{SYSREQS_API}?{query}")

    packages = sorted(
        {p for r in payload["requirements"] for p in r["requirements"]["packages"]}
    )
    rejected = [p for p in packages if not APT_PACKAGE.match(p)]
    if rejected:
        raise ValueError(f"refusing implausible apt package names: {rejected}")
    return packages


def apt_install(packages):
    subprocess.run(["sudo", "apt-get", "update", "-qq"], check=True)
    subprocess.run(
        ["sudo", "apt-get", "install", "-y", "--no-install-recommends", "--", *packages],
        check=True,
    )


def main(argv=None):
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument(
        "lockfiles",
        nargs="*",
        help="lockfiles to resolve together; defaults to the RENV_PROFILE one",
    )
    parser.add_argument(
        "--dry-run", action="store_true", help="print the packages without installing"
    )
    args = parser.parse_args(argv)

    paths = [pathlib.Path(p) for p in args.lockfiles] or [
        resolve_lockfile(None, os.environ.get("RENV_PROFILE"))
    ]
    missing = [str(p) for p in paths if not p.is_file()]
    if missing:
        print(f"no lockfile at {', '.join(missing)}", file=sys.stderr)
        return 1

    # One query and one apt transaction for every lockfile asked about: the
    # profiles overlap heavily, and apt-get update is the slow part.
    names = sorted({name for path in paths for name in cran_packages(path)})
    if not names:
        print(f"no CRAN packages recorded in {', '.join(map(str, paths))}", file=sys.stderr)
        return 1

    described = ", ".join(str(p) for p in paths)

    distribution, release = host_platform()
    try:
        packages = sysreqs(names, distribution, release)
    except (urllib.error.URLError, KeyError, ValueError) as exc:
        print(f"could not resolve system requirements from PPM: {exc}", file=sys.stderr)
        return 1

    if not packages:
        print(f"{described} needs no system packages on {distribution} {release}")
        return 0

    print(f"{described} on {distribution} {release} needs: {' '.join(packages)}")
    if args.dry_run:
        return 0
    if shutil.which("apt-get") is None:
        print("apt-get not available; install these manually", file=sys.stderr)
        return 1

    apt_install(packages)
    return 0


if __name__ == "__main__":
    sys.exit(main())
