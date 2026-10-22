shader_type canvas_item;
// La vida baja cierra la mirada desde las esquinas, en el rojo de la barra.
// La sombra y los surcos se quedan en el borde: el centro queda libre.
// `intensidad` respira con la barra. `golpe` es el tick de cada daño.

uniform float intensidad : hint_range(0.0, 1.0) = 0.0;
uniform float golpe : hint_range(0.0, 1.0) = 0.0;
uniform vec2 resolucion = vec2(1920.0, 1080.0);

float hash21(vec2 p) {
	vec3 p3 = fract(vec3(p.xyx) * 0.1031);
	p3 += dot(p3, p3.yzx + 33.33);
	return fract((p3.x + p3.y) * p3.z);
}

float ruido(vec2 p) {
	vec2 i = floor(p);
	vec2 f = fract(p);
	f = f * f * (3.0 - 2.0 * f);
	float a = hash21(i);
	float b = hash21(i + vec2(1.0, 0.0));
	float c = hash21(i + vec2(0.0, 1.0));
	float d = hash21(i + vec2(1.0, 1.0));
	return mix(mix(a, b, f.x), mix(c, d, f.x), f.y);
}

float arco(float ang, float centro, float ancho) {
	float d = abs(atan(sin(ang - centro), cos(ang - centro)));
	return 1.0 - smoothstep(ancho * 0.2, ancho, d);
}

void fragment() {
	vec2 uv = UV;
	vec2 pix = uv * resolucion;
	float aliento = clamp(intensidad, 0.0, 1.0);
	float tick = clamp(golpe, 0.0, 1.0);
	float presencia = max(aliento, tick);

	// Distancia al borde en píxeles. El producto curva las esquinas;
	// una banda por lado volvería a ser un rectángulo.
	vec2 dpx = vec2(min(uv.x, 1.0 - uv.x) * resolucion.x, min(uv.y, 1.0 - uv.y) * resolucion.y);
	// Banda corta: el latido y el golpe casi no entran en la pantalla.
	float margen = resolucion.y * (0.105 + aliento * 0.025 + tick * 0.02);
	vec2 dn = dpx / max(margen, 1.0);
	float claro = dn.x * dn.y / (dn.x + dn.y + 0.001);
	claro += (ruido(uv * vec2(2.4, 1.7)) - 0.5) * 0.1;
	float velo = pow(1.0 - smoothstep(0.0, 0.7, claro), 1.55);

	float ang = atan(pix.y - resolucion.y * 0.5, pix.x - resolucion.x * 0.5);
	// Surcos en los cuatro lados, cortos y separados de las esquinas.
	float marcas = arco(ang, -1.95, 0.34);
	marcas = max(marcas, arco(ang, -0.85, 0.26));
	marcas = max(marcas, arco(ang, 0.28, 0.3));
	marcas = max(marcas, arco(ang, 1.9, 0.32));
	marcas = max(marcas, arco(ang, 2.7, 0.2) * tick);
	float trozo = smoothstep(0.26, 0.52, ruido(vec2(ang * 12.0, 4.2)));
	marcas *= trozo;

	float nucleo = smoothstep(0.38, 0.5, velo) * (1.0 - smoothstep(0.54, 0.68, velo));
	float derrame = smoothstep(0.14, 0.38, velo) * (1.0 - smoothstep(0.5, 0.82, velo));
	nucleo *= marcas;
	derrame *= marcas;
	// Un fleco bajo en todo el perímetro, irregular, para que el peligro no dependa
	// de encontrar un solo surco. No llega a ser un tubo de luz.
	float fleco = smoothstep(0.22, 0.5, velo) * (1.0 - smoothstep(0.58, 0.9, velo));
	fleco *= 0.45 + 0.55 * ruido(uv * vec2(4.5, 3.0));

	vec3 sombra = vec3(0.07, 0.012, 0.01);
	vec3 c_halo = vec3(0.55, 0.08, 0.05);
	vec3 c_base = vec3(0.86, 0.22, 0.14);
	vec3 c_nucleo = vec3(1.0, 0.62, 0.5);
	// El latido ya trae el peligro. El golpe suma encima, no se esconde detrás.
	float fuerza = clamp(aliento * 0.82 + tick * 0.55, 0.0, 1.0);
	vec3 luz = mix(c_halo, c_base, smoothstep(0.15, 0.7, nucleo + fleco * 0.35));
	luz = mix(luz, c_nucleo, smoothstep(0.55, 0.95, nucleo) * (0.3 + 0.7 * tick));

	float a_sombra = velo * presencia * mix(0.62, 0.92, aliento);
	float a_luz = clamp(fleco * fuerza * 0.34 + derrame * fuerza * 0.28 + nucleo * fuerza, 0.0, 0.84);
	float a = a_sombra + a_luz * (1.0 - a_sombra);
	if (a < 0.012) {
		discard;
	}
	vec3 rgb = (sombra * a_sombra * (1.0 - a_luz) + luz * a_luz) / a;
	COLOR = vec4(rgb, a);
}
