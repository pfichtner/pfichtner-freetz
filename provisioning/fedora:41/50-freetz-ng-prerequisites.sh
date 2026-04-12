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
sudo dnf -y install bc binutils bison bzip2 ccache cmake curl ecj elfutils-libelf-devel flex gcc gcc-c++ gettext git glib2-devel glibc-devel gnutls-devel ImageMagick inkscape javapackages-tools kmod libacl-devel libattr-devel libcap-devel libgcc libglade2-devel libstdc++-devel libtool libuuid-devel libxml2-devel libzstd-devel make ncurses ncurses-devel ncurses-term netcat net-tools openssl openssl-devel openssl-devel-engine patch patchutils perl perl-String-CRC32 pkgconfig pv qt5-qtbase-devel readline-devel rpcgen rsync sharutils sqlite sqlite-devel subversion texinfo unar util-linux wget which xz zlib-ng-devel
