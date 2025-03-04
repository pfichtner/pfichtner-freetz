ARG PARENT=ubuntu:24.04
FROM $PARENT

# https://stackoverflow.com/questions/44438637/arg-substitution-in-run-command-not-working-for-dockerfile/56748289#56748289
ARG PARENT
ARG PROVISION_DIR=/tmp/${PARENT}

COPY provisioning/${PARENT} ${PROVISION_DIR}
COPY provisioning/files ${PROVISION_DIR}/files
COPY provisioning/scripts ${PROVISION_DIR}/scripts
WORKDIR ${PROVISION_DIR}
RUN [ -r "${PROVISION_DIR}/envs" ] && export $(cat ${PROVISION_DIR}/envs | xargs); for SCRIPT in ${PROVISION_DIR}/*.sh; do (echo set -e && cat $SCRIPT) | bash || exit $?; done && rm -rf ${PROVISION_DIR}

# if running in podman we have to create a default user in the image since we have no root priviliges to do in ENTRYPOINT
RUN useradd -G sudo -s /bin/bash -d /workspace -m builduser

WORKDIR /
COPY entrypoint.sh /usr/local/bin
ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]

