#!/bin/bash

NOTIFY_ID_FILE="${XDG_RUNTIME_DIR:-/tmp}/mic-notify.id"

# Toggle mic mute
pactl set-source-mute @DEFAULT_SOURCE@ toggle >/dev/null 2>&1

# Ambil status mute
MUTE=$(pactl get-source-mute @DEFAULT_SOURCE@)

if echo "$MUTE" | grep -q "yes"; then
    ICON="microphone-sensitivity-muted"
    TITLE="Microphone"
    BODY="Muted"
    VALUE=0
else
    ICON="microphone-sensitivity-high"
    TITLE="Microphone"

    VOLUME=$(pactl get-source-volume @DEFAULT_SOURCE@ \
        | head -1 \
        | grep -o '[0-9]\+%' \
        | head -1 \
        | tr -d '%')

    VALUE="$VOLUME"
    BODY="${VOLUME}%"
fi

# Ambil notification ID sebelumnya
OLD_ID=""
if [ -f "$NOTIFY_ID_FILE" ]; then
    OLD_ID=$(cat "$NOTIFY_ID_FILE")
fi

# Kirim notification
if [ -n "$OLD_ID" ]; then
    NEW_ID=$(notify-send \
        -i "$ICON" \
        -h int:value:"$VALUE" \
        -t 1500 \
        -r "$OLD_ID" \
        -p \
        "$TITLE" \
        "$BODY")
else
    NEW_ID=$(notify-send \
        -i "$ICON" \
        -h int:value:"$VALUE" \
        -t 1500 \
        -p \
        "$TITLE" \
        "$BODY")
fi

echo "$NEW_ID" > "$NOTIFY_ID_FILE"
