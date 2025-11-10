// Ultra-simple CRT shader - just scanlines
// Configurable intensity

extern float scanline_intensity;  // How dark the scanlines are (0.0 = none, 0.2 = strong)

vec4 effect(vec4 color, Image texture, vec2 texture_coords, vec2 screen_coords)
{
    // Sample the texture normally
    vec4 texcolor = Texel(texture, texture_coords);
    
    // Simple scanlines with configurable intensity
    float scanline = sin(screen_coords.y * 3.14159 * 0.5) * scanline_intensity + (1.0 - scanline_intensity);
    
    // Apply scanline and return
    return texcolor * vec4(scanline, scanline, scanline, 1.0) * color;
}
