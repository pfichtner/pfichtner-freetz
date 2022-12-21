BUILD_USER_HOME="${BUILD_USER_HOME:-/workspace}"

useradd -M -G sudo -s `which bash` -d $BUILD_USER_HOME $BUILD_USER
mkdir -p $BUILD_USER_HOME && chown -R $BUILD_USER $BUILD_USER_HOME

