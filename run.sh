#VER=latest

BUILD_IMAGE=pfichtner/freetz
BUILD_VER=20.04-1
PARENT=ubuntu
PARENT_VER=20.04
VOLUME_CONTAINER_IMAGE=vc_freetz
VOLUME_CONTAINER_VER=0.0.1
VOLUME_CONTAINER_NAME=vc_freetz-1

WORKSPACE=/workspace

run() {
  shift
# trys to run a volume container if not found
docker ps -a --format '{{.Names}}' | grep -q "${VOLUME_CONTAINER_NAME}" || docker run --name "${VOLUME_CONTAINER_NAME}" "${VOLUME_CONTAINER_IMAGE}:${VOLUME_CONTAINER_VER}"

  # -v $PWD/patches:/patches \
  # -v $PWD/config:/.config \
  # -v $PWD/images:$WORKSPACE/freetz-ng/images \
mkdir -p images

docker run --rm -it \
  --volumes-from="${VOLUME_CONTAINER_NAME}" \
  -v "$(pwd)/scripts:/${WORKSPACE}/scripts" \
  -v "$(pwd)/images:/${WORKSPACE}/images" \
  "${BUILD_IMAGE}:${BUILD_VER}" "$@"

#
#
#  #pttrr/freetz-ng-docker build master --no-menuconfig
# #
}

volume() {
  docker build -t "${VOLUME_CONTAINER_IMAGE}:${VOLUME_CONTAINER_VER}" -<<__EOF
FROM busybox:latest
LABEL org.opencontainers.image.authors="Reimer Prochnow reimer-github@ideenhal.de"
LABEL org.opencontainers.image.description="Freetz Volume Container Image"
LABEL org.opencontainers.image.title="${VOLUME_CONTAINER_IMAGE}"

RUN mkdir -p /workspace && \
    chmod 755 /workspace && chown 1000.1000 /workspace

VOLUME ["/workspace"]

CMD ["echo", "Volume container initialized."]
__EOF
}

build() {
  docker build --build-arg "PARENT=${PARENT}:${PARENT_VER}" -t "${BUILD_IMAGE}:${BUILD_VER}" .
}

# clean() {
#   echo Cleaning
#   rm -Rf freetz-ng/
#   mkdir freetz-ng
#   rm -f images/*
# }

"$1" $*
