#!/bin/bash

deps() {
	FILE="$PROVISIONING_DIR/$1/dependencies.json"
	cat "$FILE" | jq -r '[.packages] | flatten[]' | grep . | sort | uniq
}

calcDiff() {
	DIFF=$(diff -Naur <(deps "$2") <(deps "$1") | grep -v ' ' | sort | tr '\n' ' ')
	echo "| $2 | $1 | $DIFF |"
}


echo "| From | To | Changes |"
echo "| - | - | - |"

PROVISIONING_DIR="$1"
distroDiff() {
	DIRS=$(cd "$PROVISIONING_DIR" && ls -d $1)
	PREV=""
	echo "$DIRS" | tac | while read DISTRO; do
		[ -n "$PREV" ] && calcDiff "$PREV" "$DISTRO"
		PREV="$DISTRO"
	done
}

distroDiff 'ubuntu*'
distroDiff 'debian*'
distroDiff 'fedora*'

