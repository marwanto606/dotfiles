#!/bin/bash

SERVICE="mprisence.service"

# Bagian Toggle
if [ "$1" == "--toggle" ]; then
    if systemctl --user is-active --quiet "$SERVICE"; then
        systemctl --user stop "$SERVICE"
    else
        systemctl --user start "$SERVICE"
    fi
    
    # Memaksa polybar untuk langsung mengupdate module mprisence
    # (Pastikan opsi enable-ipc = true ada di [bar/main] di config Polybar Anda)
    polybar-msg action "#mprisence.hook.0" 2>/dev/null
    exit 0
fi

# Bagian Status
if systemctl --user is-active --quiet "$SERVICE"; then
    echo "%{F#FFFFFF}♬%{F-}"
else
    echo "%{F#FFFFFF}◼%{F-}"
fi