#!/usr/bin/env bash
set -euo pipefail

# Always run relative to repository root
REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$REPO_ROOT"

export TEXLIVE_DIR="/tmp/texlive"
export PATH="$TEXLIVE_DIR/bin/x86_64-linux:$PATH"

# Install TeX Live if not present (cache-friendly)
if ! command -v texlua >/dev/null 2>&1; then
  echo "TeX Live not found in PATH, installing to $TEXLIVE_DIR"

  curl -L -o install-tl-unx.tar.gz \
    "https://mirror.ctan.org/systems/texlive/tlnet/install-tl-unx.tar.gz"

  tar -xzf install-tl-unx.tar.gz
  cd install-tl-20*/
  ./install-tl -repository "https://mirror.ctan.org/systems/texlive/tlnet" --profile="$REPO_ROOT/texlive/texlive.profile"
  cd "$REPO_ROOT"
fi

# Mismatched Tree Guard

if [ -x /tmp/texlive/bin/x86_64-linux/tlmgr ]; then
  INSTALLED_YEAR="$(/tmp/texlive/bin/x86_64-linux/tlmgr --version | awk '/TeX Live/ {print $NF; exit}')"
  if [ "$INSTALLED_YEAR" != "2026" ]; then
    echo "Found TeX Live $INSTALLED_YEAR cached, removing to avoid cross-release mismatch."
    rm -rf /tmp/texlive
  fi
fi


# Ensure tlmgr uses a sensible CTAN mirror
tlmgr option repository "https://ctan.math.washington.edu/tex-archive/systems/texlive/tlnet"

# Update tlmgr itself before installing packages
tlmgr update --self

# Install core tools you rely on
tlmgr install latexmk luatex texliveonfly \
  collection-langeuropean collection-fontsrecommended

# Install your explicit package list (strip blank lines/comments/CRLF)
PACKAGES_FILE="$REPO_ROOT/texlive/texlive_packages"
sed -i 's/\r$//' "$PACKAGES_FILE"

# awk 'NF && $1 !~ /^#/' "$PACKAGES_FILE" | xargs -r tlmgr install

while IFS= read -r pkg; do
  # skip blanks/comments
  [[ -z "$pkg" || "$pkg" =~ ^[[:space:]]*# ]] && continue

  # strip CRLF and whitespace
  pkg="${pkg//$'\r'/}"
  pkg="$(echo "$pkg" | xargs)"

  # check package exists in tlmgr database
  if tlmgr info "$pkg" >/dev/null 2>&1; then
    echo "Installing: $pkg"
    tlmgr install "$pkg"
  else
    echo "Skipping unknown tlmgr package: $pkg"
  fi
done < "$PACKAGES_FILE"


# Prove todonotes is actually available (fail fast if not)
kpsewhich todonotes.sty >/dev/null

# Reduce cache size + keep TL up to date
tlmgr option -- autobackup 0
tlmgr update --self --all --no-auto-install
``