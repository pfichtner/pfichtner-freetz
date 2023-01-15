#!/bin/sh

HTTP_SOURCE=$1
CACHE=$2
TARGET=$3

deps() {
	CONTENT="$1"
	FILTER="$2"
	# echo "$CONTENT" | sed -n -E 's/'"$FILTER"'//p' | tr ' ' '\n' | grep .

	CONTENT=$(echo "$CONTENT" | sed -n -E 's/'"$FILTER"'//p')
	IFS=$'\n' arr=( $(xargs -n1 <<<"$CONTENT") )
	printf '%s\n' "${arr[@]}" | grep .
}

content() {
	SOURCE_FILE="$1"
	DISTRO_ENTRY="$2"
	cat "$SOURCE_FILE" | \
	# find relevant section (ignore all lines before)
	sed -n "/$DISTRO_ENTRY/,\$p" | \
	# find content between "```"
	sed -n '/```/{:loop n; /```/q; p; b loop}' | sed ':a;N;$!ba;s/\\\n//g' | sed 's/[[:space:]]\+/ /g'
}

linesToJsonArray() {
	echo "$1" | jq -R -s -c 'split("\n") | map(select(length > 0))'
}

toJson() {
	DATA=""
	printf -v DATA "$@"
	echo "$DATA"
}

writeDepsJsonFile() {
	SOURCE_FILE="$1"
	TARGET_FILE="$2"
	OVERWRITE="$3"
	DISTRO_ENTRY="$4"
	PATTERN="$5"

	[ -e "$TARGET_FILE" ] && [ "$OVERWRITE" = "false" ] && return

	[ -d $(dirname "$TARGET_FILE") ] || mkdir -p $(dirname "$TARGET_FILE")
	
 	CONTENT=$(content "$SOURCE_FILE" "$DISTRO_ENTRY") 
	DEPS=$(deps "$CONTENT" "$PATTERN")
	PACKAGES=$(linesToJsonArray "$DEPS")

	if [[ "$DISTRO_ENTRY" == *"Fedora"* ]]; then
		INSTALL_GROUPS=$(deps "$CONTENT" '^sudo dnf -y groupinstall ')
		ARR=$(linesToJsonArray "$INSTALL_GROUPS")
		toJson '{ "groups": %s, "packages": %s }' "$ARR" "$PACKAGES" >"$TARGET_FILE"
	else
		toJson '{ "packages": %s }' "$PACKAGES" >"$TARGET_FILE"
	fi

}

writePackageFile() {
	SOURCE_FILE="$1"
	TARGET_FILE="$2"
	OVERWRITE="$3"
	DISTRO_ENTRY="$4"

	[ -e "$TARGET_FILE" ] && [ "$OVERWRITE" = "false" ] && return

	[ -d `dirname "$TARGET_FILE"` ] || mkdir -p `dirname "$TARGET_FILE"`

	PREFIX='sudo() { eval ${*@Q}; }'
	CONTENT=$(content "$SOURCE_FILE" "$DISTRO_ENTRY")
	echo -e "$PREFIX\n$CONTENT\n" >"$TARGET_FILE"
}

writeFiles() {
	SOURCE_FILE="$1"
	TARGET="$2"
	SUBDIR="$3"
	OVERWRITE="$4"
	DISTRO_ENTRY="$5"
	PATTERN="$6"

	PREREQUISITES='50-freetz-ng-prerequisites.sh'
	DEPSJSON="dependencies.json"
	writeDepsJsonFile "$SOURCE_FILE" "$TARGET/$SUBDIR/$DEPSJSON" "$OVERWRITE" "$DISTRO_ENTRY" "$PATTERN"
	writePackageFile  "$SOURCE_FILE" "$TARGET/$SUBDIR/$PREREQUISITES" "$OVERWRITE" "$DISTRO_ENTRY"
}


[ -d "$TARGET" ] || mkdir -p "$TARGET"
[ -d "$CACHE" ] || mkdir -p "$CACHE"
FILENAME=`basename "$1"`
HTTP_STATUS=`curl --etag-save "$CACHE/$FILENAME.etag" --etag-compare "$CACHE/$FILENAME.etag" -so "$CACHE/$FILENAME" -w "%{http_code}" "$HTTP_SOURCE"`

OVERWRITE=false
[ "$HTTP_STATUS" = 200 ] && OVERWRITE=true

UBUNTU_PATTERN='^sudo apt-get -y install |^sudo apt -y install '
DEBIAN_PATTERN="$UBUNTU_PATTERN"
FEDORA_PATTERN='^sudo dnf -y install '

writeFiles "$CACHE/$FILENAME" "$TARGET" "ubuntu:22.04" "$OVERWRITE" ' - Ubuntu 22'     "$UBUNTU_PATTERN"
writeFiles "$CACHE/$FILENAME" "$TARGET" "ubuntu:20.04" "$OVERWRITE" ' - Ubuntu 20'     "$UBUNTU_PATTERN"
writeFiles "$CACHE/$FILENAME" "$TARGET" "ubuntu:18.04" "$OVERWRITE" ' - Ubuntu 18'     "$UBUNTU_PATTERN"
writeFiles "$CACHE/$FILENAME" "$TARGET" "ubuntu:16.04" "$OVERWRITE" ' - Ubuntu 16'     "$UBUNTU_PATTERN"
writeFiles "$CACHE/$FILENAME" "$TARGET" "ubuntu:14.04" "$OVERWRITE" ' - Ubuntu 14'     "$UBUNTU_PATTERN"

writeFiles "$CACHE/$FILENAME" "$TARGET" "debian:11"    "$OVERWRITE" ' - Debian 11'     "$DEBIAN_PATTERN"

writeFiles "$CACHE/$FILENAME" "$TARGET" "fedora:37"    "$OVERWRITE" ' - Fedora 36/37'  "$FEDORA_PATTERN"
writeFiles "$CACHE/$FILENAME" "$TARGET" "fedora:36"    "$OVERWRITE" ' - Fedora 36/37'  "$FEDORA_PATTERN"
writeFiles "$CACHE/$FILENAME" "$TARGET" "fedora:35"    "$OVERWRITE" ' - Fedora 35'     "$FEDORA_PATTERN"
writeFiles "$CACHE/$FILENAME" "$TARGET" "fedora:34"    "$OVERWRITE" ' - Fedora 33\/34' "$FEDORA_PATTERN"
writeFiles "$CACHE/$FILENAME" "$TARGET" "fedora:33"    "$OVERWRITE" ' - Fedora 33\/34' "$FEDORA_PATTERN"

