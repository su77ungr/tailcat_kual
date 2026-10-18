#!/bin/sh
# shellcheck source=common.sh
. /mnt/us/extensions/tailcat/bin/common.sh
LOG=$BIN/tailcat_genkey.log

echo "[$(date)] Generating Tailcat key..." > "$LOG"

# --force overwrites any existing key.
"$TAILCAT" genkey --key=default --fixed-region --force >> "$LOG" 2>&1 < /dev/null
STATUS=$?

if [ "$STATUS" -ne 0 ] || [ ! -s "$KEYFILE" ]; then
    echo "Key generation failed (status $STATUS):"
    show_wrapped "$(tail -n 5 "$LOG")"
    exit 1
fi

ADDR=$(extract_addr "$LOG")
if [ -z "$ADDR" ]; then
    echo "Key created, address not parsed. Raw output:"
    show_wrapped "$(tail -n 5 "$LOG")"
    exit 1
fi

echo "$ADDR" > "$ADDRFILE"
echo "$ADDR" > "$SECRET"
[ -x "$QR" ] && "$QR" -o "$QR_IMAGE" -s 5 -m 2 "$ADDR" >> "$LOG" 2>&1

echo "Key generated! Address:"
show_wrapped "$ADDR"
exit 0