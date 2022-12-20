#!/bin/sh

HTTP_SOURCE=$1
CACHE=$2
TARGET=$3

writePackageFile() {
	SOURCE_FILE="$1"
	TARGET_FILE="$2"
	OVERWRITE="$3"
	DISTRO_ENTRY="$4"

	[ -e "$TARGET_FILE" -a "$OVERWRITE" = "false" ] && return

	[ -d `dirname "$TARGET_FILE"` ] || mkdir -p `dirname "$TARGET_FILE"`
	cat $SOURCE_FILE | \
		# find relevant section (ignore all lines before)
		sed -n "/$DISTRO_ENTRY/,\$p" | \
		# find content between "```"
		sed -n '/```/{:loop n; /```/q; p; b loop}' | \
		# ignore leading "sudo "
		sed 's/^sudo //g' >"$TARGET_FILE"
}


[ -d "$TARGET" ] || mkdir -p "$TARGET"
[ -d "$CACHE" ] || mkdir -p "$CACHE"
FILENAME=`basename "$1"`
HTTP_STATUS=`curl --etag-save "$CACHE/$FILENAME.etag" --etag-compare "$CACHE/$FILENAME.etag" -so "$CACHE/$FILENAME" -w "%{http_code}" "$HTTP_SOURCE"`

OVERWRITE=false
[ "$HTTP_STATUS" = 200 ] && OVERWRITE=true

# ❯ LC_ALL=C lsb_release -s --id
# Ubuntu
# ❯ LC_ALL=C lsb_release -s --release
# 22.10

writePackageFile "$CACHE/$FILENAME" "$TARGET/ubuntu:22.04/freetz-ng-prerequisites.sh" "$OVERWRITE" " - Ubuntu 22"
writePackageFile "$CACHE/$FILENAME" "$TARGET/ubuntu:20.04/freetz-ng-prerequisites.sh" "$OVERWRITE" " - Ubuntu 20"
writePackageFile "$CACHE/$FILENAME" "$TARGET/ubuntu:18.04/freetz-ng-prerequisites.sh" "$OVERWRITE" " - Ubuntu 18"
writePackageFile "$CACHE/$FILENAME" "$TARGET/ubuntu:16.04/freetz-ng-prerequisites.sh" "$OVERWRITE" " - Ubuntu 16"
writePackageFile "$CACHE/$FILENAME" "$TARGET/ubuntu:14.04/freetz-ng-prerequisites.sh" "$OVERWRITE" " - Ubuntu 14"

writePackageFile "$CACHE/$FILENAME" "$TARGET/fedora:36/freetz-ng-prerequisites.sh" "$OVERWRITE" " - Fedora 36"
writePackageFile "$CACHE/$FILENAME" "$TARGET/fedora:35/freetz-ng-prerequisites.sh" "$OVERWRITE" " - Fedora 35"
writePackageFile "$CACHE/$FILENAME" "$TARGET/fedora:34/freetz-ng-prerequisites.sh" "$OVERWRITE" " - Fedora 33\/34"
writePackageFile "$CACHE/$FILENAME" "$TARGET/fedora:33/freetz-ng-prerequisites.sh" "$OVERWRITE" " - Fedora 33\/34"

