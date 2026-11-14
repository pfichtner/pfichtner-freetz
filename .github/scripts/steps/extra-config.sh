#!/usr/bin/env bash
set -euo pipefail

TOOLS="$1"
ROOTEMU="$2"

if [ "$TOOLS" = "yes" ]; then
  echo '# FREETZ_DOWNLOAD_TOOLCHAIN is not set' >> .config
  echo '# FREETZ_HOSTTOOLS_DOWNLOAD is not set' >> .config
elif [ "$TOOLS" = "no" ]; then
  echo 'FREETZ_DOWNLOAD_TOOLCHAIN=y' >> .config
  echo 'FREETZ_HOSTTOOLS_DOWNLOAD=y' >> .config
fi

if [ "$ROOTEMU" = "pseudo" ]; then
  echo '# FREETZ_ROOTEMU_FAKEROOT is not set' >> .config
  echo 'FREETZ_ROOTEMU_PSEUDO=y' >> .config
elif [ "$ROOTEMU" = "fakeroot" ]; then
  echo '# FREETZ_ROOTEMU_PSEUDO is not set' >> .config
  echo 'FREETZ_ROOTEMU_FAKEROOT=y' >> .config
fi
