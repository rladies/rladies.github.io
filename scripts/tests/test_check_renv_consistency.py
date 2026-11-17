"""Tests for scripts/check_renv_consistency.py."""

import gzip
import io
import json
import unittest
from unittest import mock

import support

import check_renv_consistency as checker

PINNED = support.PINNED
INDEX = {"here": "1.0.2", "curl": "8.1.0", "V8": "8.2.1"}


class CheckerTest(unittest.TestCase):
    """The script as CI runs it, with the two network checks stubbed."""

    def setUp(self):
        self.root = support.temporary_directory(self)
        patches = [
            mock.patch.object(checker, "binary_index", lambda date, codename: INDEX),
            mock.patch.object(checker, "builds_binaries_for", lambda *args: True),
        ]
        for patch in patches:
            patch.start()
            self.addCleanup(patch.stop)

    def run_checker(self, **kwargs):
        support.project(self.root, **kwargs)
        with mock.patch("sys.stdout", new=io.StringIO()) as out:
            code = checker.main(["--root", str(self.root)])
        return code, out.getvalue()

    def test_consistent_project_passes(self):
        code, output = self.run_checker()
        self.assertEqual(code, 0, output)
        self.assertIn("renv is consistent", output)

    def test_r_version_drift_between_lockfiles_fails(self):
        code, output = self.run_checker(
            profiles={"json": support.lockfile(r_version="4.5.1")}
        )
        self.assertEqual(code, 1)
        self.assertIn("R versions disagree", output)

    def test_settings_r_version_drift_fails(self):
        code, output = self.run_checker(settings_version="4.3.0")
        self.assertEqual(code, 1)
        self.assertIn("R versions disagree", output)

    def test_source_only_mirror_fails(self):
        code, output = self.run_checker(
            profiles={"json": support.lockfile(urls=["https://cloud.r-project.org"])}
        )
        self.assertEqual(code, 1)
        self.assertIn("not a pinned binary repository", output)

    def test_source_mirror_alongside_pinned_snapshot_fails(self):
        code, output = self.run_checker(
            profiles={
                "json": support.lockfile(urls=[PINNED, "https://cloud.r-project.org"])
            }
        )
        self.assertEqual(code, 1, "an extra source mirror must not pass")
        self.assertIn("cloud.r-project.org", output)

    def test_r_universe_repository_is_allowed(self):
        code, output = self.run_checker(
            profiles={"json": support.lockfile(urls=[PINNED, "https://x.r-universe.dev"])}
        )
        self.assertEqual(code, 0, output)

    def test_package_pinned_to_a_moving_repository_fails(self):
        packages = {"here": support.record("1.0.2", repository=support.FLOATING)}
        code, output = self.run_checker(
            profiles={"json": support.lockfile(packages=packages)}
        )
        self.assertEqual(code, 1, "a `latest` repository stops serving the pin")
        self.assertIn("1 packages were installed from", output)

    def test_snapshot_dates_must_agree(self):
        other = "https://packagemanager.posit.co/cran/2026-10-01"
        code, output = self.run_checker(profiles={"json": support.lockfile(urls=[other])})
        self.assertEqual(code, 1)
        self.assertIn("snapshot dates disagree", output)

    def test_unpinned_runner_fails(self):
        code, output = self.run_checker(runner="ubuntu-latest")
        self.assertEqual(code, 1)
        self.assertIn("restores renv", output)

    def test_malformed_lockfile_is_named(self):
        support.project(self.root)
        (self.root / "renv/profiles/json/renv.lock").write_text(json.dumps({"R": {}}))
        with mock.patch("sys.stdout", new=io.StringIO()) as out:
            code = checker.main(["--root", str(self.root)])
        self.assertEqual(code, 1)
        self.assertIn("malformed lockfile", out.getvalue())

    def test_version_behind_the_snapshot_fails(self):
        packages = {"curl": support.record("8.0.0")}
        code, output = self.run_checker(
            profiles={"json": support.lockfile(packages=packages)}
        )
        self.assertEqual(code, 1)
        self.assertIn("would be compiled from source", output)

    def test_r_version_without_binaries_fails(self):
        with mock.patch.object(checker, "builds_binaries_for", lambda *args: False):
            code, output = self.run_checker()
        self.assertEqual(code, 1, "an R version PPM has no binaries for must fail")
        self.assertIn("builds no binaries for R 4.6.1", output)


class SnapshotDateTest(unittest.TestCase):
    def test_accepts_plain_and_linux_and_trailing_slash(self):
        for url in (PINNED, PINNED + "/", support.PINNED_BINARY):
            with self.subTest(url=url):
                self.assertEqual(str(checker.snapshot_date(url)), "2026-11-16")

    def test_rejects_impossible_date(self):
        self.assertIsNone(
            checker.snapshot_date("https://packagemanager.posit.co/cran/2026-13-99")
        )

    def test_rejects_undated_and_other_hosts(self):
        self.assertIsNone(checker.snapshot_date(support.FLOATING))
        self.assertIsNone(checker.snapshot_date("https://cloud.r-project.org"))


class BinaryIndexTest(unittest.TestCase):
    """The PACKAGES parser, over a fixture shaped like PPM's real index."""

    PACKAGES = (
        "Package: curl\n"
        "Version: 8.1.0\n"
        "Depends: R (>= 3.5)\n"
        "Imports: Rcpp\n"
        "\n"
        "Package: brokenentry\n"
        "Depends: R (>= 3.5)\n"
        "\n"
        "Package: V8\n"
        "Version: 8.2.1\n"
    )

    def test_parses_versions_and_skips_records_without_one(self):
        body = gzip.compress(self.PACKAGES.encode())
        response = mock.MagicMock()
        response.__enter__.return_value.read.return_value = body
        with mock.patch.object(checker.urllib.request, "urlopen", return_value=response):
            index = checker.binary_index("2026-11-16", "noble")
        self.assertEqual(index, {"curl": "8.1.0", "V8": "8.2.1"})
        self.assertNotIn("brokenentry", index)


class BuildsBinariesForTest(unittest.TestCase):
    """PPM reports an unsupported R version with a specific error code."""

    def respond(self, payload):
        response = mock.MagicMock()
        response.__enter__.return_value = io.StringIO(json.dumps(payload))
        return mock.patch.object(
            checker.urllib.request, "urlopen", return_value=response
        )

    def test_supported_r_version_passes(self):
        # PPM answers "Unknown package name" once the R version is accepted.
        with self.respond({"code": 36, "error": "Unknown package name."}):
            self.assertTrue(checker.builds_binaries_for("4.6.1", "noble"))

    def test_unsupported_r_version_fails(self):
        with self.respond({"code": 34, "error": "The requested R version is not supported."}):
            self.assertFalse(checker.builds_binaries_for("4.9.0", "noble"))

    def test_only_the_major_minor_version_is_sent(self):
        seen = {}

        def capture(url):
            seen["url"] = url
            response = mock.MagicMock()
            response.__enter__.return_value = io.StringIO(json.dumps({"code": 36}))
            return response

        with mock.patch.object(checker.urllib.request, "urlopen", capture):
            checker.builds_binaries_for("4.6.1", "noble")
        self.assertIn("r_version=4.6&", seen["url"])
        self.assertIn("distribution=noble", seen["url"])


if __name__ == "__main__":
    unittest.main()
