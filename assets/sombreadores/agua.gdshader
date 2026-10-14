shader_type spatial;
render_mode cull_disabled;
// Agua de río: color profundo, ondas suaves que corren en la dirección del cauce y reflejo contenido.
uniform vec4 color_hondo : source_color = vec4(0.07, 0.16, 0.18, 1.0);
uniform vec4 color_claro : source_color = vec4(0.22, 0.40, 0.42, 1.0);
uniform float velocidad = 0.6;

varying vec3 pos_mundo;

void vertex() {
	pos_mundo = (MODEL_MATRIX * vec4(VERTEX, 1.0)).xyz;
}

float onda(vec2 p) {
	return sin(p.x) * 0.5 + sin(p.y * 1.3 + p.x * 0.4) * 0.5;
}

void fragment() {
	vec2 p = pos_mundo.xz * 0.6;
	float t = TIME * velocidad;
	// UV.x corre a lo largo del cauce
	float o = onda(vec2(UV.x * 1.5 - t * 2.0, p.y + p.x)) * 0.5 + onda(p * 1.7 + vec2(t, -t * 0.7)) * 0.5;
	float borde = smoothstep(0.0, 0.25, UV.y) * smoothstep(1.0, 0.75, UV.y);
	ALBEDO = mix(color_claro.rgb, color_hondo.rgb, borde * 0.8 + o * 0.08);
	NORMAL_MAP = normalize(vec3(o * 0.25, o * 0.18, 1.0)) * 0.5 + 0.5;
	ROUGHNESS = 0.08;
	METALLIC = 0.0;
	SPECULAR = 0.6;
	ALPHA = mix(0.75, 0.92, borde);
}
