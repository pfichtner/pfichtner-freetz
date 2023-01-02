ARG PARENT=ubuntu:22.04
FROM $PARENT

# https://stackoverflow.com/questions/44438637/arg-substitution-in-run-command-not-working-for-dockerfile/56748289#56748289
ARG PARENT
ARG PROVISION_DIR=/tmp/${PARENT}

ADD provisioning/${PARENT} ${PROVISION_DIR}
ADD provisioning/files ${PROVISION_DIR}/files
ADD provisioning/scripts ${PROVISION_DIR}/scripts
ARG DEBIAN_FRONTEND=noninteractive 
WORKDIR ${PROVISION_DIR}
RUN for SCRIPT in ${PROVISION_DIR}/*.sh; do bash $SCRIPT || exit $?; done && rm -rf ${PROVISION_DIR}

# if running in podman we have to create a default user in the image since we have no root priviliges to do in ENTRYPOINT
RUN useradd -G sudo -s /bin/bash -d /workspace -m builduser

ADD entrypoint.sh /usr/local/bin
ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]

