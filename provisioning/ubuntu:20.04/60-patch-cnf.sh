# need to run again for c-n-f
apt-get -y update

patch -p0 <$PROVISION_DIR/patch-cnf-autoinstall.patch
rm $PROVISION_DIR/patch-cnf-autoinstall.patch

