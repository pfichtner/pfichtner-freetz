command -v locale-gen >/dev/null 2>&1 || apt-get -y install locales
sed -i 's/^# *en_US\.UTF-8 UTF-8/en_US.UTF-8 UTF-8/' /etc/locale.gen && locale-gen
locale -a | grep -Ei '^(en_US)' || (echo "failed to generate locales" && exit 1)
