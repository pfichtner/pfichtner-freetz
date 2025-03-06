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

@test "volume mount with workdir, force / (does not work)" {
  touch "$TMP_DIR/test.txt"
  output=$(echo 'pwd;ls;exit' | docker run --rm -i -v $TMP_DIR:/workspace -w / $IMAGE)
  echo "$output"
  # [ "$output" == $'/' ] # <-- should be this but we cannot differ in entrypoint between "no -w" and "-w /"
  [ "$output" == $'/workspace\ntest.txt' ]
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

@test "execs tools/prerequisites if existent" {
  mkdir "$TMP_DIR/tools"
  echo -e '#!/bin/bash\necho $0 $UID\n# echo Usage: $0 [ check | list | show [os] | install [-y] [os] ]' >"$TMP_DIR/tools/prerequisites"
  chmod +x "$TMP_DIR/tools/prerequisites"
  cat "$TMP_DIR/tools/prerequisites"
  output=$(echo 'exit' | docker run --rm -i -v $TMP_DIR:/home/builduser -w /home/builduser $IMAGE)
  echo "$output"
  [ "$output" == $'tools/prerequisites 1000' ]
}

@test "does not exec tools/prerequisites if existent but disabled" {
  mkdir "$TMP_DIR/tools"
  echo -e '#!/bin/bash\necho $0 $UID\n# echo Usage: $0 [ check | list | show [os] | install [-y] [os] ]' >"$TMP_DIR/tools/prerequisites"
  chmod +x "$TMP_DIR/tools/prerequisites"
  cat "$TMP_DIR/tools/prerequisites"
  output=$(echo 'exit' | docker run --rm -i -v $TMP_DIR:/home/builduser -w /home/builduser -e AUTOINSTALL_PREREQUISITES=n $IMAGE)
  echo "$output"
  [ "$output" == $'' ]
}

# ---------------------------------------------------------------------------------------------------------

@test "BUILD_USER_UID set to backup (user has to get removed)" {
  # check if user with UID 34 and name backup really exist
  output=$(echo 'getent passwd 34' | docker run --rm --entrypoint='' -i -e BUILD_USER_UID=34 $IMAGE /bin/bash)
  echo "$output"
  [ "$output" == $'backup:x:34:34:backup:/var/backups:/usr/sbin/nologin' ]

  output=$(echo 'pwd;whoami;id -u;exit' | docker run --rm -i -e BUILD_USER_UID=34 $IMAGE)
  echo "$output"
  [ "$output" == $'/\nbuilduser\n34' ]
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

