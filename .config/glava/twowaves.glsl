/* Konfigurasi Twowaves - Soft Fluid Curve */

#define C_LINE 0

/* Sensitivitas & Batas Tinggi */
#define AMPLIFY 320
#define USE_ALPHA 1
#define MAX_HEIGHT 250.0

/* Estetika Warna:
   Pangkal (tepi layar) Fuchsia transparan -> Pucuk gelombang Teal cerah */
#define BASE_COLOR vec4(1.0, 0.0, 0.5, 0.75)   /* Fuchsia */
#define PEAK_COLOR vec4(0.0, 0.9, 1.0, 1.0)    /* Bright Teal */
#define COLOR mix(BASE_COLOR, PEAK_COLOR, smoothstep(0.0, 1.0, d / max(v, 1.0)))

/* Highlight lembut di bibir puncak gelombang */
#define CREST_COLOR vec4(0.7, 1.0, 1.0, 1.0)

#define DIRECTION 1
#define INVERT 0
#define DISABLE_MONO 1

/* ========================================================
   KUNCI MENGHILANGKAN BENTUK BAR (FLUIDITY & GLOW)
   ======================================================== */
/* Radius Peleburan (BLUR_RADIUS):
   Nilai 4.0 - 6.0 akan melumerkan "bar-bar kecil" menjadi 
   satu lengkungan gelombang kurva yang sangat menyambung. 
   Semakin besar nilainya, gelombang semakin lebar dan mulus. */
#define BLUR_RADIUS 4.5

/* Kehalusan Tepi Gelombang (EDGE_SOFTNESS):
   Nilai 2.5 - 4.0 akan membuat tepi visualizer lebih lembut 
   (sedikit ada efek glow) dan menghilangkan tepi tajam bergerigi (pixelate). */
#define EDGE_SOFTNESS 3.0

/* ========================================================
   PHYSICS & TEMPORAL BLURRING (PERGERAKAN GRAVITASI)
   ======================================================== */
/* Nilai dinaikkan dari 0.025 ke 0.058 agar puncak audio 
   tidak berkedut tajam, melainkan naik-turun membulat. */
#request setsmoothfactor 0.058

/* Gravitasi dibuat lebih tenang agar gelombang turun dengan anggun */
#request setgravitystep 4.2