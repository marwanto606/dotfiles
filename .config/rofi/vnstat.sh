#!/usr/bin/env bash

export LC_ALL=C

# ==========================================================
# KONFIGURASI INTERFACE
# ==========================================================
INTERFACE="${1:-wlan0}"

if ! command -v vnstat &>/dev/null; then
    rofi -e "Error: 'vnstat' belum terinstall."
    exit 1
fi

# ==========================================================
# 1. THEME MENU UTAMA
# ==========================================================
ROFI_THEME='
* {
    font: "JetBrains Mono 10";
}
window {
    location: center;
    anchor: center;
    width: 600px;
    padding: 15px;
    border-radius: 10px;
    border: 0px 5px;
    background-color: @bg-main;
    border-color: @fuchsia;
}
mainbox {
    children: [ inputbar, message, listview ];
    spacing: 12px;
    background-color: transparent;
}
inputbar {
    enabled: true;
    children: [ prompt, entry ];
    background-color: @bg-input;
    border: 0px;
}
prompt {
    enabled: true;
    text-color: @fuchsia;
    font: "JetBrains Mono Bold 10";
    padding: 0px 8px 0px 0px;
}
entry {
    placeholder: "Pilih menu untuk melihat detail...";
    placeholder-color: @fg-muted;
    text-color: @fg-white;
    background-color: transparent;
}
message {
    enabled: true;
    padding: 12px 16px;
    border: 0px 2px;
    border-radius: 8px;
    border-color: @fuchsia;
    background-color: @bg-main;
}
textbox {
    enabled: true;
    text-color: @fg-white;
    background-color: transparent;
    markup: true; /* Mengizinkan format warna text HTML */
}
listview {
    enabled: true;
    columns: 1;
    lines: 6; 
    fixed-height: true; /* Mengunci tinggi agar TIDAK GLITCH/KEDIP */
    spacing: 6px;
    scrollbar: false;
    background-color: transparent;
    border: 0px;
}
element {
    padding: 9px 12px;
    cursor: pointer;
    border-radius: 6px;
    background-color: @bg-item;
    text-color: @fg-white;
    border: 0px;
}
element selected.normal, element selected.active {
    background-color: @fuchsia;
    text-color: @fg-selected;
}
element-icon {
    enabled: false;
}
element-text {
    cursor: inherit;
    text-color: inherit;
    vertical-align: 0.5;
    background-color: transparent;
}
'

# ==========================================================
# 2. THEME TABEL DETAIL (MESSAGE BOX MODE)
# ==========================================================
TABLE_THEME='
* {
    font: "JetBrains Mono 10";
}
window {
    location: center;
    anchor: center;
    width: 700px;
    padding: 15px;
    border-radius: 10px;
    border: 0px 5px;
    background-color: @bg-main;
    border-color: @fuchsia;
}
mainbox {
    children: [ message, listview ];
    spacing: 12px;
    background-color: transparent;
}
message {
    enabled: true;
    padding: 15px 20px;
    border: 0px 2px;
    border-radius: 8px;
    border-color: @fuchsia;
    background-color: @bg-main;
}
textbox {
    enabled: true;
    text-color: @fg-white;
    background-color: transparent;
    font: "JetBrains Mono 9.5";
    markup: true;
}
listview {
    enabled: true;
    columns: 1;
    lines: 1; 
    fixed-height: true; /* Mencegah Glitch */
    spacing: 0px;
    scrollbar: false;
    background-color: transparent;
    border: 0px;
}
element {
    padding: 6px 12px;
    cursor: pointer;
    border-radius: 6px;
    background-color: @fuchsia;
    text-color: @fg-selected;
    border: 0px;
}
element selected.normal {
    background-color: @fuchsia;
    text-color: @fg-selected;
}
element-text {
    cursor: inherit;
    text-color: inherit;
    vertical-align: 0.5;
    horizontal-align: 0.5;
    font: "JetBrains Mono Bold 10";
    background-color: transparent;
}
'

# ==========================================================
# FUNGSI PARSING TABEL VNSTAT (MEMPERCANTIK RAW DATA)
# ==========================================================
format_table() {
    awk -v iface="$INTERFACE" '
    /^[ \t]*$/ { next }
    $0 ~ iface { next }
    
    {
        if ($0 ~ /---+/) {
            gsub(/-/, "─")
            gsub(/\+/, "┼")
            gsub(/\|/, "│")
            print "<span color=\"#555E70\">" $0 "</span>"
        } else {
            gsub(/\|/, "<span color=\"#555E70\">│</span>")
            gsub(/ rx /, "<b>   </b>")
            gsub(/ tx /, "<b>   </b>")
            gsub(/ total /, "<span color=\"#D946EF\"><b> Total </b></span>")
            gsub(/ avg. rate /, "<b> avg. rate </b>")
            print $0
        }
    }'
}

# ==========================================================
# FUNGSI PENGAMBIL DATA NETWORK
# ==========================================================
get_net_info() {
    local ssid
    ssid=$(iwgetid -r 2>/dev/null || echo "Connected")
    local ip_addr
    ip_addr=$(ip -4 addr show dev "$INTERFACE" 2>/dev/null | awk '/inet / {print $2}' | cut -d/ -f1)
    [ -z "$ip_addr" ] && ip_addr="No IP"

    local raw_data
    raw_data=$(vnstat -i "$INTERFACE" --oneline 2>/dev/null)

    if [ -n "$raw_data" ]; then
        IFS=';' read -r _ _ _ TODAY_RX TODAY_TX TODAY_TOT _ \
                            _ MONTH_RX MONTH_TX MONTH_TOT _ \
                            ALL_RX ALL_TX ALL_TOT <<< "$raw_data"
    else
        TODAY_RX="0 B"; TODAY_TX="0 B"; TODAY_TOT="0 B"
        MONTH_RX="0 B"; MONTH_TX="0 B"; MONTH_TOT="0 B"
    fi

    echo "<b><span color=\"#D946EF\">  Interface:</span></b> $INTERFACE ($ssid | $ip_addr)
<b>  Hari ini :</b>  $TODAY_RX   $TODAY_TX  <span color=\"#D946EF\"> Total: $TODAY_TOT</span>
<b>  Bulan ini:</b>  $MONTH_RX   $MONTH_TX  <span color=\"#D946EF\"> Total: $MONTH_TOT</span>"
}

# ==========================================================
# FUNGSI MENAMPILKAN TABEL DETAIL (BOX MESSAGE)
# ==========================================================
show_detail_table() {
    local cmd="$1"
    
    local output
    output=$($cmd 2>/dev/null | format_table)

    # Menggunakan mekanisme Press-Down & Release tanpa hover-select
    local clicked
    clicked=$(echo -e "Kembali ke Menu" | rofi \
        -dmenu \
        -i \
        -me-select-entry MousePrimary \
        -me-accept-entry '!MousePrimary' \
        -mesg "$output" \
        -theme-str "$TABLE_THEME")

    if [[ "$clicked" == *"Kembali"* ]]; then
        return 0
    else
        exit 0
    fi
}

# ==========================================================
# MAIN LOOP
# ==========================================================
while true; do
    HEADER_INFO=$(get_net_info)

    MENU=$(cat <<EOF
1.   Lihat Rincian Harian (Daily Stats)
2.   Lihat Rincian Bulanan (Monthly Stats)
3.   Lihat Rincian Per Jam (Hourly Stats)
4.   Lihat Top 10 Hari Terbanyak
5.   Buka Live Traffic Monitor (Terminal vnstat -l)
6.   Perbarui Database vnstat Sekarang
EOF
)

    # Menggunakan mekanisme Press-Down & Release tanpa hover-select
    SELECTED=$(echo "$MENU" | rofi \
        -dmenu \
        -i \
        -me-select-entry MousePrimary \
        -me-accept-entry '!MousePrimary' \
        -p " " \
        -mesg "$HEADER_INFO" \
        -theme-str "$ROFI_THEME")

    [ -z "$SELECTED" ] && exit 0

    case "$SELECTED" in
        *"1."*) show_detail_table "vnstat -i $INTERFACE -d" ;;
        *"2."*) show_detail_table "vnstat -i $INTERFACE -m" ;;
        *"3."*) show_detail_table "vnstat -i $INTERFACE -h" ;;
        *"4."*) show_detail_table "vnstat -i $INTERFACE -t" ;;
        *"5."*)
            for term in kitty alacritty wezterm foot gnome-terminal xfce4-terminal xterm; do
                if command -v "$term" &>/dev/null; then
                    "$term" -e vnstat -i "$INTERFACE" -l &
                    break
                fi
            done
            exit 0
            ;;
        *"6."*)
            vnstat -u -i "$INTERFACE" &>/dev/null
            command -v notify-send &>/dev/null && notify-send -u low "vnstat" "Database untuk $INTERFACE berhasil diperbarui!"
            continue
            ;;
        *) exit 0 ;;
    esac
done