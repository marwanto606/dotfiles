#!/usr/bin/env bash

TOTAL_WIDTH=80

DATA=$(cat << 'EOF'
super + alt + r::Restart BSPWM
super + alt + s::Reload SXHKD config
super + F1::Cheat Sheet Keybindings
ctrl + alt + l::Lock Screen (betterlockscreen)
super + Escape::Rofi Power Menu
super + alt + b::Toggle Polybar
super + Return::Terminal (qterminal)
super + alt + Return::Floating Terminal (qterminal)
super + t::Terminal (kitty)
super + alt + t::Floating Terminal (kitty)
super + d::App Launcher (rofi drun)
super + Tab::Switch Active Windows (rofi window)
super + r::Run Command [Shift + enter] / GUI [Enter] (rofi run)
super + e::File Manager (Thunar)
super + alt + f::Open File Borwser (rofi filebrowser)
super + w::Open Wifi (rofi wifi)
super + ctrl + r::Open Process Manager (rofi proccess)
super + a::Browser (Google Chrome)
super + s::Discord
super + z::Text Editor (Zed)
super + x::AB Download Manager
super + g::Toggle Glava Visualizer
super + q::Close active window
super + shift + q::Force Kill window
super + m::Toggle Monocle layout
super + f::Toggle Fullscreen
super + v::Toggle Floating mode
super + (j, k, i, l)::Fokus Jendela (West/South/North/East)
super + shift + (j, k, i, l)::Tukar Jendela (West/South/North/East)
super + (1-9, 0)::Pindah Workspace 1 - 10
super + shift + (1-9, 0)::Kirim Jendela ke Workspace 1 - 10
super + (Left, Right)::Pindah Workspace (Prev / Next)
super + shift + (Left, Right)::Kirim Jendela & Ikuti
super + shift + alt + Arrows::Geser Floating Window (20px)
super + alt + Arrows::Perbesar Ukuran Window
super + ctrl + Arrows::Perkecil Ukuran Window
super + ctrl + (j, k, i, l)::Preselection Split Mode
super + ctrl + space::Batalkan Preselection
XF86 Audio Keys::Volume Up / Down / Mute
XF86 Brightness Keys::Brightness Up / Down
XF86 Mic::Toggle Mic Mute
WLAN::Toggle Wifi on/off
Print / super + p::Screenshot Fullscreen
alt + Print / super + alt + p::Screenshot Area
ctrl + Print / super + ctrl + p::Screen Record (Start)
ctrl + alt + Print / super + ctrl + alt + p::Screen Record (Pause)
ctrl + shift + Print / super + ctrl + shift + p::Screen Record (Save & Stop)
super + shift + r::Screen Record Settings GUI
super + \::Open, play, pause (AIMP player)
super + shift + \::Kill Aimp player
super + ]::Next Track Music (AIMP player)
super + [::Previous Track Music (AIMP player)
EOF
)

# Format agar Shortcut di sisi kiri dan Keterangan selalu rata kanan
FORMATTED_DATA=""

while IFS= read -r line; do
    [ -z "$line" ] && continue
    key="${line%%::*}"
    desc="${line##*::}"
    len_key=${#key}
    len_desc=${#desc}
    pad_len=$(( TOTAL_WIDTH - len_key - len_desc ))
    [ "$pad_len" -lt 2 ] && pad_len=2

    spaces=$(printf '%*s' "$pad_len" "")
    FORMATTED_DATA+="${key}${spaces}${desc}"$'\n'
done <<< "$DATA"

# Eksekusi Rofi mewarisi warna config.rasi dengan layout custom
echo -n "$FORMATTED_DATA" | rofi -dmenu \
    -i \
    -p " " \
    -theme-str '
    configuration {
        font: "JetBrains Mono 10";
        show-icons: false;
        hover-select: false;
        me-select-entry: "";
        me-accept-entry: "";
        kb-move-front: "Control+Home";
        kb-clear-line: "Control+a,Control+w"; 
    }
    * {
        background-color: transparent;
    }
    window {
        width: 710px;
        background-color: @bg-main;
        border: 0px 5px;
        border-color: @teal;
        border-radius: 12px;
        padding: 15px;
    }
    mainbox {
        spacing: 12px;
        children: [ inputbar, listview ];
    }
    inputbar {
        background-color: @bg-input;
        border: 0px;
        border-radius: 8px;
        padding: 8px 12px;
        spacing: 8px;
        children: [ prompt, entry ];
    }
    prompt {
        text-color: @teal;
        font: "JetBrains Mono Bold 10";
        vertical-align: 0.5;
    }
    entry {
        text-color: @fg-white;
        placeholder: "Cari shortcut atau fungsi...";
        placeholder-color: @fg-muted;
        vertical-align: 0.5;
    }
    listview {
        columns: 1;
        lines: 11;
        spacing: 5px;
        cycle: true;
        dynamic: true;
        scrollbar: false;
    }
    element {
        padding: 8px 12px;
        border-radius: 6px;
        cursor: pointer;
        border: 0px;
        background-color: @bg-item;
        text-color: @fg-white;
        children: [ element-text ];
    }

    element-text {
        horizontal-align: 0.0;
        vertical-align:   0.5;
        background-color: transparent;
        cursor: inherit;
        text-color: @fg-white;
        expand: true;
    }
    /* Terpilih (Menggunakan Fuchsia tema Anda) */
    element selected.normal, element selected.active {
        background-color: @teal;
        text-color: @fg-selected;
    }
    element selected.normal element-text, element selected.active element-text {
        font: "JetBrains Mono Bold 10";
    }
'