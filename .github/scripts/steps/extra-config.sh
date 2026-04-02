#!/usr/bin/env bash
set -euo pipefail

TOOLS="$1"
ROOTEMU="$2"

[[ "$TOOLS" == "yes" ]] && echo '# FREETZ_DOWNLOAD_TOOLCHAIN is not set' >> .config
[[ "$TOOLS" != "yes" ]] && echo 'FREETZ_DOWNLOAD_TOOLCHAIN=y' >> .config

[[ "$ROOTEMU" == "pseudo" ]] && echo '# FREETZ_ROOTEMU_FAKEROOT is not set' >> .config
[[ "$ROOTEMU" != "pseudo" ]] && echo 'FREETZ_ROOTEMU_FAKEROOT=y' >> .config

[[ "$ROOTEMU" == "fakeroot" ]] && echo '# FREETZ_ROOTEMU_PSEUDO is not set' >> .config
[[ "$ROOTEMU" != "fakeroot" ]] && echo 'FREETZ_ROOTEMU_PSEUDO=y' >> .config
