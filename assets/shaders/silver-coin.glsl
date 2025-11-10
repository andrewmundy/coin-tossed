// Shader to recolor gold coin to silver
// Converts warm gold tones to cool silver tones

vec4 effect(vec4 color, Image texture, vec2 texture_coords, vec2 screen_coords)
{
    vec4 texcolor = Texel(texture, texture_coords);
    
    // Detect gold/yellow tones (high red and green, low blue)
    float is_gold = step(0.5, texcolor.r) * step(0.5, texcolor.g) * step(texcolor.b, 0.6);
    
    if (is_gold > 0.0) {
        // Convert to silver: desaturate and add blue tint
        float brightness = (texcolor.r + texcolor.g + texcolor.b) / 3.0;
        
        // Silver has a slight blue tint
        vec3 silver = vec3(brightness * 0.9, brightness * 0.95, brightness * 1.0);
        
        texcolor.rgb = silver;
    }
    
    return texcolor * color;
}

