#!/bin/sh
. /mnt/us/extensions/tailcat/bin/common.sh
LOG=$BIN/tailcat_genkey.log

echo "[$(date)] Generating Tailcat key..." > "$LOG"

# If a key already exists, don't clobber it: genkey prints the address
# only once, so show the one we saved earlier.
if [ -s "$KEYFILE" ] && [ -s "$ADDRFILE" ] && [ "$1" != "--rotate" ]; then
    echo "Key already exists. Saved address:"
    show_wrapped "$(cat "$ADDRFILE")"
    exit 0
fi

# Fresh generation (or rotate): remove the old key, then create it.
# --fixed-region keeps the address identical across restarts.
[ -f "$KEYFILE" ] && "$TAILCAT" genkey --delete --key=default >> "$LOG" 2>&1
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
