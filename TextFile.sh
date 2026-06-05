#!/bin/bash
set -euo pipefail

VRC_LOG_DIR="/mnt/WD_BLACK_2TB/SteamLibrary/steamapps/compatdata/438100/pfx/drive_c/users/steamuser/AppData/LocalLow/VRChat/VRChat/"
LIST_LINK="https://raw.githubusercontent.com/Furry-Hideout1/moderator-whitelist/refs/heads/main/moderators.txt"
HIDE="Entering Room: \| Joining or Creating Room:"
TMP_LIST=$(mktemp)

boo() {
    notify-send \
        --transient "$MATCH" \
        --icon=dialog-warning \
        --expire-time=5000
    pw-play untitled.opus
}

rmtemp() {
    rm -f "$TMP_LIST"
    echo "TMP wiped"
}

trap rmtemp EXIT INT TERM

VRC_LOG_FILE=$(ls -t "$VRC_LOG_DIR"output_log_*.txt | head -n 1)

if [[ -z "$VRC_LOG_FILE" ]]; then
    echo "No logfile found in $VRC_LOG_DIR"
    exit 1
fi

if ! curl -fsSL "$LIST_LINK" -o "$TMP_LIST"; then
    echo "Failed to download list"
    exit 1
fi

if [[ ! -s "$TMP_LIST" ]]; then
    echo "List is empty"
    exit 1
fi

echo "Log file in use: $VRC_LOG_FILE"
echo "$HIDE"
tail -fn0 "$VRC_LOG_FILE" \
    | grep --line-buffered -Ff "$TMP_LIST" \
    | grep --line-buffered -v "$HIDE" \
    | while read -r MATCH ; do
        echo "$MATCH"
        boo
        done
