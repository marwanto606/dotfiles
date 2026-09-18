#!/bin/bash

# Tentukan Tab
TAB=$([ "$1" == "mic" ] && echo 4 || echo 3)

# 1. Toggle: Tutup jika sudah terbuka
if pgrep -x pavucontrol >/dev/null; then pkill -x pavucontrol; exit 0; fi

# 2. Buka Pavucontrol
pavucontrol --tab="$TAB" >/dev/null 2>&1 &

# 3. Cari Window ID
WIN_ID=""
for i in {1..20}; do
    WIN_ID=$(xdotool search --onlyvisible --class pavucontrol 2>/dev/null | head -n 1)
    [ -n "$WIN_ID" ] && break; sleep 0.1
done
[ -z "$WIN_ID" ] && exit 1

# 4. Pemantau Auto-Close & Escape (Sangat Simpel dengan xinput)
(
    xinput test-xi2 --root | grep -E --line-buffered "RawButtonPress|detail: 9" | while read -r event; do
        
        ! pgrep -x pavucontrol >/dev/null && break
        
        ACTIVE=$(xdotool getactivewindow 2>/dev/null)

        # Jika tombol Escape ditekan saat pavucontrol aktif
        if [[ "$event" == *"detail: 9"* ]] && [ "$ACTIVE" == "$WIN_ID" ]; then
            pkill -x pavucontrol; break
        fi

        # Jika Mouse di-klik
        if [[ "$event" == *"RawButtonPress"* ]]; then
            # Cek apakah klik terjadi di area luar jendela pavucontrol
            eval $(xdotool getmouselocation --shell 2>/dev/null)
            eval $(xdotool getwindowgeometry --shell "$WIN_ID" 2>/dev/null | sed 's/^X=/W_X=/; s/^Y=/W_Y=/; s/^WIDTH=/W_W=/; s/^HEIGHT=/W_H=/')
            
            if (( X < W_X || X > W_X + W_W || Y < W_Y || Y > W_Y + W_H )); then
                pkill -x pavucontrol; break
            fi
        fi
    done
) &