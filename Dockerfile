FROM ubuntu:14.04

ARG BUILD_USER=builduser

# Configure Timezone
### ENV TZ=Europe/Berlin
### RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

RUN apt-get -y update && \
    apt-get -y upgrade && \
    apt-get -y dist-upgrade && \
    DEBIAN_FRONTEND=noninteractive apt-get -y install \
               sudo command-not-found wget inkscape bc \
               rsync kmod execstack sqlite3 libsqlite3-dev \
               cmake lib32z1-dev unar inkscape imagemagick \
               subversion git bc wget sudo ccache gcc g++ binutils autoconf automake \
               autopoint libtool make bzip2 libncurses5-dev libreadline-dev \
               zlib1g-dev flex bison patch texinfo tofrodos gettext pkg-config sharutils \
               ecj fastjar perl libstring-crc32-perl ruby gawk python \
	       bsdmainutils sudo locales \
               libusb-dev unzip intltool libacl1-dev libcap-dev libc6-dev-i386 \
               lib32ncurses5-dev gcc-multilib lib32stdc++6 libglib2.0-dev \
               libxml2-dev cpio && \
    \
    # need to run again for c-n-f
    apt-get -y update && \
    \
    # sed -i -e 's/# en_US.UTF-8 UTF-8/en_US.UTF-8 UTF-8/' /etc/locale.gen && \
    # locale-gen && \
    \
    useradd -M -G sudo -d /workspace $BUILD_USER && \
    mkdir -p /workspace && chown -R $BUILD_USER /workspace && \
    \
    echo '%sudo ALL=(ALL) NOPASSWD:ALL' >>/etc/sudoers && \
    # disable sudo hint without having any matching file in $HOME
    sed -i 's/\[ \! -e \"\$HOME\/\.hushlogin\" \]/false/' /etc/bash.bashrc

    # do not purge package lists since we need them for autoinstalling via c-n-f
    # rm -rf /var/lib/apt/lists/*

WORKDIR /workspace
ENV BUILD_USER=$BUILD_USER
ADD entrypoint.sh /usr/local/bin
ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]

