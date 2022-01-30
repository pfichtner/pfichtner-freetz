#!/bin/sh -e

UID=`stat -c "%u" /workspace`
[ $UID -ne 0 -a $UID -ne `id -u $BUILD_USER` ] && usermod -u $UID $BUILD_USER
gosu $BUILD_USER "$@"

