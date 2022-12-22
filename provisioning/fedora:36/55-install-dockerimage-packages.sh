# add repo
dnf -y install dnf-utils
. /etc/os-release 
rpm --import "http://downloadcontent.opensuse.org/repositories/home:/alvistack/Fedora_$VERSION_ID/repodata/repomd.xml.key"
yum-config-manager --add-repo "http://downloadcontent.opensuse.org/repositories/home:/alvistack/Fedora_$VERSION_ID"

# our docker entrypoint relies on gosu to switch to unprivileged user
dnf -y install gosu

