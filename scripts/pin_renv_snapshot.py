#!/usr/bin/env python3
"""Pin the root renv.lock and renv/settings.json to an R version and PPM snapshot.

The profile lockfiles are written by renv::snapshot (see scripts/refresh_renv.R).
The root lockfile is not re-snapshotted -- it exists so that setup-r's
`r-version: renv` resolves the same R version the profiles were built with -- so
its two fields are set here instead.
"""

import argparse
import datetime
import json
import pathlib
import sys

ROOT = pathlib.Path(__file__).resolve().parent.parent
PPM = "https://packagemanager.posit.co/cran"


def main(argv=None):
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--r-version", required=True)
    parser.add_argument("--snapshot-date", required=True)
    args = parser.parse_args(argv)

    datetime.date.fromisoformat(args.snapshot_date)

    lockfile = ROOT / "renv.lock"
    lock = json.loads(lockfile.read_text())
    lock["R"]["Version"] = args.r_version
    lock["R"]["Repositories"] = [
        {"Name": "CRAN", "URL": f"{PPM}/{args.snapshot_date}"}
    ]
    lockfile.write_text(json.dumps(lock, indent=2) + "\n")

    settings_file = ROOT / "renv/settings.json"
    settings = json.loads(settings_file.read_text())
    settings["r.version"] = args.r_version
    settings_file.write_text(json.dumps(settings, indent=2) + "\n")

    print(f"pinned renv.lock to R {args.r_version}, snapshot {args.snapshot_date}")
    return 0


if __name__ == "__main__":
    sys.exit(main())
