#!/usr/bin/env bash
set -euo pipefail

FOS="$1"
BOX="$2"

truncate -s0 .config

echo 'FREETZ_MODULES_OWN=""' >> .config

for x in UDEVMOUNT; do echo "# FREETZ_PATCH_$x is not set" >> .config; done
for x in dummy loop usbserial; do echo "# FREETZ_MODULE_$x is not set" >> .config; done
for x in DROPBEAR; do echo "# FREETZ_PACKAGE_$x is not set" >> .config; done

echo "FREETZ_PACKAGE_LDD=y" >> .config

echo 'FREETZ_SERIES_ALL=y' >> .config
echo 'FREETZ_USER_LEVEL_DEVELOPER=y' >> .config

grep -q '^FREETZ_TYPE_' .config || echo "FREETZ_TYPE_$BOX=y" >> .config
grep -q '^FREETZ_TYPE_FIRMWARE_' .config || echo "FREETZ_TYPE_FIRMWARE_$FOS=y" >> .config
