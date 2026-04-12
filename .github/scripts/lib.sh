#!/usr/bin/env bash
set -euo pipefail

log() {
  echo "################################################################"
  echo "$*"
}

trim() {
  sed 's/^[[:space:]]*//;s/[[:space:]]*$//'
}
