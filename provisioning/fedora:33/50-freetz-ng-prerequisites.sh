sudo() { eval ${*@Q}; }
sudo dnf -y groupinstall 'Development Tools' 'Development Libraries'
sudo dnf -y install autoconf automake bc binutils bison bzip2 ccache cmake cpio ecj flex gcc gcc-c++ gettext git glib2-devel glibc-devel.i686 gnutls-devel ImageMagick inkscape kmod libacl-devel libattr-devel libcap-devel libgcc.i686 libglade2-devel libstdc++-devel.i686 libtool libuuid-devel libzstd-devel.i686 make ncurses-devel ncurses-devel.i686 ncurses-term openssl openssl-devel patch perl perl-String-CRC32 pkgconfig pv qt5-qtbase-devel rsync sqlite-devel sqlite.i686 subversion texinfo unar util-linux wget xz zlib-devel zlib-devel.i686

