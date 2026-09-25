shader_type spatial;

uniform sampler2D texture_base : source_color, filter_nearest;
uniform sampler2D texture_overlay : source_color, filter_nearest;

uniform vec2 uv_face = vec2(0.0, 0.0);
uniform int uv_color = 0;

void vertex() {
	
}

void fragment() {
	vec2 offset_color = UV2 + vec2(float(uv_color) * 0.0625, 0.0);
	vec2 offset_face = UV + (uv_face * vec2(0.25, -0.25));
	
	vec4 base_color = texture(texture_base, offset_color);
	vec4 overlay_color = texture(texture_overlay, offset_face);

	float mix_factor = overlay_color.a;

	vec3 final_color = mix(base_color.rgb, overlay_color.rgb, mix_factor);

	EMISSION = final_color;
}
