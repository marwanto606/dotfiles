#!/bin/bash

WALLPAPER_DIR="$HOME/Pictures/wallpapers"

set_wallpaper() {
    case "$1" in
	0) WALLPAPER="$WALLPAPER_DIR/cyber0.png" ;;
        1) WALLPAPER="$WALLPAPER_DIR/cyber1.png" ;;
        2) WALLPAPER="$WALLPAPER_DIR/cyber2.png" ;;
        3) WALLPAPER="$WALLPAPER_DIR/cyber3.png" ;;
        4) WALLPAPER="$WALLPAPER_DIR/cyber4.png" ;;
        5) WALLPAPER="$WALLPAPER_DIR/cyber5.png" ;;
        6) WALLPAPER="$WALLPAPER_DIR/cyber6.png" ;;
        7) WALLPAPER="$WALLPAPER_DIR/cyber7.png" ;;
        8) WALLPAPER="$WALLPAPER_DIR/cyber8.png" ;;
        9) WALLPAPER="$WALLPAPER_DIR/cyber9.png" ;;
        *) return ;;
    esac

    [ -f "$WALLPAPER" ] && feh --bg-fill "$WALLPAPER"
}

# Pas BSPWM mulai, langsung pasang wallpaper workspace aktif
DESKTOP=$(bspc query -D -d focused --names)
set_wallpaper "$DESKTOP"

# Pantau perpindahan workspace
bspc subscribe desktop_focus | while read -r _ _ _ _; do
    DESKTOP=$(bspc query -D -d focused --names)
    set_wallpaper "$DESKTOP"
done
