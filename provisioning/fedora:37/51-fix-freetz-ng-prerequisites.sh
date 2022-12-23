# program     rpcgen                 FREETZ_PACKAGE_NFS_UTILS FREETZ_PACKAGE_AUTOFS
# program     javac                  FREETZ_PACKAGE_CLASSPATH
dnf -y install rpcgen python-unversioned-command javapackages-tools
ln -sf /usr/bin/ecj /etc/alternatives/javac
ln -sf /etc/alternatives/javac /usr/bin/javac

