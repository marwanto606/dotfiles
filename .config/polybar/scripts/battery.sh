#!/usr/bin/env bash

COLOR_TEAL="#008080"
COLOR_FUCHSIA="#D946EF"
COLOR_FG="#FFFFFF"

# Cek apakah ada baterai di sistem
BAT_PATH=""
for b in /sys/class/power_supply/BAT*; do
    if [ -d "$b" ]; then
        BAT_PATH="$b"
        break
    fi
done

# Cek status adapter AC
AC_ONLINE=0
for ac in /sys/class/power_supply/A*/online; do
    if [ -f "$ac" ] && [ "$(cat "$ac" 2>/dev/null)" = "1" ]; then
        AC_ONLINE=1
        break
    fi
done

# JIKA TIDAK ADA BATERAI SAMA SEKALI (MURNI AC ONLY)
if [ -z "$BAT_PATH" ]; then
    echo "%{F$COLOR_TEAL}%{F-} %{F$COLOR_FG}AC Mode%{F-}"
    exit 0
fi

# Baca kapasitas & status dengan batas timeout 1 detik (Anti Freeze)
CAPACITY=$(timeout 1s cat "$BAT_PATH/capacity" 2>/dev/null || echo "0")
STATUS=$(timeout 1s cat "$BAT_PATH/status" 2>/dev/null || echo "Unknown")

# LOGIKA DETEKSI AC / CAS / BATERAI
if [ "$STATUS" = "Charging" ]; then
    ICON=""
    ICON_COLOR="$COLOR_TEAL"
    TEXT="${CAPACITY}%"
elif [ "$STATUS" = "Full" ] || [ "$STATUS" = "Not charging" ] || [ "$AC_ONLINE" -eq 1 ]; then
    # Charger tertancap dan baterai tidak sedang mengisi (AC Only / Standby)
    ICON=""
    ICON_COLOR="$COLOR_TEAL"
    TEXT="AC ${CAPACITY}%"
else
    # Murni memakai baterai (Discharging)
    ICON_COLOR="$COLOR_FUCHSIA"
    TEXT="${CAPACITY}%"
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

echo "%{F$ICON_COLOR}$ICON%{F-} %{F$COLOR_FG}$TEXT%{F-}"