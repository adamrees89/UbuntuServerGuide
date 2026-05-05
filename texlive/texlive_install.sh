#!/usr/bin/env bash
set -euo pipefail

# Determine repo root from script location
REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$REPO_ROOT"

TEXLIVE_DIR="/tmp/texlive"
TLBIN="$TEXLIVE_DIR/bin/x86_64-linux"

# If a TeX Live tree exists, check its year BEFORE doing anything else.
if [[ -x "$TLBIN/tlmgr" ]]; then
  INSTALLED_YEAR="$("$TLBIN/tlmgr" --version | awk '/TeX Live/ {print $NF; exit}')"
  echo "Found existing TeX Live: $INSTALLED_YEAR at $TEXLIVE_DIR"

  if [[ "$INSTALLED_YEAR" != "2026" ]]; then
    echo "Removing mismatched TeX Live ($INSTALLED_YEAR) to avoid local/repo incompatibility..."
    rm -rf "$TEXLIVE_DIR"
  fi
fi

# Add TeX Live bin to PATH only after potential cleanup
export PATH="$TLBIN:$PATH"

# Install TeX Live 2026 if not present
if ! command -v texlua >/dev/null 2>&1; then
  echo "Installing TeX Live 2026 into $TEXLIVE_DIR"

  curl -L -o install-tl-unx.tar.gz \
    "https://mirror.ctan.org/systems/texlive/tlnet/install-tl-unx.tar.gz"

  tar -xzf install-tl-unx.tar.gz
  cd install-tl-20*/
  ./install-tl -repository "https://mirror.ctan.org/systems/texlive/tlnet" \
    --profile="$REPO_ROOT/texlive/texlive.profile"
  cd "$REPO_ROOT"

  export PATH="$TLBIN:$PATH"
fi

# Pin repository (use one stable mirror; avoid auto-redirect churn)
tlmgr option repository "https://mirror.ctan.org/systems/texlive/tlnet"

# Update tlmgr infra (safe; may be no-op)
tlmgr update --self

# Core tools
tlmgr install latexmk luatex

# Install from packages file safely
PACKAGES_FILE="$REPO_ROOT/texlive/texlive_packages"
sed -i 's/\r$//' "$PACKAGES_FILE"

while IFS= read -r pkg; do
  # Trim whitespace
  pkg="$(echo "$pkg" | xargs)"
  # Skip blanks/comments
  [[ -z "$pkg" || "$pkg" =~ ^# ]] && continue

  if tlmgr info "$pkg" >/dev/null 2>&1; then
    echo "Installing: $pkg"
    tlmgr install "$pkg"
  else
    echo "Skipping unknown tlmgr package id: $pkg"
  fi
done < "$PACKAGES_FILE"

# Refresh filename database
mktexlsr

# Optional sanity checks
kpsewhich todonotes.sty >/dev/null || true