in vec4 gl_FragCoord;

#request uniform "screen" screen
uniform ivec2 screen;

#request uniform "audio_sz" audio_sz
uniform int audio_sz;

#include ":twowaves.glsl"

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

#define TWOPI 6.28318530718
#define PI 3.14159265359

#if DISABLE_MONO == 1
#define _CHANNELS 2
#endif

/* ========================================================
   FUNGSI SPATIAL BLUR + STEREO CROSSFADE SEAMLESS
   ======================================================== */
float sample_fluid_unified(float nx, int sz, float blur) {
    float val = 0.0;
    float weight_sum = 0.0;
    float spread = blur / float(sz);
    
    for(float i = -6.0; i <= 6.0; i += 1.0) { 
        float w = exp(-0.5 * pow(i / (blur * 0.5), 2.0)); 
        float sample_nx = clamp(nx + (i * spread), -1.0, 1.0);
        
        float p = abs(sample_nx);
        #if DIRECTION == 1
        p = 1.0 - p;
        #endif
        p = clamp(p, 0.0, 1.0);
        
        float s_val = 0.0;
        #if _CHANNELS == 2
            // Ambil data frekuensi Kiri & Kanan sekaligus
            float val_L = texture(audio_l, p).x;
            float val_R = texture(audio_r, p).x;
            
            #if INVERT > 0
            float val_pos = val_L;
            float val_neg = val_R;
            #else
            float val_pos = val_R;
            float val_neg = val_L;
            #endif
            
            /* KUNCI PENGHILANG GARIS ASIMETRIS (CROSSFADE):
               Fungsi smoothstep(-0.1, 0.1) akan membuat 10% area di tengah layar 
               menjadi zona transisi percampuran (blend). 
               Di tengah pas (0.0), visualizer membaca persis 50% Kiri + 50% Kanan 
               sehingga kedua sisi menyambung sempurna dan garis/tangga hilang permanen. */
            float mix_ratio = smoothstep(-0.1, 0.1, sample_nx);
            s_val = mix(val_neg, val_pos, mix_ratio);
        #else
            s_val = texture(audio_l, p).x;
        #endif
        
        val += s_val * w;
        weight_sum += w;
    }
    return val / weight_sum;
}

void main() {
    #if MIRROR_YX == 0
    float area_w = float(screen.x);
    float area_h = float(screen.y);
    float pos_x  = gl_FragCoord.x;
    float pos_y  = gl_FragCoord.y;
    #else
    float area_w = float(screen.y);
    float area_h = float(screen.x);
    float pos_x  = gl_FragCoord.y;
    float pos_y  = gl_FragCoord.x;
    #endif

    float d = min(pos_y, area_h - pos_y);

    float norm_x = (pos_x - (area_w * 0.5)) / (area_w * 0.5);
    norm_x = clamp(norm_x, -1.0, 1.0);

    /* Eksekusi fungsi Blur & Crossfade */
    float v = sample_fluid_unified(norm_x, audio_sz, float(BLUR_RADIUS));

    v *= float(AMPLIFY);
    v = min(v, float(MAX_HEIGHT));

    float alpha = smoothstep(v + (float(EDGE_SOFTNESS) * 0.5), v - float(EDGE_SOFTNESS), d);

    if (alpha > 0.0) {
        vec4 base_wave = COLOR;

        float crest = smoothstep(v - (float(EDGE_SOFTNESS) * 3.0), v, d);
        vec4 final_color = mix(base_wave, CREST_COLOR, crest * 0.6);

        fragment = final_color * alpha;
        return;
    }

    fragment = vec4(0.0);
}