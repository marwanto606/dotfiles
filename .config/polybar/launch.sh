#!/bin/bash

polybar-msg cmd quit 2>/dev/null
killall -q polybar

# Ubah pgrep di sini
while pgrep -x polybar >/dev/null; do
    sleep 0.1
done

# Jalankan polybar
polybar -c "$HOME/.config/polybar/config.ini" main >/dev/null 2>&1 &