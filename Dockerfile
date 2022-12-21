ARG PARENT=ubuntu:20.04
FROM $PARENT

# https://stackoverflow.com/questions/44438637/arg-substitution-in-run-command-not-working-for-dockerfile/56748289#56748289
ARG PARENT
ARG BUILD_USER=builduser
ARG BUILD_USER_HOME="/workspace"

ARG PROVISION_DIR=/tmp/${PARENT}

ADD provisioning/${PARENT} ${PROVISION_DIR}
ARG DEBIAN_FRONTEND=noninteractive 
RUN for SCRIPT in ${PROVISION_DIR}/*.sh; do sh $SCRIPT || exit $?; done && rm -rf ${PROVISION_DIR}

WORKDIR ${BUILD_USER_HOME}
ENV BUILD_USER=$BUILD_USER
ENV BUILD_USER_HOME=$BUILD_USER_HOME
ADD entrypoint.sh /usr/local/bin
ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]

