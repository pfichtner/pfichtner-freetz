FROM ubuntu:20.04

ARG BUILD_USER=builduser

# Configure Timezone
### ENV TZ=Europe/Berlin
### RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

ADD patch-cnf-autoinstall.patch /tmp

RUN apt-get -y update && \
    apt-get -y upgrade && \
    apt-get -y dist-upgrade && \
    DEBIAN_FRONTEND=noninteractive apt-get -y install \
               sudo command-not-found vim-gtk3 wget inkscape bc \
               rsync kmod execstack sqlite3 libsqlite3-dev libzstd-dev \
               libzstd-dev cmake lib32z1-dev unar inkscape imagemagick \
               subversion git bc wget sudo ccache gcc g++ binutils autoconf automake \
               autopoint libtool-bin make bzip2 libncurses5-dev libreadline-dev \
               zlib1g-dev flex bison patch texinfo tofrodos gettext pkg-config sharutils \
               ecj fastjar perl libstring-crc32-perl ruby gawk python \
	       bsdmainutils sudo locales \
               libusb-dev unzip intltool libacl1-dev libcap-dev libc6-dev-i386 \
               lib32ncurses5-dev gcc-multilib lib32stdc++6 libglib2.0-dev \
               libxml2-dev cpio \
               u-boot-tools device-tree-compiler \
               # needed by tools/freetz_patch
               patchutils \
               # not necessary for building but uploading via tools/push_firmware
               iproute2 ncftp iputils-ping net-tools \
               # not for freetz but this docker image to switch to unprivileged user in entrypoint
               gosu \
               && \
    \
    # need to run again for c-n-f
    apt-get -y update && \
    \
    sed -i -e 's/# en_US.UTF-8 UTF-8/en_US.UTF-8 UTF-8/' /etc/locale.gen && \
    locale-gen && \
    \
    useradd -M -G sudo -s `which bash` -d /workspace $BUILD_USER && \
    mkdir -p /workspace && chown -R $BUILD_USER /workspace && \
    \
    patch -p0 </tmp/patch-cnf-autoinstall.patch && \
    rm /tmp/patch-cnf-autoinstall.patch && \
    echo '%sudo ALL=(ALL) NOPASSWD:ALL' >>/etc/sudoers && \
    # disable sudo hint without having any matching file in $HOME
    sed -i 's/\[ \! -e \"\$HOME\/\.hushlogin\" \]/false/' /etc/bash.bashrc

    # do not purge package lists since we need them for autoinstalling via c-n-f
    # rm -rf /var/lib/apt/lists/*

WORKDIR /workspace
ENV BUILD_USER=$BUILD_USER
ADD entrypoint.sh /usr/local/bin
ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]

