#!/bin/bash

SCREENSHOT_DIR="$HOME/Pictures/Screenshots"

mkdir -p "$SCREENSHOT_DIR"

case "$1" in
    full)
        FILE="$SCREENSHOT_DIR/$(date +%Y-%m-%d-%H-%M-%S)-screenshot.png"

        if scrot "$FILE"; then
            notify-send \
                -i "camera-photo" \
                -t 2000 \
                "Screenshot" \
                "Saved: $(basename "$FILE")"
        fi
        ;;

    area)
        FILE="$SCREENSHOT_DIR/$(date +%Y-%m-%d-%H-%M-%S)-screenshot.png"

        if scrot -s "$FILE"; then
            notify-send \
                -i "camera-photo" \
                -t 2000 \
                "Screenshot" \
                "Saved: $(basename "$FILE")"
        fi
        ;;

    *)
        echo "Usage: $0 {full|area}"
        exit 1
        ;;
esac
