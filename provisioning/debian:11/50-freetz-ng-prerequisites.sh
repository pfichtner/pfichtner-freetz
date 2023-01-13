sudo() { eval ${*@Q}; }
sudo apt -y install pv cpio rsync kmod imagemagick inkscape graphicsmagick subversion git bc unar wget sudo gcc g++ binutils autoconf automake autopoint libtool-bin make bzip2 libncurses5-dev libreadline-dev zlib1g-dev flex bison patch texinfo tofrodos gettext pkg-config ecj perl libstring-crc32-perl ruby gawk libusb-dev unzip intltool libacl1-dev libcap-dev libc6-dev-i386 lib32ncurses5-dev gcc-multilib bsdmainutils lib32stdc++6 libglib2.0-dev ccache cmake lib32z1-dev libsqlite3-dev sqlite3 libzstd-dev netcat curl uuid-dev libssl-dev libgnutls28-dev sharutils
#excestack-package muss manuell installiert werden, siehe https://bugs.debian.org/cgi-bin/bugreport.cgi?bug=921401
wget http://ftp.de.debian.org/debian/pool/main/p/prelink/execstack_0.0.20131005-1+b10_amd64.deb
sudo apt install ./execstack_0.0.20131005-1+b10_amd64.deb
echo "export PATH=$PATH:/usr/sbin" >> ~/.bashrc

