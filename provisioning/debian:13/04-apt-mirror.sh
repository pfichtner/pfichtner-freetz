add_apt_mirror() {
mkdir -p /etc/apt/mirrors
for a in $(find /etc/apt/sources.list /etc/apt/sources.list.d/debian.sources); do \
    sed -E -i \
    -e 's#http://[^[:space:]]*debian\.org/debian-security#mirror+file:/etc/apt/mirrors/debian-security.list#g' \
    -e 's#http://[^[:space:]]*debian\.org/debian#mirror+file:/etc/apt/mirrors/debian.list#g' \
    $a; \
done || exit 1
}

change_mirror() {
mkdir -p /etc/apt/mirrors
cat > /etc/apt/mirrors/debian-security.list <<EOF
http://mirrors.dotsrc.org/debian-security
http://deb.debian.org/debian-security
EOF
cat > /etc/apt/mirrors/debian.list <<EOF
http://mirrors.dotsrc.org/debian
http://deb.debian.org/debian
EOF
}

change_mirror && add_apt_mirror
