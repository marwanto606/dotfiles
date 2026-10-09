#!/bin/bash

# Matikan instance polybar yang sedang berjalan
polybar-msg cmd quit 2>/dev/null
killall -q polybar

while pgrep -x polybar >/dev/null; do
    sleep 0.1
done

# Jalankan polybar secara dinamis berdasarkan monitor yang terhubung
if command -v xrandr >/dev/null 2>&1; then
    # Loop semua monitor yang statusnya "connected"
    for m in $(xrandr --query | grep " connected" | cut -d" " -f1); do
        MONITOR=$m polybar -c "$HOME/.config/polybar/config.ini" main >/dev/null 2>&1 &
    done
else
    # Cadangan jika xrandr tidak ada
    polybar -c "$HOME/.config/polybar/config.ini" main >/dev/null 2>&1 &
fi