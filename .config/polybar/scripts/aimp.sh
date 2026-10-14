#!/usr/bin/env bash

# ==============================================================
# 1. KONTROL DARI SXHKD (JIKA DIBERIKAN ARGUMEN)
# ==============================================================
ACTION="$1"

if [ -n "$ACTION" ]; then
    case "$ACTION" in
        play-pause|toggle)
            # Jika AIMP belum menyala, buka AIMP dan tunggu hingga siap
            if ! playerctl --player=AIMP status > /dev/null 2>&1; then
                aimp > /dev/null 2>&1 &
                
                # Loop maksimal 3 detik menunggu D-Bus MPRIS AIMP siap
                for i in {1..15}; do
                    sleep 0.2
                    if playerctl --player=AIMP status > /dev/null 2>&1; then
                        playerctl --player=AIMP play 2>/dev/null
                        break
                    fi
                done
                exit 0
            fi
            playerctl --player=AIMP play-pause
            ;;
        next)
            playerctl --player=AIMP next 2>/dev/null
            ;;
        prev|previous)
            playerctl --player=AIMP previous 2>/dev/null
            ;;
    esac
    exit 0
fi

# ==============================================================
# 2. OUTPUT DISPLAY POLYBAR (JIKA TANPA ARGUMEN)
# ==============================================================

# Lokasi file config Polybar
CONFIG_FILE="$HOME/.config/polybar/config.ini"
[ ! -f "$CONFIG_FILE" ] && CONFIG_FILE="$HOME/.config/polybar/config"

get_poly_color() {
    grep -m 1 "^[[:space:]]*$1[[:space:]]*=" "$CONFIG_FILE" 2>/dev/null | cut -d'=' -f2 | tr -d ' "' | cut -d';' -f1 | xargs
}

TEAL=$(get_poly_color "teal")
FUCHSIA=$(get_poly_color "fuchsia")
PURPLE=$(get_poly_color "purple")
DISABLED=$(get_poly_color "disabled")
FOREGROUND=$(get_poly_color "foreground")

TEAL="${TEAL:-#008080}"
FUCHSIA="${FUCHSIA:-#D946EF}"
PURPLE="${PURPLE:-#A855F7}"
DISABLED="${DISABLED:-#475569}"
FOREGROUND="${FOREGROUND:-#FFFFFF}"

F_ICON="%{T3}"
F_END="%{T-}"

STATUS=$(playerctl --player=AIMP status 2>/dev/null)

if [ "$STATUS" = "Playing" ] || [ "$STATUS" = "Paused" ]; then
    if [ "$STATUS" = "Playing" ]; then
        PLAY_ICON="%{F$TEAL}"
    else
        PLAY_ICON="%{F$FUCHSIA}"
    fi

    PREV_BTN="%{A1:playerctl --player=AIMP previous:}%{A}"
    PLAY_BTN="%{A1:playerctl --player=AIMP play-pause:}${PLAY_ICON}%{A}"
    NEXT_BTN="%{A1:playerctl --player=AIMP next:}%{A}"

    echo "${F_ICON}%{F$FOREGROUND}$PREV_BTN  $PLAY_BTN  %{F$FOREGROUND}$NEXT_BTN%{F-}${F_END}"
else
    # Klik kiri saat offline meluncurkan AIMP lewat logika script yang baru
    echo "${F_ICON}%{F$DISABLED}%{A1:~/.config/polybar/scripts/aimp.sh play-pause:}%{A}%{F-}${F_END}"
fi