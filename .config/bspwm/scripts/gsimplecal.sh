#!/usr/bin/env bash

# Toggle: Jika sudah terbuka, tutup. Jika belum, buka.
if pgrep -x gsimplecal >/dev/null; then 
    pkill -x gsimplecal
else
    gsimplecal &
fi