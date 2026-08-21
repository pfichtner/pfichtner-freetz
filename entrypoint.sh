#!/usr/bin/env bash
set -e

[ "${COMMAND_NOT_FOUND_AUTOINSTALL}" = 'n' ] && unset COMMAND_NOT_FOUND_AUTOINSTALL || export COMMAND_NOT_FOUND_AUTOINSTALL=y

DEFAULT_BUILD_USER='builduser'

setToDefaults() {
	BUILD_USER="$DEFAULT_BUILD_USER" && BUILD_USER_HOME='/workspace'
}


autoInstallPrerequisites() {
	TOOL=tools/prerequisites

	[ -x "$TOOL" ] || return
	grep -qE 'Usage:.*(check.*install|install.*check)' "$TOOL" || return

	"$TOOL" check || "$TOOL" install -y
}



# for backwards compatibility
if [ -z "$BUILD_USER" ] && [ -z "$BUILD_USER_HOME" ] && [ -z "$BUILD_USER_UID" ]; then
	setToDefaults
	[ -z "$USE_UID_FROM" ] && USE_UID_FROM="$BUILD_USER_HOME"
	[ "$PWD" != "/" ] || cd "$BUILD_USER_HOME"
fi

# ignore PARAMS BUILD_USER and BUILD_USER_HOME (use defaults) if not root
[ `id -u` -eq 0 ] || setToDefaults

[ -z "$BUILD_USER" ] && BUILD_USER="$DEFAULT_BUILD_USER"
[ -n "$USE_UID_FROM" ] && BUILD_USER_UID=`stat -c "%u" $USE_UID_FROM`

if [ `id -u` -eq 0 ] && [ "$BUILD_USER_UID" != 0 ]; then  # UID=0, but mapped to calling user in UserNS Podman
	# better read HOME/DHOME from /etc/default/useradd /etc/adduser.conf
	[ -z "$BUILD_USER_HOME" ] && BUILD_USER_HOME=/home/$BUILD_USER

	USERADD="useradd -G sudo -s /bin/bash -d $BUILD_USER_HOME"
	[ -d "$BUILD_USER_HOME" ] && USERADD="$USERADD -M" || USERADD="$USERADD -m"
	if [ -n "$BUILD_USER_UID" ]; then
		# delete a conflicting user at that UID (except root/builduser)
		TMP_DEL_USER=$(getent passwd "$BUILD_USER_UID" | cut -d':' -f1)
		if [ -n "$TMP_DEL_USER" ] && [ "$TMP_DEL_USER" != "$DEFAULT_BUILD_USER" ] && [ "$TMP_DEL_USER" != "root" ]; then
			userdel "$TMP_DEL_USER" >/dev/null 2>/dev/null || true
			groupdel "$TMP_DEL_USER" >/dev/null 2>/dev/null || true
		fi
		# add -u flag if UID is free or only occupied by builduser (deleted below on line 57)
		if [ -z "$TMP_DEL_USER" ] || [ "$TMP_DEL_USER" = "$DEFAULT_BUILD_USER" ] || ! getent passwd "$BUILD_USER_UID" >/dev/null 2>&1; then
			USERADD="$USERADD -u $BUILD_USER_UID"
		fi
	fi

	[ -n "$BUILD_USER_GID" ] && USERADD="$USERADD -g $BUILD_USER_GID" && (getent group "$BUILD_USER_GID" || groupadd "$BUILD_USER_GID" "$BUILD_USER")

	USERADD="$USERADD $BUILD_USER"
	# remove the default builduser created in Dockerfile that exists in image
	userdel "$DEFAULT_BUILD_USER"
	eval "$USERADD" || true
fi

# if there are missing prerequisites we try to install them via tools/prerequisites
if [ "${AUTOINSTALL_PREREQUISITES}" != 'n' ]; then
	export -f autoInstallPrerequisites
	if [ `id -u` -eq 0 ]; then
		su "$BUILD_USER" -c autoInstallPrerequisites 2>/dev/null || true
	else
		autoInstallPrerequisites || true
	fi
	unset autoInstallPrerequisites
fi

DEFAULT_SHELL=$(getent passwd "$BUILD_USER" | cut -f 7 -d':') || true
if [ "$(id -u)" -eq 0 ] && [ "$BUILD_USER_UID" != 0 ] && [ -n "$DEFAULT_SHELL" ]; then  # UID=0, but mapped to calling user in UserNS Podman
	[ "$#" -gt 0 ] && exec gosu "$BUILD_USER" "$@" || exec gosu "$BUILD_USER" "$DEFAULT_SHELL"
else
	[ "$#" -gt 0 ] && exec "$@" || exec "${DEFAULT_SHELL:-/bin/bash}"
fi

