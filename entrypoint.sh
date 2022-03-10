#!/bin/bash -e

[ "${COMMAND_NOT_FOUND_AUTOINSTALL}" = 'n' ] && unset COMMAND_NOT_FOUND_AUTOINSTALL || export COMMAND_NOT_FOUND_AUTOINSTALL=y

umask 0022

WS_OWNER=`stat -c "%u" /workspace`
[ $WS_OWNER -ne 0 -a $WS_OWNER -ne `id -u $BUILD_USER` ] && usermod -u $WS_OWNER $BUILD_USER

[ "$#" -gt 0 ] && gosu "$BUILD_USER" "$@" || gosu "$BUILD_USER" "$SHELL"

