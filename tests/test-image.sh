#!/usr/bin/env bats

# Overridable so CI can pin the exact image that was just built (see docker-publish.yml).
# Defaults to the published image for local runs.
IMAGE="${IMAGE:-pfichtner/freetz}"
PODMAN_IMAGE="localhost/$IMAGE"


# Verifies that podman's keep-id userns produces a valid numeric UID
# and matches the host user's UID when running as non-root.
@test "podman keep-id produces valid uid mapping" {
  uid=$(podman run --pull=never --rm --userns keep-id -i -v "/:/workspace" $PODMAN_IMAGE id -u)

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
  uid=$(podman run --pull=never --rm --userns keep-id -i -u root $PODMAN_IMAGE id -u)
  [ "$uid" != "0" ]
}

# Verifies that mounting the host root (/) as a volume does not trick the
# image into running as UID 0, even with -u root and no userns mapping.
@test "podman keep-id does not mirror UID 0 from mounted workspace" {
  uid=$(podman run --pull=never --rm -i -u root -v "/:/workspace" $PODMAN_IMAGE id -u)
  # must NOT be root
  [ "$uid" != "0" ]
}

# Verifies that a basic podman run with a volume mount doesn't crash and
# doesn't run as root, covering the simplest podman usage pattern.
@test "podman without -u root mounting /" {
  uid=$(podman run --pull=never --rm -i -v "/:/workspace" $PODMAN_IMAGE id -u)
  # should not crash and should not run as root
  [[ "$uid" =~ ^[0-9]+$ ]]
  [ "$uid" != "0" ]
}

# Verifies that keep-id combined with a volume mount mirrors the host UID,
# which is the expected behavior for development workflows.
@test "podman without -u root mounting / with --userns keep-id" {
  uid=$(podman run --pull=never --rm --userns keep-id -i -v "/:/workspace" $PODMAN_IMAGE id -u)
  # should mirror host UID
  [ "$uid" = "$UID" ]
}

# Verifies that requesting UID 0 does not crash when the image tries to
# remove conflicting users, which previously broke podman userns setups.
@test "BUILD_USER_UID=0 does not try to delete root user (Podman userns fix)" {
  output=$(docker run --pull=never --rm -i -e BUILD_USER_UID=0 $IMAGE id -u)
  # must not crash: should fall through to run as root
  [ "$output" == "0" ]
}

# Regression guard: mounting $PWD as /workspace (a common development pattern)
# must not crash due to attempting to delete the root user inside the container.
@test "podman with mounted \$PWD as /workspace does not crash (userdel root guard)" {
  if ! podman image exists $PODMAN_IMAGE; then
    skip "build locally with podman or run 'docker save $IMAGE | podman load' first"
  fi
  output=$(podman run --pull=never --rm -i -v "$PWD:/workspace" $PODMAN_IMAGE id -u)
  # must not crash; output must be a valid numeric UID
  [[ "$output" =~ ^[0-9]+$ ]]
}
