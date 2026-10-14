shader_type spatial;
render_mode cull_disabled;
// Vegetación de los kits: textura con recorte, un poco de viento en las hojas y un hueco tramado alrededor de
// Eromash cuando un árbol queda entre él y la cámara (así nunca se lo tapa).

uniform sampler2D textura : source_color, filter_linear_mipmap, repeat_enable;
uniform vec4 tinte : source_color = vec4(1.0);
uniform bool recolorear = false;      // hojas de otro color en el kit: se toma su luz y se pinta con `tinte`
uniform float recorte = 0.4;
uniform float viento = 0.0;          // 0 en troncos y rocas
uniform bool ocultable = true;
uniform vec3 emision : source_color = vec3(0.0);
uniform float emision_fuerza = 0.0;
global uniform vec3 pos_heroe;
global uniform vec3 pos_camara;

varying vec3 pos_mundo;

void vertex() {
	vec3 w = (MODEL_MATRIX * vec4(VERTEX, 1.0)).xyz;
	if (viento > 0.0) {
		float h = max(VERTEX.y, 0.0);
		float fase = w.x * 0.21 + w.z * 0.17;
		VERTEX.x += sin(TIME * 1.3 + fase) * 0.025 * h * viento;
		VERTEX.z += cos(TIME * 1.1 + fase) * 0.02 * h * viento;
	}
	pos_mundo = (MODEL_MATRIX * vec4(VERTEX, 1.0)).xyz;
}

// tramado de 4x4 para desvanecer sin transparencia real
float bayer(vec2 p) {
	ivec2 i = ivec2(mod(p, 4.0));
	int m[16] = int[](0, 8, 2, 10, 12, 4, 14, 6, 3, 11, 1, 9, 15, 7, 13, 5);
	return float(m[i.y * 4 + i.x]) / 16.0;
}

void fragment() {
	vec4 c = texture(textura, UV);
	if (c.a < recorte) {
		discard;
	}
	if (ocultable) {
		vec3 a = pos_camara;
		vec3 b = pos_heroe + vec3(0.0, 1.0, 0.0);
		vec3 ab = b - a;
		float t = clamp(dot(pos_mundo - a, ab) / dot(ab, ab), 0.0, 1.0);
		float d = length(pos_mundo - (a + ab * t));
		// solo lo que está entre la cámara y el héroe y por encima de su cintura
		float tapa = (1.0 - smoothstep(2.2, 4.2, d)) * step(t, 0.97) * step(pos_heroe.y + 0.8, pos_mundo.y);
		if (tapa * 0.85 > bayer(FRAGCOORD.xy)) {
			discard;
		}
	}
	vec3 col = c.rgb * tinte.rgb;
	if (recolorear) {
		float l = dot(c.rgb, vec3(0.3, 0.55, 0.15));
		col = tinte.rgb * (0.35 + l * 1.3);
	}
	ALBEDO = col;
	EMISSION = emision * emision_fuerza;
	ROUGHNESS = 0.9;
	SPECULAR = 0.15;
	BACKLIGHT = vec3(viento * 0.25);
}
