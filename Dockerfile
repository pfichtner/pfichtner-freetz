FROM ubuntu:20.04

ARG BUILD_USER=builduser

# Configure Timezone
### ENV TZ=Europe/Berlin
### RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

# iproute2 ncftp iputils-ping net-tools: not necessary for building but uploading via tools/push_firmware
RUN apt-get -y update && \
    apt-get -y upgrade && \
    apt-get -y dist-upgrade && \
    DEBIAN_FRONTEND=noninteractive apt-get -y install \
               sudo vim-gtk3 wget inkscape bc \
               rsync kmod execstack sqlite3 libsqlite3-dev libzstd-dev \
               libzstd-dev cmake lib32z1-dev unar inkscape imagemagick \
               subversion git bc wget sudo ccache gcc g++ binutils autoconf automake \
               autopoint libtool-bin make bzip2 libncurses5-dev libreadline-dev \
               zlib1g-dev flex bison patch texinfo tofrodos gettext pkg-config \
               ecj fastjar perl libstring-crc32-perl ruby gawk python \
	       bsdmainutils sudo locales \
               libusb-dev unzip intltool libacl1-dev libcap-dev libc6-dev-i386 \
               lib32ncurses5-dev gcc-multilib lib32stdc++6 libglib2.0-dev \
               sqlite3 libxml2-dev cpio \
               \
               gosu \
               \
               iproute2 ncftp iputils-ping net-tools && \
    \
    sed -i -e 's/# en_US.UTF-8 UTF-8/en_US.UTF-8 UTF-8/' /etc/locale.gen && \
    locale-gen && \
    \
    useradd -M -d /workspace $BUILD_USER && \
    mkdir -p /workspace && chown -R $BUILD_USER /workspace && \
    \
    echo umask 0022 >>/etc/bash.bashrc && \
    \
    \
    rm -rf /var/lib/apt/lists/*

WORKDIR /workspace
ENV BUILD_USER=$BUILD_USER
ENTRYPOINT usermod -u $(stat -c "%u" /workspace) $BUILD_USER && gosu $BUILD_USER bash "$@"

