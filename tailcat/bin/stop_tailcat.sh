#!/bin/sh
# shellcheck source=common.sh
. /mnt/us/extensions/tailcat/bin/common.sh

echo "[$(date)] Stopping Tailcat..." > "$LOG"

if [ -f "$PIDFILE" ]; then
    kill "$(cat "$PIDFILE")" 2>/dev/null
fi
# Match only the server process, not this script (its path also contains "tailcat")
pkill -f "$TAILCAT serve" 2>/dev/null || true
rm -f "$PIDFILE"

log "Tailcat stopped"
echo "Tailcat stopped."

exit 0