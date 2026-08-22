#!/usr/bin/env bats

IMAGE=pfichtner/freetz
PODMAN_IMAGE=localhost/$IMAGE


# Global variable to store the path of the temporary directory
TMP_DIR=""

setup() {
  TMP_DIR=$(mktemp -d)  # Create a temporary directory
}

teardown() {
  [[ -d "$TMP_DIR" ]] && rm -rf "$TMP_DIR"
}

# Verifies the image provides a sane default environment without any configuration.
@test "without any args" {
  output=$(echo 'pwd;ls -l;whoami;id -u;exit' | docker run --rm -i $IMAGE)
  echo "$output"
  [ "$output" == $'/workspace\ntotal 0\nbuilduser\n1000' ]
}

# Verifies that passing a command directly works the same as piping to bash,
# so users don't always have to shell in to run a single command.
@test "without any args: run id instead of bash" {
  output=$(docker run --rm -i $IMAGE id -u)
  echo "$output"
  [ "$output" == $'1000' ]
}

# Verifies that BUILD_USER can rename the non-root user without breaking
# the default working directory or UID.
@test "BUILD_USER root get's the workdir" {
  output=$(echo 'pwd;whoami;id -u;exit' | docker run --rm -i -e BUILD_USER=otheruser $IMAGE)
  echo "$output"
  [ "$output" == $'/\notheruser\n1000' ]
}

# Verifies that BUILD_USER_UID can change the non-root user's UID without
# breaking the default working directory or user name.
@test "BUILD_USER_UID root get's the workdir" {
  output=$(echo 'pwd;whoami;id -u;exit' | docker run --rm -i -e BUILD_USER_UID=1042 $IMAGE)
  echo "$output"
  [ "$output" == $'/\nbuilduser\n1042' ]
}

# Verifies that BUILD_USER_HOME changes the home directory without
# affecting the working directory, since home and workdir are independent.
@test "BUILD_USER_HOME root still get's the workdir" {
  output=$(echo 'pwd;whoami;id -u;exit' | docker run --rm -i -e BUILD_USER_HOME=/home/someOtherHome $IMAGE)
  echo "$output"
  [ "$output" == $'/\nbuilduser\n1000' ]
}

# Verifies that a volume mount replaces /workspace as the working directory
# without requiring any extra flags, which is the typical bind-mount workflow.
@test "volume mount w/o workdir" {
  touch "$TMP_DIR/test.txt"
  output=$(echo 'pwd;ls;exit' | docker run --rm -i -v $TMP_DIR:/workspace $IMAGE)
  echo "$output"
  [ "$output" == $'/workspace\ntest.txt' ]
}

# Verifies that an explicit -w flag overrides the default working directory,
# so users can mount into a non-standard path and still start there.
@test "volume mount with workdir" {
  [[ "$(id -u)" -eq 1000 ]] || skip "UID is not 1000"
  touch "$TMP_DIR/test.txt"
  output=$(echo 'pwd;ls;exit' | docker run --rm -i -v $TMP_DIR:/home/builduser -w /home/builduser $IMAGE)
  echo "$output"
  [ "$output" == $'/home/builduser\ntest.txt' ]
}

# Documents a known limitation: the entrypoint cannot distinguish "no -w"
# from "-w /", so forcing -w / does not take effect. This test locks in
# current behavior so regressions are caught.
@test "volume mount with workdir, force / (does not work)" {
  touch "$TMP_DIR/test.txt"
  output=$(echo 'pwd;ls;exit' | docker run --rm -i -v $TMP_DIR:/workspace -w / $IMAGE)
  echo "$output"
  # [ "$output" == $'/' ] # <-- should be this but we cannot differ in entrypoint between "no -w" and "-w /"
  [ "$output" == $'/workspace\ntest.txt' ]
}

# Verifies that combining volume mount, explicit workdir, and BUILD_USER_HOME
# all point to the same location, ensuring a consistent home/workdir layout.
@test "volume mount with workdir and homedir" {
  [[ "$(id -u)" -eq 1000 ]] || skip "UID is not 1000"
  touch "$TMP_DIR/test.txt"
  output=$(echo 'pwd;ls;exit' | docker run --rm -i -v $TMP_DIR:/home/builduser -w /home/builduser -e BUILD_USER_HOME=/home/builduser $IMAGE)
  echo "$output"
  [ "$output" == $'/home/builduser\ntest.txt' ]
}

# ---------------------------------------------------------------------------------------------------------

# Verifies that USE_UID_FROM picks up the UID from a mounted path's ownership,
# enabling permission-compatible builds when bind-mounting host directories.
@test "use UID from volume w/o workdir" {
  [[ "$(id -u)" -eq 1000 ]] || skip "UID is not 1000"
  touch "$TMP_DIR/test.txt"
  output=$(echo 'pwd;ls;exit' | docker run --rm -i -v $TMP_DIR:/home/builduser -e USE_UID_FROM=/home/builduser $IMAGE)
  echo "$output"
  [ "$output" == $'/workspace' ] # no test.txt since we volume mounted /home/builduser and current dir is workspace here
}

# Verifies that USE_UID_FROM combined with a custom workdir keeps the UID
# from the mount and lands in the expected directory with its files visible.
@test "use UID from volume with workdir" {
  touch "$TMP_DIR/test.txt"
  output=$(echo 'pwd;ls;exit' | docker run --rm -i -v $TMP_DIR:/home/builduser -e USE_UID_FROM=/home/builduser -w /home/builduser $IMAGE)
  echo "$output"
  [ "$output" == $'/home/builduser\ntest.txt' ]
}

# ---------------------------------------------------------------------------------------------------------

# Verifies that tools/prerequisites is auto-executed when present,
# providing a hook for projects to install dependencies on container start.
@test "execs tools/prerequisites if existent" {
  mkdir "$TMP_DIR/tools"
  echo -e '#!/bin/bash\necho $0 $UID\n# echo Usage: $0 [ check | list | show [os] | install [-y] [os] ]' >"$TMP_DIR/tools/prerequisites"
  chmod +x "$TMP_DIR/tools/prerequisites"
  cat "$TMP_DIR/tools/prerequisites"
  output=$(echo 'exit' | docker run --rm -i -v $TMP_DIR:/home/builduser -e USE_UID_FROM=/home/builduser -w /home/builduser $IMAGE)
  echo "$output"
  [ "$output" == $'tools/prerequisites '$UID ]
}

# Verifies that AUTOINSTALL_PREREQUISITES=n disables the auto-execution
# of tools/prerequisites, so users can opt out of automatic setup.
@test "does not exec tools/prerequisites if existent but disabled" {
  mkdir "$TMP_DIR/tools"
  echo -e '#!/bin/bash\necho $0 $UID\n# echo Usage: $0 [ check | list | show [os] | install [-y] [os] ]' >"$TMP_DIR/tools/prerequisites"
  chmod +x "$TMP_DIR/tools/prerequisites"
  cat "$TMP_DIR/tools/prerequisites"
  output=$(echo 'exit' | docker run --rm -i -v $TMP_DIR:/home/builduser -e USE_UID_FROM=/home/builduser -w /home/builduser -e AUTOINSTALL_PREREQUISITES=n $IMAGE)
  echo "$output"
  [ "$output" == $'' ]
}

# ---------------------------------------------------------------------------------------------------------

# Verifies that UID collision with an existing system user is handled gracefully:
# the conflicting user (backup, UID 34) is removed so builduser can take that UID.
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

# Verifies that the image can be entered as root for debugging or admin tasks
# when the entrypoint is disabled and -u 0 is specified.
@test "run as root with disabled entrypoint" {
  output=$(echo 'pwd;whoami;id -u;exit' | docker run --rm --entrypoint='' -i -u 0 $IMAGE /bin/bash)
  echo "$output"
  [ "$output" == $'/\nroot\n0' ]
}

# ---------------------------------------------------------------------------------------------------------

# Verifies that podman's keep-id userns produces a valid numeric UID
# and matches the host user's UID when running as non-root.
@test "podman keep-id produces valid uid mapping" {
  uid=$(podman run --rm --userns keep-id -i $PODMAN_IMAGE id -u)

  [[ "$uid" =~ ^[0-9]+$ ]]

  if [ "$UID" -ne 0 ]; then
    [ "$uid" = "$UID" ]
  else
    [ "$uid" != "0" ]
  fi
}

# Verifies that running as root with keep-id still maps to a non-root UID,
# preventing accidental privileged builds even when -u root is passed.
@test "podman keep-id maps to a non-root uid (host or overflow)" {
  uid=$(podman run --rm --userns keep-id -i -u root $PODMAN_IMAGE id -u)
  [ "$uid" != "0" ]
}

# Verifies that mounting the host root (/) as a volume does not trick the
# image into running as UID 0, even with -u root and no userns mapping.
@test "podman keep-id does not mirror UID 0 from mounted workspace" {
  uid=$(podman run --rm -i -u root -v "/:/workspace" $PODMAN_IMAGE id -u)
  # must NOT be root
  [ "$uid" != "0" ]
}

# Verifies that a basic podman run with a volume mount doesn't crash and
# doesn't run as root, covering the simplest podman usage pattern.
@test "podman without -u root mounting /" {
  uid=$(podman run --rm -i -v "/:/workspace" $PODMAN_IMAGE id -u)
  # should not crash and should not run as root
  [[ "$uid" =~ ^[0-9]+$ ]]
  [ "$uid" != "0" ]
}

# Verifies that keep-id combined with a volume mount mirrors the host UID,
# which is the expected behavior for development workflows.
@test "podman without -u root mounting / with --userns keep-id" {
  uid=$(podman run --rm --userns keep-id -i -v "/:/workspace" $PODMAN_IMAGE id -u)
  # should mirror host UID
  [ "$uid" = "$UID" ]
}

# Verifies that requesting UID 0 does not crash when the image tries to
# remove conflicting users, which previously broke podman userns setups.
@test "BUILD_USER_UID=0 does not try to delete root user (Podman userns fix)" {
  output=$(docker run --rm -i -e BUILD_USER_UID=0 $IMAGE id -u)
  # must not crash: should fall through to run as root
  [ "$output" == "0" ]
}

# Regression guard: mounting $PWD as /workspace (a common development pattern)
# must not crash due to attempting to delete the root user inside the container.
@test "podman with mounted \$PWD as /workspace does not crash (userdel root guard)" {
  if ! podman image exists $PODMAN_IMAGE; then
    skip "build locally with podman or run 'docker save $IMAGE | podman load' first"
  fi
  output=$(podman run --rm -i -v "$PWD:/workspace" $PODMAN_IMAGE id -u)
  # must not crash; output must be a valid numeric UID
  [[ "$output" =~ ^[0-9]+$ ]]
}
