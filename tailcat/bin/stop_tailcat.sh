#!/bin/sh

BIN=/mnt/us/extensions/tailcat/bin
PIDFILE=$BIN/tailcat.pid
LOG=$BIN/tailcat.log

eips_log() {
    echo "$1" >> "$LOG"
    eips 0 22 "$(printf '%-50s' "$1")" 2>/dev/null
}

echo "[$(date)] Stopping Tailcat..." > "$LOG"

pkill -f "tailcat" 2>/dev/null || true
rm -f "$PIDFILE"

eips_log "Tailcat stopped"
echo "Tailcat stopped."

exit 0
