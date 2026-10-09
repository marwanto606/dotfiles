#!/bin/bash

# Tentukan Tab (Default 3 = Output, mic 4 = Input)
TAB=$([ "$1" == "mic" ] && echo 4 || echo 3)

# 1. Toggle: Tutup jika sudah terbuka
if pgrep -x pavucontrol >/dev/null; then 
    pkill -x pavucontrol
    exit 0
fi

# 2. Buka Pavucontrol
GTK_THEME=Layan-Dark:dark pavucontrol --tab="$TAB" >/dev/null 2>&1 &

# 3. Cari Window ID pavucontrol (Gunakan [Pp] agar kebal huruf besar/kecil)
WIN_ID=""
for _ in {1..30}; do
    WIN_ID=$(xdotool search --onlyvisible --class [Pp]avucontrol 2>/dev/null | head -n 1)
    [ -n "$WIN_ID" ] && break
    sleep 0.1
done

# Jika gagal mendapatkan ID jendela, batalkan
[ -z "$WIN_ID" ] && exit 1

# 4. Pemantau Auto-Close (Klik Luar, Feh Wallpaper, Polybar, & Escape)
(
    # Gunakan stdbuf -oL agar output stream tidak tertahan di buffer pipe Parrot OS
    stdbuf -oL xinput test-xi2 --root 2>/dev/null | grep -E --line-buffered "RawButtonPress|detail: 9" | while read -r event; do
        
        # Hentikan listener jika pavucontrol sudah tertutup
        ! pgrep -x pavucontrol >/dev/null && break

        # A. TOMBOL ESCAPE (detail: 9)
        # Langsung tutup pavucontrol saat tombol Esc ditekan
        if [[ "$event" == *"detail: 9"* ]]; then
            pkill -x pavucontrol
            break
        fi

        # B. KLIK MOUSE DI LUAR AREA (RawButtonPress)
        if [[ "$event" == *"RawButtonPress"* ]]; then
            # Ambil koordinat kursor mouse saat ini
            eval "$(xdotool getmouselocation --shell 2>/dev/null)"
            
            # Ambil koordinat dan dimensi kotak pavucontrol
            eval "$(xdotool getwindowgeometry --shell "$WIN_ID" 2>/dev/null | sed 's/^X=/W_X=/; s/^Y=/W_Y=/; s/^WIDTH=/W_W=/; s/^HEIGHT=/W_H=/')"
            
            # Jika posisi klik berada DI LUAR kotak jendela pavucontrol:
            # (Berlaku untuk wallpaper feh, panel Polybar, maupun jendela app lain)
            if [ -n "$W_X" ] && [ -n "$W_W" ]; then
                if (( X < W_X || X > W_X + W_W || Y < W_Y || Y > W_Y + W_H )); then
                    pkill -x pavucontrol
                    break
                fi
            fi
        fi
    done
) &