#!/usr/bin/env python3
"""Verify the renv setup cannot drift back into compiling packages from source.

CI installs R from the root renv.lock (r-lib/actions setup-r with r-version:
renv) while each workflow restores a profile lockfile, and Posit Package
Manager builds binaries per R version and per distro release. Five invariants
keep that working:

1. every lockfile, and renv/settings.json, records the same R version;
2. every repository is a dated PPM snapshot (or an r-universe, which also
   serves binaries) -- never a source-only CRAN mirror, and never PPM's
   `latest`, which stops serving the pinned version as soon as CRAN moves on;
3. every job that restores renv runs on the pinned runner image;
4. every pinned package version is the one that snapshot serves for that
   image -- an older version is kept only as source, and is compiled;
5. PPM really serves binaries for the pinned R version. The package index is
   the same for every R version; PPM chooses binary or source from the
   User-Agent, so this is checked by asking for a package the way R does.
"""

import argparse
import datetime
import gzip
import json
import pathlib
import re
import sys
import urllib.error
import urllib.request

import yaml

sys.path.insert(0, str(pathlib.Path(__file__).resolve().parent))

import renv_ci  # noqa: E402

PPM_SNAPSHOT = re.compile(
    r"^https://packagemanager\.posit\.co/cran/"
    r"(?:__linux__/[^/]+/)?(?P<date>\d{4}-\d{2}-\d{2})/?$"
)
R_UNIVERSE = re.compile(r"^https://[\w.-]+\.r-universe\.dev/?$")


def snapshot_date(url):
    """The snapshot date of a PPM URL, or None if it is not a dated one."""
    match = PPM_SNAPSHOT.match(url)
    if match is None:
        return None
    try:
        return datetime.date.fromisoformat(match.group("date"))
    except ValueError:
        return None


def read_lockfiles(root):
    """[(path relative to root, parsed lockfile)], malformed ones reported."""
    locks, errors = [], []
    for path in renv_ci.lockfiles(root):
        rel = str(path.relative_to(root))
        try:
            lock = renv_ci.load_lockfile(path)
            lock["R"]["Version"], lock["R"]["Repositories"]
        except (KeyError, TypeError, ValueError, OSError) as exc:
            errors.append(f"{rel}: malformed lockfile ({exc})")
            continue
        locks.append((rel, lock))
    return locks, errors


def check_repositories(locks):
    """Invariant 2: nothing resolves packages from a moving or source repo."""
    errors, dates = [], {}
    for rel, lock in locks:
        pinned = False
        for url in (repo["URL"] for repo in lock["R"]["Repositories"]):
            date = snapshot_date(url)
            if date is not None:
                dates.setdefault(date.isoformat(), []).append(rel)
                pinned = True
            elif not R_UNIVERSE.match(url):
                errors.append(
                    f"{rel}: {url} is not a pinned binary repository; use "
                    f"{renv_ci.PPM_CRAN}/YYYY-MM-DD so Linux binaries exist "
                    "for the pinned package versions"
                )
        if not pinned:
            errors.append(f"{rel}: no Posit Package Manager snapshot")

        floating = renv_ci.floating_repositories(lock)
        if floating:
            repositories = sorted(set(floating.values()))
            errors.append(
                f"{rel}: {len(floating)} packages were installed from "
                f"{', '.join(repositories)}, which stops serving their pinned "
                "version once CRAN moves on. Re-run Refresh renv lockfiles, "
                "which pins the repository to the snapshot date"
            )
    return errors, dates


def check_r_versions(locks, settings):
    """Invariant 1: setup-r reads the root lockfile, the jobs restore profiles."""
    versions = {rel: lock["R"]["Version"] for rel, lock in locks}
    versions["renv/settings.json"] = settings["r.version"]
    if len(set(versions.values())) == 1:
        return [], next(iter(versions.values()))
    listed = ", ".join(f"{k} -> {v}" for k, v in sorted(versions.items()))
    return [f"R versions disagree: {listed}"], None


def renv_jobs(workflow):
    """(job id, runs-on) for every job in a workflow that restores renv."""
    spec = yaml.safe_load(workflow.read_text()) or {}
    for job_id, job in (spec.get("jobs") or {}).items():
        steps = job.get("steps") or []
        if any("setup-renv" in str(step.get("uses", "")) for step in steps):
            yield job_id, job.get("runs-on")


def check_runners(root):
    """Invariant 3: PPM builds binaries per distro release."""
    errors = []
    for workflow in sorted((root / ".github/workflows").glob("*.y*ml")):
        for job_id, runs_on in renv_jobs(workflow):
            if runs_on != renv_ci.PINNED_RUNNER:
                errors.append(
                    f"{workflow.relative_to(root)}: job '{job_id}' restores renv "
                    f"on '{runs_on}' but PPM binaries are built for "
                    f"{renv_ci.PINNED_RUNNER}"
                )
    return errors


def binary_index(date, codename):
    """Package -> version served by the snapshot for this image."""
    url = renv_ci.binary_index_url(date, codename)
    with urllib.request.urlopen(url) as response:
        body = gzip.decompress(response.read()).decode()

    index, name = {}, None
    for line in body.splitlines():
        if line.startswith("Package:"):
            name = line.split(":", 1)[1].strip()
        elif line.startswith("Version:") and name is not None:
            index[name] = line.split(":", 1)[1].strip()
            name = None
    return index


def check_versions(locks, date, codename):
    """Invariant 4: an older pin is kept only as source, so it is compiled."""
    try:
        index = binary_index(date, codename)
    except (urllib.error.URLError, OSError) as exc:
        return [f"could not read the {date} {codename} package index: {exc}"]

    errors = []
    for rel, lock in locks:
        for name, version in sorted(renv_ci.cran_records(lock).items()):
            if name in renv_ci.BINARY_EXEMPT:
                continue
            served = index.get(name)
            if served is None:
                errors.append(f"{rel}: {name} {version} is not in the {date} snapshot")
            elif served != version:
                errors.append(
                    f"{rel}: {name} {version} would be compiled from source; the "
                    f"{date} snapshot serves {served}. Re-run Refresh renv lockfiles"
                )
    return errors


def serves_binary(date, codename, package, version, r_version):
    """Whether PPM hands R a binary, which it decides from the User-Agent."""
    request = urllib.request.Request(
        renv_ci.binary_package_url(date, codename, package, version),
        method="HEAD",
        headers={"User-Agent": renv_ci.r_user_agent(r_version)},
    )
    with urllib.request.urlopen(request) as response:
        return response.headers.get("Content-Type") == "binary/octet-stream"


def check_r_version_has_binaries(locks, date, codename, r_version):
    """Invariant 5: the index is R-version agnostic, so ask for a package."""
    for _, lock in locks:
        records = renv_ci.cran_records(lock)
        for package in renv_ci.COMPILED_PROBES:
            if package not in records:
                continue
            try:
                if serves_binary(date, codename, package, records[package], r_version):
                    return []
            except (urllib.error.URLError, OSError) as exc:
                return [f"could not ask PPM for {package}: {exc}"]
            return [
                f"PPM serves {package} {records[package]} as source for R "
                f"{r_version} on {codename}: the {date} snapshot has no binaries "
                "for that R version, so every compiled package would be built "
                "on the runner"
            ]
    return []


def main(argv=None):
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument(
        "--root",
        type=pathlib.Path,
        default=renv_ci.project_root(),
        help="project directory to check (default: this script's project)",
    )
    args = parser.parse_args(argv)
    root = args.root

    locks, errors = read_lockfiles(root)
    settings = json.loads((root / "renv/settings.json").read_text())

    repository_errors, dates = check_repositories(locks)
    version_errors, r_version = check_r_versions(locks, settings)
    errors += repository_errors + version_errors + check_runners(root)

    if len(dates) > 1:
        listed = ", ".join(f"{d} -> {sorted(f)}" for d, f in sorted(dates.items()))
        errors.append(f"snapshot dates disagree: {listed}")

    codename = renv_ci.RUNNERS[renv_ci.PINNED_RUNNER]
    if len(dates) == 1 and not errors:
        date = next(iter(dates))
        errors += check_versions(locks, date, codename)
        if r_version:
            errors += check_r_version_has_binaries(locks, date, codename, r_version)

    for error in errors:
        print(f"ERROR {error}")
    if errors:
        return 1

    print(
        f"renv is consistent: R {r_version}, PPM snapshot {next(iter(dates))}, "
        f"runner {renv_ci.PINNED_RUNNER} ({codename})"
    )
    return 0


if __name__ == "__main__":
    sys.exit(main())
