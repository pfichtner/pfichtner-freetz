command -v sudo >/dev/null 2>&1 || dnf -y install sudo
groupadd -fr sudo

[ -d "/etc/sudoers.d" ] && TARGET="/etc/sudoers.d/sudo-group-nopasswd-sudoers" || TARGET="/etc/sudoers"
echo '%sudo ALL=(ALL) NOPASSWD:ALL' >>"$TARGET"

