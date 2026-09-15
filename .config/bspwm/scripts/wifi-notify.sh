#!/bin/bash

NOTIFY_ID_FILE="${XDG_RUNTIME_DIR:-/tmp}/wifi-notify.id"

# Ambil status Wi-Fi sekarang
STATUS=$(nmcli radio wifi)

# Toggle Wi-Fi
if [ "$STATUS" = "enabled" ]; then
    nmcli radio wifi off >/dev/null 2>&1
else
    nmcli radio wifi on >/dev/null 2>&1
fi

# Tunggu NetworkManager memperbarui status
sleep 0.2

STATUS=$(nmcli radio wifi)

if [ "$STATUS" = "enabled" ]; then
    ICON="network-wireless"
    TITLE="Wi-Fi"
    BODY="Enabled"
else
    ICON="network-wireless-offline"
    TITLE="Wi-Fi"
    BODY="Disabled"
fi

# Ambil notification ID sebelumnya
OLD_ID=""

if [ -f "$NOTIFY_ID_FILE" ]; then
    OLD_ID=$(cat "$NOTIFY_ID_FILE")
fi

# Kirim notification tanpa slider
if [ -n "$OLD_ID" ]; then
    NEW_ID=$(notify-send \
        -i "$ICON" \
        -t 1500 \
        -r "$OLD_ID" \
        -p \
        "$TITLE" \
        "$BODY")
else
    NEW_ID=$(notify-send \
        -i "$ICON" \
        -t 1500 \
        -p \
        "$TITLE" \
        "$BODY")
fi

echo "$NEW_ID" > "$NOTIFY_ID_FILE"