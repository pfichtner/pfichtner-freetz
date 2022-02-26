#!/bin/sh -e

[ "${COMMAND_NOT_FOUND_AUTOINSTALL}" = 'n' ] && unset COMMAND_NOT_FOUND_AUTOINSTALL || export COMMAND_NOT_FOUND_AUTOINSTALL=y

umask 0022

UID=`stat -c "%u" /workspace`
[ $UID -ne 0 -a $UID -ne `id -u $BUILD_USER` ] && usermod -u $UID $BUILD_USER
gosu $BUILD_USER "$@"

