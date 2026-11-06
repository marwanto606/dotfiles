#!/usr/bin/env bash

# ==========================================
# KONFIGURASI
# ==========================================
# Ubah ke 'true' jika ingin troubleshooting, ubah ke 'false' untuk pemakaian sehari-hari
DEBUG=false
LOG_FILE="/tmp/desktop_menu.log"

log() {
    [ "$DEBUG" = true ] && echo "[$(date '+%H:%M:%S')] $*" >> "$LOG_FILE"
}

# 1. Ambil posisi mouse & ID window di bawah kursor
eval "$(xdotool getmouselocation --shell 2>/dev/null)"
CUR_WIN="${WINDOW:-0}"

# 2. Ambil Root Window (Cache di /tmp agar tidak membebani CPU menjalankan xwininfo terus-menerus)
ROOT_FILE="/tmp/bspwm_root_win"
if [ -s "$ROOT_FILE" ]; then
    ROOT_WIN=$(<"$ROOT_FILE")
else
    ROOT_WIN=$(xwininfo -root -int 2>/dev/null | awk '/Window id:/{print $4; exit}')
    ROOT_WIN="${ROOT_WIN:-0}"
    [ "$ROOT_WIN" -gt 0 ] && echo "$ROOT_WIN" > "$ROOT_FILE"
fi

# 3. Ambil WID live wallpaper jika xwinwrap aktif
XWIN_DEC=""
if [ -s /tmp/xwinwrap_wid ]; then
    RAW_WID=$(< /tmp/xwinwrap_wid)
    RAW_WID="${RAW_WID//[[:space:]]/}"
    [ -n "$RAW_WID" ] && XWIN_DEC=$((RAW_WID)) 2>/dev/null
fi

log "--------------------------------------------------"
log "CUR_WIN: $CUR_WIN | ROOT_WIN: $ROOT_WIN | XWIN_DEC: $XWIN_DEC"

# Fungsi pemicu jgmenu (Kompatibel untuk stay_alive 0 maupun 1)
show_menu() {
    log "Keputusan: BUKA JGMENU ($1)"
    
    # Cek apakah proses jgmenu sedang berjalan di sistem
    if pgrep -x jgmenu >/dev/null 2>&1; then
        # Jika jgmenu sudah ada di background (stay_alive = 1), bangunkan dengan sinyal:
        killall -SIGUSR1 jgmenu
    else
        # Jika belum berjalan (stay_alive = 0 atau belum autostart), jalankan dari awal:
        jgmenu --at-pointer &
    fi
    exit 0
}

# ==========================================
# EVALUASI PRIORITAS TERTINGGI (SUPER CEPAT)
# ==========================================

# 1. Desktop Biasa / Feh / Gap antar jendela (Langsung lolos dalam ~1ms)
if [ "$ROOT_WIN" -gt 0 ] && [ "$CUR_WIN" -eq "$ROOT_WIN" ]; then
    show_menu "Root Window (Desktop/Gap)"
fi

# 2. Live Wallpaper (xwinwrap)
if [ -n "$XWIN_DEC" ] && [ "$CUR_WIN" -eq "$XWIN_DEC" ]; then
    show_menu "Xwinwrap Live Wallpaper"
fi

# 3. Fallback Khusus: Child window MPV atau Visualizer GLava
CUR_TITLE=$(xdotool getwindowname "$CUR_WIN" 2>/dev/null)
if [ "$CUR_TITLE" = "live_wallpaper" ]; then
    show_menu "Title Live Wallpaper"
fi

CUR_CLASS=$(xdotool getwindowclassname "$CUR_WIN" 2>/dev/null)
if [ "$CUR_CLASS" = "GLava" ]; then
    show_menu "GLava Desktop Visualizer"
fi

# Jika mouse berada di jendela aplikasi (Chrome, terminal, menu popup, dll.), langsung abaikan:
log "Keputusan: DIABAIKAN (Bukan area desktop)"
exit 0