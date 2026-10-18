in vec4 gl_FragCoord;

#request uniform "screen" screen
uniform ivec2 screen;

#request uniform "audio_sz" audio_sz
uniform int audio_sz;

/* #include "@twobars-white.glsl" */
#include ":twobars-white.glsl"

#request uniform "audio_l" audio_l
#request transform audio_l "window"
#request transform audio_l "fft"
#request transform audio_l "gravity"
#request transform audio_l "avg"
uniform sampler1D audio_l;

#request uniform "audio_r" audio_r
#request transform audio_r "window"
#request transform audio_r "fft"
#request transform audio_r "gravity"
#request transform audio_r "avg"
uniform sampler1D audio_r;

out vec4 fragment;
#include ":util/smooth.glsl"

#define TWOPI 6.28318530718
#define PI 3.14159265359

#if DISABLE_MONO == 1
#define _CHANNELS 2
#endif

void main() {

    #if MIRROR_YX == 0
    #define AREA_WIDTH screen.x
    #define AREA_HEIGHT screen.y
    #define AREA_X gl_FragCoord.x
    #define AREA_Y gl_FragCoord.y
    #else
    #define AREA_WIDTH screen.y
    #define AREA_HEIGHT screen.x
    #define AREA_X gl_FragCoord.y
    #define AREA_Y gl_FragCoord.x
    #endif

    #if _CHANNELS == 2
    float dx = (AREA_X - (AREA_WIDTH / 2));
    #else
    #if INVERT == 1
    float dx = AREA_WIDTH - AREA_X;
    #else
    float dx = AREA_X;
    #endif
    #endif
    float d = min(AREA_Y, AREA_HEIGHT - AREA_Y);
    float section = BAR_WIDTH + BAR_GAP;
    float center =  section / 2.0F;
    float m = abs(mod(dx, section));
    float md = m - center;
    float nbars = floor((AREA_WIDTH * 0.5F) / section) * 2;
    float p, s;
    if (md < ceil(float(BAR_WIDTH) / 2) && md >= -floor(float(BAR_WIDTH) / 2)) {
        s = dx / section;
        p = (sign(s) == 1.0 ? ceil(s) : floor(s));
        #if _CHANNELS == 2
        p /= float(nbars / 2);
        #else
        p /= float(nbars);
        #endif
        p += sign(p) * ((0.5F + center) / AREA_WIDTH);
        
        #define smooth_f(tex, p) smooth_audio(tex, audio_sz, p)
        float v;
        p = clamp(p, -1.0F, 1.0F);
        if (p > 0.0F) {
            #if DIRECTION == 1
            p = 1.0F - p;
            #endif
            #if _CHANNELS == 1
            v = smooth_f(audio_l, p);
            #elif INVERT > 0 
            v = smooth_f(audio_l, p);
            #else
            v = smooth_f(audio_r, p);
            #endif
        } else {
            p = abs(p);
            #if DIRECTION == 1
            p = 1.0F - p;
            #endif
            #if _CHANNELS == 1
            v = smooth_f(audio_l, p);
            #elif INVERT > 0
            v = smooth_f(audio_r, p);
            #else
            v = smooth_f(audio_l, p);
            #endif
        }
        #undef smooth_f

        v *= AMPLIFY;
        v = min(v, MAX_HEIGHT);

        /* ========================================================
         * 1. PENGATURAN WARNA & DASH
         * ======================================================== */
        #ifndef DASH_HEIGHT
        #define DASH_HEIGHT 3.5
        #endif
        #ifndef DASH_Y
        #define DASH_Y 10.0
        #endif
        #ifndef FLOAT_RATIO
        #define FLOAT_RATIO 0.55
        #endif

        vec3 color_white = vec3(1.0, 1.0, 1.0);
        vec3 color_sea   = vec3(0.02, 0.62, 0.98); /* Biru Laut Pekat & Cerah */

        float v_bottom = v * FLOAT_RATIO;
        bool is_in_dash = (d >= DASH_Y && d <= (DASH_Y + DASH_HEIGHT));

        /* ========================================================
         * 2. KONDISI A: BAR AKTIF MELAYANG (Ada Sinyal Suara)
         * ======================================================== */
        if (v > (DASH_Y + DASH_HEIGHT + 3.0) && d >= v_bottom && d < v - BAR_OUTLINE_WIDTH) {
            
            float progress = clamp((d - v_bottom) / max(v - v_bottom, 1.0), 0.0, 1.0);
            float signal_strength = clamp(v / MAX_HEIGHT, 0.0, 1.0);

            /* Biru laut dipertinggi porsinya:
             * - Sinyal santai: Biru laut menutupi 50% bagian atas bar.
             * - Sinyal tinggi: Biru laut menyelimuti hingga 85% badan bar!
             */
            float blue_coverage = mix(0.50, 0.85, signal_strength);
            float blue_start = 1.0 - blue_coverage;
            float blue_factor = smoothstep(blue_start, 0.95, progress);

            vec3 final_rgb = mix(color_white, color_sea, blue_factor);

            /* Alpha: Memudar transparan di bawah agar tetap melayang */
            float alpha = smoothstep(0.0, 0.55, progress);

            fragment = vec4(final_rgb, alpha);
            return;
        }

        /* ========================================================
         * 3. KONDISI B: RESTING DASH (Saat Sinyal Kosong / Hening)
         * ======================================================== */
        /* Jika frekuensi ini kosong/hening, tinggalkan dash biru laut agar tidak ompong */
        if (v <= (DASH_Y + DASH_HEIGHT + 3.0) && is_in_dash) {
            fragment = vec4(color_sea, 0.95);
            return;
        }
    }
    
    /* Ruang kosong 100% transparan */
    fragment = vec4(0.0, 0.0, 0.0, 0.0);
}