#!/bin/bash

# 1. Toggle: Tutup jika sudah terbuka (tutup lewat bspwm agar terminal & htop ikut mati)
EXIST_ID=$(xdotool search --onlyvisible --class "HtopTaskManager" 2>/dev/null | tail -n 1)
if [ -n "$EXIST_ID" ]; then
    bspc node "$EXIST_ID" --close
    pkill -f "htop --sort-key" 2>/dev/null
    exit 0
fi

# 2. Setup Config
CONFIG_DIR="$HOME/.config/htop"
CUSTOM_HTOPRC="$CONFIG_DIR/htoprc_taskmanager"
mkdir -p "$CONFIG_DIR"
[ ! -f "$CUSTOM_HTOPRC" ] && cp "$CONFIG_DIR/htoprc" "$CUSTOM_HTOPRC" 2>/dev/null

# 3. Buka Htop
env HTOPRC="$CUSTOM_HTOPRC" xfce4-terminal --disable-server --class="HtopTaskManager" --title="Task Manager" --command="htop --sort-key PERCENT_MEM" >/dev/null 2>&1 &

# 4. Cari Window ID
WIN_ID=""
for _ in {1..30}; do
    WIN_ID=$(xdotool search --onlyvisible --class "HtopTaskManager" 2>/dev/null | tail -n 1)
    [ -n "$WIN_ID" ] && break
    sleep 0.05
done
[ -z "$WIN_ID" ] && exit 1

# Fungsi untuk menutup jendela dengan bersih
close_taskmanager() {
    bspc node "$WIN_ID" --close 2>/dev/null
    pkill -f "htop --sort-key" 2>/dev/null
}

# 5. Pemantau Auto-Close
(
    # Listener 1: Tangkap jika fokus pindah ke jendela/workspace lain di bspwm
    bspc subscribe node_focus 2>/dev/null | while read -r _; do
        close_taskmanager
        break
    done
) &
SUB_PID=$!

(
    # Listener 2: Tangkap klik di luar area (wallpaper/polybar) dan tombol Escape (detail: 9)
    xinput test-xi2 --root 2>/dev/null | grep -E --line-buffered "(ButtonPress|detail: 9)" | while read -r event; do
        
        # Hentikan listener jika jendela sudah tidak ada
        if ! xdotool getwindowname "$WIN_ID" >/dev/null 2>&1; then
            kill $SUB_PID 2>/dev/null
            break
        fi

        # A. Tombol Escape
        if [[ "$event" == *"detail: 9"* ]]; then
            ACTIVE=$(xdotool getactivewindow 2>/dev/null)
            if [ "$ACTIVE" = "$WIN_ID" ]; then
                close_taskmanager
                kill $SUB_PID 2>/dev/null
                break
            fi
        fi

        # B. Klik di Luar Jendela
        if [[ "$event" == *"ButtonPress"* ]]; then
            # Ambil koordinat kursor mouse
            eval "$(xdotool getmouselocation --shell 2>/dev/null)"
            
            # Ambil geometri jendela yang akurat via xwininfo
            eval "$(xwininfo -id "$WIN_ID" 2>/dev/null | awk '
                /Absolute upper-left X:/ {print "W_X=" $4}
                /Absolute upper-left Y:/ {print "W_Y=" $4}
                /Width:/ {print "W_W=" $2}
                /Height:/ {print "W_H=" $2}
            ')"

            if [ -n "$W_X" ] && [ -n "$W_W" ]; then
                if (( X < W_X || X > W_X + W_W || Y < W_Y || Y > W_Y + W_H )); then
                    close_taskmanager
                    kill $SUB_PID 2>/dev/null
                    break
                fi
            fi
        fi
    done
) &