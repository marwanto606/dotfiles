#!/bin/bash

NOTIFY_ID_FILE="${XDG_RUNTIME_DIR:-/tmp}/brightness-notify.id"

case "$1" in
    up)
        brightnessctl set +5% >/dev/null 2>&1
        ;;

    down)
        brightnessctl set 5%- >/dev/null 2>&1
        ;;
esac

# Ambil brightness sekarang
CURRENT=$(brightnessctl get)
MAX=$(brightnessctl max)

PERCENT=$((CURRENT * 100 / MAX))

# Pilih icon berdasarkan tingkat brightness
if [ "$PERCENT" -le 20 ]; then
    ICON="weather-clear-night"
elif [ "$PERCENT" -le 50 ]; then
    ICON="weather-clear"
else
    ICON="weather-clear"
fi

TITLE="Brightness"
BODY="${PERCENT}%"

# Ambil notification ID sebelumnya
OLD_ID=""

if [ -f "$NOTIFY_ID_FILE" ]; then
    OLD_ID=$(cat "$NOTIFY_ID_FILE")
fi

# Replace notification sebelumnya
if [ -n "$OLD_ID" ]; then
    NEW_ID=$(notify-send \
        -i "$ICON" \
        -h int:value:"$PERCENT" \
        -t 1500 \
        -r "$OLD_ID" \
        -p \
        "$TITLE" \
        "$BODY")
else
    NEW_ID=$(notify-send \
        -i "$ICON" \
        -h int:value:"$PERCENT" \
        -t 1500 \
        -p \
        "$TITLE" \
        "$BODY")
fi

echo "$NEW_ID" > "$NOTIFY_ID_FILE"