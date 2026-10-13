#!/usr/bin/env bash

export LC_ALL=C

# 1. Styling Utama
ROFI_THEME='
* {
    font: "JetBrains Mono 10";
}
window {
    width: 400px;
    height: 400px;
    padding: 15px;
    border-radius: 10px;
    border-color: #D946EF;
}
mainbox {
    children: [ inputbar, message, listview ];
    spacing: 10px;
}
entry {
    placeholder: "Select Wi-Fi Network...";
}
prompt {
    enabled: true;
    font: "JetBrains Mono 12";
    text-color: #D946EF;
}
message {
    enabled: true;
    padding: 8px 12px;
    border: 1px;
    border-color: #444444;
    border-radius: 6px;
}
textbox {
    enabled: true;
    text-color: #ffffff;
}
listview {
    enabled: true;
    columns: 1;
    lines: 8;
    fixed-num-lines: false;
    spacing: 4px;
    scrollbar: false;
}
element-icon {
    enabled: false;
}
element-text {
    margin: 0px;
    padding: 3px 0px;
}
element normal.normal, element alternate.normal {
        background-color: #161A26;
        text-color: #FFFFFF;
        border-color: #23283B;
    }

/* Kotak Terpilih / Hover (Fuchsia Solid) */
element selected.normal, element selected.active {
        background-color: #D946EF;
        border-color: #D946EF;
}
'

# Styling Kotak Input Password (Icon Kunci , mematikan icon kaca pembesar default)
ROFI_PASS_THEME='
* {
    font: "JetBrains Mono 10";
}
window {
    width: 380px;
    padding: 15px;
    border-radius: 10px;
}
mainbox {
    children: [ inputbar ];
}
inputbar {
    children: [ prompt, entry ];
    spacing: 10px;
}
prompt {
    enabled: true;
    font: "JetBrains Mono 11";
}
textbox-prompt-colon {
    enabled: false;
    str: "";
}
entry {
    placeholder: "Enter Wi-Fi Password...";
}
'

# 2. Cek Status Wi-Fi & SSID yang Sedang Terhubung
wifi_state=$(nmcli radio wifi)
wifi_dev=$(nmcli -t -f DEVICE,TYPE device | awk -F: '$2=="wifi" {print $1; exit}')

# Ambil SSID yang aktif
current_ssid=$(nmcli -t -f active,ssid dev wifi | awk -F: '$1=="yes" {sub(/^yes:/, ""); print; exit}')
if [ -z "$current_ssid" ]; then
    current_ssid=$(nmcli -t -f TYPE,STATE,CONNECTION device | awk -F: '$1=="wifi" && $2=="connected" {print $3; exit}')
fi

if [ "$wifi_state" = "disabled" ]; then
    SYS_INFO="󰖪  Wi-Fi is currently Disabled"
    toggle="󰖩  Enable Wi-Fi"
else
    if [ -n "$current_ssid" ]; then
        SYS_INFO="󰖩  Connected to: $current_ssid"
    else
        SYS_INFO="󰖪  Disconnected"
    fi
    toggle="󰖪  Disable Wi-Fi"
fi

# 3. Ambil Daftar Wi-Fi (Tandai yang terhubung dan letakkan di posisi teratas)
wifi_list=""
if [ "$wifi_state" = "enabled" ]; then
    wifi_list=$(nmcli -t -f SSID,SECURITY dev wifi list | awk -F: -v cur="$current_ssid" '
        $1 != "" && !seen[$1]++ {
            icon = ($2 ~ /WPA|WEP/) ? "" : "";
            if (cur != "" && $1 == cur) {
                connected_entry = sprintf("  %s  %s  [Connected]", icon, $1);
            } else {
                other_entries = (other_entries ? other_entries "\n" : "") sprintf("   %s  %s", icon, $1);
            }
        }
        END {
            if (cur != "" && connected_entry == "") {
                connected_entry = sprintf("    %s  [Connected]", cur);
            }
            if (connected_entry != "") print connected_entry;
            if (other_entries != "") print other_entries;
        }
    ')
fi

# 4. Gabungkan Menu Tanpa Baris Kosong
if [ -n "$wifi_list" ]; then
    menu_content=$(printf "%s\n%s" "$toggle" "$wifi_list" | sed '/^[[:space:]]*$/d')
else
    menu_content="$toggle"
fi

# 5. Tampilkan Menu Rofi
chosen_network=$(echo "$menu_content" | rofi \
    -dmenu \
    -i \
    -p " " \
    -mesg "$SYS_INFO" \
    -theme-str "$ROFI_THEME")

# Keluar jika Escape ditekan
[ -z "$chosen_network" ] && exit 0

# 6. Logika Toggle On/Off
if [ "$chosen_network" = "󰖩  Enable Wi-Fi" ]; then
    nmcli radio wifi on && notify-send "Wi-Fi" "Wi-Fi Diaktifkan"
    exit 0
elif [ "$chosen_network" = "󰖪  Disable Wi-Fi" ]; then
    nmcli radio wifi off && notify-send "Wi-Fi" "Wi-Fi Dinonaktifkan"
    exit 0
fi

# 7. Logika Disconnect (Jika mengklik yang bertanda [Connected] atau )
if [[ "$chosen_network" == *"[Connected]"* ]] || [[ "$chosen_network" == *""* ]]; then
    target_ssid="$current_ssid"
    if [ -z "$target_ssid" ]; then
        target_ssid=$(echo "$chosen_network" | sed -E 's/^[[:space:]]*[[:space:]]+(|)[[:space:]]+//; s/[[:space:]]+\[Connected\]$//')
    fi

    notify-send "Wi-Fi" "Disconnecting from \"$target_ssid\"..."
    
    # Putuskan koneksi pada adapter Wi-Fi & profil koneksi
    if [ -n "$wifi_dev" ]; then
        nmcli device disconnect "$wifi_dev"
    fi
    if [ -n "$target_ssid" ]; then
        nmcli connection down id "$target_ssid" 2>/dev/null
    fi

    notify-send "Wi-Fi" "Disconnected from \"$target_ssid\""
    exit 0
fi

# 8. Logika Sambung ke Wi-Fi Lain
chosen_id=$(echo "$chosen_network" | sed -E 's/^[[:space:]]*(|)[[:space:]]+//')

saved_connections=$(nmcli -g NAME connection)

if echo "$saved_connections" | grep -Fxq "$chosen_id"; then
    notify-send "Wi-Fi" "Connecting to \"$chosen_id\"..."
    if nmcli connection up id "$chosen_id"; then
        notify-send "Wi-Fi" "Connected to \"$chosen_id\""
    else
        notify-send "Wi-Fi" "Failed to connect to \"$chosen_id\""
    fi
else
    # Jika koneksi baru dan memiliki proteksi password
    if [[ "$chosen_network" =~ "" ]]; then
        # Buka dialog password dengan prompt icon Kunci 
        wifi_password=$(rofi \
            -dmenu \
            -password \
            -i \
            -p "   " \
            -theme-str "$ROFI_PASS_THEME")

        [ -z "$wifi_password" ] && exit 0

        notify-send "Wi-Fi" "Connecting to \"$chosen_id\"..."
        if nmcli device wifi connect "$chosen_id" password "$wifi_password"; then
            notify-send "Wi-Fi" "Connected to \"$chosen_id\""
        else
            notify-send "Wi-Fi" "Failed to connect to \"$chosen_id\". Check password."
        fi
    else
        # Wi-Fi publik / Open
        notify-send "Wi-Fi" "Connecting to \"$chosen_id\"..."
        if nmcli device wifi connect "$chosen_id"; then
            notify-send "Wi-Fi" "Connected to \"$chosen_id\""
        else
            notify-send "Wi-Fi" "Failed to connect to \"$chosen_id\""
        fi
    fi
fi