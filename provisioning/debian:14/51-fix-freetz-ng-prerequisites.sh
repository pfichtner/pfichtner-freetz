error() {
	echo "$1"
	exit 1
}

expectToBeAbsent() {
	dpkg -l "$1" && error "$1 was expected to be absent but was present"
}

