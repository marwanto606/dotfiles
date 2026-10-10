#!/bin/bash

TAB=$([ "$1" == "mic" ] && echo 4 || echo 3)

# 1. Toggle: Tutup jika sudah berjalan
if pgrep -x pavucontrol >/dev/null; then 
    pkill -x pavucontrol
    exit 0
fi

# 2. Buka Pavucontrol
GTK_THEME=Layan-Dark:dark pavucontrol --tab="$TAB" >/dev/null 2>&1 &

# 3. Cari Window ID pavucontrol
WIN_ID=""
for _ in {1..40}; do
    WIN_ID=$(xdotool search --onlyvisible --class pavucontrol 2>/dev/null | tail -n 1)
    [ -n "$WIN_ID" ] && break
    sleep 0.05
done

[ -z "$WIN_ID" ] && exit 1

# 4. Listener Auto-Close
(
    # Listener 1: Tangkap saat fokus pindah ke jendela lain via bspwm
    bspc subscribe node_focus 2>/dev/null | while read -r _; do
        pkill -x pavucontrol
        break
    done
) &
SUB_PID=$!

(
    # Listener 2: Tangkap klik di wallpaper/polybar dan tombol Escape
    # Menangkap ButtonPress biasa maupun Raw, serta detail: 9 (Esc)
    xinput test-xi2 --root 2>/dev/null | grep -E --line-buffered "(ButtonPress|detail: 9)" | while read -r event; do
        
        # Jika pavucontrol sudah mati, hentikan listener
        if ! pgrep -x pavucontrol >/dev/null; then
            kill $SUB_PID 2>/dev/null
            break
        fi

        # A. Tombol Escape
        if [[ "$event" == *"detail: 9"* ]]; then
            pkill -x pavucontrol
            kill $SUB_PID 2>/dev/null
            break
        fi

        # B. Klik Mouse di Luar Jendela
        if [[ "$event" == *"ButtonPress"* ]]; then
            # Ambil koordinat mouse
            eval "$(xdotool getmouselocation --shell 2>/dev/null)"
            
            # Ambil koordinat kotak jendela pavucontrol
            eval "$(xwininfo -id "$WIN_ID" 2>/dev/null | awk '
                /Absolute upper-left X:/ {print "W_X=" $4}
                /Absolute upper-left Y:/ {print "W_Y=" $4}
                /Width:/ {print "W_W=" $2}
                /Height:/ {print "W_H=" $2}
            ')"

            if [ -n "$W_X" ] && [ -n "$W_W" ]; then
                if (( X < W_X || X > W_X + W_W || Y < W_Y || Y > W_Y + W_H )); then
                    pkill -x pavucontrol
                    kill $SUB_PID 2>/dev/null
                    break
                fi
            fi
        fi
    done
) &