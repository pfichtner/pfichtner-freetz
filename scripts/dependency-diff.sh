#!/bin/bash

deps() {
	FILE="provisioning/$1/50-freetz-ng-prerequisites.sh"
	sed -n -E 's/^sudo apt-get -y install |^sudo apt -y install //p' $FILE | tr ' ' '\n' | grep . | sort | uniq
}

calcDiff() {
	DIFF=$(diff -Naur <(deps "$2") <(deps "$1") | grep -v ' ' | sort | tr '\n' ' ')
	echo "+$1 -$2: $DIFF"
}

calcDiff "ubuntu:22.04" "ubuntu:20.04"
calcDiff "ubuntu:20.04" "ubuntu:18.04"
calcDiff "ubuntu:18.04" "ubuntu:16.04"
calcDiff "ubuntu:16.04" "ubuntu:14.04"

