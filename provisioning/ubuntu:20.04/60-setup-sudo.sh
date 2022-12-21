command -v sudo >/dev/null 2>&1 || apt-get -y install sudo

echo '%sudo ALL=(ALL) NOPASSWD:ALL' >>/etc/sudoers

# disable sudo hint without having any matching file in $HOME
sed -i 's/\[ \! -e \"\$HOME\/\.hushlogin\" \]/false/' /etc/bash.bashrc

