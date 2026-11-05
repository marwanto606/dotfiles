#!/bin/sh

win_id=$(bspc query -N -n focused)
[ -z "$win_id" ] && exit 0

# 1. Cek apakah window saat ini sedang floating
is_floating=$(bspc query -N -n focused.floating)

if [ -n "$is_floating" ]; then
    # Jika sudah floating, kembalikan ke tiled
    bspc node "$win_id" -t tiled
    exit 0
fi

# ========================================================
# 2. Tentukan Ukuran Berdasarkan Class Aplikasi
# ========================================================
# Ambil WM_CLASS
class=$(xprop -id "$win_id" WM_CLASS 2>/dev/null | awk -F '"' '{print tolower($4)}')
[ -z "$class" ] && class=$(xprop -id "$win_id" WM_CLASS 2>/dev/null | awk -F '"' '{print tolower($2)}')

case "$class" in
    *kitty*|*xfce4-terminal*)
        W=800
        H=500
        ;;
    *thunar*)
        W=900
        H=600
        ;;
    *code*|*vscodium*)
        W=920
        H=620
        ;;
    *chrome*|*chromium*|*brave*)
        W=920
        H=620
        ;;
    *)
        # Default global
        W=920
        H=620
        ;;
esac

# ========================================================
# 3. Hitung Posisi Tengah (Center)
# ========================================================
[ -f /tmp/screen_res ] && . /tmp/screen_res

# Jika /tmp/screen_res kosong/tidak ada, ambil langsung ukuran layar saat ini
if [ -z "$WIDTH" ] || [ -z "$HEIGHT" ]; then
    eval "$(xdotool getdisplaygeometry --shell 2>/dev/null)"
fi
WIDTH=${WIDTH:-1366}
HEIGHT=${HEIGHT:-768}

X=$(( (WIDTH - W) / 2 ))
Y=$(( (HEIGHT - H) / 2 ))

[ "$X" -lt 0 ] && X=0
[ "$Y" -lt 0 ] && Y=0

# ========================================================
# 4. Terapkan Floating & Resize
# ========================================================
# Matikan honor_size_hints agar jendela menuruti ukuran script
bspc config honor_size_hints false 2>/dev/null

# Ubah window menjadi floating
bspc node "$win_id" -t floating

# KUNCI UTAMA: Cabut status MAXIMIZED dari Chrome/aplikasi X11
if command -v wmctrl >/dev/null 2>&1; then
    wmctrl -ir "$win_id" -b remove,maximized_vert,maximized_horz 2>/dev/null
    wmctrl -ir "$win_id" -e "0,$X,$Y,$W,$H"
else
    xdotool windowstate --remove MAXIMIZED_VERT "$win_id" 2>/dev/null
    xdotool windowstate --remove MAXIMIZED_HORZ "$win_id" 2>/dev/null
    xdotool windowsize "$win_id" "$W" "$H" 2>/dev/null
    xdotool windowmove "$win_id" "$X" "$Y" 2>/dev/null
fi

# Micro-delay sync (memastikan CSD Chrome selesai me-render layout barunya)
(
    sleep 0.05
    if command -v wmctrl >/dev/null 2>&1; then
        wmctrl -ir "$win_id" -e "0,$X,$Y,$W,$H"
    else
        xdotool windowsize "$win_id" "$W" "$H" 2>/dev/null
        xdotool windowmove "$win_id" "$X" "$Y" 2>/dev/null
    fi
) &