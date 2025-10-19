shader_type canvas_item;

// Adjustable parameters
uniform float glitch_intensity : hint_range(0.0, 1.0) = 0.5;
uniform float distortion_amount : hint_range(0.0, 0.5) = 0.1;
uniform float aberration_amount : hint_range(0.0, 0.1) = 0.03;
uniform float scan_line_count : hint_range(0.0, 500.0) = 200.0;
uniform float noise_amount : hint_range(0.0, 1.0) = 0.2;
uniform sampler2D screen_texture : hint_screen_texture, repeat_disable, filter_nearest;

// Random function
float rand(vec2 co) {
    return fract(sin(dot(co.xy, vec2(12.9898, 78.233))) * 43758.5453);
}

// Noise function
float noise(vec2 p) {
    vec2 i = floor(p);
    vec2 f = fract(p);
    
    float a = rand(i);
    float b = rand(i + vec2(1.0, 0.0));
    float c = rand(i + vec2(0.0, 1.0));
    float d = rand(i + vec2(1.0, 1.0));
    
    vec2 u = f * f * (3.0 - 2.0 * f);
    
    return mix(a, b, u.x) + (c - a) * u.y * (1.0 - u.x) + (d - b) * u.x * u.y;
}

void fragment() {
    vec2 uv = SCREEN_UV;
    float time = TIME;
    
    // Use glitch intensity directly (no automatic pulsing)
    float current_intensity = glitch_intensity;
    
    // Horizontal distortion blocks
    float block_size = 0.05;
    float block_y = floor(uv.y / block_size) * block_size;
    float distortion_noise = noise(vec2(block_y * 10.0, time * 2.0));
    float distortion = 0.0;
    
    if (distortion_noise > 0.6) {
        distortion = (distortion_noise - 0.6) * distortion_amount * current_intensity;
    }
    
    // Apply horizontal displacement
    vec2 distorted_uv = uv;
    distorted_uv.x += distortion * sin(time * 50.0);
    
    // RGB channel separation (chromatic aberration)
    float aberration = aberration_amount * current_intensity;
    vec2 r_offset = vec2(aberration, 0.0);
    vec2 g_offset = vec2(0.0, 0.0);
    vec2 b_offset = vec2(-aberration, 0.0);
    
    // Add some vertical aberration based on noise
    float vert_noise = noise(vec2(time * 3.0, uv.y * 20.0));
    r_offset.y += vert_noise * aberration * 0.5;
    b_offset.y -= vert_noise * aberration * 0.5;
    
    // Sample color channels separately
    vec4 r_channel = texture(screen_texture, distorted_uv + r_offset);
    vec4 g_channel = texture(screen_texture, distorted_uv + g_offset);
    vec4 b_channel = texture(screen_texture, distorted_uv + b_offset);
    
    // Combine channels
    vec4 color = vec4(r_channel.r, g_channel.g, b_channel.b, 1.0);
    
    // Digital noise overlay
    float digital_noise = rand(uv + vec2(time * 0.001)) * noise_amount * current_intensity;
    color.rgb += vec3(digital_noise);
    
    // Scanlines
    float scanline = sin(uv.y * scan_line_count * 3.14159) * 0.04 * current_intensity;
    color.rgb -= scanline;
    
    // Random blackout lines
    float line_noise = noise(vec2(time * 5.0, floor(uv.y * 30.0)));
    if (line_noise > 0.95) {
        color.rgb *= 0.3;
    }
    
    // Flickering brightness (more stable now, only flickers at high intensity)
    float flicker = 1.0;
    if (current_intensity > 0.7) {
        flicker = 1.0 - (rand(vec2(time * 0.1)) * 0.2 * (current_intensity - 0.7) / 0.3);
    }
    color.rgb *= flicker;
    
    // Color corruption
    float corruption = noise(vec2(time * 10.0, uv.x * uv.y * 100.0));
    if (corruption > 0.9 && current_intensity > 0.5) {
        color.rgb = vec3(
            color.r * 2.0,
            color.g * 0.5,
            color.b * (sin(time * 20.0) + 1.0)
        );
    }
    
    // Ensure we don't go out of bounds
    color = clamp(color, 0.0, 1.0);
    
    COLOR = color;
}