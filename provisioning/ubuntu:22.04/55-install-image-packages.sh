# for convenience inside the container
apt-get -y install command-not-found vim-gtk3 locales

# our docker entrypoint relies on gosu to switch to unprivileged user
# we do rely on patch so get sure it's really there
apt-get -y install gosu patch

######################################################################################################
######################################################################################################

# not necessary for building but by tools/freetz_patch (lsdiff filterdiff)
apt-get -y install patchutils

# not necessary for building but uploading via tools/push_firmware
apt-get -y install iproute2 ncftp iputils-ping net-tools

