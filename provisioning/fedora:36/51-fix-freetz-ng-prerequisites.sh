# program     rpcgen                 FREETZ_PACKAGE_NFS_UTILS FREETZ_PACKAGE_AUTOFS
# program     javac                  FREETZ_PACKAGE_CLASSPATH
dnf -y install rpcgen python-unversioned-command javapackages-tools
update-alternatives --install /usr/bin/javac javac /usr/bin/ecj 20

