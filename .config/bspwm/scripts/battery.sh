#!/usr/bin/env bash

# ==========================================================
# MASUKKAN KODE HEX WARNA ANDA DI SINI
# (Lihat kode hex di bagian [colors] pada config Polybar Anda)
# ==========================================================
COLOR_TEAL="#008080"      # Ganti dengan kode warna teal Anda (misal: #00b4d8)
COLOR_FUCHSIA="#D946EF"   # Ganti dengan kode warna fuchsia Anda (misal: #e040fb)
COLOR_FG="#FFFFFF"        # Ganti dengan kode warna foreground Anda (misal: #ffffff)

# Cari folder baterai di sistem
BAT_PATH=$(find /sys/class/power_supply/ -maxdepth 1 -name "BAT*" | head -n 1)

if [ -z "$BAT_PATH" ]; then
    echo "%{F$COLOR_TEAL}%{F-}%{F$COLOR_FG}AC%{F-}"
    exit 0
fi

CAPACITY=$(cat "$BAT_PATH/capacity" 2>/dev/null || echo "0")
STATUS=$(cat "$BAT_PATH/status" 2>/dev/null || echo "Unknown")

if [ "$STATUS" = "Charging" ]; then
    ICON=""
    ICON_COLOR="$COLOR_TEAL"
elif [ "$STATUS" = "Full" ] || [ "$STATUS" = "Not charging" ]; then
    ICON=""
    ICON_COLOR="$COLOR_TEAL"
else
    # Sedang memakai baterai (Discharging)
    ICON_COLOR="$COLOR_FUCHSIA"
    if [ "$CAPACITY" -ge 90 ]; then
        ICON=""
    elif [ "$CAPACITY" -ge 60 ]; then
        ICON=""
    elif [ "$CAPACITY" -ge 35 ]; then
        ICON=""
    elif [ "$CAPACITY" -ge 15 ]; then
        ICON=""
    else
        ICON=""
    fi
fi

# Cetak icon dan persentase
echo "%{F$ICON_COLOR}$ICON%{F-} %{F$COLOR_FG}${CAPACITY}%%{F-}"