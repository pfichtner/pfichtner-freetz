# add repo
dnf -y install dnf-utils
rpm --import "http://downloadcontent.opensuse.org/repositories/home:/alvistack/Fedora_36/repodata/repomd.xml.key"
yum-config-manager --add-repo "http://downloadcontent.opensuse.org/repositories/home:/alvistack/Fedora_36"

# our docker entrypoint relies on gosu to switch to unprivileged user
dnf -y install gosu

