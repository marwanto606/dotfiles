#!/bin/bash

# ==========================================
# KONFIGURASI
# ==========================================
MODE="${1:-static}"
WALLPAPER_DIR="$HOME/Pictures/wallpapers"
LIVE_WALLPAPER_DIR="$HOME/Pictures/wallpapers/live"

PID_FILE="/tmp/workspace-wallpaper.pid"
WID_FILE="/tmp/xwinwrap_wid"

# 1. Hentikan instance skrip ini sebelumnya secara bersih
if [ -f "$PID_FILE" ]; then
    kill "$(cat "$PID_FILE")" 2>/dev/null
    rm -f "$PID_FILE"
fi
echo "$$" > "$PID_FILE"

# 2. Hentikan xwinwrap & mpv KHUSUS wallpaper saja (tidak mengganggu MPV lain)
killall -q xwinwrap
pkill -f "title=live_wallpaper" 2>/dev/null

# Aktifkan nullglob agar ekstensi yang tidak ada tidak menjadi string literal (error)
shopt -s nullglob

# ==========================================
# MODE: LIVE WALLPAPER (xwinwrap + mpv)
# ==========================================
if [ "$MODE" = "live" ]; then
    LIVE_VIDEOS=("$LIVE_WALLPAPER_DIR"/*.mp4)

    if [ ${#LIVE_VIDEOS[@]} -eq 0 ]; then
        echo "Error: Tidak ada file .mp4 di $LIVE_WALLPAPER_DIR"
        exit 1
    fi

    rm -f "$WID_FILE"
    xsetroot -solid "#000000"

    SELECTED_VIDEO="${LIVE_VIDEOS[RANDOM % ${#LIVE_VIDEOS[@]}]}"

    # Jalankan xwinwrap
    xwinwrap -fs -fdt -ni -b -s -st -sp -nf -- sh -c '
        echo "$1" > /tmp/xwinwrap_wid
        exec mpv -wid "$1" \
            --title="live_wallpaper" \
            --loop \
            --no-audio \
            --hwdec=auto \
            --panscan=1.0 \
            --no-osc \
            --no-osd-bar \
            --really-quiet \
            "$2"
    ' _ WID "$SELECTED_VIDEO" &

    # Pastikan wallpaper berada di tumpukan paling bawah
    (
        sleep 0.15
        [ -s "$WID_FILE" ] && xdo lower $(cat "$WID_FILE") 2>/dev/null
        # Jika GLava sedang berjalan, pastikan GLava ada di atas wallpaper
        xdo lower -N GLava 2>/dev/null
        [ -s "$WID_FILE" ] && xdo lower $(cat "$WID_FILE") 2>/dev/null
    ) &

    exit 0
fi

# ==========================================
# MODE: STATIC WORKSPACE WALLPAPER
# ==========================================
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