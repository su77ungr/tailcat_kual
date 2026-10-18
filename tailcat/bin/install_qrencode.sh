#!/bin/sh
# shellcheck source=paths.sh
. /mnt/us/extensions/tailcat/bin/paths.sh
set -eu

BASE=$QR_DIR
WORK="/tmp/kindle-qrencode-setup"
ARCH="arm-linux-gnueabi"

QR_URL="https://archive.debian.org/debian/pool/main/q/qrencode"
PNG_URL="https://archive.debian.org/debian/pool/main/libp/libpng"

QR_DEB="qrencode_3.4.3-1_armel.deb"
LIB_DEB="libqrencode3_3.4.3-1_armel.deb"
PNG_DEB="libpng12-0_1.2.50-2+deb8u3_armel.deb"

echo "========================================"
echo " Kindle qrencode setup"
echo "========================================"

# Check required tools
for cmd in wget dpkg-deb cp chmod mkdir find; do
    if ! command -v "$cmd" >/dev/null 2>&1; then
        echo "ERROR: Required command not found: $cmd"
        exit 1
    fi
done

# Check architecture
echo
echo "[1/9] Checking Kindle architecture..."
uname -m

# Prepare directories
echo
echo "[2/9] Preparing directories..."

mkdir -p "$BASE"
mkdir -p "$WORK"
mkdir -p "$BASE/lib/$ARCH"
mkdir -p "$BASE/png/lib/$ARCH"

cd "$WORK"

# Download packages
echo
echo "[3/9] Downloading Debian packages..."

wget -O "$QR_DEB" "$QR_URL/$QR_DEB"
wget -O "$LIB_DEB" "$QR_URL/$LIB_DEB"
wget -O "$PNG_DEB" "$PNG_URL/$PNG_DEB"

# Extract the executable
echo
echo "[4/9] Extracting qrencode..."

mkdir -p "$WORK/qr"
dpkg-deb -x "$QR_DEB" "$WORK/qr"

if [ ! -f "$WORK/qr/usr/bin/qrencode" ]; then
    echo "ERROR: qrencode executable was not extracted."
    exit 1
fi

cp "$WORK/qr/usr/bin/qrencode" "$BASE/qrencode"
chmod 755 "$BASE/qrencode"

# Extract QR library
echo
echo "[5/9] Extracting libqrencode..."

mkdir -p "$WORK/libqr"
dpkg-deb -x "$LIB_DEB" "$WORK/libqr" || {
    echo "Package extraction reported an error; checking extracted files..."
}

QR_LIB="$(find "$WORK/libqr" -name 'libqrencode.so.3.4.3' -print | head -n 1)"

if [ -z "$QR_LIB" ] || [ ! -f "$QR_LIB" ]; then
    echo "ERROR: libqrencode.so.3.4.3 was not found."
    exit 1
fi

cp "$QR_LIB" "$BASE/lib/$ARCH/libqrencode.so.3"
cp "$QR_LIB" "$BASE/lib/$ARCH/libqrencode.so.3.4.3"

# Extract PNG library
echo
echo "[6/9] Extracting libpng..."

mkdir -p "$WORK/png"
dpkg-deb -x "$PNG_DEB" "$WORK/png"

PNG_LIB="$(find "$WORK/png" -name 'libpng12.so.0.50.0' -print | head -n 1)"

if [ -z "$PNG_LIB" ] || [ ! -f "$PNG_LIB" ]; then
    echo "ERROR: libpng12.so.0.50.0 was not found."
    exit 1
fi

cp "$PNG_LIB" "$BASE/png/lib/$ARCH/libpng12.so.0"
cp "$PNG_LIB" "$BASE/png/lib/$ARCH/libpng12.so.0.50.0"

# Create launcher
echo
echo "[7/9] Creating launcher..."

cat > "$BASE/run-qrencode" <<'LAUNCHER_EOF'
#!/bin/sh

BASE="/mnt/us/qrencode"

export LD_LIBRARY_PATH="$BASE/lib/arm-linux-gnueabi:$BASE/png/lib/arm-linux-gnueabi${LD_LIBRARY_PATH:+:$LD_LIBRARY_PATH}"

exec "$BASE/qrencode" "$@"
LAUNCHER_EOF

chmod 755 "$BASE/run-qrencode"

# Verify files
echo
echo "[8/9] Verifying installation..."

ls -l "$BASE/qrencode"
ls -l "$BASE/run-qrencode"
ls -l "$BASE/lib/$ARCH/"
ls -l "$BASE/png/lib/$ARCH/"

# Test terminal output
echo
echo "[9/9] Testing terminal QR generation..."

if "$BASE/run-qrencode" -t ANSI "Hello Kindle"; then
    echo
    echo "SUCCESS: Terminal QR generation works."
else
    echo
    echo "WARNING: Terminal test failed."
    echo "Check the missing-library error above."
    exit 1
fi

echo
echo "========================================"
echo " Setup completed successfully!"
echo "========================================"
echo
echo "Executable:"
echo "  $BASE/qrencode"
echo
echo "Generate a terminal QR code:"
echo "  $BASE/run-qrencode -t ANSI 'Hello Kindle'"
echo
echo "Generate a PNG:"
echo "  $BASE/run-qrencode -o $BASE/test.png 'Hello Kindle'"
echo