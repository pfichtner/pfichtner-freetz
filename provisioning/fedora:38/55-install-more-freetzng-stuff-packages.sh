# not necessary for building but by tools/freetz_patch (lsdiff filterdiff)
dnf -y install patchutils

# not necessary for building but uploading via tools/push_firmware
# ncftp: /usr/bin/ncftpput
# net-tools: /sbin/ifconfig
dnf -y install ncftp net-tools

