shopt -s expand_aliases
alias sudo=eval
sudo dnf -y groupinstall 'Development Tools' 'Development Libraries'
sudo dnf -y install pv cpio rsync kmod execstack sqlite.i686 sqlite-devel cmake zlib-devel.i686 libstdc++-devel.i686 openssl xz bc unar inkscape ImageMagick subversion ccache gcc gcc-c++ binutils autoconf automake libtool make bzip2 libglade2-devel qt5-qtbase-devel ncurses-devel ncurses-term zlib-devel flex bison patch texinfo gettext pkgconfig ecj perl perl-String-CRC32 wget glib2-devel git util-linux libacl-devel libattr-devel libcap-devel ncurses-devel.i686 glibc-devel.i686 libgcc.i686 libuuid-devel openssl-devel gnutls-devel libzstd-devel.x86_64 libstdc++-devel.x86_64 netcat curl sharutils
