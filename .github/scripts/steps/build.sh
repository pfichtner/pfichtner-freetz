#!/usr/bin/env bash
set -euo pipefail

make && rm -f images/latest.image

# Copy the Docker image to Podman's store so Podman tests can use the local build
if command -v podman &> /dev/null; then
  docker save pfichtner/freetz:latest | podman load
fi
