#!/bin/bash

# 1. Toggle: kalau htop sudah ada, tutup
if pgrep -x htop >/dev/null; then
    pkill -x htop
    exit 0
fi

# 2. Setup konfigurasi terpisah untuk "Task Manager" Mode
CONFIG_DIR="$HOME/.config/htop"
CUSTOM_HTOPRC="$CONFIG_DIR/htoprc_taskmanager"

mkdir -p "$CONFIG_DIR"
# Jika custom config belum ada, copy dari default
if [ ! -f "$CUSTOM_HTOPRC" ] && [ -f "$CONFIG_DIR/htoprc" ]; then
    cp "$CONFIG_DIR/htoprc" "$CUSTOM_HTOPRC"
fi

# 3. Jalankan Htop dengan custom config dan urutkan berdasar RAM (%MEM)
env HTOPRC="$CUSTOM_HTOPRC" xfce4-terminal \
    --disable-server \
    --class="HtopTaskManager" \
    --title="Task Manager" \
    --command="htop --sort-key PERCENT_MEM" &

# 4. --- FITUR AUTO CLOSE & ESCAPE TO CLOSE ---
(
    # Buat file konfigurasi hotkey sementara khusus untuk tombol Esc
    TMP_SXHKD="/tmp/htop_esc_bind"
    echo "Escape" > "$TMP_SXHKD"
    echo "    pkill -x htop" >> "$TMP_SXHKD"
    
    # Jalankan sxhkd sementara di background untuk menangkap tombol Esc
    sxhkd -c "$TMP_SXHKD" >/dev/null 2>&1 &
    SXHKD_PID=$!

    # Tunggu sebentar sampai window HtopTaskManager benar-benar muncul dan mendapat fokus
    for i in {1..15}; do
        FOCUSED_NODE=$(bspc query -N -n focused)
        FOCUSED_CLASS=$(xprop -id "$FOCUSED_NODE" WM_CLASS 2>/dev/null)
        
        if [[ "$FOCUSED_CLASS" == *"HtopTaskManager"* ]]; then
            break
        fi
        sleep 0.2
    done
    
    # Setelah fokus didapat, mulai pantau (Auto-close)
    while pgrep -x htop > /dev/null; do
        FOCUSED_NODE=$(bspc query -N -n focused)
        
        if [ -n "$FOCUSED_NODE" ]; then
            FOCUSED_CLASS=$(xprop -id "$FOCUSED_NODE" WM_CLASS 2>/dev/null)
            
            # Jika fokus hilang (klik window lain), tutup Htop!
            if [[ "$FOCUSED_CLASS" != *"HtopTaskManager"* ]]; then
                pkill -x htop
                break
            fi
        fi
        sleep 0.2 # Cek setiap 0.2 detik
    done
    
    # --- CLEANUP (Pembersihan) ---
    # Saat loop berhenti (karena Esc ditekan ATAU klik area lain), bersihkan hotkey sementara
    kill $SXHKD_PID 2>/dev/null
    rm -f "$TMP_SXHKD"
) &