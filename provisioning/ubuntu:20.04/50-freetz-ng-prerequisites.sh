-e sudo() { eval ${*@Q}; }
sudo apt-get -y install pv cpio rsync kmod execstack imagemagick inkscape graphicsmagick subversion git bc unar wget sudo gcc g++ binutils autoconf automake autopoint libtool-bin make bzip2 libncurses5-dev libreadline-dev zlib1g-dev flex bison patch texinfo tofrodos gettext pkg-config ecj fastjar perl libstring-crc32-perl ruby gawk python libusb-dev unzip intltool libacl1-dev libcap-dev libc6-dev-i386 lib32ncurses5-dev gcc-multilib bsdmainutils lib32stdc++6 libglib2.0-dev ccache cmake lib32z1-dev libsqlite3-dev sqlite3 libzstd-dev netcat curl uuid-dev libssl-dev libgnutls28-dev sharutils
# sqlite-32bit lässt sich mit apt nicht installieren, aber mit apt-get schon. Siehe auch: https://developpaper.com/ubuntu-solves-the-problem-of-libsqlite3-0-dependency-recommended/
sudo apt -y install libzstd-dev:i386 sqlite3:i386

