#!/bin/sh
# shellcheck source=common.sh
. /mnt/us/extensions/tailcat/bin/common.sh
LOG=$BIN/tailcat_ssh.log

echo "[$(date)] Starting no-auth SSH..." > "$LOG"

[ -s "$KEYFILE" ] || { show_wrapped "No key yet - run Generate Default Key first"; exit 1; }

# Stop any running instance (normal mode or SSH mode) so the key is free
if [ -f "$PIDFILE" ]; then
    kill "$(cat "$PIDFILE")" 2>/dev/null
    rm -f "$PIDFILE"
fi
pkill -f "$TAILCAT serve" 2>/dev/null
sleep 1

# Remove the old address file so we only accept a fresh one
rm -f "$ADDRFILE"

TAILCAT_ADDR_FILE="$ADDRFILE" nohup "$TAILCAT" serve no-auth-ssh >> "$LOG" 2>&1 < /dev/null &
PID=$!
echo "$PID" > "$PIDFILE"

COUNT=0
while [ "$COUNT" -lt 30 ]; do
    if ! kill -0 "$PID" 2>/dev/null; then
        rm -f "$PIDFILE"
        echo "SSH failed to start:"
        show_wrapped "$(tail -n 5 "$LOG")"
        exit 1
    fi
    [ -s "$ADDRFILE" ] && break
    sleep 1
    COUNT=$((COUNT + 1))
done

# Fall back to the address saved at genkey time
if [ -s "$ADDRFILE" ]; then
    ADDR=$(tr -d '\r\n' < "$ADDRFILE")
elif [ -s "$SECRET" ]; then
    ADDR=$(tr -d '\r\n' < "$SECRET")
else
    show_wrapped "SSH running, but address not found. See tailcat_ssh.log"
    exit 1
fi
echo "$ADDR" > "$SECRET"

# Short key fingerprint: last 10 characters of the address
KEYID=$(printf '%s' "$ADDR" | tail -c 10)

show_wrapped "Insecure SSH started!"
show_wrapped "Key: default (...$KEYID)"
show_wrapped "Address:"
show_wrapped "$ADDR"
show_wrapped "Usage (from your computer):"
show_wrapped "tailcat ssh root@$ADDR"
show_wrapped "WARNING: NO AUTH! Everyone who has this key has ROOT access to this Kindle. With great power comes great responsibility."

exit 0