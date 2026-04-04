add_apt_mirror() {
for a in $(find /etc/apt/sources.list /etc/apt/sources.list.d/ubuntu.sources); do \
    sed -E -i \
    -e 's#http://[^[:space:]]*ubuntu\.com/(ubuntu|ubuntu-ports)#mirror+file:///etc/apt/mirrors/ubuntu.list#g' \
    $a; \
done || exit 1
}

x86_change_mirror() {
mkdir -p /etc/apt/mirrors
cat > /etc/apt/mirrors/ubuntu.list <<EOF
http://mirrors.dotsrc.org/ubuntu
http://archive.ubuntu.com/ubuntu
EOF
}

arm_change_mirror() {
mkdir -p /etc/apt/mirrors
cat > /etc/apt/mirrors/ubuntu.list <<EOF
http://mirrors.dotsrc.org/ubuntu-ports
http://ports.ubuntu.com/ubuntu-ports
EOF
}

if [ "$(uname -m)" = "x86_64" ] || [ "$(uname -m)" = "i686" ]; then
    x86_change_mirror && add_apt_mirror
elif [ "$(uname -m)" = "aarch64" ] || [ "$(uname -m)" = "armv7l" ]; then
    arm_change_mirror && add_apt_mirror
else
    echo "Unsupported architecture: $(uname -m)"
fi
