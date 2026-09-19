#!/bin/bash

# 1. Toggle: Jika kalender sudah terbuka, tutup
if pgrep -x gsimplecal >/dev/null; then 
    pkill -x gsimplecal
    exit 0
fi

# 2. Jalankan gsimplecal (posisi & ukuran ditangani bspwmrc)
gsimplecal &

# 3. Cari Window ID gsimplecal
WIN_ID=""
for i in {1..20}; do
    # Menggunakan classname sesuai skrip bawaan Anda
    WIN_ID=$(xdotool search --onlyvisible --classname gsimplecal 2>/dev/null | tail -n 1)
    [ -n "$WIN_ID" ] && break; sleep 0.1
done

# Jika Window ID tidak ditemukan (gagal buka), keluar dari script
[ -z "$WIN_ID" ] && exit 1

# 4. Pemantau Auto-Close & Escape (Berjalan di background)
(
    # Pantau klik mouse (RawButtonPress) dan tombol Esc (keycode 9)
    xinput test-xi2 --root | grep -E --line-buffered "RawButtonPress|detail: 9" | while read -r event; do
        
        # Berhenti memantau jika gsimplecal sudah tertutup
        ! pgrep -x gsimplecal >/dev/null && break
        
        ACTIVE=$(xdotool getactivewindow 2>/dev/null)

        # Jika tombol Escape ditekan saat gsimplecal aktif
        if [[ "$event" == *"detail: 9"* ]] && [ "$ACTIVE" == "$WIN_ID" ]; then
            pkill -x gsimplecal; break
        fi

        # Jika Mouse di-klik
        if [[ "$event" == *"RawButtonPress"* ]]; then
            # Cek apakah klik terjadi di area luar jendela gsimplecal
            eval $(xdotool getmouselocation --shell 2>/dev/null)
            eval $(xdotool getwindowgeometry --shell "$WIN_ID" 2>/dev/null | sed 's/^X=/W_X=/; s/^Y=/W_Y=/; s/^WIDTH=/W_W=/; s/^HEIGHT=/W_H=/')
            
            # Jika klik di luar koordinat jendela gsimplecal, maka tutup
            if (( X < W_X || X > W_X + W_W || Y < W_Y || Y > W_Y + W_H )); then
                pkill -x gsimplecal; break
            fi
        fi
    done
) &