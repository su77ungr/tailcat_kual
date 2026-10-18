#!/bin/sh
# shellcheck source=common.sh
. /mnt/us/extensions/tailcat/bin/common.sh

# Generate the QR PNG for an address and save it to $QR_IMAGE
make_qr() {
    if [ ! -x "$QR" ]; then
        log "qrencode missing - run Install"
        return 1
    fi

    rm -f "$QR_IMAGE"

    if ! "$QR" -t PNG -o "$QR_IMAGE" -s 8 -m 4 -l L "$1" >> "$LOG" 2>&1; then
        log "QR generation failed (see log)"
        return 1
    fi

    if [ ! -s "$QR_IMAGE" ]; then
        log "QR file was not created"
        return 1
    fi

    log "QR saved: $QR_IMAGE"
    return 0
}

RECV_DIR=$(get_recv_dir)

echo "[$(date)] Starting Tailcat (serve -> $RECV_DIR)..." > "$LOG"
log "Starting Tailcat..."

# Already running: show the address and make sure the QR exists
if [ -f "$PIDFILE" ] && kill -0 "$(cat "$PIDFILE")" 2>/dev/null; then
    ADDR=$(tr -d '\r\n' < "$ADDRFILE" 2>/dev/null)
    [ -n "$ADDR" ] && [ ! -s "$QR_IMAGE" ] && make_qr "$ADDR"
    log "Tailcat already running"
    show_wrapped "$ADDR"
    exit 0
fi
rm -f "$PIDFILE"

if [ ! -s "$KEYFILE" ]; then
    log "No key yet - run Generate Default Key"
    exit 1
fi

if ! mkdir -p "$RECV_DIR"; then
    log "Cannot create $RECV_DIR"
    exit 1
fi

chmod +x "$HANDLER"

# Clear stale address and QR so we only use the fresh ones
rm -f "$ADDRFILE" "$QR_IMAGE"

TAILCAT_ADDR_FILE="$ADDRFILE" nohup "$TAILCAT" serve \
    --files="$RECV_DIR:rw" files exec -- "$HANDLER" \
    >> "$LOG" 2>&1 < /dev/null &
PID=$!
echo "$PID" > "$PIDFILE"

log "Waiting for address..."

COUNT=0
while [ "$COUNT" -lt 30 ]; do
    if ! kill -0 "$PID" 2>/dev/null; then
        log "Tailcat failed to start"
        show_wrapped "$(tail -n 5 "$LOG")"
        rm -f "$PIDFILE"
        exit 1
    fi

    if [ -s "$ADDRFILE" ]; then
        ADDR=$(tr -d '\r\n' < "$ADDRFILE")
        echo "$ADDR" > "$SECRET"
        log "Address saved: $SECRET"

        make_qr "$ADDR"      # failure here is logged but doesn't stop Tailcat

        log "Receiving into $RECV_DIR"
        show_wrapped "$ADDR"
        exit 0
    fi

    sleep 1
    COUNT=$((COUNT + 1))
done

log "Address not detected"
show_wrapped "$(tail -n 5 "$LOG")"
exit 1