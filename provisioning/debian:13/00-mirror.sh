#!/bin/bash
set -e

for f in /etc/apt/sources.list /etc/apt/sources.list.d/*.sources; do
  [ -f "$f" ] || continue

  if [ -n "$DEBIAN_MIRROR" ]; then
    echo "Using custom Debian mirror: $DEBIAN_MIRROR"
    sed -i "s|http://deb.debian.org/debian|$DEBIAN_MIRROR|g" "$f"
  fi

  if [ -n "$DEBIAN_SECURITY_MIRROR" ]; then
    echo "Using custom Debian security mirror: $DEBIAN_SECURITY_MIRROR"
    sed -i "s|http://security.debian.org/debian-security|$DEBIAN_SECURITY_MIRROR|g" "$f"
  fi
done
