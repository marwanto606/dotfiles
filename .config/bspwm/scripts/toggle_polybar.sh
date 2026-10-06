#!/bin/bash

# Tinggi Polybar Anda (sesuaikan nilainya, misal 20 atau 25)
BAR_HEIGHT=20

# Cek kondisi saat ini berdasarkan nilai bottom_padding BSPWM
CURRENT_PADDING=$(bspc config bottom_padding)

if [ "$CURRENT_PADDING" -gt 0 ]; then
    # KONDISI: Sedang Tampil -> SEMBUNYIKAN
    polybar-msg cmd hide
    bspc config bottom_padding 0
else
    # KONDISI: Sedang Tersembunyi -> TAMPILKAN
    # 1. Geser jendela terlebih dahulu dengan memberi padding
    bspc config bottom_padding "$BAR_HEIGHT"

    # 2. Munculkan Polybar kembali
    polybar-msg cmd show

    # 3. Angkat jendela Polybar ke depan agar tidak tertutup window lain
    xdo raise -N Polybar
fi