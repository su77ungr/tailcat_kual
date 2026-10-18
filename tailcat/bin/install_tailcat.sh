#!/bin/sh
# shellcheck source=paths.sh
. /mnt/us/extensions/tailcat/bin/paths.sh

mkdir -p "$BIN" || exit 1

URL="https://github.com/tailscale/tailcat/releases/download/v${TAILCAT_VERSION}/tailcat_${TAILCAT_VERSION}_linux_armv7.tar.gz"

ARCHIVE="/mnt/us/tailcat_${TAILCAT_VERSION}.tar.gz"
TMP="/mnt/us/tailcat_install_tmp"
LOG="$BIN/install_tailcat.log"
QR_SCRIPT="$BIN/install_qrencode.sh"
QR_WORK="/tmp/kindle-qrencode-setup"

log() {
    echo "$1" >> "$LOG"
    eips 0 22 "$(printf '%-50s' "$1")" 2>/dev/null
}

echo "[$(date)] Installing Tailcat..." > "$LOG"
log "Downloading Tailcat..."

if ! wget -O "$ARCHIVE" "$URL" >> "$LOG" 2>&1; then
    log "Download failed"
    rm -f "$ARCHIVE"
    exit 1
fi

rm -rf "$TMP"
mkdir -p "$TMP" || exit 1

if ! tar -xzf "$ARCHIVE" -C "$TMP" >> "$LOG" 2>&1; then
    log "Extraction failed"
    rm -rf "$TMP"
    rm -f "$ARCHIVE"
    exit 1
fi

TAILCAT_BIN=$(find "$TMP" -type f -name tailcat | head -n 1)

if [ -z "$TAILCAT_BIN" ] || [ ! -f "$TAILCAT_BIN" ]; then
    log "Tailcat binary not found in archive"
    rm -rf "$TMP"
    rm -f "$ARCHIVE"
    exit 1
fi

if ! cp "$TAILCAT_BIN" "$TAILCAT"; then
    log "Failed to install binary"
    rm -rf "$TMP"
    rm -f "$ARCHIVE"
    exit 1
fi

chmod 755 "$TAILCAT"

if [ ! -x "$TAILCAT" ]; then
    log "Tailcat binary is not executable"
    rm -rf "$TMP"
    rm -f "$ARCHIVE"
    exit 1
fi

rm -rf "$TMP"
rm -f "$ARCHIVE"

log "Tailcat installed successfully"

# ----------------------------------------------------------------------
# qrencode (separate script)
# ----------------------------------------------------------------------
if [ ! -f "$QR_SCRIPT" ]; then
    log "install_qrencode.sh not found"
    exit 1
fi

log "Checking qrencode..."

# Clear stale work dir from any previous run (dpkg-deb -x won't overwrite)
rm -rf "$QR_WORK"

if ! sh "$QR_SCRIPT" >> "$LOG" 2>&1; then
    log "qrencode install failed (see log)"
    rm -rf "$QR_WORK"
    exit 1
fi

rm -rf "$QR_WORK"

log "qrencode ready"
exit 0