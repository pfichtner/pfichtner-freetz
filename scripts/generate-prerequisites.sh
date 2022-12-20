#!/bin/sh

HTTP_SOURCE=$1
TARGET=$2

writePackageFile() {
	SOURCE_FILE="$1"
	TARGET_FILE="$2"
	OVERWRITE="$3"
	DISTRO_ENTRY="$4"

	[ -e "$TARGET_FILE" -a "$OVERWRITE" = "false" ] && return

	cat $SOURCE_FILE | \
		# find relevant section (ignore all lines before)
		sed -n "/$DISTRO_ENTRY/,\$p" | \
		# find content between "```"
		sed -n '/```/{:loop n; /```/q; p; b loop}' | \
		# ignore leading "sudo "
		sed 's/^sudo //g' >"$TARGET_FILE"
}


[ -d "$TARGET" ] || mkdir -p "$TARGET"
FILENAME=`basename "$1"`
HTTP_STATUS=`curl --etag-save "$TARGET/$FILENAME.etag" --etag-compare "$TARGET/$FILENAME.etag" -so "$TARGET/$FILENAME" -w "%{http_code}" "$HTTP_SOURCE"`

OVERWRITE=false
[ "$HTTP_STATUS" = 200 ] && OVERWRITE=true

# ❯ LC_ALL=C lsb_release -s --id
# Ubuntu
# ❯ LC_ALL=C lsb_release -s --release
# 22.10

writePackageFile "$TARGET/$FILENAME" "$TARGET/ubuntu:22.04-prerequisites-packages.sh" "$OVERWRITE" " - Ubuntu 22"
writePackageFile "$TARGET/$FILENAME" "$TARGET/ubuntu:20.04-prerequisites-packages.sh" "$OVERWRITE" " - Ubuntu 20"
writePackageFile "$TARGET/$FILENAME" "$TARGET/ubuntu:18.04-prerequisites-packages.sh" "$OVERWRITE" " - Ubuntu 18"
writePackageFile "$TARGET/$FILENAME" "$TARGET/ubuntu:16.04-prerequisites-packages.sh" "$OVERWRITE" " - Ubuntu 16"
writePackageFile "$TARGET/$FILENAME" "$TARGET/ubuntu:14.04-prerequisites-packages.sh" "$OVERWRITE" " - Ubuntu 14"

writePackageFile "$TARGET/$FILENAME" "$TARGET/Fedora:36-prerequisites-packages.sh" "$OVERWRITE" " - Fedora 36"
writePackageFile "$TARGET/$FILENAME" "$TARGET/Fedora:35-prerequisites-packages.sh" "$OVERWRITE" " - Fedora 35"
writePackageFile "$TARGET/$FILENAME" "$TARGET/Fedora:34-prerequisites-packages.sh" "$OVERWRITE" " - Fedora 33\/34"
writePackageFile "$TARGET/$FILENAME" "$TARGET/Fedora:33-prerequisites-packages.sh" "$OVERWRITE" " - Fedora 33\/34"

