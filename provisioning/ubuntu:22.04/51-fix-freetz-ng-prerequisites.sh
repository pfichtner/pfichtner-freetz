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

# .prerequisites
# program     xml2-config            FREETZ_PACKAGE_GNTPSEND FREETZ_PACKAGE_ASTERISK
# program     javac                  FREETZ_PACKAGE_CLASSPATH
# ecj (get's installed) depends on java-wrappers but ths dependency is missing in ecj, https://salsa.debian.org/java-team/ecj/-/commit/f7d6cae26fbde9b146d02affe08da534f801a0f7
expectToBeAbsent libxml2-dev
expectToBePresent ecj && expectToBeAbsent java-wrappers
apt-get -y install libxml2-dev java-wrappers

