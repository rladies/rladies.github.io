"""Tests for scripts/install_sysreqs.py.

The PPM request is the part that has bitten us (it answers 500 for the whole
query if one package name is unknown to it), so the query construction and the
response handling are tested without touching the network.
"""

import io
import json
import pathlib
import shutil
import sys
import tempfile
import unittest
import urllib.error
from unittest import mock

SCRIPTS = pathlib.Path(__file__).resolve().parent.parent
sys.path.insert(0, str(SCRIPTS))

import install_sysreqs  # noqa: E402

LOCKFILE = {
    "R": {"Version": "4.6.1", "Repositories": []},
    "Packages": {
        "V8": {"Source": "Repository", "Version": "8.2.1"},
        "airtabler": {"Source": "GitHub", "Version": "0.1.6"},
        "here": {"Source": "Repository", "Version": "1.0.2"},
    },
}


def fake_response(payload):
    response = io.BytesIO(json.dumps(payload).encode())
    response.__enter__ = lambda self=response: self
    response.__exit__ = lambda *args: None
    return response


class LockfileTest(unittest.TestCase):
    def setUp(self):
        self.root = pathlib.Path(tempfile.mkdtemp())
        self.addCleanup(shutil.rmtree, self.root, True)
        self.lockfile = self.root / "renv.lock"
        self.lockfile.write_text(json.dumps(LOCKFILE))

    def test_github_packages_are_not_sent_to_ppm(self):
        # PPM 500s on the whole query when it is asked about a name it does not
        # know, which is what broke the airtable and dev profiles.
        self.assertEqual(install_sysreqs.cran_packages(self.lockfile), ["V8", "here"])

    def test_implausible_package_name_is_rejected(self):
        self.lockfile.write_text(
            json.dumps({"Packages": {"--oops": {"Source": "Repository"}}})
        )
        with self.assertRaises(ValueError):
            install_sysreqs.cran_packages(self.lockfile)

    def test_resolve_lockfile_prefers_argument_then_profile(self):
        self.assertEqual(
            install_sysreqs.resolve_lockfile("a/b.lock", "json"),
            pathlib.Path("a/b.lock"),
        )
        self.assertEqual(
            install_sysreqs.resolve_lockfile(None, "json"),
            pathlib.Path("renv/profiles/json/renv.lock"),
        )
        self.assertEqual(
            install_sysreqs.resolve_lockfile(None, None), pathlib.Path("renv.lock")
        )


class SysreqsTest(unittest.TestCase):
    def test_packages_are_deduplicated_and_sorted(self):
        payload = {
            "requirements": [
                {"requirements": {"packages": ["libnode-dev", "libssl-dev"]}},
                {"requirements": {"packages": ["libssl-dev"]}},
            ]
        }
        with mock.patch.object(
            install_sysreqs.urllib.request, "urlopen", return_value=fake_response(payload)
        ):
            self.assertEqual(
                install_sysreqs.sysreqs(["V8"], "ubuntu", "24.04"),
                ["libnode-dev", "libssl-dev"],
            )

    def test_empty_requirements_are_not_an_error(self):
        with mock.patch.object(
            install_sysreqs.urllib.request,
            "urlopen",
            return_value=fake_response({"requirements": []}),
        ):
            self.assertEqual(install_sysreqs.sysreqs(["here"], "ubuntu", "24.04"), [])

    def test_option_like_package_name_is_refused(self):
        payload = {"requirements": [{"requirements": {"packages": ["--reinstall"]}}]}
        with mock.patch.object(
            install_sysreqs.urllib.request, "urlopen", return_value=fake_response(payload)
        ):
            with self.assertRaises(ValueError):
                install_sysreqs.sysreqs(["V8"], "ubuntu", "24.04")

    def test_query_carries_every_package_and_the_platform(self):
        seen = {}

        def capture(url):
            seen["url"] = url
            return fake_response({"requirements": []})

        with mock.patch.object(install_sysreqs.urllib.request, "urlopen", capture):
            install_sysreqs.sysreqs(["V8", "here"], "ubuntu", "24.04")
        self.assertIn("pkgname=V8", seen["url"])
        self.assertIn("pkgname=here", seen["url"])
        self.assertIn("distribution=ubuntu", seen["url"])
        self.assertIn("release=24.04", seen["url"])


class MainTest(unittest.TestCase):
    def setUp(self):
        self.root = pathlib.Path(tempfile.mkdtemp())
        self.addCleanup(shutil.rmtree, self.root, True)
        self.lockfile = self.root / "renv.lock"
        self.lockfile.write_text(json.dumps(LOCKFILE))

    def test_missing_lockfile_fails(self):
        self.assertEqual(install_sysreqs.main([str(self.root / "nope.lock")]), 1)

    def test_unreachable_ppm_fails_loudly(self):
        with mock.patch.object(
            install_sysreqs,
            "sysreqs",
            side_effect=urllib.error.URLError("boom"),
        ):
            self.assertEqual(install_sysreqs.main([str(self.lockfile)]), 1)

    def test_nothing_to_install_succeeds_without_calling_apt(self):
        with mock.patch.object(install_sysreqs, "sysreqs", return_value=[]):
            with mock.patch.object(install_sysreqs, "apt_install") as apt:
                self.assertEqual(install_sysreqs.main([str(self.lockfile)]), 0)
        apt.assert_not_called()

    def test_packages_are_installed_when_present(self):
        with mock.patch.object(install_sysreqs, "sysreqs", return_value=["libnode-dev"]):
            with mock.patch.object(install_sysreqs, "apt_install") as apt:
                with mock.patch.object(install_sysreqs.shutil, "which", return_value="/usr/bin/apt-get"):
                    self.assertEqual(install_sysreqs.main([str(self.lockfile)]), 0)
        apt.assert_called_once_with(["libnode-dev"])

    def test_dry_run_never_installs(self):
        with mock.patch.object(install_sysreqs, "sysreqs", return_value=["libnode-dev"]):
            with mock.patch.object(install_sysreqs, "apt_install") as apt:
                self.assertEqual(
                    install_sysreqs.main([str(self.lockfile), "--dry-run"]), 0
                )
        apt.assert_not_called()


if __name__ == "__main__":
    unittest.main()
