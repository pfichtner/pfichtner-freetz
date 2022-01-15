#!/bin/sh -e

UID=`stat -c "%u" /workspace`
if [ $UID -ne 0 ]; then
	usermod -u $UID $BUILD_USER
	gosu $BUILD_USER "$@"
else
	exec "$@"
fi

