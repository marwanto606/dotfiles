#!/usr/bin/env bash

# Menggunakan fitur rahasia Rofi: Memuat Ikon SVG bawaan sistem!
# Format: Nama Menu \0icon\x1f Nama Ikon Papirus
options="Lock\0icon\x1fsystem-lock-screen\n"
options+="Logout\0icon\x1fsystem-log-out\n"
options+="Reboot\0icon\x1fsystem-reboot\n"
options+="Shutdown\0icon\x1fsystem-shutdown"

# Jalankan Rofi dengan opsi -show-icons
chosen="$(echo -e "$options" | rofi -dmenu -i -show-icons -p "Power" -theme-str '
    configuration {
        icon-theme:       "Papirus";
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
    }
    element-text {
        horizontal-align: 0.5;
        vertical-align:   0.5;
        font:             "JetBrains Mono Bold 11";
        text-color:       inherit;
        background-color: transparent;
    }

    /* KOTAK NORMAL (DARK PEKAT) */
    element normal.normal, element alternate.normal {
        background-color: #161A26;
        text-color:       #E2E8F0;
        border-color:     #23283B;
    }

    /* KOTAK TERPILIH (MAGENTA SOLID, IKON & TEKS HITAM PEKAT) */
    element selected.normal {
        background-color: #D946EF;
        text-color:       #0F111A;
        border-color:     #D946EF;
    }
    element selected.normal element-text {
        text-color:       #0F111A;
    }
')"

# Jika pengguna menekan ESC atau membatalkan (variabel kosong), langsung keluar
[[ -z "$chosen" ]] && exit 0

# Beri jeda sepersekian detik agar animasi fade-out Rofi selesai sepenuhnya dari layar
sleep 0.25

# Eksekusi aksi berdasarkan kata yang dipilih
case "$chosen" in
    "Lock")
        dm-tool lock || i3lock || slock || xflock4
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