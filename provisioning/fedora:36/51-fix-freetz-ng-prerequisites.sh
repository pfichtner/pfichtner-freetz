# program     rpcgen                 FREETZ_PACKAGE_NFS_UTILS FREETZ_PACKAGE_AUTOFS
# program     javac                  FREETZ_PACKAGE_CLASSPATH

error() {
	echo "$1"
	exit 1
}

expectToBeAbsent() {
	dnf list installed "$1" >/dev/null && error "$1 was expected to be absent but was present"
}

expectToBeAbsent rpcgen 
expectToBeAbsent javapackages-tools
dnf -y install rpcgen javapackages-tools
update-alternatives --install /usr/bin/javac javac /usr/bin/ecj 20

