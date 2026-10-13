#!/usr/bin/env bash

export LC_ALL=C

# 1. Styling Rofi (Menu Utama)
ROFI_THEME='
* {
    font: "JetBrains Mono 10";
}
window {
    width: 950px;
    padding: 15px;
    border-radius: 10px;
}
mainbox {
    children: [ inputbar, message, listview ];
    spacing: 10px;
}
entry {
    placeholder: "Search process...";
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
    lines: 10;
    spacing: 4px;
    scrollbar: false;
}
element {
    padding: 5px 8px;
    cursor: pointer;
    border-radius: 4px;
}
element-icon {
    enabled: false;
}
element-text {
    margin: 0px;
    padding: 0px;
    cursor: inherit;
    vertical-align: 0.5;
}
'

# Styling Dialog Aksi
ACTION_THEME='
* {
    font: "JetBrains Mono 10";
}
window {
    width: 420px;
    padding: 15px;
    border-radius: 10px;
    border: 2px;
    border-color: #D946EF;
}
mainbox {
    children: [ inputbar, listview ];
    spacing: 12px;
}
inputbar {
    enabled: true;
    children: [ prompt ];
}
prompt {
    enabled: true;
    text-color: #D946EF;
    font: "JetBrains Mono Bold 10";
    expand: true;
    padding: 0px 5px;
}
entry {
    enabled: false;
}
message {
    enabled: false;
}
textbox {
    enabled: false;
}
listview {
    columns: 1;
    lines: 3;
    spacing: 6px;
}
element {
    padding: 6px 10px;
    cursor: pointer;
    border-radius: 4px;
}
element normal.normal, element alternate.normal {
    background-color: #161A26;
    text-color: #FFFFFF;
    border-color: #23283B;
}
element-icon {
    enabled: false;
}
element-text {
    cursor: inherit;
    vertical-align: 0.5;
}
element selected.normal, element selected.active {
    background-color: #D946EF;
    border-color: #D946EF;
}
element selected.normal element-text, element selected.active element-text {
    text-color: #0F111A;
}
'

# 2. Fungsi Ambil Status Sistem
get_sys_info() {
    local cpu_idle=$(top -bn1 | awk '/Cpu\(s\)/ {for(i=1;i<=NF;i++) if($i ~ /id/) print $(i-1)}')
    local cpu_usage
    if [ -n "$cpu_idle" ]; then
        cpu_usage=$(awk "BEGIN {printf \"%.1f%%\", 100 - $cpu_idle}")
    else
        cpu_usage="$(awk '{print $1}' /proc/loadavg) (load)"
    fi

    local mem_swap_info=$(awk '
    /^MemTotal:/      { total = $2 }
    /^MemFree:/       { free = $2 }
    /^Buffers:/       { buffers = $2 }
    /^Cached:/        { cached = $2 }
    /^SReclaimable:/  { sreclaim = $2 }
    /^Shmem:/         { shmem = $2 }
    /^SwapTotal:/     { sw_total = $2 }
    /^SwapFree:/      { sw_free = $2 }
    function fmt(kib) {
        if (kib >= 1048576) {
            return sprintf("%.1f GB", kib / 1048576)
        } else {
            return sprintf("%d MB", kib / 1024)
        }
    }
    END {
        used = total - free - buffers - cached - sreclaim + shmem
        if (used < 0) used = 0

        ram_str = fmt(used) " / " fmt(total)

        if (sw_total == 0) {
            swap_str = "Off"
        } else {
            swap_str = fmt(sw_total - sw_free) " / " fmt(sw_total)
        }

        print ram_str "|" swap_str
    }' /proc/meminfo)

    local ram_info="${mem_swap_info%|*}"
    local swap_info="${mem_swap_info#*|}"
    local disk_info=$(df -h / | awk 'NR==2 {print $3 " / " $2}')

    echo "  CPU: $cpu_usage    RAM: $ram_info    Swap: $swap_info    Disk: $disk_info"
}

# 3. Main Loop
while true; do
    SYS_INFO=$(get_sys_info)

    PROCESS_LIST=$(ps -eo pid,%cpu,rss,args --sort=-rss | tail -n +2 | head -n 50 | \
        awk '
        function human_mem(kib) {
            if (kib >= 1048576) {
                return sprintf("%.2f GB", kib / 1048576);
            } else if (kib >= 1024) {
                return sprintf("%.1f MB", kib / 1024);
            } else {
                return sprintf("%d KB", kib);
            }
        }
        {
            pid = $1;
            cpu = $2;
            rss = $3;
            $1 = ""; $2 = ""; $3 = "";
            sub(/^[ \t]+/, "");
            printf "%-7s │ RAM: %9s │ CPU: %5.1f%% │ %s\n", pid, human_mem(rss), cpu, $0
        }')

    # 4. Tampilkan Menu Utama (-hover-select dimatikan agar scroll tidak naik turun)
    SELECTED=$(echo "$PROCESS_LIST" | rofi \
        -dmenu \
        -i \
        -me-select-entry '' \
        -me-accept-entry MousePrimary \
        -p " " \
        -mesg "$SYS_INFO" \
        -theme-str "$ROFI_THEME")

    # Keluar jika Escape ditekan di menu utama
    [ -z "$SELECTED" ] && exit 0

    # 5. Ambil PID dan Nama Program
    PID=$(echo "$SELECTED" | awk '{print $1}')
    PROC_CMD=$(echo "$SELECTED" | awk -F '│' '{print $NF}' | xargs)
    PROC_SHORT=$(basename "$(echo "$PROC_CMD" | awk '{print $1}')")

    # Jeda mikro agar event klik dari menu pertama tuntas sebelum menu kedua muncul
    sleep 0.1

    # 6. Dialog Aksi
    ACTION=$(echo -e "1. Terminate (SIGTERM - Normal)\n2. Kill (SIGKILL - Paksa)\n3. Cancel (Kembali)" | rofi \
        -dmenu \
        -i \
        -me-select-entry '' \
        -me-accept-entry MousePrimary \
        -p "$PROC_SHORT PID: $PID" \
        -theme-str "$ACTION_THEME")

    # 7. Eksekusi Aksi
    case "$ACTION" in
        *"Terminate"*)
            kill -15 "$PID" && notify-send "Process Manager" "SIGTERM dikirim ke $PROC_SHORT (PID: $PID)"
            exit 0
            ;;
        *"Kill"*)
            kill -9 "$PID" && notify-send "Process Manager" "$PROC_SHORT (PID: $PID) berhasil di-kill!"
            exit 0
            ;;
        *"Cancel"*|*"Kembali"*)
            # HANYA opsi ini yang kembali ke daftar proses
            continue
            ;;
        *)
            # Klik di luar window, tekan Escape, atau klik lainnya langsung MENUTUP Rofi
            exit 0
            ;;
    esac
done