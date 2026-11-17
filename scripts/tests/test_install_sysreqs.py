"""Tests for scripts/install_sysreqs.py.

The PPM request is the part that has bitten us -- it answers 500 for the whole
query if one package name is unknown to it -- so query construction and
response handling are tested without touching the network.
"""

import json
import pathlib
import unittest
import urllib.error
from unittest import mock

import support

import install_sysreqs

LOCKFILE = support.lockfile(
    packages={
        "V8": support.record("8.2.1"),
        "here": support.record("1.0.2"),
        "airtabler": support.record("0.1.6", repository=None, source="GitHub"),
    }
)


class LockfileTest(unittest.TestCase):
    def setUp(self):
        self.root = support.temporary_directory(self)
        self.lockfile = self.root / "renv.lock"
        self.lockfile.write_text(json.dumps(LOCKFILE))

    def test_github_packages_are_not_sent_to_ppm(self):
        # PPM 500s on the whole query when asked about a name it does not know,
        # which is what broke the airtable and dev profiles.
        self.assertEqual(install_sysreqs.cran_packages(self.lockfile), ["V8", "here"])

    def test_implausible_package_name_is_rejected(self):
        self.lockfile.write_text(
            json.dumps(support.lockfile(packages={"--oops": support.record("1.0")}))
        )
        with self.assertRaises(ValueError):
            install_sysreqs.cran_packages(self.lockfile)

    def test_resolve_lockfile_prefers_argument_then_profile(self):
        self.assertEqual(
            install_sysreqs.resolve_lockfile("a/b.lock", "json"), pathlib.Path("a/b.lock")
        )
        self.assertEqual(
            install_sysreqs.resolve_lockfile(None, "json"),
            pathlib.Path("renv/profiles/json/renv.lock"),
        )
        self.assertEqual(
            install_sysreqs.resolve_lockfile(None, None), pathlib.Path("renv.lock")
        )


class SysreqsTest(unittest.TestCase):
    def fetch(self, payload):
        return mock.patch.object(install_sysreqs, "fetch_json", return_value=payload)

    def test_packages_are_deduplicated_and_sorted(self):
        payload = {
            "requirements": [
                {"requirements": {"packages": ["libnode-dev", "libssl-dev"]}},
                {"requirements": {"packages": ["libssl-dev"]}},
            ]
        }
        with self.fetch(payload):
            self.assertEqual(
                install_sysreqs.sysreqs(["V8"], "ubuntu", "24.04"),
                ["libnode-dev", "libssl-dev"],
            )

    def test_empty_requirements_are_not_an_error(self):
        with self.fetch({"requirements": []}):
            self.assertEqual(install_sysreqs.sysreqs(["here"], "ubuntu", "24.04"), [])

    def test_option_like_package_name_is_refused(self):
        payload = {"requirements": [{"requirements": {"packages": ["--reinstall"]}}]}
        with self.fetch(payload), self.assertRaises(ValueError):
            install_sysreqs.sysreqs(["V8"], "ubuntu", "24.04")

    def test_query_carries_every_package_and_the_platform(self):
        seen = {}

        def capture(url):
            seen["url"] = url
            return {"requirements": []}

        with mock.patch.object(install_sysreqs, "fetch_json", capture):
            install_sysreqs.sysreqs(["V8", "here"], "ubuntu", "24.04")
        self.assertIn("pkgname=V8", seen["url"])
        self.assertIn("pkgname=here", seen["url"])
        self.assertIn("distribution=ubuntu", seen["url"])
        self.assertIn("release=24.04", seen["url"])


class MainTest(unittest.TestCase):
    def setUp(self):
        self.root = support.temporary_directory(self)
        self.lockfile = self.root / "renv.lock"
        self.lockfile.write_text(json.dumps(LOCKFILE))
        self.other = self.root / "other.lock"
        self.other.write_text(
            json.dumps(support.lockfile(packages={"curl": support.record("8.1.0")}))
        )
        self.apt = mock.patch.object(install_sysreqs, "apt_install").start()
        self.addCleanup(mock.patch.stopall)
        mock.patch.object(install_sysreqs.shutil, "which", return_value="/usr/bin/apt-get").start()

    def test_missing_lockfile_fails(self):
        self.assertEqual(install_sysreqs.main([str(self.root / "nope.lock")]), 1)
        self.apt.assert_not_called()

    def test_unreachable_ppm_fails_loudly(self):
        mock.patch.object(
            install_sysreqs, "sysreqs", side_effect=urllib.error.URLError("boom")
        ).start()
        self.assertEqual(install_sysreqs.main([str(self.lockfile)]), 1)
        self.apt.assert_not_called()

    def test_nothing_to_install_succeeds_without_calling_apt(self):
        mock.patch.object(install_sysreqs, "sysreqs", return_value=[]).start()
        self.assertEqual(install_sysreqs.main([str(self.lockfile)]), 0)
        self.apt.assert_not_called()

    def test_packages_are_installed_when_present(self):
        mock.patch.object(install_sysreqs, "sysreqs", return_value=["libnode-dev"]).start()
        self.assertEqual(install_sysreqs.main([str(self.lockfile)]), 0)
        self.apt.assert_called_once_with(["libnode-dev"])

    def test_several_lockfiles_resolve_in_one_query_and_one_install(self):
        queried = []

        def capture(names, distribution, release):
            queried.append(names)
            return ["libnode-dev"]

        mock.patch.object(install_sysreqs, "sysreqs", capture).start()
        code = install_sysreqs.main([str(self.lockfile), str(self.other)])
        self.assertEqual(code, 0)
        self.assertEqual(queried, [["V8", "curl", "here"]])
        self.apt.assert_called_once_with(["libnode-dev"])

    def test_dry_run_never_installs(self):
        mock.patch.object(install_sysreqs, "sysreqs", return_value=["libnode-dev"]).start()
        self.assertEqual(install_sysreqs.main([str(self.lockfile), "--dry-run"]), 0)
        self.apt.assert_not_called()


if __name__ == "__main__":
    unittest.main()
