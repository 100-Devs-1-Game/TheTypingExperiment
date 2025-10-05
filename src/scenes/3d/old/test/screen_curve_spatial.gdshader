shader_type spatial;
render_mode depth_draw_opaque, diffuse_burley, specular_schlick_ggx;

uniform sampler2D tex: source_color, filter_linear;
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

	// Sample texture with curved UV coordinates
	vec4 tex_color = texture(tex, uv);

	// Set material properties
	ALBEDO = tex_color.rgb;
	ALPHA = tex_color.a;

	// Make it unlit and emissive for monitor screen effect
	//EMISSION = tex_color.rgb * 0.8;
}