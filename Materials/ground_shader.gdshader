shader_type spatial;

uniform sampler2D texture_base : source_color, filter_nearest;

uniform vec3 Input1; // Sphere center (world space)
uniform float Input2; // Sphere radius
uniform vec3 Input3; // Multiply color

varying vec3 world_pos;

void vertex() {
	world_pos = (MODEL_MATRIX * vec4(VERTEX, 1.0)).xyz;
}

void fragment() {
	vec3 base_color = texture(texture_base, UV).rgb;

	float dist = distance(world_pos, Input1);

	vec3 final_color = base_color;
	if (dist < Input2) {
		final_color *= Input3;
	}

	EMISSION = final_color;
}