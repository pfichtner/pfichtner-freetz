#!/bin/bash

deps() {
	FILTER="$1"
	FILE="$2/50-freetz-ng-prerequisites.sh"
	sed -n -E 's/'"$FILTER"'//p' $FILE | tr ' ' '\n' | grep . | sort | uniq
}

ubuntuDeps() {
	debs "$1" 
}

calcDiff() {
	DIFF=$(diff -Naur <(deps "$1" "$3") <(deps "$1" "$2") | grep -v ' ' | sort | tr '\n' ' ')
	echo "| $3 | $2 | $DIFF |"
}


echo "| From | To | Changes |"
echo "| - | - | - |"
PROVISIONING_DIR="provisioning"
distroDiff() {
	DIRS=$(cd "$PROVISIONING_DIR" && ls -d $1)
	PREV=""
	echo "$DIRS" | tac | while read DISTRO; do
		[ -n "$PREV" ] && calcDiff "$2" "$PROVISIONING_DIR/$PREV" "$PROVISIONING_DIR/$DISTRO"
		PREV="$DISTRO"
	done
}

distroDiff 'ubuntu*' '^sudo apt-get -y install |^sudo apt -y install '
distroDiff 'debian*' '^sudo apt-get -y install |^sudo apt -y install '
distroDiff 'fedora*' '^sudo dnf -y install'

