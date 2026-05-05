#!/usr/bin/env bash
set -euo pipefail

# Repo root = directory containing this script's parent (adjust if script is in texlive/)
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"
cd "$REPO_ROOT"

TEXLIVE_DIR="/tmp/texlive"
TLBIN="${TEXLIVE_DIR}/bin/x86_64-linux"
PROFILE="${REPO_ROOT}/texlive/texlive.profile"
REPO_URL="https://mirror.ctan.org/systems/texlive/tlnet"

echo "Repo root: $REPO_ROOT"
echo "Profile:   $PROFILE"

# Ensure profile exists before doing anything
if [[ ! -f "$PROFILE" ]]; then
  echo "ERROR: TeX Live profile not found at: $PROFILE"
  echo "       Check that texlive/texlive.profile exists in the repo."
  exit 1
fi

# If an old TeX Live exists, check its year and wipe if not 2026
if [[ -x "${TLBIN}/tlmgr" ]]; then
  INSTALLED_YEAR="$("${TLBIN}/tlmgr" --version | awk '/TeX Live/ {print $NF; exit}')"
  echo "Found existing TeX Live ${INSTALLED_YEAR} in ${TEXLIVE_DIR}"
  if [[ "$INSTALLED_YEAR" != "2026" ]]; then
    echo "Removing mismatched TeX Live (${INSTALLED_YEAR}) to avoid local/repo incompatibility..."
    rm -rf "$TEXLIVE_DIR"
  fi
fi

# Install TeX Live if not present
if [[ ! -x "${TLBIN}/texlua" ]]; then
  echo "Installing TeX Live 2026 into ${TEXLIVE_DIR}"
  curl -fsSL -o install-tl-unx.tar.gz "${REPO_URL}/install-tl-unx.tar.gz"
  tar -xzf install-tl-unx.tar.gz

  cd install-tl-20*/
  # Non-interactive install using the profile
  ./install-tl --repository "${REPO_URL}" --profile "${PROFILE}"
  cd "$REPO_ROOT"
fi

# Now TeX Live exists; add to PATH
export PATH="${TLBIN}:${PATH}"

# Sanity check: tlmgr must exist now
command -v tlmgr >/dev/null 2>&1 || { echo "ERROR: tlmgr not found after install"; exit 1; }
tlmgr --version

# Pin repo (avoid mirror churn)
tlmgr option repository "${REPO_URL}"
tlmgr update --self

# Install core tools
tlmgr install latexmk luatex

# Install from packages file safely
PACKAGES_FILE="${REPO_ROOT}/texlive/texlive_packages"
if [[ ! -f "$PACKAGES_FILE" ]]; then
  echo "ERROR: packages file not found at: $PACKAGES_FILE"
  exit 1
fi

sed -i 's/\r$//' "$PACKAGES_FILE"

while IFS= read -r pkg; do
  pkg="$(echo "$pkg" | xargs)"        # trim
  [[ -z "$pkg" || "$pkg" =~ ^# ]] && continue

  if tlmgr info "$pkg" >/dev/null 2>&1; then
    echo "Installing: $pkg"
    tlmgr install "$pkg"
  else
    echo "Skipping unknown tlmgr package id: $pkg"
  fi
done < "$PACKAGES_FILE"

mktexlsr