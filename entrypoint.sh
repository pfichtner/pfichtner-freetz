#!/usr/bin/env bash
set -e

[ "${COMMAND_NOT_FOUND_AUTOINSTALL}" = 'n' ] && unset COMMAND_NOT_FOUND_AUTOINSTALL || export COMMAND_NOT_FOUND_AUTOINSTALL=y

umask 0022

DEFAULT_BUILD_USER='builduser'

setToDefaults() {
	BUILD_USER="$DEFAULT_BUILD_USER" && BUILD_USER_HOME='/workspace'
}

# for backwards compatibility
[ -z "$BUILD_USER" ] && [ -z "$BUILD_USER_HOME" ] && [ -z "$BUILD_USER_UID" ] && setToDefaults && USE_UID_FROM="$BUILD_USER_HOME" && cd "$BUILD_USER_HOME"

# ignore PARAMS BUILD_USER and BUILD_USER_HOME (use defaults) if not root
[ `id -u` -eq 0 ] || setToDefaults

[ -z "$BUILD_USER" ] && BUILD_USER="$DEFAULT_BUILD_USER"
[ -n "$USE_UID_FROM" ] && BUILD_USER_UID=`stat -c "%u" $USE_UID_FROM`

if [ `id -u` -eq 0 ]; then
	# better read HOME/DHOME from /etc/default/useradd /etc/adduser.conf
	[ -z "$BUILD_USER_HOME" ] && BUILD_USER_HOME=/home/$BUILD_USER

	CMD="useradd -G sudo -s /bin/bash -d $BUILD_USER_HOME"
	[ ! -d "$BUILD_USER_HOME" ] && CMD="$CMD -m"
	[ -n "$BUILD_USER_UID" ] && CMD="$CMD -u $BUILD_USER_UID"

	CMD="$CMD $BUILD_USER"
	# remove the default builduser created in Dockerfile that exists in image
	userdel "$DEFAULT_BUILD_USER"
	eval "$CMD"
fi

DEFAULT_SHELL=`getent passwd $BUILD_USER | cut -f 7 -d':'`
if [ `id -u` -eq 0 ]; then
	[ "$#" -gt 0 ] && exec gosu "$BUILD_USER" "$@" || exec gosu "$BUILD_USER" "$DEFAULT_SHELL"
else
	[ "$#" -gt 0 ] && exec "$@" || exec "$DEFAULT_SHELL"
fi

