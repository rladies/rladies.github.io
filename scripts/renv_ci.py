"""Shared facts about how this project restores renv in CI.

Both check_renv_consistency.py and install_sysreqs.py need the same answers to
"where are the lockfiles", "which records come from CRAN" and "what does a
Posit Package Manager URL look like", and they must not drift apart: the
checker exempting a record the installer asks PPM about is how a profile ends
up unvalidated.
"""

import json
import pathlib
import re

PPM_CRAN = "https://packagemanager.posit.co/cran"
PPM_API = "https://packagemanager.posit.co/__api__/repos/cran"
SNAPSHOT_DATED = re.compile(r"/\d{4}-\d{2}-\d{2}/?$")

# PPM builds binaries per distro release, so the runner image is part of the
# contract. Keeping the codename beside the label stops the two drifting.
RUNNERS = {"ubuntu-22.04": "jammy", "ubuntu-24.04": "noble"}
PINNED_RUNNER = "ubuntu-24.04"

# Repository names renv writes for packages that came from CRAN or a PPM
# mirror of it; anything else (r-universe, GitHub) is not in the PPM index.
# renv may also record the repository URL it installed from instead of a name.
CRAN_REPOSITORIES = {"CRAN", "RSPM", "PPM"}

# renv is pinned by the committed renv/activate.R rather than by the snapshot,
# and is pure R, so it costs nothing to install from source.
BINARY_EXEMPT = frozenset({"renv"})

# PPM's error code for an R version it builds no binaries for.
UNSUPPORTED_R_VERSION = 34


def project_root():
    return pathlib.Path(__file__).resolve().parent.parent


def lockfiles(root):
    """The root lockfile and every profile lockfile, in a stable order."""
    return [root / "renv.lock"] + sorted(root.glob("renv/profiles/*/renv.lock"))


def load_lockfile(path):
    return json.loads(pathlib.Path(path).read_text())


def from_cran(record):
    """Whether this record came from CRAN or a PPM mirror of it."""
    if record.get("Source") != "Repository":
        return False
    repository = record.get("Repository", "")
    return repository in CRAN_REPOSITORIES or repository.startswith(PPM_CRAN)


def cran_records(lock):
    """{name: version} for the records PPM can be asked about."""
    return {
        name: record.get("Version")
        for name, record in lock.get("Packages", {}).items()
        if from_cran(record)
    }


def floating_repositories(lock):
    """{name: repository} for records pinned to a moving PPM repository.

    renv records the repository it actually installed from. If that is PPM's
    `latest`, the lockfile version stops being served as a binary as soon as
    CRAN moves on, which puts the build back to compiling from source.
    """
    return {
        name: record["Repository"]
        for name, record in lock.get("Packages", {}).items()
        if from_cran(record)
        and record.get("Repository", "").startswith(PPM_CRAN)
        and not SNAPSHOT_DATED.search(record["Repository"])
    }


def snapshot_url(date):
    return f"{PPM_CRAN}/{date}"


def binary_index_url(date, codename):
    return f"{PPM_CRAN}/__linux__/{codename}/{date}/src/contrib/PACKAGES.gz"


def binaries_api_url(r_version, codename):
    """PPM's binary endpoint, which validates the R version and distribution."""
    minor = ".".join(r_version.split(".")[:2])
    return f"{PPM_API}/binaries?r_version={minor}&distribution={codename}"
