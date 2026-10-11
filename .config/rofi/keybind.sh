#!/usr/bin/env bash

THEME="$HOME/.config/rofi/keybind.rasi"
TOTAL_WIDTH=80

DATA=$(cat << 'EOF'
super + alt + r::Restart BSPWM
super + alt + s::Reload SXHKD config
super + d::Cheat Sheet Keybindings
ctrl + alt + l::Lock Screen (betterlockscreen)
super + Escape::Rofi Power Menu
super + alt + b::Toggle Polybar
super + Return::Terminal (qterminal)
super + alt + Return::Floating Terminal (qterminal)
super + t::Terminal (kitty)
super + alt + t::Floating Terminal (kitty)
super + space::App Launcher (rofi drun)
super + Tab::Switch Active Windows (rofi window)
super + e::File Manager (Thunar)
super + a::Browser (Google Chrome)
super + c::Music Player (AIMP)
super + s::Discord
super + z::Text Editor (Zed)
super + x::AB Download Manager
super + g::Toggle Glava Visualizer
super + shift + g::Kill Glava
super + q::Close active window
super + shift + q::Force Kill window
super + m::Toggle Monocle layout
super + f::Toggle Fullscreen
super + v::Toggle Floating mode
super + [j, k, i, l]::Fokus Jendela (West/South/North/East)
super + shift + [j, k, i, l]::Tukar Jendela (West/South/North/East)
super + [1-9, 0]::Pindah Workspace 1 - 10
super + shift + [1-9, 0]::Kirim Jendela ke Workspace 1 - 10
super + [Left, Right]::Pindah Workspace (Prev / Next)
super + shift + [Left, Right]::Kirim Jendela & Ikuti
super + shift + Arrows::Geser Floating Window (20px)
super + alt + Arrows::Perbesar Ukuran Window
super + ctrl + Arrows::Perkecil Ukuran Window
super + ctrl + [j, k, i, l]::Preselection Split Mode
super + ctrl + space::Batalkan Preselection
XF86 Audio Keys::Volume Up / Down / Mute
XF86 Brightness Keys::Brightness Up / Down
XF86 Mic / WLAN::Toggle Mic Mute / Wifi Info
Print::Screenshot Fullscreen
alt + Print::Screenshot Area
ctrl + Print::Screen Record (Start)
ctrl + alt + Print::Screen Record (Pause)
ctrl + shift + Print::Screen Record (Save & Stop)
super + shift + r::Screen Record Settings GUI
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

# Jalankan via Rofi dmenu (sangat cepat & fuzzy search bawaan Rofi aktif)
echo -n "$FORMATTED_DATA" | rofi -dmenu \
    -i \
    -p "Shortcuts" \
    -theme "$THEME"