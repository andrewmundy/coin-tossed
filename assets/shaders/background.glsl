// Balatro-style background shader
// Converted from Godot to LÖVE2D
// Original from Balatro: https://www.playbalatro.com

extern number time;
extern vec2 resolution;
extern number spin_rotation_speed;
extern number move_speed;
extern vec2 offset;
extern vec4 colour_1;
extern vec4 colour_2;
extern vec4 colour_3;
extern number contrast;
extern number lighting;
extern number spin_amount;
extern number pixel_filter;
extern bool is_rotating;

#define SPIN_EASE 1.0

vec4 background_effect(vec2 screenSize, vec2 screen_coords) {
    float pixel_size = length(screenSize.xy) / pixel_filter;
    vec2 uv = (floor(screen_coords.xy * (1.0 / pixel_size)) * pixel_size - 0.5 * screenSize.xy) / length(screenSize.xy) - offset;
    float uv_len = length(uv);

    float speed = (spin_rotation_speed * SPIN_EASE * 0.2);
    if (is_rotating) {
        speed = time * speed;
    }
    speed += 302.2;
    float new_pixel_angle = atan(uv.y, uv.x) + speed - SPIN_EASE * 20.0 * (1.0 * spin_amount * uv_len + (1.0 - 1.0 * spin_amount));
    
    // Rotate around origin (already centered)
    uv = vec2(uv_len * cos(new_pixel_angle), uv_len * sin(new_pixel_angle));

    uv *= 30.0;
    speed = time * move_speed;
    vec2 uv2 = vec2(uv.x + uv.y);

    for (int i = 0; i < 5; i++) {
        uv2 += sin(max(uv.x, uv.y)) + uv;
        uv += 0.5 * vec2(cos(5.1123314 + 0.353 * uv2.y + speed * 0.131121), sin(uv2.x - 0.113 * speed));
        uv -= 1.0 * cos(uv.x + uv.y) - 1.0 * sin(uv.x * 0.711 - uv.y);
    }

    float contrast_mod = (0.25 * contrast + 0.5 * spin_amount + 1.2);
    float paint_res = min(2.0, max(0.0, length(uv) * (0.035) * contrast_mod));
    float c1p = max(0.0, 1.0 - contrast_mod * abs(1.0 - paint_res));
    float c2p = max(0.0, 1.0 - contrast_mod * abs(paint_res));
    float c3p = 1.0 - min(1.0, c1p + c2p);
    
    float light = (lighting - 0.2) * max(c1p * 5.0 - 4.0, 0.0) + lighting * max(c2p * 5.0 - 4.0, 0.0);
    vec4 ret_col = (0.3 / contrast) * colour_1 + (1.0 - 0.3 / contrast) * (colour_1 * c1p + colour_2 * c2p + vec4(c3p * colour_3.rgb, c3p * colour_1.a)) + light;
    return ret_col;
}

vec4 effect(vec4 color, Image texture, vec2 texture_coords, vec2 screen_coords) {
    return background_effect(resolution, screen_coords);
}

