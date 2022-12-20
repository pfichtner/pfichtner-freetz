ARG PARENT=ubuntu:20.04
FROM $PARENT
# https://stackoverflow.com/questions/44438637/arg-substitution-in-run-command-not-working-for-dockerfile/56748289#56748289
ARG PARENT

ARG BUILD_USER=builduser

# Configure Timezone
### ENV TZ=Europe/Berlin
### RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

ADD patch-cnf-autoinstall.patch /tmp
ADD provisioning/${PARENT} /tmp/${PARENT}

ENV DEBIAN_FRONTEND=noninteractive 
RUN dpkg --add-architecture i386 && \
    apt-get -y update && \
    apt-get -y upgrade && \
    apt-get -y dist-upgrade && \
    [ -r /tmp/${PARENT}/init-image-packages.sh ] && sh /tmp/${PARENT}/init-image-packages.sh || true

RUN sh /tmp/${PARENT}/freetz-ng-prerequisites.sh && \
    \
    command -v locale-gen >/dev/null 2>&1 && locale-gen en_US.UTF-8 || true && \
    \
    # need to run again for c-n-f
    apt-get -y update && \
    \
    useradd -M -G sudo -s `which bash` -d /workspace $BUILD_USER && \
    mkdir -p /workspace && chown -R $BUILD_USER /workspace && \
    \
    patch -p0 </tmp/patch-cnf-autoinstall.patch && \
    rm /tmp/patch-cnf-autoinstall.patch && \
    echo '%sudo ALL=(ALL) NOPASSWD:ALL' >>/etc/sudoers && \
    # disable sudo hint without having any matching file in $HOME
    sed -i 's/\[ \! -e \"\$HOME\/\.hushlogin\" \]/false/' /etc/bash.bashrc && \
    rm -rf /tmp/${PARENT}

    # do not purge package lists since we need them for autoinstalling via c-n-f
    # rm -rf /var/lib/apt/lists/*

WORKDIR /workspace
ENV BUILD_USER=$BUILD_USER
ADD entrypoint.sh /usr/local/bin
ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]

