"""Tests for scripts/check_renv_consistency.py.

The script resolves the project root from its own location, so each test builds
a throwaway project tree, copies the script into it, and runs it as CI does.
"""

import json
import pathlib
import shutil
import subprocess
import sys
import tempfile
import unittest

SCRIPTS = pathlib.Path(__file__).resolve().parent.parent
sys.path.insert(0, str(SCRIPTS))

import check_renv_consistency as checker  # noqa: E402

PINNED = "https://packagemanager.posit.co/cran/2026-11-16"
WORKFLOW = """
jobs:
  build:
    runs-on: {runner}
    steps:
      - uses: actions/checkout@v6
      - uses: r-lib/actions/setup-renv@v2
"""


def lockfile(r_version="4.6.1", urls=(PINNED,), packages=None):
    return {
        "R": {
            "Version": r_version,
            "Repositories": [{"Name": "CRAN", "URL": url} for url in urls],
        },
        "Packages": packages or {},
    }


class ProjectTree:
    """A minimal renv project with the checker installed in it."""

    def __init__(self, profiles=None, settings_version="4.6.1", runner="ubuntu-24.04"):
        self.root = pathlib.Path(tempfile.mkdtemp())
        (self.root / "scripts").mkdir()
        shutil.copy(SCRIPTS / "check_renv_consistency.py", self.root / "scripts")
        workflows = self.root / ".github/workflows"
        workflows.mkdir(parents=True)
        (workflows / "build.yaml").write_text(WORKFLOW.format(runner=runner))
        (self.root / "renv").mkdir()
        (self.root / "renv/settings.json").write_text(
            json.dumps({"r.version": settings_version})
        )
        self.write("renv.lock", lockfile())
        for name, content in (profiles or {"json": lockfile()}).items():
            (self.root / "renv/profiles" / name).mkdir(parents=True)
            self.write(f"renv/profiles/{name}/renv.lock", content)

    def write(self, relative, content):
        path = self.root / relative
        path.write_text(content if isinstance(content, str) else json.dumps(content))

    def run(self, *args):
        return subprocess.run(
            [sys.executable, "scripts/check_renv_consistency.py", "--offline", *args],
            cwd=self.root,
            capture_output=True,
            text=True,
        )

    def cleanup(self):
        shutil.rmtree(self.root, ignore_errors=True)


class CheckerTest(unittest.TestCase):
    def tree(self, **kwargs):
        tree = ProjectTree(**kwargs)
        self.addCleanup(tree.cleanup)
        return tree

    def test_consistent_project_passes(self):
        result = self.tree().run()
        self.assertEqual(result.returncode, 0, result.stdout + result.stderr)
        self.assertIn("consistent", result.stdout)

    def test_r_version_drift_between_lockfiles_fails(self):
        tree = self.tree(profiles={"json": lockfile(r_version="4.5.1")})
        result = tree.run()
        self.assertEqual(result.returncode, 1)
        self.assertIn("R versions disagree", result.stdout)

    def test_settings_r_version_drift_fails(self):
        result = self.tree(settings_version="4.3.0").run()
        self.assertEqual(result.returncode, 1)
        self.assertIn("R versions disagree", result.stdout)

    def test_source_only_mirror_fails(self):
        tree = self.tree(profiles={"json": lockfile(urls=["https://cloud.r-project.org"])})
        result = tree.run()
        self.assertEqual(result.returncode, 1)
        self.assertIn("not a pinned binary repository", result.stdout)

    def test_source_mirror_alongside_pinned_snapshot_fails(self):
        tree = self.tree(
            profiles={"json": lockfile(urls=[PINNED, "https://cloud.r-project.org"])}
        )
        result = tree.run()
        self.assertEqual(result.returncode, 1, "an extra source mirror must not pass")
        self.assertIn("cloud.r-project.org", result.stdout)

    def test_r_universe_repository_is_allowed(self):
        tree = self.tree(
            profiles={"json": lockfile(urls=[PINNED, "https://ggseg.r-universe.dev"])}
        )
        self.assertEqual(tree.run().returncode, 0)

    def test_snapshot_dates_must_agree(self):
        other = "https://packagemanager.posit.co/cran/2026-10-01"
        tree = self.tree(profiles={"json": lockfile(urls=[other])})
        result = tree.run()
        self.assertEqual(result.returncode, 1)
        self.assertIn("snapshot dates disagree", result.stdout)

    def test_unpinned_runner_fails(self):
        result = self.tree(runner="ubuntu-latest").run()
        self.assertEqual(result.returncode, 1)
        self.assertIn("restores renv on", result.stdout)

    def test_malformed_lockfile_is_named(self):
        tree = self.tree()
        tree.write("renv/profiles/json/renv.lock", json.dumps({"R": {"Version": "4.6.1"}}))
        result = tree.run()
        self.assertEqual(result.returncode, 1)
        self.assertIn("malformed lockfile", result.stdout)


class SnapshotDateTest(unittest.TestCase):
    def test_accepts_plain_and_linux_and_trailing_slash(self):
        for url in (
            PINNED,
            PINNED + "/",
            "https://packagemanager.posit.co/cran/__linux__/noble/2026-11-16",
        ):
            with self.subTest(url=url):
                self.assertEqual(str(checker.snapshot_date(url)), "2026-11-16")

    def test_rejects_impossible_date(self):
        url = "https://packagemanager.posit.co/cran/2026-13-99"
        self.assertIsNone(checker.snapshot_date(url))

    def test_rejects_other_hosts(self):
        self.assertIsNone(checker.snapshot_date("https://cloud.r-project.org"))


class BinaryParityTest(unittest.TestCase):
    """check_binaries flags versions the snapshot serves only as source."""

    def setUp(self):
        self.root = pathlib.Path(tempfile.mkdtemp())
        self.addCleanup(shutil.rmtree, self.root, True)
        (self.root / "renv/profiles/json").mkdir(parents=True)
        self.addCleanup(setattr, checker, "ROOT", checker.ROOT)
        checker.ROOT = self.root
        self.addCleanup(setattr, checker, "binary_index", checker.binary_index)
        checker.binary_index = lambda date: {"curl": "8.1.0", "here": "1.0.2"}

    def write_packages(self, packages):
        content = lockfile(packages=packages)
        (self.root / "renv.lock").write_text(json.dumps(lockfile()))
        (self.root / "renv/profiles/json/renv.lock").write_text(json.dumps(content))

    def run_check(self):
        errors = []
        checker.check_binaries(errors, "2026-11-16")
        return errors

    def test_versions_matching_the_index_pass(self):
        self.write_packages(
            {
                "curl": {"Source": "Repository", "Version": "8.1.0"},
                "here": {"Source": "Repository", "Version": "1.0.2"},
            }
        )
        self.assertEqual(self.run_check(), [])

    def test_version_older_than_the_binary_is_flagged(self):
        self.write_packages({"curl": {"Source": "Repository", "Version": "8.0.0"}})
        errors = self.run_check()
        self.assertEqual(len(errors), 1, errors)
        self.assertIn("curl 8.0.0 would be compiled from source", errors[0])

    def test_package_missing_from_the_snapshot_is_flagged(self):
        self.write_packages({"jsonlite": {"Source": "Repository", "Version": "2.0.0"}})
        errors = self.run_check()
        self.assertEqual(len(errors), 1, errors)
        self.assertIn("is not in the 2026-11-16 snapshot", errors[0])

    def test_github_and_exempt_packages_are_skipped(self):
        self.write_packages(
            {
                "airtabler": {"Source": "GitHub", "Version": "0.1.6"},
                "renv": {"Source": "Repository", "Version": "1.1.5"},
            }
        )
        self.assertEqual(self.run_check(), [])


if __name__ == "__main__":
    unittest.main()
