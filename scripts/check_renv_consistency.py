#!/usr/bin/env python3
"""Verify every renv lockfile agrees on R version and uses a pinned binary repository.

CI installs R from the root renv.lock (r-lib/actions setup-r with r-version: renv),
while each workflow restores a profile lockfile. If those disagree, or if a lockfile
points at a source-only CRAN mirror, packages are compiled from source on the runner
and break whenever the toolchain moves.
"""

import json
import pathlib
import re
import sys

ROOT = pathlib.Path(__file__).resolve().parent.parent
PINNED_PPM = re.compile(r"^https://packagemanager\.posit\.co/cran/\d{4}-\d{2}-\d{2}$")


def lockfiles():
    return [ROOT / "renv.lock"] + sorted(ROOT.glob("renv/profiles/*/renv.lock"))


def main():
    errors = []
    r_versions = {}
    repo_dates = {}

    for lock in lockfiles():
        rel = lock.relative_to(ROOT)
        spec = json.loads(lock.read_text())["R"]
        r_versions[str(rel)] = spec["Version"]
        urls = [repo["URL"] for repo in spec["Repositories"]]
        pinned = [url for url in urls if PINNED_PPM.match(url)]
        if not pinned:
            errors.append(
                f"{rel}: no pinned Posit Package Manager snapshot in {urls}; "
                "use https://packagemanager.posit.co/cran/YYYY-MM-DD so Linux binaries "
                "exist for the pinned package versions"
            )
        repo_dates[str(rel)] = {url.rsplit("/", 1)[-1] for url in pinned}

    settings = json.loads((ROOT / "renv/settings.json").read_text())
    r_versions["renv/settings.json"] = settings["r.version"]

    if len(set(r_versions.values())) > 1:
        errors.append(
            "R versions disagree: "
            + ", ".join(f"{k} -> {v}" for k, v in sorted(r_versions.items()))
        )

    dates = set().union(*repo_dates.values()) if repo_dates else set()
    if len(dates) > 1:
        errors.append(
            "snapshot dates disagree: "
            + ", ".join(f"{k} -> {sorted(v)}" for k, v in sorted(repo_dates.items()))
        )

    for error in errors:
        print(f"ERROR {error}")
    if errors:
        return 1

    print(f"renv lockfiles consistent: R {next(iter(set(r_versions.values())))}, "
          f"PPM snapshot {next(iter(dates))}")
    return 0


if __name__ == "__main__":
    sys.exit(main())
