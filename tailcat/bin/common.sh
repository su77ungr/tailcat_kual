#!/bin/sh
BIN=/mnt/us/extensions/tailcat/bin
TAILCAT=$BIN/tailcat
ADDRFILE=$BIN/tailcat.address
SECRET=/mnt/us/tailcat_secret.txt
QR=/mnt/us/qrencode/run-qrencode
QR_IMAGE=/mnt/us/tailcat_qr.png
KEYFILE=$BIN/.config/tailcat/keys/default.private.json
WRAP=39          # characters per line
ROW=20           # first eips row used for output

export HOME="$BIN"
export XDG_CONFIG_HOME="$BIN/.config"   # make the key location explicit
mkdir -p "$XDG_CONFIG_HOME"
cd "$BIN" || exit 1

# Print text wrapped at $WRAP chars, to stdout and to the e-ink screen
show_wrapped() {
    row=$ROW
    printf '%s\n' "$1" | fold -w "$WRAP" | while IFS= read -r line; do
        echo "$line"
        eips 0 "$row" "$(printf "%-${WRAP}s" "$line")" 2>/dev/null
        row=$((row + 1))
    done
}

# Extract the address from tailcat output (file given as $1)
extract_addr() {
    A=$(sed -n \
        -e 's/.*Server listening with.*address[^:]*: *//p' \
        -e 's/.*Server listening with saved key "default": *//p' \
        -e 's/.*[Aa]ddress: *//p' "$1" | head -n 1 | tr -d '\r')
    if [ -z "$A" ]; then
        A=$(grep -Eio '(tailcat|https?)://[A-Za-z0-9._:/?&=%+~-]+' "$1" | head -n 1 | tr -d '\r')
    fi
    echo "$A"
}


# Show caption + address at the top, QR code near the bottom
show_qr() {
    [ -s "$QR_IMAGE" ] || { show_wrapped "No QR yet - run Start Tailcat"; return 1; }

    # Prefer FBInk if present (handles any PNG type, can align to the bottom)
    FBINK=$(command -v fbink 2>/dev/null)
    [ -x "$FBINK" ] || for p in /mnt/us/libkh/bin/fbink /mnt/us/koreader/fbink /mnt/us/usbnet/bin/fbink; do
        [ -x "$p" ] && FBINK=$p && break
    done

    # 1. Clear, then draw the text at the top
    eips -c 2>/dev/null
    eips 0 2 "$(printf "%-${WRAP}s" "Scan with your phone to get the address")" 2>/dev/null

    ADDR=$(tr -d '\r\n' < "$ADDRFILE" 2>/dev/null)
    if [ -n "$ADDR" ]; then
        ROW=4
        show_wrapped "$ADDR"
    fi

    # 2. Draw the QR at the bottom (no clear, so the text stays)
    if [ -x "$FBINK" ]; then
        "$FBINK" -g file="$QR_IMAGE",halign=CENTER,valign=BOTTOM 2>/dev/null && return 0
    fi
    eips -g "$QR_IMAGE" 2>/dev/null
    return 0
}
