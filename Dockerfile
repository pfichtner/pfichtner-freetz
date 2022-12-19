ARG PARENT=ubuntu:20.04
FROM $PARENT
# https://stackoverflow.com/questions/44438637/arg-substitution-in-run-command-not-working-for-dockerfile/56748289#56748289
ARG PARENT

ARG BUILD_USER=builduser

# Configure Timezone
### ENV TZ=Europe/Berlin
### RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

ADD patch-cnf-autoinstall.patch /tmp
ADD prerequisites/${PARENT}-*-packages.txt /tmp/

RUN apt-get -y update && \
    apt-get -y upgrade && \
    apt-get -y dist-upgrade && \
    DEBIAN_FRONTEND=noninteractive xargs -a /tmp/${PARENT}-prerequisites-packages.txt apt-get -y install && \
    # otherwise sed complains: sed: can't read /etc/locale.gen: No such file or directory
    which locale-gen >/dev/null && locale-gen en_US.UTF-8 UTF-8 || true \
    [ -r /tmp/${PARENT}-add-packages.txt ] && sed 's/#.*$//;/^$/d' /tmp/${PARENT}-add-packages.txt | DEBIAN_FRONTEND=noninteractive xargs apt-get -y install || true

RUN DEBIAN_FRONTEND=noninteractive xargs -a /tmp/${PARENT}-prerequisites-packages.txt apt-get -y install && \
    rm /tmp/${PARENT}-*-packages.txt && \
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
    sed -i 's/\[ \! -e \"\$HOME\/\.hushlogin\" \]/false/' /etc/bash.bashrc

    # do not purge package lists since we need them for autoinstalling via c-n-f
    # rm -rf /var/lib/apt/lists/*

WORKDIR /workspace
ENV BUILD_USER=$BUILD_USER
ADD entrypoint.sh /usr/local/bin
ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]

