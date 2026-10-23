shader_type canvas_item;

// Algunas zonas del perímetro del cuadro se decoloran hacia el pergamino, como si
// la acuarela se hubiera aguado al llegar al borde. Fijo en pantalla, como el papel.
uniform sampler2D pantalla : hint_screen_texture, filter_linear;
uniform float fuerza = 0.7;   // en lo más aguado queda a un 30 % de ser pergamino
uniform float ancho = 0.16;   // qué tan adentro llega desde el borde
uniform vec3 papel = vec3(0.87, 0.81, 0.68);

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
float lum(vec3 c) { return dot(c, vec3(0.299, 0.587, 0.114)); }

void fragment() {
	vec3 c = texture(pantalla, SCREEN_UV).rgb;
	vec2 uv = SCREEN_UV;
	// distancia al borde más cercano, con el lado corto escalado al aspecto 16:9
	float d = min(min(uv.x, 1.0 - uv.x) * 1.78, min(uv.y, 1.0 - uv.y));
	d += (fbm(uv * 9.0 + 2.0) - 0.5) * 0.08; // borde irregular de agua
	float borde = 1.0 - smoothstep(0.0, ancho, d);
	// solo en algunos tramos del perímetro
	float tramos = smoothstep(0.48, 0.62, fbm(uv * vec2(2.6, 2.0) + 31.0));
	float m = borde * tramos * fuerza;
	// el pigmento se va, el trazo oscuro queda como tinta sobre el papel
	vec3 lavado = papel * mix(0.55, 1.0, smoothstep(0.08, 0.55, lum(c)));
	COLOR = vec4(mix(c, lavado, m), 1.0);
}
