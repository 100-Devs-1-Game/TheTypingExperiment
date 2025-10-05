shader_type canvas_item;

uniform sampler2D tex: filter_linear;
uniform float curve_amount : hint_range(0.0, 1.0) = 0.3;
uniform float screen_ratio : hint_range(0.5, 1.0) = 0.75;

void fragment() {
	vec2 uv = UV - 0.5;
	uv.x /= screen_ratio;
	
	float dist = length(uv);
	float bend = curve_amount * dist * dist * 0.5;
	
	uv *= 1.0 + bend;
	uv.x *= screen_ratio;
	uv += 0.5;
	
	COLOR = texture(tex, uv);
}