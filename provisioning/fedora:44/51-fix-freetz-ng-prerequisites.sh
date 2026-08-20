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

# gcc.x86_64 requires "libatomic" without architecture qualifier.
# DNF may resolve this to the i686 variant, which installs to /usr/lib/ instead of /usr/lib64/.
# Explicitly install the x86_64 variant so the linker finds libatomic.so.1.2.0.
[ "$(uname -m)" = "x86_64" ] && dnf install -y libatomic.x86_64

