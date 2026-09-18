#!/bin/bash

# ==========================================================
# PAVUCONTROL SINGLE SCRIPT
#
# Usage:
#   pavucontrol.sh speaker
#   pavucontrol.sh mic
# ==========================================================

case "$1" in
    speaker)
        TAB=3
        ;;
    mic)
        TAB=4
        ;;
    *)
        echo "Usage: $0 {speaker|mic}"
        exit 1
        ;;
esac


# ==========================================================
# Tutup Pavucontrol lama
# ==========================================================

pkill -x pavucontrol 2>/dev/null
sleep 0.3


# ==========================================================
# Buka Pavucontrol
# ==========================================================

pavucontrol --tab="$TAB" >/dev/null 2>&1 &


# ==========================================================
# Tunggu window benar-benar muncul
# ==========================================================

for i in {1..50}; do
    WIN_ID=$(xdotool search --onlyvisible --class pavucontrol 2>/dev/null | head -n 1)

    if [ -n "$WIN_ID" ]; then
        break
    fi

    sleep 0.1
done


# Kalau window tidak ditemukan, selesai
[ -z "$WIN_ID" ] && exit 1


# ==========================================================
# Auto close ketika fokus pindah
# ==========================================================

(
    # Tunggu sampai Pavucontrol mendapatkan fokus terlebih dahulu
    while true; do
        FOCUSED=$(xdotool getactivewindow 2>/dev/null)

        if [ "$FOCUSED" = "$WIN_ID" ]; then
            break
        fi

        # Kalau Pavucontrol sudah mati, keluar
        if ! pgrep -x pavucontrol >/dev/null; then
            exit 0
        fi

        sleep 0.1
    done


    # Setelah Pavucontrol aktif, pantau fokus
    while pgrep -x pavucontrol >/dev/null; do

        FOCUSED=$(xdotool getactivewindow 2>/dev/null)

        if [ "$FOCUSED" != "$WIN_ID" ]; then
            pkill -x pavucontrol 2>/dev/null
            break
        fi

        sleep 0.15
    done
) &