in vec4 gl_FragCoord;

#request uniform "screen" screen
uniform ivec2 screen;

#request uniform "audio_sz" audio_sz
uniform int audio_sz;

#include ":ncs.glsl"

#request uniform "audio_l" audio_l
#request transform audio_l "fft"
uniform sampler1D audio_l;

#request uniform "audio_r" audio_r
#request transform audio_r "fft"
uniform sampler1D audio_r;

out vec4 fragment;

#include ":util/smooth.glsl"

#define PI 3.14159265359
#define TWOPI 6.28318530718

// Ekstrak warna HEX dari preprocessor GLava
vec3 col_dot          = (COLOR_DOT).rgb;
vec3 col_dot_shadow   = (COLOR_DOT_SHADOW).rgb;
vec3 col_globe_bg     = (COLOR_GLOBE_BG).rgb;
vec3 col_graph_outer  = (COLOR_GRAPH_OUTER).rgb;
vec3 col_graph_peak   = (COLOR_GRAPH_PEAK).rgb;

// Fungsi Menghitung Titik Poros Berdasarkan 9 Grid Layar
vec2 get_grid_center(ivec2 scr) {
    float safe_margin = BASE_RADIUS + GRAPH_DEPTH + MARGIN_PADDING;
    float mx = clamp(safe_margin, 0.0, float(scr.x) * 0.45);
    float my = clamp(safe_margin, 0.0, float(scr.y) * 0.45);

    float left_x   = mx;
    float center_x = float(scr.x) * 0.5;
    float right_x  = float(scr.x) - mx;

    float top_y    = float(scr.y) - my;
    float center_y = float(scr.y) * 0.5;
    float bottom_y = my;

    #if POSITION_GRID == 1
        return vec2(left_x, top_y);
    #elif POSITION_GRID == 2
        return vec2(center_x, top_y);
    #elif POSITION_GRID == 3
        return vec2(right_x, top_y);
    #elif POSITION_GRID == 4
        return vec2(left_x, center_y);
    #elif POSITION_GRID == 6
        return vec2(right_x, center_y);
    #elif POSITION_GRID == 7
        return vec2(left_x, bottom_y);
    #elif POSITION_GRID == 8
        return vec2(center_x, bottom_y);
    #elif POSITION_GRID == 9
        return vec2(right_x, bottom_y);
    #else
        return vec2(center_x, center_y);
    #endif
}

// Fungsi Partikel Titik: Horizontal Mati Total Saat Bass Menghentak
float get_globe_dots(vec3 p, float melody, float raw_bass, float r_norm, float bass_mode) {
    float lat = asin(clamp(p.y, -1.0, 1.0));
    float lat_step = PI / GLOBE_ROWS;
    float lat_idx = floor((lat / lat_step) + 0.5);
    float snapped_lat = lat_idx * lat_step;
    
    float circ = cos(snapped_lat);
    float num_dots = max(1.0, floor((GLOBE_COLS * circ) + 0.5));
    
    float lon = atan(p.z, p.x);
    float lon_step = TWOPI / num_dots;
    float lon_idx = floor((lon / lon_step) + 0.5);
    float snapped_lon = lon_idx * lon_step;
    
    vec3 dot_center = vec3(
        cos(snapped_lat) * cos(snapped_lon),
        sin(snapped_lat),
        cos(snapped_lat) * sin(snapped_lon)
    );
    
    float d_dot = length(p - dot_center);

    // ==============================================================
    // 1. POLA MELODI HORIZONTAL
    // ==============================================================
    float travel_phase = sin((lat_idx * MELODY_WAVE_FREQ) - (melody * MELODY_WAVE_SPEED));
    float band_intensity = smoothstep(-0.4, 0.75, travel_phase);

    float lat_norm = abs(snapped_lat) / (PI * 0.5);
    float row_sample_pos = clamp(lat_norm * 0.38 + 0.04, 0.03, 0.65);
    float row_freq_l = smooth_audio(audio_l, audio_sz, row_sample_pos);
    float row_freq_r = smooth_audio(audio_r, audio_sz, row_sample_pos);
    float row_freq = (row_freq_l + row_freq_r) * 0.5;

    float raw_melody_pattern = (band_intensity * 0.5 + 0.5) * (row_freq * 1.5 + melody * 1.1) * MELODY_RESIZE_SCALE;

    // MATIKAN TOTAL HORIZONTAL KETIKA BASS MODE AKTIF (1.0 - bass_mode)
    float melody_pattern = raw_melody_pattern * (1.0 - bass_mode);

    // ==============================================================
    // 2. POLA BASS CIRCLE WAVE (MENONJOL MAKSIMAL SAAT BASS MASUK)
    // ==============================================================
    float ring_travel = sin((r_norm * BASS_RING_FREQ * PI) - (raw_bass * BASS_WAVE_SPEED));
    // Cincin gelombang dibuat sangat kontras dan tegas
    float ring_band = smoothstep(-0.25, 0.75, ring_travel);
    float circle_pattern = ring_band * (BASS_RING_SCALE * bass_mode);

    // ==============================================================
    // 3. KOMBINASI UKURAN TITIK
    // ==============================================================
    // Saat bass_mode = 1.0 -> melody_pattern = 0.0 (horizontal mati total)
    // Hanya circle_pattern yang hidup dan mendominasi penuh!
    float combined_scale = melody_pattern + circle_pattern;
    combined_scale = min(combined_scale, MAX_DOT_SCALE);

    float dynamic_size = DOT_SIZE * (1.0 + combined_scale);
    dynamic_size = clamp(dynamic_size, 0.002, 0.036);

    return smoothstep(dynamic_size, dynamic_size * 0.68, d_dot);
}

void main() {
    vec2 center = get_grid_center(screen);
    vec2 pos = gl_FragCoord.xy - center;
    float dist = length(pos);
    float angle = atan(pos.y, pos.x);

    // =================================================================
    // 1. EKSTRAKSI FREKUENSI AUDIO DENGAN DETEKSI BASS PEKA
    // =================================================================
    float f_sub   = (smooth_audio(audio_l, audio_sz, 0.012) + smooth_audio(audio_r, audio_sz, 0.012)) * 0.5;
    float f_punch = (smooth_audio(audio_l, audio_sz, 0.028) + smooth_audio(audio_r, audio_sz, 0.028)) * 0.5;

    // Nilai bass riil murni dari sub-kick drum
    float raw_bass = max(f_sub, f_punch * 1.15);

    // BASS MODE: 0.0 (Melodi Horizontal) s.d 1.0 (Bass Cincin Aktif Penuh & Horizontal Mati)
    float bass_mode = smoothstep(BASS_TRIGGER_THRESH, BASS_TRIGGER_THRESH + 0.12, raw_bass);

    // Frekuensi Melodi (Piano, Gitar, Vokal)
    float f_lowm1 = (smooth_audio(audio_l, audio_sz, 0.055) + smooth_audio(audio_r, audio_sz, 0.055)) * 0.5;
    float f_lowm2 = (smooth_audio(audio_l, audio_sz, 0.105) + smooth_audio(audio_r, audio_sz, 0.105)) * 0.5;
    float f_mid1  = (smooth_audio(audio_l, audio_sz, 0.190) + smooth_audio(audio_r, audio_sz, 0.190)) * 0.5;
    float f_mid2  = (smooth_audio(audio_l, audio_sz, 0.350) + smooth_audio(audio_r, audio_sz, 0.350)) * 0.5;
    float f_high  = (smooth_audio(audio_l, audio_sz, 0.580) + smooth_audio(audio_r, audio_sz, 0.580)) * 0.5;

    float melody_peak_low  = max(f_lowm1, f_lowm2);
    float melody_peak_mid  = max(f_mid1, f_mid2);
    float melody_peak_high = f_high;
    
    float melody = max(melody_peak_low * 1.4, max(melody_peak_mid * 1.2, melody_peak_high * 0.8)) * MELODY_SENSITIVITY;

    float total_audio = (raw_bass + f_lowm1 + f_lowm2 + f_mid1 + f_mid2 + f_high) * 1.4;
    float dot_visibility = smoothstep(0.008, 0.08, total_audio);

    // Radius dinamis bola (mendat-mendut)
    float radius = BASE_RADIUS + (raw_bass * PULSE_STRENGTH);

    // Masking batas luar bola
    float sphere_mask = smoothstep(radius + 1.5, radius - 1.5, dist);
    if (sphere_mask == 0.0) {
        fragment = vec4(0.0);
        return;
    }

    // -----------------------------------------------------------------
    // 2. SISTEM ROTASI 3D GLOBE DENGAN KEMIRINGAN TILT
    // -----------------------------------------------------------------
    vec2 rot_vec = vec2(0.0);
    rot_vec += raw_bass * vec2( 1.00,  0.00);
    rot_vec += f_lowm1  * vec2( 0.71,  0.71);
    rot_vec += f_lowm2  * vec2( 0.00,  1.00);
    rot_vec += f_mid1   * vec2(-0.71,  0.71);
    rot_vec += f_mid2   * vec2(-1.00,  0.00);
    rot_vec += f_high   * vec2( 0.00, -1.00);

    float phase_angle = atan(rot_vec.y, rot_vec.x);
    float ry = (phase_angle * ROT_SPEED) + (melody * 0.75 * ROT_SPEED);
    float rx = (raw_bass * 0.35 * ROT_SPEED);

    float tilt_rad = radians(GLOBE_TILT);

    mat3 rotX = mat3(
        1.0, 0.0, 0.0,
        0.0, cos(rx), -sin(rx),
        0.0, sin(rx), cos(rx)
    );
    mat3 rotY = mat3(
        cos(ry), 0.0, sin(ry),
        0.0, 1.0, 0.0,
        -sin(ry), 0.0, cos(ry)
    );
    mat3 rotTilt = mat3(
        cos(tilt_rad), -sin(tilt_rad), 0.0,
        sin(tilt_rad),  cos(tilt_rad), 0.0,
        0.0,            0.0,           1.0
    );

    // 3. Proyeksi Kedalaman 3D
    float z_screen = sqrt(max(0.0, radius * radius - dist * dist));
    vec3 p_screen_front = vec3(pos.x, pos.y, z_screen) / radius;
    vec3 p_screen_back  = vec3(pos.x, pos.y, -z_screen) / radius;

    vec3 p_front = rotY * rotX * rotTilt * p_screen_front;
    vec3 p_back  = rotY * rotX * rotTilt * p_screen_back;

    // 4. Hitung Partikel Titik Mikro (Horizontal Mati saat Bass Mode Aktif)
    float r_norm = clamp(dist / radius, 0.0, 1.0);
    float dots_front = get_globe_dots(p_front, melody, raw_bass, r_norm, bass_mode);
    float dots_back  = get_globe_dots(p_back, melody, raw_bass, r_norm, bass_mode);

    // 5. Pencahayaan 3D Stabil
    vec3 sphere_normal = vec3(pos.x, pos.y, z_screen) / radius;
    vec3 light_dir = normalize(vec3(0.35, 0.45, 0.82));
    float light_diff = clamp(dot(sphere_normal, light_dir) * 0.45 + 0.55, 0.25, 1.0);

    vec3 dot_front_color = mix(col_dot_shadow, col_dot, light_diff);
    vec3 dot_back_color  = col_dot_shadow;

    // -----------------------------------------------------------------
    // 6. PIPELINE WARNA & OPASITAS GEOMETRIS
    // -----------------------------------------------------------------
    vec3 final_color = vec3(0.0);
    float final_alpha = 0.0;

    // A. Badan Bola Belakang
    if (GLOBE_BG_OPACITY > 0.0) {
        float inner_sphere = smoothstep(radius, radius - 2.0, dist);
        final_color = col_globe_bg;
        final_alpha = GLOBE_BG_OPACITY * inner_sphere;
    }

    // B. Komposisi Partikel Titik
    float dot_boundary_mask = smoothstep(radius, radius - 2.5, dist);
    if (dot_visibility > 0.0) {
        float dot_back_cov  = dots_back * 0.25 * dot_visibility * dot_boundary_mask;
        float dot_front_cov = dots_front * 1.5 * dot_visibility * dot_boundary_mask;

        if (dot_back_cov > 0.0) {
            final_color = mix(final_color, dot_back_color, dot_back_cov);
            final_alpha = max(final_alpha, dot_back_cov);
        }
        if (dot_front_cov > 0.0) {
            final_color = mix(final_color, dot_front_color, clamp(dot_front_cov, 0.0, 1.0));
            final_alpha = max(final_alpha, clamp(dot_front_cov, 0.0, 1.0));
        }
    }

    // C. Solid Filled Circle Graph
    float d_from_rim = radius - dist;
    float continuous_sweep = (phase_angle * 1.2) + ((raw_bass + f_lowm2 + f_mid2) * 2.5);
    float graph_rot = continuous_sweep * GRAPH_ROT_SPEED;
    float rotated_graph_angle = angle + graph_rot;

    float norm_ang = abs(mod((rotated_graph_angle * 2.0) + PI, TWOPI) - PI) / PI;
    norm_ang = clamp(norm_ang, 0.0, 1.0);

    float wave_amp = (smooth_audio(audio_l, audio_sz, norm_ang) + 
                      smooth_audio(audio_r, audio_sz, norm_ang)) * 0.5;
    float wave_depth = wave_amp * GRAPH_DEPTH;

    if (d_from_rim <= wave_depth && wave_depth > 1.0) {
        float fill_ratio = d_from_rim / max(wave_depth, 1.0);
        vec3 fill_color = mix(col_graph_outer, col_graph_peak, fill_ratio);
        
        final_color = mix(final_color, fill_color, 0.85);
        final_alpha = max(final_alpha, 0.85);
    }

    // D. Garis Kontur Puncak Grafik
    float edge_dist = abs(d_from_rim - wave_depth);
    float edge_line = smoothstep(GRAPH_LINE_WIDTH, 0.0, edge_dist) * smoothstep(1.5, 6.0, wave_depth);
    if (edge_line > 0.0) {
        final_color = mix(final_color, col_graph_peak, edge_line);
        final_alpha = max(final_alpha, edge_line);
    }

    // E. Garis Lingkar Luar Bola (Rim)
    float rim = smoothstep(0.92, 1.0, dist / radius) * 0.35;
    vec3 rim_color = mix(vec3(0.3), col_graph_outer, dot_visibility);
    final_color = mix(final_color, rim_color, rim);
    final_alpha = max(final_alpha, rim);

    // Terapkan batas mask bola luar
    final_alpha *= sphere_mask;

    fragment = vec4(final_color, clamp(final_alpha, 0.0, 1.0));
}