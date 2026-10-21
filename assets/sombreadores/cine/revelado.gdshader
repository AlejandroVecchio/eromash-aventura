shader_type canvas_item;

// Boceto sacado de la misma imagen a color (líneas oscuras + bordes) y revelado
// del color con una máscara de ruido que crece desde un origen.
// Vida lenta: `ondulacion` mece lo que está lejos de los bordes de la imagen
// (ramas ancladas al marco); `deriva` hace fluir la parte de arriba (cielo, nubes).
uniform float progreso : hint_range(0.0, 1.0) = 0.0;
uniform vec2 origen = vec2(0.5, 0.5);
uniform float suavidad = 0.18;
uniform vec3 papel = vec3(0.87, 0.81, 0.68);
uniform vec3 tinta = vec3(0.16, 0.11, 0.08);
uniform float ondulacion = 0.0; // en píxeles de la imagen
uniform float deriva = 0.0;     // en píxeles de la imagen
uniform float limite_cielo = 0.5;
// color pleno solo donde el ruido queda por debajo del umbral; el resto se pinta con una aguada tenue
// (2.0 = todo pleno; 0.543 ≈ 60 % pleno con el origen protegido)
uniform float aguada = 0.93; // cuánto color lleva la parte tenue
uniform float intensidad = 1.0; // cuánto color lleva la parte plena (y las capas sin aguada)
uniform float umbral_color = 2.0;
// runas: lo azul brillante de la imagen brilla (#73D5DB) o se apaga a gris carbón
uniform float brillo_runa = 0.0;
uniform float apagado_runa = 0.0;
// fuego: lo cálido y brillante (ventanas, faroles) late
uniform float fuego = 0.0;

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
	vec2 px = TEXTURE_PIXEL_SIZE;
	vec2 uv = UV;
	if (ondulacion > 0.0) {
		float borde_img = min(min(UV.x, 1.0 - UV.x), min(UV.y, 1.0 - UV.y));
		float w = smoothstep(0.0, 0.3, borde_img);
		vec2 m = vec2(sin(TIME * 0.55 + UV.y * 5.0 + UV.x * 2.0), cos(TIME * 0.42 + UV.x * 4.0) * 0.6);
		m += (vec2(fbm(UV * 4.0 + TIME * 0.08), fbm(UV * 4.0 - TIME * 0.07)) - 0.5) * 1.2;
		uv += m * ondulacion * w * px;
	}
	if (deriva > 0.0) {
		float cielo = 1.0 - smoothstep(limite_cielo - 0.15, limite_cielo, UV.y);
		vec2 q = UV * vec2(2.5, 5.0) + vec2(TIME * 0.035, 0.0);
		vec2 m = vec2(fbm(q), fbm(q + 7.3)) - 0.5;
		uv += m * deriva * cielo * px;
	}
	vec4 col = texture(TEXTURE, uv);
	// Sobel sobre la luminancia
	float tl = lum(texture(TEXTURE, uv + px * vec2(-1, -1)).rgb);
	float t  = lum(texture(TEXTURE, uv + px * vec2( 0, -1)).rgb);
	float tr = lum(texture(TEXTURE, uv + px * vec2( 1, -1)).rgb);
	float l  = lum(texture(TEXTURE, uv + px * vec2(-1,  0)).rgb);
	float r  = lum(texture(TEXTURE, uv + px * vec2( 1,  0)).rgb);
	float bl = lum(texture(TEXTURE, uv + px * vec2(-1,  1)).rgb);
	float b  = lum(texture(TEXTURE, uv + px * vec2( 0,  1)).rgb);
	float br = lum(texture(TEXTURE, uv + px * vec2( 1,  1)).rgb);
	float gx = (tr + 2.0 * r + br) - (tl + 2.0 * l + bl);
	float gy = (bl + 2.0 * b + br) - (tl + 2.0 * t + tr);
	float borde = smoothstep(0.18, 0.55, length(vec2(gx, gy)));
	float oscuro = 1.0 - smoothstep(0.04, 0.22, lum(col.rgb));
	float trazo = clamp(max(borde * 0.8, oscuro * 0.45), 0.0, 1.0);
	vec3 boceto = mix(papel, tinta, trazo);

	// máscara: distancia al origen + ruido (sobre UV fijo, para que el borde no ondule)
	float v = distance(UV, origen) * 0.75 + fbm(UV * 7.0) * 0.45;
	float rev = clamp((progreso * (1.2 + suavidad) - v) / suavidad, 0.0, 1.0);
	// borde irregular de acuarela; cerca del origen (el foco del plano) siempre se colorea
	float manchas = fbm(UV * vec2(3.5, 2.0) + 11.0) + (fbm(UV * 22.0 + 5.0) - 0.5) * 0.10;
	manchas -= (1.0 - smoothstep(0.12, 0.40, distance(UV, origen))) * 0.25;
	float pleno = 1.0 - smoothstep(umbral_color - 0.05, umbral_color + 0.05, manchas);
	// aguada: el color desaturado, rebajado con agua (papel) y con el trazo del boceto a la vista
	vec3 lavado = mix(vec3(lum(col.rgb)), col.rgb, 0.85);
	vec3 tenue = mix(boceto, mix(lavado, papel, 0.22), aguada);
	vec3 destino = mix(tenue, mix(boceto, col.rgb, intensidad), pleno);
	// borde húmedo: el pigmento se acumula en el frente del revelado
	float frente = rev * (1.0 - rev) * 4.0;
	vec3 c = mix(boceto, destino, rev) * (1.0 - 0.22 * frente);
	float mr = smoothstep(0.12, 0.30, col.b - col.r) * smoothstep(0.40, 0.70, col.b);
	c = mix(c, vec3(lum(c)) * 0.45, mr * apagado_runa);
	c += vec3(0.451, 0.835, 0.859) * mr * brillo_runa;
	float mf = smoothstep(0.62, 0.90, col.r) * smoothstep(0.18, 0.40, col.r - col.b);
	c *= 1.0 + mf * fuego;
	COLOR = vec4(c, col.a);
}
