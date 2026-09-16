#!/bin/bash

SERVICE="mprisence.service"
# Perintah untuk membuka AIMP (sesuaikan jika Anda menjalankannya lewat command lain/Wine)
PLAYER_CMD="aimp"

# Bagian Toggle
if [ "$1" == "--toggle" ]; then
    if systemctl --user is-active --quiet "$SERVICE"; then
        # JIKA AKTIF: Matikan HANYA mprisence-nya saja (AIMP tetap dibiarkan menyala)
        systemctl --user stop "$SERVICE"
    else
        # JIKA NONAKTIF: Nyalakan service mprisence
        systemctl --user start "$SERVICE"

        # Buka AIMP jika belum berjalan (di-detach di background agar polybar tidak freeze)
        if ! pgrep -i -f "$PLAYER_CMD" >/dev/null; then
            nohup "$PLAYER_CMD" >/dev/null 2>&1 &
        fi
    fi
    
    # Memaksa polybar untuk update instan
    # Catatan: Untuk "type = custom/script", action-nya adalah .exec (bukan .hook)
    polybar-msg action "#mprisence.exec" 2>/dev/null
    exit 0
fi

# Bagian Status
if systemctl --user is-active --quiet "$SERVICE"; then
    echo "%{F#FFFFFF}%{F-}"
else
    echo "%{F#FFFFFF}%{F-}"
fi