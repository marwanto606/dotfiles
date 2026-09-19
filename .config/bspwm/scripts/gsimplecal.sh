#!/bin/bash

# Toggle: Jika kalender sudah terbuka, tutup
if xdotool search --onlyvisible --classname gsimplecal 2>/dev/null; then
    xdotool search --onlyvisible --classname gsimplecal | xargs -r xdotool windowclose
    exit 0
fi

# Jalankan gsimplecal (posisi & ukuran otomatis ditangani bspwmrc)
gsimplecal &