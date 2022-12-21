#!/bin/bash -e

[ "${COMMAND_NOT_FOUND_AUTOINSTALL}" = 'n' ] && unset COMMAND_NOT_FOUND_AUTOINSTALL || export COMMAND_NOT_FOUND_AUTOINSTALL=y

umask 0022

WS_OWNER=`stat -c "%u" $BUILD_USER_HOME`
[ $WS_OWNER -ne 0 -a $WS_OWNER -ne `id -u $BUILD_USER` ] && usermod -u $WS_OWNER $BUILD_USER

DEFAULT_SHELL=`getent passwd $BUILD_USER | cut -f 7 -d':'`
if [ `id -u` -eq 0 ]; then
	[ "$#" -gt 0 ] && gosu "$BUILD_USER" "$@" || gosu "$BUILD_USER" "$DEFAULT_SHELL"
else
	[ "$#" -gt 0 ] && "$@" || "$DEFAULT_SHELL"
fi

