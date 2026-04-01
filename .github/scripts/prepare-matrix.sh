#!/usr/bin/env bash
set -euo pipefail

INPUT_OS="${1:-_all}"

if [[ "$INPUT_OS" != "_all" ]]; then
  OSLIST="$INPUT_OS"
else
  OSLIST="
fedora-43-latest
debian-13-latest
ubuntu-22.04-latest
ubuntu-24.04-latest
ubuntu-26.04-latest
"
fi

OSLIST=$(echo "$OSLIST" | sed 's/^[[:space:]]*//;s/[[:space:]]*$//')
OSLIST_JSON=$(echo "$OSLIST" | awk 'NF {printf "\"%s\",", $0}' | sed 's/,$//')

echo "os=[$OSLIST_JSON]"
