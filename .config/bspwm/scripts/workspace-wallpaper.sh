#!/bin/bash

WALLPAPER_DIR="$HOME/Pictures/wallpapers"

# Aktifkan nullglob agar ekstensi yang tidak ada tidak menjadi string literal (error)
shopt -s nullglob

# MEMORI CACHE: Baca isi folder SATU KALI SAJA saat script dijalankan.
# Ini membuat perpindahan wallpaper bebas lag dan sangat hemat CPU.
WALLPAPERS=("$WALLPAPER_DIR"/*.{png,jpg,jpeg})

# Jika tidak ada file gambar di dalam folder, matikan script
if [ ${#WALLPAPERS[@]} -eq 0 ]; then
    exit 1
fi

set_random_wallpaper() {
    # Pilih indeks gambar secara acak (menggunakan math bawaan bash)
    local random_index=$(( RANDOM % ${#WALLPAPERS[@]} ))
    local random_pic="${WALLPAPERS[$random_index]}"
    
    # Eksekusi feh (tambahkan --no-fehbg agar tidak meninggalkan file sampah)
    feh --bg-fill "$random_pic" --no-fehbg
}

# 1. Saat BSPWM baru mulai, pasang satu wallpaper acak
set_random_wallpaper

# 2. Dapatkan ID dari desktop (workspace) yang sedang aktif sekarang
CURRENT_DESK_ID=$(bspc query -D -d focused)

# 3. Pantau perpindahan workspace
bspc subscribe desktop_focus | while read -r _ _ desktop_id; do
    # Jika ID workspace baru BERBEDA dengan ID workspace sebelumnya,
    # maka ganti wallpaper. Ini mencegah script tereksekusi dua kali.
    if [ "$desktop_id" != "$CURRENT_DESK_ID" ]; then
        CURRENT_DESK_ID="$desktop_id"
        set_random_wallpaper
    fi
done