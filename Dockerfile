ARG PARENT=ubuntu:20.04
FROM $PARENT

# https://stackoverflow.com/questions/44438637/arg-substitution-in-run-command-not-working-for-dockerfile/56748289#56748289
ARG PARENT
ARG BUILD_USER=builduser
ENV BUILD_USER=$BUILD_USER

ARG PROVISION_DIR=/tmp/${PARENT}

ADD provisioning/${PARENT} ${PROVISION_DIR}
ARG DEBIAN_FRONTEND=noninteractive 
RUN for SCRIPT in ${PROVISION_DIR}/*.sh; do sh $SCRIPT; done && rm -rf ${PROVISION_DIR}

WORKDIR /workspace
ADD entrypoint.sh /usr/local/bin
ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]

