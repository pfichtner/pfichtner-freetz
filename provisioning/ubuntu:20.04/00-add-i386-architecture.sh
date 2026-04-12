ARCH="$(dpkg --print-architecture 2>/dev/null || true)"
[ -n "$ARCH" ] || ARCH="$(uname -m 2>/dev/null || true)"

# On arm64, Ubuntu ports repositories generally do not provide i386 indexes.
case "$ARCH" in
	arm64|aarch64) ;;
	*) dpkg --add-architecture i386 ;;
esac

