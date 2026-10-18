#!/bin/sh
# shellcheck source=common.sh
. /mnt/us/extensions/tailcat/bin/common.sh
show_qr || exit 1
sleep 60          # keep it up long enough to scan
eips -c           # clear when done