# shellcheck shell=sh
# shellcheck disable=SC2034 

EXT=/mnt/us/extensions/tailcat
BIN=$EXT/bin

# tailcat
TAILCAT=$BIN/tailcat
TAILCAT_VERSION=0.7.0
KEYFILE=$BIN/.config/tailcat/keys/default.private.json
ADDRFILE=$BIN/tailcat.address
PIDFILE=$BIN/tailcat.pid
HANDLER=$BIN/tailcat_handler.sh

# receive dir
RECVDIR_CONF=$BIN/recvdir.conf
DEFAULT_RECV_DIR=$EXT/inbox

# qrencode
QR_DIR=/mnt/us/qrencode
QR=$QR_DIR/run-qrencode
QR_IMAGE=/mnt/us/tailcat_qr.png

# saved address
SECRET=/mnt/us/tailcat_secret.txt

# default log (scripts override LOG after sourcing if they want their own)
LOG=$BIN/tailcat.log