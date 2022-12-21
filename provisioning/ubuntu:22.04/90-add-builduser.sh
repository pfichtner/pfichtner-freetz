useradd -M -G sudo -s `which bash` -d /workspace $BUILD_USER
mkdir -p /workspace && chown -R $BUILD_USER /workspace

