#!/bin/sh -ex

UID=`stat -c "%u" /workspace`
if [ $UID -ne 0 ]; then
	usermod -u $UID $BUILD_USER
	exec gosu $BUILD_USER "$@"
else
	exec "$@"
fi

