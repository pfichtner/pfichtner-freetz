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
expectToBeAbsent python-unversioned-command
expectToBeAbsent javapackages-tools
dnf -y install rpcgen python-unversioned-command javapackages-tools readline-devel
update-alternatives --install /usr/bin/javac javac /usr/bin/ecj 20

# program     fastjar                FREETZ_PACKAGE_CLASSPATH
FILE=fastjar-0.98-5.1.x86_64.rpm
wget -c "https://raw.githubusercontent.com/rpmsphere/x86_64/master/f/$FILE" && dnf -y install "$FILE" && rm "$FILE"

