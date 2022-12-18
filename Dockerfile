FROM ubuntu:20.04
ARG FREETZ_DISTRO_ENTRY="Ubuntu 20 64-Bit:"
ARG FREETZ_CMD_ENTRY="sudo apt-get -y install "

ARG BUILD_USER=builduser

# Configure Timezone
### ENV TZ=Europe/Berlin
### RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

ADD patch-cnf-autoinstall.patch /tmp

RUN apt-get -y update && \
    apt-get -y upgrade && \
    apt-get -y dist-upgrade && \
    DEBIAN_FRONTEND=noninteractive apt-get -y install \
               # things needed by freetz but missing there?
               libxml2-dev sharutils \
               # needed by tools/freetz_patch
               patchutils \
               # not necessary for building but uploading via tools/push_firmware
               iproute2 ncftp iputils-ping net-tools \
               # for convenience inside the container
               command-not-found vim-gtk3 locales \
               # not for freetz but this docker image to switch to unprivileged user in entrypoint
               gosu \
               # needed to download prerequisites
               wget \
               && \
    # install prerequisites
    wget --quiet -O- https://raw.githubusercontent.com/Freetz-NG/freetz-ng/master/docs/PREREQUISITES.md | sed -n "/$FREETZ_DISTRO_ENTRY/,\$p" | sed -n "0,/$FREETZ_CMD_ENTRY/{s/$FREETZ_CMD_ENTRY//p}" | DEBIAN_FRONTEND=noninteractive xargs apt-get -y install && \
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

