#!/bin/sh
# shellcheck source=common.sh
. /mnt/us/extensions/tailcat/bin/common.sh
DIR="$1"
[ -n "$DIR" ] || { show_wrapped "No directory given"; exit 1; }
[ -d "$DIR" ] || mkdir -p "$DIR" || { show_wrapped "Cannot create $DIR"; exit 1; }
echo "$DIR" > "$RECVDIR_CONF"
show_wrapped "Receive folder set to: $DIR (restart Tailcat to apply)"