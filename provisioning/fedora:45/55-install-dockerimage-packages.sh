set -eux

dnf -y install gnupg

GOSU_VERSION=1.19
ARCH="$(uname -m)"

case "$ARCH" in
	x86_64) GOSU_ARCH=amd64 ;;
	aarch64) GOSU_ARCH=arm64 ;;
	armv7l) GOSU_ARCH=armhf ;;
	*) echo "Unsupported architecture: $ARCH" && exit 1 ;;
esac

curl -fsSL -o /usr/local/bin/gosu \
	"https://github.com/tianon/gosu/releases/download/${GOSU_VERSION}/gosu-${GOSU_ARCH}"

curl -fsSL -o /usr/local/bin/gosu.asc \
	"https://github.com/tianon/gosu/releases/download/${GOSU_VERSION}/gosu-${GOSU_ARCH}.asc"

# Verify signature
export GNUPGHOME="$(mktemp -d)"
gpg --batch --keyserver hkps://keys.openpgp.org --recv-keys B42F6819007F00F88E364FD4036A9C25BF357DD4
gpg --batch --verify /usr/local/bin/gosu.asc /usr/local/bin/gosu

chmod +x /usr/local/bin/gosu

