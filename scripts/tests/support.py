"""Shared fixtures for the renv CI script tests."""

import json
import pathlib
import shutil
import sys
import tempfile

SCRIPTS = pathlib.Path(__file__).resolve().parent.parent
if str(SCRIPTS) not in sys.path:
    sys.path.insert(0, str(SCRIPTS))

PINNED = "https://packagemanager.posit.co/cran/2026-11-16"
PINNED_BINARY = "https://packagemanager.posit.co/cran/__linux__/noble/2026-11-16"
FLOATING = "https://packagemanager.posit.co/cran/__linux__/noble/latest"

WORKFLOW = """
jobs:
  build:
    runs-on: {runner}
    steps:
      - uses: actions/checkout@v6
      - uses: r-lib/actions/setup-renv@v2
"""


def record(version, repository=PINNED_BINARY, source="Repository"):
    return {"Version": version, "Source": source, "Repository": repository}


def lockfile(r_version="4.6.1", urls=(PINNED,), packages=None):
    return {
        "R": {
            "Version": r_version,
            "Repositories": [{"Name": "CRAN", "URL": url} for url in urls],
        },
        "Packages": packages if packages is not None else {"here": record("1.0.2")},
    }


def project(tmp, profiles=None, settings_version="4.6.1", runner="ubuntu-24.04"):
    """Write a minimal renv project into tmp and return its path."""
    root = pathlib.Path(tmp)
    workflows = root / ".github/workflows"
    workflows.mkdir(parents=True, exist_ok=True)
    (workflows / "build.yaml").write_text(WORKFLOW.format(runner=runner))
    (root / "renv").mkdir(exist_ok=True)
    (root / "renv/settings.json").write_text(json.dumps({"r.version": settings_version}))
    (root / "renv.lock").write_text(json.dumps(lockfile()))
    for name, content in (profiles or {"json": lockfile()}).items():
        (root / "renv/profiles" / name).mkdir(parents=True, exist_ok=True)
        (root / "renv/profiles" / name / "renv.lock").write_text(json.dumps(content))
    return root


def temporary_directory(test):
    path = pathlib.Path(tempfile.mkdtemp())
    test.addCleanup(shutil.rmtree, path, True)
    return path
