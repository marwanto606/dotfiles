/* Konfigurasi Custom Bar - High Visibility Sea Blue & Anti-Ompong Dash */

#define C_LINE 0

/* 1. Dimensi Bar Rapi */
#define BAR_WIDTH 8
#define BAR_GAP 3
#define BAR_OUTLINE_WIDTH 0

/* 2. Batas Tinggi Aman (Tidak Menutupi Kepala Karakter) */
#define MAX_HEIGHT 220.0
#define AMPLIFY 280
#define USE_ALPHA 1

/* 3. Rasio Melayang (55% bawah dipotong) */
#define FLOAT_RATIO 0.55

/* 4. Pengaturan Resting Dash (Saat Sinyal Kosong) */
#define DASH_HEIGHT 3.5          /* Ketebalan strip dash (3.5 pixel) */
#define DASH_Y 10.0              /* Ketinggian melayang strip dash dari dasar layar */

#define DIRECTION 1
#define INVERT 1
#define FLIP 1
#define MIRROR 0
#define DISABLE_MONO 1

/* 5. Respon Beat Lincah */
#request setgravitystep 4.2
#request setsmoothfactor 0.038