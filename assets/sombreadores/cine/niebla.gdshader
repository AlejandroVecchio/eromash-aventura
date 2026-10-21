shader_type canvas_item;

// Bruma que avanza despacio entre el fondo y el medio.
uniform float fuerza = 0.2;
uniform float centro = 0.62;   // altura de la franja (0 arriba, 1 abajo)
uniform float alto = 0.35;
uniform vec3 color : source_color = vec3(0.95, 0.9, 0.8);

float hash(vec2 p) { return fract(sin(dot(p, vec2(127.1, 311.7))) * 43758.5453); }
float ruido(vec2 p) {
	vec2 i = floor(p); vec2 f = fract(p);
	f = f * f * (3.0 - 2.0 * f);
	return mix(mix(hash(i), hash(i + vec2(1, 0)), f.x), mix(hash(i + vec2(0, 1)), hash(i + vec2(1, 1)), f.x), f.y);
}
float fbm(vec2 p) {
	float v = 0.0; float a = 0.5;
	for (int k = 0; k < 5; k++) { v += a * ruido(p); p *= 2.03; a *= 0.5; }
	return v;
}

void fragment() {
	float franja = 1.0 - smoothstep(0.0, alto * 0.5, abs(UV.y - centro));
	vec2 q = UV * vec2(2.2, 7.0);
	float n = fbm(q + vec2(TIME * 0.025, 0.0)) * 0.6 + fbm(q * 1.7 + vec2(-TIME * 0.018, 3.0)) * 0.4;
	float a = smoothstep(0.42, 0.75, n) * franja * fuerza;
	COLOR = vec4(color, a);
}
