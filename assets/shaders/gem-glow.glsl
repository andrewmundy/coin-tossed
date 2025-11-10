// Gem glow shader - creates bright colored glow with white-hot center
// Samples the gem texture and creates an expanding glow with the gem's colors

extern number glow_intensity;
extern number glow_size;

vec4 effect(vec4 color, Image texture, vec2 texture_coords, vec2 screen_coords)
{
    // Sample the gem at the center
    vec4 gem_color = Texel(texture, texture_coords);
    
    // If the pixel is mostly transparent, create glow
    if (gem_color.a < 0.5) {
        // Sample multiple points from the texture to get average color
        vec4 avg_color = vec4(0.0);
        float samples = 0.0;
        
        // Sample in a grid pattern to get the gem's dominant color
        for (float x = 0.2; x <= 0.8; x += 0.3) {
            for (float y = 0.2; y <= 0.8; y += 0.3) {
                vec4 sample_color = Texel(texture, vec2(x, y));
                if (sample_color.a > 0.5) {
                    avg_color += sample_color;
                    samples += 1.0;
                }
            }
        }
        
        if (samples > 0.0) {
            avg_color /= samples;
            
            // Calculate distance from center
            vec2 center = vec2(0.5, 0.5);
            float dist = distance(texture_coords, center);
            
            // Create bright glow with white-hot center
            // Close to gem = bright white, far away = gem color fading to transparent
            float glow_dist = dist - 0.3;  // Start glow outside gem
            float glow_strength = smoothstep(0.6 * glow_size, 0.0, glow_dist) * glow_intensity;
            
            // Mix white (close) to gem color (far) based on distance
            float color_mix = smoothstep(0.0, 0.3 * glow_size, glow_dist);
            vec3 glow_color = mix(vec3(1.0), avg_color.rgb, color_mix);
            
            // Return glowing edge - very bright!
            return vec4(glow_color * 2.0, glow_strength);
        }
    }
    
    // Return original pixel with color tint
    return gem_color * color;
}
