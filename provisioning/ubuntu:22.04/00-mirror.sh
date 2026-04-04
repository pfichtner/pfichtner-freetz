#!/bin/bash
set -e

if [ -n "$UBUNTU_MIRROR" ]; then
  if [ -f /etc/apt/sources.list ]; then
    sed -i \
      -e "s|http://archive.ubuntu.com/ubuntu|$UBUNTU_MIRROR|g" \
      -e "s|http://security.ubuntu.com/ubuntu|$UBUNTU_MIRROR|g" \
      /etc/apt/sources.list
  fi

  if ls /etc/apt/sources.list.d/*.sources >/dev/null 2>&1; then
    sed -i \
      -e "s|http://archive.ubuntu.com/ubuntu/|$UBUNTU_MIRROR|g" \
      -e "s|http://security.ubuntu.com/ubuntu/|$UBUNTU_MIRROR|g" \
      /etc/apt/sources.list.d/*.sources
  fi
fi
