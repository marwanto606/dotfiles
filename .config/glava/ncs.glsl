/* === POSISI 9 GRID LAYAR ===
   1 = Kiri-Atas     2 = Tengah-Atas     3 = Kanan-Atas
   4 = Kiri-Tengah   5 = Tengah (Pusat)  6 = Kanan-Tengah
   7 = Kiri-Bawah    8 = Tengah-Bawah    9 = Kanan-Bawah
*/
#define POSITION_GRID   1       /* Pilih angka 1 sampai 9 */
#define MARGIN_PADDING  20.0    /* Jarak aman (pixel) dari tepi layar */

/* === BOLA GLOBE MENDAT-MENDUT === */
#define BASE_RADIUS 165.0       /* Radius dasar bola saat diam (pixel) */
#define PULSE_STRENGTH 115.0    /* Kekuatan membal bola saat bass masuk */

/* === PENGATURAN DASAR PARTIKEL === */
#define GLOBE_ROWS 34.0         /* Jumlah baris lintang */
#define GLOBE_COLS 68.0         /* Jumlah kolom bujur */
#define DOT_SIZE 0.010          /* Ukuran dasar partikel mikro */
#define GLOBE_TILT 0.0        /* Sudut kemiringan pola dot (derajat) */

/* === PENGATURAN POLA MELODI (HORIZONTAL) === */
#define MELODY_SENSITIVITY   1.3    /* Kepekaan deteksi melodi */
#define MELODY_RESIZE_SCALE  3.0     /* Skala pembesaran garis horizontal */
#define MELODY_WAVE_FREQ     3.8    /* Kerapatan garis pita horizontal */
#define MELODY_WAVE_SPEED    5.0   /* Kecepatan gelombang horizontal naik-turun */

/* === PENGATURAN POLA BASS (CIRCLE WAVE MANDIRI) === */
#define BASS_TRIGGER_THRESH  0.07   /* Ambang deteksi kick (semakin kecil = semakin peka mematikan horizontal) */
#define BASS_RING_SCALE      3.0    /* Skala pembesaran cincin lingkaran agar SANGAT MENONJOL */
#define BASS_RING_FREQ       3.8    /* Kerapatan cincin lingkaran konsentris */
#define BASS_WAVE_SPEED      10.0   /* Kecepatan riak cincin merambat keluar */
#define MAX_DOT_SCALE        2.8    /* Batas maksimal pembesaran titik (anti-balok tebal) */

/* === PERPUTARAN === */
#define ROT_SPEED 0.0          /* Kecepatan putaran bola partikel 3D */
#define GRAPH_ROT_SPEED 0.0     /* Kecepatan putaran grafik ke kanan */

/* === SOLID FILLED CIRCLE GRAPH (DUAL-BALANCED) === */
#define GRAPH_DEPTH 90.0        /* Kedalaman grafik menusuk ke pusat bola */
#define GRAPH_LINE_WIDTH 5.0    /* Ketebalan garis pembatas gelombang */

/* === PEWARNAAN MENGGUNAKAN KODE HEX === */
#define COLOR_DOT           #00E5FF   /* Warna titik partikel */
#define COLOR_DOT_SHADOW    #003344   /* Warna bayangan titik 3D */

/* Pengaturan Kontras Badan Bola (Globe Body): */
#define COLOR_GLOBE_BG      #000000   /* Warna dasar badan bola di belakang titik */
#define GLOBE_BG_OPACITY    0.5       /* Opasitas badan bola */

/* Warna Gradien Grafik (General): */
#define COLOR_GRAPH_OUTER   #FF007F   /* Warna bibir luar grafik (pangkal) */
#define COLOR_GRAPH_PEAK    #00E5FF   /* Warna puncak grafik menusuk ke dalam */