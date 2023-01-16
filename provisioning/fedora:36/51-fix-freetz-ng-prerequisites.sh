error() {
	echo "$1"
	exit 1
}

expectToBePresent() {
	dnf list installed "$1" >/dev/null 2>&1 || error "$1 was expected to be present but was absent"
}

expectToBeAbsent() {
	dnf list installed "$1" >/dev/null 2>&1 && error "$1 was expected to be absent but was present"
}

