#!/bin/bash

deps() {
	FILE="$1/50-freetz-ng-prerequisites.sh"
	sed -n -E 's/^sudo apt-get -y install |^sudo apt -y install //p' $FILE | tr ' ' '\n' | grep . | sort | uniq
}

calcDiff() {
	DIFF=$(diff -Naur <(deps "$2") <(deps "$1") | grep -v ' ' | sort | tr '\n' ' ')
	echo "$2 -> $1: $DIFF"
}


cd provisioning
PREV=""
ls -d ubuntu* | tac | while read DISTRO; do
	[ -n "$PREV" ] && calcDiff "$PREV" "$DISTRO"
	PREV="$DISTRO"
done

