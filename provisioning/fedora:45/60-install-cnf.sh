dnf -y install PackageKit-command-not-found
sed -i -e '/^SingleInstall=/s/=.*/=install/' /etc/PackageKit/CommandNotFound.conf

