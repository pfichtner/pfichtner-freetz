sudo() { eval ${*@Q}; }
sudo apt-get -y install autopoint bc binutils bison bsdmainutils bzip2 ccache cmake cpio curl ecj flex g++ gawk gcc gcc-multilib gettext git graphicsmagick imagemagick inkscape intltool java-wrappers kmod lib32ncurses5-dev lib32stdc++6 lib32z1-dev libacl1-dev libc6-dev-i386 libcap-dev libelf-dev libglib2.0-dev libgnutls28-dev libncurses5-dev libreadline-dev libsqlite3-dev libssl-dev libstring-crc32-perl libtool-bin libusb-dev libxml2-dev libzstd-dev make ncftp netcat net-tools patch patchutils perl pkg-config pv rsync sharutils sqlite3 subversion sudo texinfo tofrodos unar unzip uuid-dev wget zip zlib1g-dev
# sqlite-32bit lässt sich mit apt nicht installieren, aber mit apt-get schon. Siehe auch:
# https://developpaper.com/ubuntu-solves-the-problem-of-libsqlite3-0-dependency-recommended/
sudo apt -y install libzstd-dev:i386 sqlite3:i386

