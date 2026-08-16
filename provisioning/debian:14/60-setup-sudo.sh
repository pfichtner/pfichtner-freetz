command -v sudo >/dev/null 2>&1 || apt-get -y install sudo

[ -d "/etc/sudoers.d" ] && TARGET="/etc/sudoers.d/sudo-group-nopasswd-sudoers" || TARGET="/etc/sudoers"
echo '%sudo ALL=(ALL) NOPASSWD:ALL' >>"$TARGET"

# disable sudo hint without having any matching file in $HOME
sed -i 's/\[ \! -e \"\$HOME\/\.hushlogin\" \]/false/' /etc/bash.bashrc

