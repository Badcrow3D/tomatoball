shader_type spatial;

uniform sampler2D texture_base : source_color, filter_nearest;
uniform sampler2D texture_overlay : source_color, filter_nearest;

void vertex() {
	// Called for every vertex the material is visible on.
}

void fragment() {
	vec4 base_color = texture(texture_base, UV2);
	vec4 overlay_color = texture(texture_overlay, UV);

	// Use the overlay texture's alpha as the mix factor
	float mix_factor = overlay_color.a;

	vec3 final_color = mix(base_color.rgb, overlay_color.rgb, mix_factor);

	EMISSION = final_color;
}
