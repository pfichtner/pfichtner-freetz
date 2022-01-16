#!/bin/sh -e

UID=`stat -c "%u" /workspace`
if [ $UID -ne 0 -a $UID -ne `uid -u $BUILD_USER` ]; then
	usermod -u $UID $BUILD_USER
	gosu $BUILD_USER "$@"
else
	exec "$@"
fi

