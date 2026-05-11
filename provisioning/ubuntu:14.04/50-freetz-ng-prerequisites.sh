sudo() { "$@"; }
_f() {
  local c=$1; shift
  local a_m=$(uname -m)
  local f=""
  case "$a_m" in
    x86_64) f="${AMD64_FILTER_PACKAGES:-}" ;;
    aarch64) f="${ARM64_FILTER_PACKAGES:-}" ;;
    armv7l) f="${ARMHF_FILTER_PACKAGES:-}" ;;
  esac
  if [ -n "$f" ]; then
    local p=()
    for a in "$@"; do
      if [[ ",$f," == *",$a,"* ]]; then
        :
      else
        p+=("$a")
      fi
    done
    command "$c" "${p[@]}"
  else
    command "$c" "$@"
  fi
}
apt-get() { _f apt-get "$@"; }
apt() { _f apt "$@"; }
dnf() { _f dnf "$@"; }
sudo apt-get -y install autoconf automake automake1.9 autopoint bc binutils bison bsdmainutils build-essential bzip2 ccache cmake curl ecj flex g++ gawk gcc gcc-multilib gettext git graphicsmagick imagemagick inkscape intltool kmod lib32ncurses5-dev lib32stdc++6 lib32z1-dev libacl1-dev libc6-dev-i386 libcap-dev libglib2.0-dev libncurses5-dev libreadline-dev libsqlite3-dev libstring-crc32-perl libtool libusb-dev make netcat openssl patch perl pkg-config pv realpath rsync sqlite3 subversion sudo texinfo unar unzip wget zlib1g-dev
