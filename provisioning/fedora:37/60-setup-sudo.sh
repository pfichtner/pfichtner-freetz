command -v sudo >/dev/null 2>&1 || dnf -y install sudo
groupadd -fr sudo

echo '%sudo ALL=(ALL) NOPASSWD:ALL' >>/etc/sudoers

