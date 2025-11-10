// Simple CRT effect for LÖVE2D
// Minimalist approach - just the essentials

extern number time;
extern vec2 resolution;
extern float scanlines_opacity;
extern float scanlines_width;
extern float grille_opacity;
extern float static_noise_intensity;
extern float aberration;
extern float brightness;
extern float warp_amount;
extern float vignette_opacity;
extern float vignette_intensity;

// Simple random function
float rand(vec2 co){
    return fract(sin(dot(co.xy, vec2(12.9898, 78.233))) * 43758.5453);
}

// Very gentle warp
vec2 warp(vec2 uv){
    vec2 delta = uv - 0.5;
    float delta2 = dot(delta, delta);
    return uv + delta * delta2 * warp_amount;
}

// Vignette
float vignette(vec2 uv){
    uv *= 1.0 - uv.xy;
    float vig = uv.x * uv.y * 15.0;
    return pow(vig, vignette_intensity * vignette_opacity);
}

vec4 effect(vec4 color, Image texture, vec2 texture_coords, vec2 screen_coords)
{
    // Apply subtle warp
    vec2 uv = warp(texture_coords);
    
    // Clamp UV to prevent black borders
    uv = clamp(uv, 0.0, 1.0);
    
    // Sample with chromatic aberration
    float aberr = aberration * 0.001;
    vec4 col;
    col.r = Texel(texture, uv + vec2(aberr, 0.0)).r;
    col.g = Texel(texture, uv).g;
    col.b = Texel(texture, uv - vec2(aberr, 0.0)).b;
    col.a = 1.0;
    
    // Scanlines
    if (scanlines_opacity > 0.0) {
        float scanline = sin(uv.y * resolution.y * 3.14159265);
        float s = smoothstep(scanlines_width, scanlines_width + 0.5, abs(scanline));
        col.rgb = mix(col.rgb * 0.5, col.rgb, s);
        col.rgb = mix(col.rgb, col.rgb * vec3(s), scanlines_opacity);
    }
    
    // RGB grille (subtle)
    if (grille_opacity > 0.0) {
        float x_pos = uv.x * resolution.x;
        float grille = 1.0 - abs(sin(x_pos * 3.14159265)) * grille_opacity;
        col.rgb *= grille;
    }
    
    // Static noise
    if (static_noise_intensity > 0.0) {
        float noise = rand(uv + fract(time)) * static_noise_intensity;
        col.rgb += noise;
    }
    
    // Apply brightness
    col.rgb *= brightness;
    
    // Vignette (subtle)
    float vig = vignette(uv);
    col.rgb = mix(col.rgb * 0.3, col.rgb, vig);
    
    return col * color;
}
