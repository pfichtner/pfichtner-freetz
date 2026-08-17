apt-get -y install command-not-found

# need to run again after installing c-n-f
update-command-not-found

# we need the patch binary so get sure it's really there 
# (we could uninstall it afterwards but leave it there, it doesn't harm)
command -v patch >/dev/null 2>&1 || apt-get -y install patch

(cd / && patch -p0 <$PROVISION_DIR/patch-cnf-autoinstall.patch)
rm $PROVISION_DIR/patch-cnf-autoinstall.patch

