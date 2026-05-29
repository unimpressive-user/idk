#!/bin/bash
set -euo pipefail

VRC_LOG_DIR="/mnt/WD_BLACK_2TB/SteamLibrary/steamapps/compatdata/438100/pfx/drive_c/users/steamuser/AppData/LocalLow/VRChat/VRChat/"
LIST_LINK="https://raw.githubusercontent.com/Furry-Hideout1/moderator-whitelist/refs/heads/main/moderators.txt"

TMP_LIST=$(mktemp)
SEEN=$(mktemp)

rmtemp() {
    rm -f "$TMP_LIST" "$SEEN"
}

trap rmtemp EXIT INT TERM

VRC_LOG_FILE=$(ls -t "$VRC_LOG_DIR"output_log_*.txt | head -n 1)

if [[ -z "$VRC_LOG_FILE" ]]; then
    echo "No logfile found in $VRC_LOG_DIR"
    exit 1
fi

if ! curl -fsSL "$LIST_LINK" -o "$TMP_LIST"; then
    echo "Failed to download moderator list"
    exit 1
fi

if [[ ! -s "$TMP_LIST" ]]; then
    echo "Moderator list is empty"
    exit 1
fi

while true; do

    if [[ -s "$SEEN" ]]; then
        MATCH=$(grep -Ff "$TMP_LIST" "$VRC_LOG_FILE" | grep -Fvf "$SEEN" || true)
    else
        MATCH=$(grep -Ff "$TMP_LIST" "$VRC_LOG_FILE" || true)
    fi

    if [[ -n "$MATCH" ]]; then
        echo "$MATCH" >> "$SEEN"
        echo "$MATCH"
    else
        echo "No match found"
    fi

    sleep 1
done

