command -v locale-gen >/dev/null 2>&1 || apt-get -y install locales
locale-gen en_US.UTF-8
locale -a | grep -Ei '^(en_US)' || (echo "failed to generate locales" && exit 1)
