#!/usr/bin/env bash

# Buat daftar menu menggunakan format dmenu icon Rofi
options="Lock\0icon\x1fsystem-lock-screen\n\
Logout\0icon\x1fsystem-log-out\n\
Reboot\0icon\x1fsystem-reboot\n\
Shutdown\0icon\x1fsystem-shutdown"

# Eksekusi Rofi:
# -no-config : Mencegah Rofi membaca file config global (SANGAT MEMPERCEPAT WAKTU BUKA)
chosen=$(printf "%b" "$options" | rofi -no-config -dmenu -i -show-icons -p "Power" -theme-str '
    configuration {
        icon-theme:   "Papirus-Dark";
    }
    * {
        background-color: transparent;
    }
    window {
        width:            380px;
        height:           380px;
        background-color: #0F111A;
        border:           2px;
        border-color:     #D946EF;
        border-radius:    20px;
        padding:          20px;
    }
    mainbox {
        children: [ listview ];
    }
    listview {
        columns:          2;
        lines:            2;
        flow:             horizontal;
        fixed-columns:    true;
        fixed-height:     true;
        spacing:          16px;
        scrollbar:        false;
        cycle:            true;
        border:           0;
    }
    element {
        orientation:      vertical;
        border-radius:    14px;
        padding:          25px 0px;
        cursor:           pointer;
        border:           1px;
        spacing:          15px;
    }
    element-icon {
        size:             64px;
        horizontal-align: 0.5;
        background-color: transparent;
        cursor:           inherit;
    }
    element-text {
        horizontal-align: 0.5;
        vertical-align:   0.5;
        font:             "JetBrains Mono Bold 11";
        text-color:       inherit;
        background-color: transparent;
        cursor:           inherit;
    }

    /* Kotak Normal (Dark Pekat, Border Halus) */
    element normal.normal, element alternate.normal {
        background-color: #161A26;
        text-color:       #FFFFFF;
        border-color:     #23283B;
    }

    /* Kotak Terpilih / Hover (Fuchsia Solid) */
    element selected.normal, element selected.active {
        background-color: #D946EF;
        border-color:     #D946EF;
    }
    element selected.normal element-text, element selected.active element-text {
        text-color:       #0F111A;
    }
')

# Keluar jika pengguna menekan ESC / klik di luar jendela
[[ -z "$chosen" ]] && exit 0

# Eksekusi instan tanpa sleep
case "$chosen" in
    "Lock")
        # Ganti dengan locker spesifik Anda jika tidak memakai i3lock
        dm-tool lock || i3lock  || slock
        ;;
    "Logout")
        bspc quit
        ;;
    "Reboot")
        systemctl reboot
        ;;
    "Shutdown")
        systemctl poweroff
        ;;
esac