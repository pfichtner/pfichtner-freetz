error() {
	echo "$1"
	exit 1
}

expectToBePresent() {
	dpkg -l "$1" || error "$1 was expected to be present but was absent"
}

expectToBeAbsent() {
	dpkg -l "$1" && error "$1 was expected to be absent but was present"
}

