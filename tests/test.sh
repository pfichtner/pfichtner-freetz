#!/usr/bin/env bats

IMAGE=pfichtner/freetz


# Global variable to store the path of the temporary directory
TMP_DIR=""

setup() {
  TMP_DIR=$(mktemp -d)  # Create a temporary directory
}

teardown() {
  [[ -d "$TMP_DIR" ]] && rm -rf "$TMP_DIR"
}

@test "without any args" {
  output=$(echo 'pwd;ls -l;whoami;id -u;exit' | docker run --rm -i $IMAGE)
  echo "$output"
  [ "$output" == $'/workspace\ntotal 0\nbuilduser\n1000' ]
}

@test "without any args: run id instead of bash" {
  output=$(docker run --rm -i $IMAGE id -u)
  echo "$output"
  [ "$output" == $'1000' ]
}

@test "BUILD_USER root get's the workdir" {
  output=$(echo 'pwd;whoami;id -u;exit' | docker run --rm -i -e BUILD_USER=otheruser $IMAGE)
  echo "$output"
  [ "$output" == $'/\notheruser\n1000' ]
}

@test "BUILD_USER_UID root get's the workdir" {
  output=$(echo 'pwd;whoami;id -u;exit' | docker run --rm -i -e BUILD_USER_UID=1042 $IMAGE)
  echo "$output"
  [ "$output" == $'/\nbuilduser\n1042' ]
}

@test "BUILD_USER_HOME root still get's the workdir" {
  output=$(echo 'pwd;whoami;id -u;exit' | docker run --rm -i -e BUILD_USER_HOME=/home/someOtherHome $IMAGE)
  echo "$output"
  [ "$output" == $'/\nbuilduser\n1000' ]
}

@test "volume mount w/o workdir" {
  touch "$TMP_DIR/test.txt"
  output=$(echo 'pwd;ls;exit' | docker run --rm -i -v $TMP_DIR:/workspace $IMAGE)
  echo "$output"
  [ "$output" == $'/workspace\ntest.txt' ]
}

@test "volume mount with workdir" {
  touch "$TMP_DIR/test.txt"
  output=$(echo 'pwd;ls;exit' | docker run --rm -i -v $TMP_DIR:/home/builduser -w /home/builduser $IMAGE)
  echo "$output"
  [ "$output" == $'/home/builduser\ntest.txt' ]
}

@test "volume mount with workdir and homedir" {
  touch "$TMP_DIR/test.txt"
  output=$(echo 'pwd;ls;exit' | docker run --rm -i -v $TMP_DIR:/home/builduser -w /home/builduser -e BUILD_USER_HOME=/home/builduser $IMAGE)
  echo "$output"
  [ "$output" == $'/home/builduser\ntest.txt' ]
}

# ---------------------------------------------------------------------------------------------------------

@test "use UID from volume w/o workdir" {
  touch "$TMP_DIR/test.txt"
  output=$(echo 'pwd;ls;exit' | docker run --rm -i -v $TMP_DIR:/home/builduser -e USE_UID_FROM=/home/builduser $IMAGE)
  echo "$output"
  [ "$output" == $'/workspace' ] # no test.txt since we volume mounted /home/builduser and current dir is workspace here
}

@test "use UID from volume with workdir" {
  touch "$TMP_DIR/test.txt"
  output=$(echo 'pwd;ls;exit' | docker run --rm -i -v $TMP_DIR:/home/builduser -e USE_UID_FROM=/home/builduser -w /home/builduser $IMAGE)
  echo "$output"
  [ "$output" == $'/home/builduser\ntest.txt' ]
}

# ---------------------------------------------------------------------------------------------------------

@test "BUILD_USER_UID set to nobody (user has to get removed)" {
  output=$(echo 'pwd;whoami;id -u;exit' | docker run --rm -i -e BUILD_USER_UID=65534 $IMAGE)
  echo "$output"
  [ "$output" == $'/\nbuilduser\n65534' ]
}

# ---------------------------------------------------------------------------------------------------------

@test "run as root with disabled entrypoint" {
  output=$(echo 'pwd;whoami;id -u;exit' | docker run --rm --entrypoint='' -i -u 0 $IMAGE /bin/bash)
  echo "$output"
  [ "$output" == $'/\nroot\n0' ]
}

# ---------------------------------------------------------------------------------------------------------

@test "run using podman" {
  output=$(echo 'pwd;ls -l;whoami;id -u;exit' | podman run -u root --userns keep-id --rm -i docker.io/$IMAGE)
  echo "$output"
  [ "$output" == $'/workspace\ntotal 0\nbuilduser\n1000' ]
}

@test "run using podman: run id instead of bash" {
  output=$(podman run -u root --userns keep-id --rm -i docker.io/$IMAGE id -u)
  echo "$output"
  [ "$output" == $'1000' ]
}

