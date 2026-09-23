#!/usr/bin/env bash

FIFO="/tmp/ssr-pipe"
NOTIF_ID=9991  # ID khusus agar notifikasi saling menimpa/menggantikan

# Fungsi bantuan untuk mengirim/mengganti notifikasi di tempat yang sama
send_notif() {
    # -r: replace ID (menimpa)
    # -t: durasi muncul (1500 ms = 1.5 detik)
    notify-send -r "$NOTIF_ID" -t 1500 -u normal -i "$1" "Screen Recorder" "$2"
}

# Buat FIFO pipe jika belum ada
[ -p "$FIFO" ] || mkfifo "$FIFO"

# Pastikan SimpleScreenRecorder berjalan di latar belakang (tray)
if ! pgrep -f "simplescreenrecorder" > /dev/null; then
    tail -f /dev/null > "$FIFO" &
    simplescreenrecorder --start-hidden < "$FIFO" > /dev/null 2>&1 &
    sleep 0.5
fi

case "$1" in
    start)
        # 1. Tampilkan notifikasi aba-aba
        send_notif "media-record" "Perekaman dimulai"
        sleep 1.2
        
        # 2. Tutup notifikasi lebih dulu agar layar bersih (jika memakai dunst)
        command -v dunstctl &>/dev/null && dunstctl close
        
        # 3. Mulai perekaman (hasil video bersih tanpa popup)
        echo "record-start" > "$FIFO"
        ;;
        
    pause)
        # 1. Jeda perekaman terlebih dahulu
        echo "record-pause" > "$FIFO"
        sleep 0.2
        
        # 2. Tampilkan notifikasi setelah frame berhenti
        send_notif "media-playback-pause" "Perekaman Dijeda"
        ;;
        
    save)
        # 1. Simpan & matikan frame perekaman terlebih dahulu
        echo "record-save" > "$FIFO"
        sleep 0.2
        
        # 2. Tampilkan notifikasi bahwa file sudah tersimpan
        send_notif "media-playback-stop" "Rekaman Telah Disimpan"
        ;;
        
    gui)
        echo "window-show" > "$FIFO"
        ;;
        
    quit)
        echo "quit" > "$FIFO"
        killall -q tail
        notify-send -r "$NOTIF_ID" -t 1500 -u low "Screen Recorder" "SimpleScreenRecorder Dimatikan"
        ;;
        
    *)
        echo "Usage: $0 {start|pause|save|gui|quit}"
        ;;
esac