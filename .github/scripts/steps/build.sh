#!/usr/bin/env bash
set -euo pipefail

make || make 
rm -f images/latest.image
