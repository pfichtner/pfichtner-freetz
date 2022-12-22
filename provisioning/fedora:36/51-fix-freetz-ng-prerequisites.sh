# program     rpcgen                 FREETZ_PACKAGE_NFS_UTILS FREETZ_PACKAGE_AUTOFS
# program     javac                  FREETZ_PACKAGE_CLASSPATH
dnf -y remove ecj
dnf -y install rpcgen python-unversioned-command java-1.8.0-openjdk-devel

