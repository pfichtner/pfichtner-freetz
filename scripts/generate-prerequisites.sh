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
		sed 's/^sudo //g' | \
		# only accept lines starting with pattern A or pattern B (and cut the matching pattern), yes, this is ubuntu specific at the moment
		sed -n -E 's/^apt-get -y install |^apt -y install //p' | \
		# if there are packages named foo:i386 or bar:i386 ignore the "i386"
		sed 's/:i386//g' | \
		# collapse multiple whitespaces
		tr -s '[:blank:]' >"$TARGET_FILE"
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

writePackageFile "$TARGET/$FILENAME" "$TARGET/Ubuntu-22.04-prerequisites-packages.txt" "$OVERWRITE" " - Ubuntu 22"
writePackageFile "$TARGET/$FILENAME" "$TARGET/Ubuntu-20.04-prerequisites-packages.txt" "$OVERWRITE" " - Ubuntu 20"
writePackageFile "$TARGET/$FILENAME" "$TARGET/Ubuntu-18.04-prerequisites-packages.txt" "$OVERWRITE" " - Ubuntu 18"
writePackageFile "$TARGET/$FILENAME" "$TARGET/Ubuntu-16.04-prerequisites-packages.txt" "$OVERWRITE" " - Ubuntu 16"

