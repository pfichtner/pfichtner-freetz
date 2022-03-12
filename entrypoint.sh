#!/bin/bash -e

umask 0022

WS_OWNER=`stat -c "%u" /workspace`
[ $WS_OWNER -ne 0 -a $WS_OWNER -ne `id -u $BUILD_USER` ] && usermod -u $WS_OWNER $BUILD_USER

[ "$#" -gt 0 ] && sudo -Hu "$BUILD_USER" "$@" || sudo -Hu "$BUILD_USER" "$SHELL"

