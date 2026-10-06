/* Konfigurasi Custom Bar - Responsive Wave */

#define C_LINE 0

/* 1. Bar Ramping & Rapat (Menciptakan ilusi gelombang padat) */
#define BAR_WIDTH 20
#define BAR_GAP 0
#define BAR_OUTLINE_WIDTH 0

/* 2. Sensitivitas pantulan */
#define AMPLIFY 380
#define USE_ALPHA 1

/* warna Fuchsia (#FF007F) ke warna Teal (#00E5FF)
  20% ujung pucuk bertransisi ke  */
#define COLOR @fg:mix( #FF007F, #00E5FF, smoothstep(0.20, 1.0, d / max(v, 1.0)))

#define DIRECTION 1
#define INVERT 1
#define FLIP 1
#define MIRROR 0
#define DISABLE_MONO 1
#define MAX_HEIGHT 400.0   /* Bar tidak akan pernah lebih tinggi dari nilai */

/* 4. Kontrol Gravitasi & Transisi Gelombang */
/* Nilai gravitasi: Semakin tinggi, semakin cepat bar jatuh kembali setelah lompat karena bass */
#request setgravitystep 6.0

/* Smoothing factor: Semakin kecil nilainya (misal 0.02 - 0.035), lekukan gelombang antar bar semakin menyatu */
#request setsmoothfactor 0.025