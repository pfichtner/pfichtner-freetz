# for convenience inside the container
apt-get -y install command-not-found vim-gtk3 locales

# not for freetz but this docker image to switch to unprivileged user in entrypoint
apt-get -y install gosu

######################################################################################################
######################################################################################################

# missing in Freeet-NG's .prerequisites -> .prerequisites:program|uudecode|FREETZ_PACKAGE_ASTERISK_GUI
apt-get -y install sharutils

# not necessary for building but by tools/freetz_patch (lsdiff filterdiff)
apt-get -y install patchutils

# not necessary for building but uploading via tools/push_firmware
apt-get -y install iproute2 ncftp iputils-ping net-tools

