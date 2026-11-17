#!/usr/bin/env bash
# Install the system libraries required by the packages in an renv lockfile.
#
# Binary packages from Posit Package Manager link against shared libraries that
# are not all present on a bare runner (V8 needs libnode, curl needs libcurl).
# Asking PPM which ones a lockfile needs keeps the workflows from guessing.

set -euo pipefail

profile="${RENV_PROFILE:-}"
if [ -n "${1:-}" ]; then
  lockfile="$1"
elif [ -n "$profile" ]; then
  lockfile="renv/profiles/${profile}/renv.lock"
else
  lockfile="renv.lock"
fi

if [ -r /etc/os-release ]; then
  # shellcheck disable=SC1091
  . /etc/os-release
  distribution="${ID}"
  release="${VERSION_ID}"
else
  distribution="ubuntu"
  release="24.04"
fi

query=$(python3 - "$lockfile" <<'PY'
import json
import sys
import urllib.parse

packages = json.load(open(sys.argv[1]))["Packages"]
print(urllib.parse.urlencode([("pkgname", name) for name in sorted(packages)]))
PY
)

url="https://packagemanager.posit.co/__api__/repos/cran/sysreqs?all=false&distribution=${distribution}&release=${release}&${query}"

mapfile -t sysreqs < <(curl -fsSL "$url" | python3 -c '
import json
import sys

requirements = json.load(sys.stdin)["requirements"]
print("\n".join(sorted({p for r in requirements for p in r["requirements"]["packages"]})))
')

if [ "${#sysreqs[@]}" -eq 0 ]; then
  echo "No system requirements for ${lockfile} on ${distribution} ${release}"
  exit 0
fi

echo "Installing for ${lockfile} on ${distribution} ${release}: ${sysreqs[*]}"
sudo apt-get update -qq
sudo apt-get install -y --no-install-recommends "${sysreqs[@]}"
