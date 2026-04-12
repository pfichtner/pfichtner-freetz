#!/usr/bin/env bash
set -euo pipefail

CMD="${1:-}"

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
STEPS_DIR="$SCRIPT_DIR/steps"

source "$SCRIPT_DIR/lib.sh"

case "$CMD" in
  prepare-matrix)   "$STEPS_DIR/prepare-matrix.sh" "${2:-_all}" ;;
  config)           "$STEPS_DIR/config.sh" "$2" "$3" ;;
  extra-config)     "$STEPS_DIR/extra-config.sh" "$2" "$3" ;;
  build)            "$STEPS_DIR/build.sh" ;;
  result)           "$STEPS_DIR/result.sh" ;;
  vars)             "$STEPS_DIR/vars.sh" ;;
  *)
    echo "Unknown command: $CMD"
    exit 1
    ;;
esac
