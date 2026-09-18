#!/bin/bash

# 1. Toggle: Tutup jika sudah terbuka
if pgrep -x htop >/dev/null; then pkill -x htop; exit 0; fi

# 2. Setup Config
CONFIG_DIR="$HOME/.config/htop"
CUSTOM_HTOPRC="$CONFIG_DIR/htoprc_taskmanager"
mkdir -p "$CONFIG_DIR"
[ ! -f "$CUSTOM_HTOPRC" ] && cp "$CONFIG_DIR/htoprc" "$CUSTOM_HTOPRC" 2>/dev/null

# 3. Buka Htop
env HTOPRC="$CUSTOM_HTOPRC" xfce4-terminal --disable-server --class="HtopTaskManager" --title="Task Manager" --command="htop --sort-key PERCENT_MEM" &

# 4. Cari Window ID
WIN_ID=""
for i in {1..20}; do
    WIN_ID=$(xdotool search --onlyvisible --class "HtopTaskManager" 2>/dev/null | tail -n 1)
    [ -n "$WIN_ID" ] && break; sleep 0.1
done
[ -z "$WIN_ID" ] && exit 1

# 5. Pemantau Auto-Close & Escape (Sangat Simpel dengan xinput)
(
    # Pantau klik mouse (RawButtonPress) dan tombol Esc (keycode 9)
    xinput test-xi2 --root | grep -E --line-buffered "RawButtonPress|detail: 9" | while read -r event; do
        
        # Berhenti memantau jika htop sudah tertutup
        ! pgrep -x htop >/dev/null && break
        
        ACTIVE=$(xdotool getactivewindow 2>/dev/null)

        # Jika tombol Escape ditekan saat htop aktif
        if [[ "$event" == *"detail: 9"* ]] && [ "$ACTIVE" == "$WIN_ID" ]; then
            pkill -x htop; break
        fi

        # Jika Mouse di-klik
        if [[ "$event" == *"RawButtonPress"* ]]; then
            # Cek apakah klik terjadi di area luar jendela htop
            eval $(xdotool getmouselocation --shell 2>/dev/null)
            eval $(xdotool getwindowgeometry --shell "$WIN_ID" 2>/dev/null | sed 's/^X=/W_X=/; s/^Y=/W_Y=/; s/^WIDTH=/W_W=/; s/^HEIGHT=/W_H=/')
            
            if (( X < W_X || X > W_X + W_W || Y < W_Y || Y > W_Y + W_H )); then
                pkill -x htop; break
            fi
        fi
    done
) &