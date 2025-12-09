#!/bin/bash -eu

HTTP_SOURCE=$1
CACHE=$2
TARGET=$3

fail() {
    echo "Error: $1" >&2
    exit 1
}

deps() {
    local CONTENT="$1"
    local FILTER="$2"

    # Remove comment lines
    CONTENT=$(echo "$CONTENT" | sed -E '/^[[:space:]]*#/d')

    # Remove installer prefix (sudo apt-get/apt/dnf -y install …)
    CONTENT=$(echo "$CONTENT" | sed -E "s/${FILTER}//")

    # Normalize spacing
    CONTENT=$(echo "$CONTENT" | sed -E 's/ +/ /g; s/^ //')

    # One word per line
    WORDS=$(echo "$CONTENT" | xargs -n1)

    # Output clean package list (unquoted)
    printf '%s\n' $WORDS
}

content() {
    local SOURCE_FILE="$1"
    local DISTRO_ENTRY="$2"

    awk -v pat="$DISTRO_ENTRY" '
        $0 ~ pat { found=1; next }

        found && /^```/ {
            if (fence == 0) { fence=1; next }   # start block
            else if (fence == 1) exit           # end block
        }

        fence == 1 { print }
    ' "$SOURCE_FILE" \
    | sed ':a;N;$!ba;s/\\\n/ /g' \
    | sed -E 's/[[:space:]]+/ /g' \
    | sed -E 's/^[[:space:]]+//' \
    | sed -E 's/[[:space:]]+$//'
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
	[ -z "$CONTENT" ] && fail "No content for $DISTRO_ENTRY"

	DEPS=$(deps "$CONTENT" "$PATTERN")
	PACKAGES=$(linesToJsonArray "$DEPS")
	toJson '{ "packages": %s }' "$PACKAGES" >"$TARGET_FILE"
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
	[ -z "$CONTENT" ] && fail "No content for $DISTRO_ENTRY"
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
[[ $HTTP_STATUS =~ ^(2[0-9]{2}|304)$ ]] || fail "Failed to download $HTTP_SOURCE (HTTP $HTTP_STATUS)"

OVERWRITE=false
[ "$HTTP_STATUS" = 200 ] && OVERWRITE=true

UBUNTU_PATTERN='^sudo apt-get -y install |^sudo apt -y install '
DEBIAN_PATTERN="$UBUNTU_PATTERN"
FEDORA_PATTERN='^sudo dnf -y install '

writeFiles "$CACHE/$FILENAME" "$TARGET" "ubuntu:26.04" "$OVERWRITE" '- Ubuntu 23\/24\/25 64-Bit:' "$UBUNTU_PATTERN"
writeFiles "$CACHE/$FILENAME" "$TARGET" "ubuntu:24.04" "$OVERWRITE" '- Ubuntu 23\/24\/25 64-Bit:' "$UBUNTU_PATTERN"
writeFiles "$CACHE/$FILENAME" "$TARGET" "ubuntu:22.04" "$OVERWRITE" '- Ubuntu 22'         "$UBUNTU_PATTERN"
writeFiles "$CACHE/$FILENAME" "$TARGET" "ubuntu:20.04" "$OVERWRITE" '- Ubuntu 20'         "$UBUNTU_PATTERN"
writeFiles "$CACHE/$FILENAME" "$TARGET" "ubuntu:18.04" "$OVERWRITE" '- Ubuntu 18'         "$UBUNTU_PATTERN"
writeFiles "$CACHE/$FILENAME" "$TARGET" "ubuntu:16.04" "$OVERWRITE" '- Ubuntu 15\/16'     "$UBUNTU_PATTERN"
writeFiles "$CACHE/$FILENAME" "$TARGET" "ubuntu:14.04" "$OVERWRITE" '- Ubuntu 14'         "$UBUNTU_PATTERN"

writeFiles "$CACHE/$FILENAME" "$TARGET" "debian:13"    "$OVERWRITE" '- Debian 13'         "$DEBIAN_PATTERN"
writeFiles "$CACHE/$FILENAME" "$TARGET" "debian:12"    "$OVERWRITE" '- Debian 12'         "$DEBIAN_PATTERN"
writeFiles "$CACHE/$FILENAME" "$TARGET" "debian:11"    "$OVERWRITE" '- Debian 11'         "$DEBIAN_PATTERN"

writeFiles "$CACHE/$FILENAME" "$TARGET" "fedora:43"    "$OVERWRITE" '- Fedora 42/43'      "$FEDORA_PATTERN"
writeFiles "$CACHE/$FILENAME" "$TARGET" "fedora:42"    "$OVERWRITE" '- Fedora 42/43'      "$FEDORA_PATTERN"
writeFiles "$CACHE/$FILENAME" "$TARGET" "fedora:41"    "$OVERWRITE" '- Fedora 41'         "$FEDORA_PATTERN"
writeFiles "$CACHE/$FILENAME" "$TARGET" "fedora:40"    "$OVERWRITE" '- Fedora 40'         "$FEDORA_PATTERN"
writeFiles "$CACHE/$FILENAME" "$TARGET" "fedora:39"    "$OVERWRITE" '- Fedora 37\/38\/39' "$FEDORA_PATTERN"
writeFiles "$CACHE/$FILENAME" "$TARGET" "fedora:38"    "$OVERWRITE" '- Fedora 37\/38\/39' "$FEDORA_PATTERN"
writeFiles "$CACHE/$FILENAME" "$TARGET" "fedora:37"    "$OVERWRITE" '- Fedora 37\/38\/39' "$FEDORA_PATTERN"
writeFiles "$CACHE/$FILENAME" "$TARGET" "fedora:36"    "$OVERWRITE" '- Fedora 36'         "$FEDORA_PATTERN"
writeFiles "$CACHE/$FILENAME" "$TARGET" "fedora:35"    "$OVERWRITE" '- Fedora 35'         "$FEDORA_PATTERN"
writeFiles "$CACHE/$FILENAME" "$TARGET" "fedora:34"    "$OVERWRITE" '- Fedora 33\/34'     "$FEDORA_PATTERN"
writeFiles "$CACHE/$FILENAME" "$TARGET" "fedora:33"    "$OVERWRITE" '- Fedora 33\/34'     "$FEDORA_PATTERN"

