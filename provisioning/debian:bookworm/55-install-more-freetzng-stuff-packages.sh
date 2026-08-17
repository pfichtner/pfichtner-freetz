# not necessary for building but by tools/freetz_patch (lsdiff filterdiff)
apt-get -y install patchutils

# not necessary for building but uploading via tools/push_firmware
# they USED to be not part of the PREREQUISITES but now they are. 
# Neverless we enforce the installation here anyway

# iproute2: /bin/ip /sbin/bridge /sbin/ip (not needed but useful)
# ncftp: /usr/bin/ncftpput
# iputils-ping: /bin/ping
# net-tools: /sbin/ifconfig
apt-get -y install iproute2 ncftp iputils-ping net-tools

