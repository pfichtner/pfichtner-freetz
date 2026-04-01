#!/usr/bin/env bash
set -euo pipefail

make
rm -f images/latest.image
