#!/bin/bash

# Tinggi padding BSPWM untuk Polybar
BAR_HEIGHT=45

CURRENT_PADDING=$(bspc config bottom_padding)

if [ "$CURRENT_PADDING" -gt 0 ]; then
    # KONDISI: Sedang Tampil -> SEMBUNYIKAN
    polybar-msg cmd hide
    bspc config bottom_padding 0
else
    # KONDISI: Sedang Tersembunyi -> TAMPILKAN
    # 1. Beri ruang padding
    bspc config bottom_padding "$BAR_HEIGHT"

    # 2. Munculkan Polybar
    polybar-msg cmd show

    # Tunggu sebentar (50ms) agar Polybar ter-render di X11
    sleep 0.05

    # 3. KUNCI SUSUNAN LAYER:
    # Pertama, turunkan Polybar (agar berada di bawah player fullscreen)
    xdo lower -N Polybar 2>/dev/null

    # Kedua, turunkan GLava (agar GLava berada di bawah Polybar)
    xdo lower -N GLava 2>/dev/null
fi