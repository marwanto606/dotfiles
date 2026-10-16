#!/usr/bin/env bash

# Buat daftar menu menggunakan format dmenu icon Rofi
options="Lock\0icon\x1fsystem-lock-screen\n\
Logout\0icon\x1fsystem-log-out\n\
Reboot\0icon\x1fsystem-reboot\n\
Shutdown\0icon\x1fsystem-shutdown"

# Eksekusi Rofi:
chosen=$(printf "%b" "$options" | rofi -dmenu -i -show-icons -p "Power" -theme-str '
    configuration {
        icon-theme: "WhiteSur-dark";
        hover-select: true;
        me-select-entry: "MousePrimary";
        me-accept-entry: "!MousePrimary";
    }
    * {
        background-color: transparent;
    }
    window {
        width: 380px;
        background-color: @bg-main;
        border: 0px 5px;
        border-color: @fuchsia;
        border-radius: 20px;
        padding: 20px;
    }
    mainbox {
        children: [ listview ];
    }
    listview {
        columns: 2;
        lines: 2;
        flow: horizontal;
        fixed-columns: true;
        fixed-height: true;
        spacing: 16px;
        scrollbar: false;
        cycle: true;
        border: 0;
    }
    element {
        orientation: vertical;
        border-radius: 14px;
        padding: 25px 0px;
        cursor: pointer;
        border: 1px;
        spacing: 15px;
    }
    element-icon {
        size: 64px;
        horizontal-align: 0.5;
        background-color: transparent;
        cursor: inherit;
    }
    element-text {
        horizontal-align: 0.5;
        vertical-align: 0.5;
        font: "JetBrains Mono Bold 11";
        text-color: inherit;
        background-color: transparent;
        cursor: inherit;
    }

    /* Kotak Normal (Menggunakan variabel tema Anda) */
    element normal.normal, element alternate.normal {
        background-color: @bg-item;
        text-color: @fg-white;
        border-color: @bg-item;
    }

    /* Kotak Terpilih / Saat diklik (Fuchsia Solid) */
    element selected.normal, element selected.active {
        background-color: @fuchsia;
        border-color: @fuchsia;
    }
    element selected.normal element-text, element selected.active element-text {
        text-color: @fg-selected;
    }
')

# Keluar jika pengguna menekan ESC / klik di luar jendela
[[ -z "$chosen" ]] && exit 0

# Beri jeda sepersekian detik agar animasi fade-out Rofi selesai sepenuhnya dari layar
sleep 0.25

# Eksekusi aksi berdasarkan kata yang dipilih
case "$chosen" in
    "Lock")
        betterlockscreen -l blur || dm-tool lock
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