#!/bin/sh
# shellcheck source=paths.sh
. /mnt/us/extensions/tailcat/bin/paths.sh

DIR="$(cat "$RECVDIR_CONF" 2>/dev/null)"
[ -n "$DIR" ] || DIR=$DEFAULT_RECV_DIR

f="$DIR/$(date +%Y%m%d-%H%M%S)-$$"
cat > "$f"

magic=$(dd bs=8 count=1 if="$f" 2>/dev/null | od -An -tx1 | tr -d ' \n')
case $magic in
  504b0304*)
      if head -c 100 "$f" | grep -q 'application/epub+zip'; then
          ext=epub
      else
          ext=zip
      fi ;;
  25504446*)         ext=pdf ;;
  89504e470d0a1a0a*) ext=png ;;
  ffd8ff*)           ext=jpg ;;
  1f8b*)             ext=gz ;;
  *)                 ext=bin ;;
esac

mv "$f" "$f.$ext" && f="$f.$ext"
echo "received: $(basename "$f")  $(wc -c < "$f") bytes  from ${TAILCAT_PEER_KEY:-unknown}" >&2