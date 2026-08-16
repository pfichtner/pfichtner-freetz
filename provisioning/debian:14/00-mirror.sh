#!/bin/bash
set -e

if [ -n "$DEBIAN_MIRROR" ]; then
  echo "Using custom Debian mirror: $DEBIAN_MIRROR"
  sed -i "s|http://deb.debian.org/debian|$DEBIAN_MIRROR|g" /etc/apt/sources.list
fi

if [ -n "$DEBIAN_SECURITY_MIRROR" ]; then
  echo "Using custom Debian security mirror: $DEBIAN_SECURITY_MIRROR"
  sed -i "s|http://security.debian.org/debian-security|$DEBIAN_SECURITY_MIRROR|g" /etc/apt/sources.list
fi
