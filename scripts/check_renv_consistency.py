#!/usr/bin/env python3
"""Verify the renv setup cannot drift back into compiling packages from source.

CI installs R from the root renv.lock (r-lib/actions setup-r with r-version: renv)
while each workflow restores a profile lockfile, and Posit Package Manager builds
binaries per R version and per distro release. Three invariants keep that working:

1. every lockfile, and renv/settings.json, records the same R version;
2. every repository is a dated PPM snapshot (or an r-universe, which also serves
   binaries) -- never a source-only CRAN mirror;
3. every job that restores renv runs on the pinned runner image;
4. every pinned package version is the one that snapshot serves as a binary for
   that image -- a version the snapshot has only in its source archive is
   compiled on the runner, which is the failure this setup exists to avoid.
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

ROOT = pathlib.Path(__file__).resolve().parent.parent
WORKFLOWS = ROOT / ".github/workflows"
PINNED_RUNNER = "ubuntu-24.04"
RUNNER_CODENAME = "noble"
# renv is pinned by the committed renv/activate.R, not by the snapshot, and is
# pure R, so it costs nothing to install from source.
BINARY_EXEMPT = {"renv"}
PPM_SNAPSHOT = re.compile(
    r"^https://packagemanager\.posit\.co/cran/"
    r"(?:__linux__/[^/]+/)?(?P<date>\d{4}-\d{2}-\d{2})/?$"
)
R_UNIVERSE = re.compile(r"^https://[\w.-]+\.r-universe\.dev/?$")


def lockfiles():
    return [ROOT / "renv.lock"] + sorted(ROOT.glob("renv/profiles/*/renv.lock"))


def snapshot_date(url):
    """Return the snapshot date of a PPM URL, or None if it is not one."""
    match = PPM_SNAPSHOT.match(url)
    if match is None:
        return None
    try:
        return datetime.date.fromisoformat(match.group("date"))
    except ValueError:
        return None


def check_lockfiles(errors, r_versions, dates):
    for lock in lockfiles():
        rel = str(lock.relative_to(ROOT))
        try:
            spec = json.loads(lock.read_text())["R"]
            r_versions[rel] = spec["Version"]
            urls = [repo["URL"] for repo in spec["Repositories"]]
        except (KeyError, TypeError, ValueError) as exc:
            errors.append(f"{rel}: malformed lockfile ({exc})")
            continue

        pinned = False
        for url in urls:
            date = snapshot_date(url)
            if date is not None:
                dates.setdefault(date.isoformat(), []).append(rel)
                pinned = True
            elif not R_UNIVERSE.match(url):
                errors.append(
                    f"{rel}: {url} is not a pinned binary repository; use "
                    "https://packagemanager.posit.co/cran/YYYY-MM-DD so Linux "
                    "binaries exist for the pinned package versions"
                )
        if not pinned:
            errors.append(f"{rel}: no Posit Package Manager snapshot in {urls}")


def binary_index(date):
    """Package -> version served as a binary by the snapshot for the runner."""
    url = (
        f"https://packagemanager.posit.co/cran/__linux__/{RUNNER_CODENAME}/"
        f"{date}/src/contrib/PACKAGES.gz"
    )
    with urllib.request.urlopen(url) as response:
        body = gzip.decompress(response.read()).decode()

    index = {}
    name = None
    for line in body.splitlines():
        if line.startswith("Package: "):
            name = line.split(": ", 1)[1].strip()
        elif line.startswith("Version: ") and name is not None:
            index[name] = line.split(": ", 1)[1].strip()
            name = None
    return index


def check_binaries(errors, date):
    try:
        index = binary_index(date)
    except (urllib.error.URLError, OSError) as exc:
        errors.append(f"could not read the {date} binary index for {RUNNER_CODENAME}: {exc}")
        return

    for lock in lockfiles():
        rel = str(lock.relative_to(ROOT))
        packages = json.loads(lock.read_text()).get("Packages", {})
        for name, record in sorted(packages.items()):
            if record.get("Source") != "Repository" or name in BINARY_EXEMPT:
                continue
            served = index.get(name)
            if served is None:
                errors.append(f"{rel}: {name} {record['Version']} is not in the {date} snapshot")
            elif served != record["Version"]:
                errors.append(
                    f"{rel}: {name} {record['Version']} would be compiled from source; "
                    f"the {date} snapshot serves a binary for {served}. "
                    "Re-snapshot with the Refresh renv lockfiles workflow"
                )


def renv_jobs(workflow):
    """Yield (job id, runs-on) for every job in a workflow that restores renv."""
    import yaml

    spec = yaml.safe_load(workflow.read_text()) or {}
    for job_id, job in (spec.get("jobs") or {}).items():
        steps = job.get("steps") or []
        if any("setup-renv" in str(step.get("uses", "")) for step in steps):
            yield job_id, job.get("runs-on")


def check_runners(errors):
    try:
        import yaml  # noqa: F401
    except ImportError:
        errors.append(
            "PyYAML is required to check workflow runner pins (pip install pyyaml)"
        )
        return

    for workflow in sorted(WORKFLOWS.glob("*.y*ml")):
        for job_id, runs_on in renv_jobs(workflow):
            if runs_on != PINNED_RUNNER:
                errors.append(
                    f"{workflow.relative_to(ROOT)}: job '{job_id}' restores renv on "
                    f"'{runs_on}' but Posit Package Manager binaries are built for "
                    f"{PINNED_RUNNER}"
                )


def main(argv=None):
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument(
        "--offline",
        action="store_true",
        help="skip the check that every pinned version has a binary (needs PPM)",
    )
    args = parser.parse_args(argv)

    errors = []
    r_versions = {}
    dates = {}

    check_lockfiles(errors, r_versions, dates)

    settings = json.loads((ROOT / "renv/settings.json").read_text())
    r_versions["renv/settings.json"] = settings["r.version"]

    if len(set(r_versions.values())) > 1:
        errors.append(
            "R versions disagree: "
            + ", ".join(f"{k} -> {v}" for k, v in sorted(r_versions.items()))
        )

    if len(dates) > 1:
        errors.append(
            "snapshot dates disagree: "
            + ", ".join(f"{d} -> {sorted(f)}" for d, f in sorted(dates.items()))
        )

    check_runners(errors)

    if len(dates) == 1 and not args.offline:
        check_binaries(errors, next(iter(dates)))

    for error in errors:
        print(f"ERROR {error}")
    if errors:
        return 1

    print(
        f"renv lockfiles consistent: R {r_versions['renv.lock']}, "
        f"PPM snapshot {next(iter(dates))}, runner {PINNED_RUNNER}"
    )
    return 0


if __name__ == "__main__":
    sys.exit(main())
