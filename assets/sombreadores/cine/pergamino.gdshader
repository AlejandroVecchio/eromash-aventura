shader_type canvas_item;
render_mode blend_mul;

// Pergamino fijo encima de todo: fibras, manchas suaves y viñeta. Multiplica.
uniform float fuerza = 1.0;
uniform float vineta = 0.35;

float hash(vec2 p) { return fract(sin(dot(p, vec2(127.1, 311.7))) * 43758.5453); }
float ruido(vec2 p) {
	vec2 i = floor(p); vec2 f = fract(p);
	f = f * f * (3.0 - 2.0 * f);
	return mix(mix(hash(i), hash(i + vec2(1, 0)), f.x), mix(hash(i + vec2(0, 1)), hash(i + vec2(1, 1)), f.x), f.y);
}
float fbm(vec2 p) {
	float v = 0.0; float a = 0.5;
	for (int k = 0; k < 6; k++) { v += a * ruido(p); p *= 2.07; a *= 0.5; }
	return v;
}

void fragment() {
	vec2 uv = UV;
	vec2 asp = vec2(16.0, 9.0);
	float grano = ruido(uv * asp * 90.0) * 0.5 + ruido(uv * asp * 200.0) * 0.5;
	float fibras = fbm(vec2(uv.x * 40.0, uv.y * 400.0)) ; // fibras largas horizontales
	float manchas = smoothstep(0.55, 0.85, fbm(uv * asp * 0.35 + 3.1));
	vec3 base = vec3(1.0, 0.965, 0.90);
	vec3 c = base;
	c *= 1.0 - 0.06 * grano - 0.05 * fibras;
	c *= mix(vec3(1.0), vec3(0.86, 0.76, 0.60), manchas * 0.6);
	float d = distance(uv, vec2(0.5));
	c *= 1.0 - vineta * smoothstep(0.38, 0.78, d);
	COLOR = vec4(mix(vec3(1.0), c, fuerza), 1.0);
}
