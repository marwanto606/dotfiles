#!/bin/bash

NOTIFY_ID_FILE="${XDG_RUNTIME_DIR:-/tmp}/volume-notify.id"

case "$1" in
    up)
        pactl set-sink-volume @DEFAULT_SINK@ +5% >/dev/null 2>&1
        ;;

    down)
        pactl set-sink-volume @DEFAULT_SINK@ -5% >/dev/null 2>&1
        ;;

    mute)
        pactl set-sink-mute @DEFAULT_SINK@ toggle >/dev/null 2>&1
        ;;
esac

# Ambil status mute
MUTE=$(pactl get-sink-mute @DEFAULT_SINK@)

if echo "$MUTE" | grep -q "yes"; then
    ICON="audio-volume-muted"
    TITLE="Volume"
    BODY="Muted"
    VALUE=0
else
    ICON="audio-volume-high"
    TITLE="Volume"

    VOLUME=$(pactl get-sink-volume @DEFAULT_SINK@ \
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

# Kirim notification dan replace notification sebelumnya
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
