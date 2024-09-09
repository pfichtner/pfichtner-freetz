# do not purge package lists since we need them for autoinstalling via c-n-f
# rm -rf /var/lib/apt/lists/*

# remove the default ubuntu user (we don't need it and mostly UID 1000 will clash with the owner of the volume mount, see entrypoint.sh)
userdel -r ubuntu

