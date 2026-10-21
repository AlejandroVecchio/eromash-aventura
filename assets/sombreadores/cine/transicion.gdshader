shader_type canvas_item;

// Mezcla dos escenas (cada una en su SubViewport) con transiciones de libro ilustrado:
// 0 nada (solo A) · 1 acuarela: A se destiñe al papel y B florece como una mancha
// desde un punto (primero el trazo, después el color) · 2 página: la cámara se
// desliza por el pergamino de una ilustración a la otra · 3 destello rúnico ·
// 4 barrido rápido · 5 cierre: A vuelve al papel y se hunde en la tinta oscura.
uniform sampler2D escena_a : filter_linear;
uniform sampler2D escena_b : filter_linear;
uniform float p : hint_range(0.0, 1.0) = 0.0;
uniform int modo = 0;
uniform vec2 origen = vec2(0.5, 0.5);
uniform float lado = 1.0;          // sentido del deslizamiento (1 = hacia la izquierda)
uniform bool a_es_papel = false;   // para la apertura: A es la página vacía
uniform vec3 papel = vec3(0.87, 0.81, 0.68);
uniform vec3 runa = vec3(0.451, 0.835, 0.859);

float hash(vec2 q) { return fract(sin(dot(q, vec2(127.1, 311.7))) * 43758.5453); }
float ruido(vec2 q) {
	vec2 i = floor(q); vec2 f = fract(q);
	f = f * f * (3.0 - 2.0 * f);
	return mix(mix(hash(i), hash(i + vec2(1, 0)), f.x), mix(hash(i + vec2(0, 1)), hash(i + vec2(1, 1)), f.x), f.y);
}
float fbm(vec2 q) {
	float v = 0.0; float a = 0.5;
	for (int k = 0; k < 5; k++) { v += a * ruido(q); q *= 2.03; a *= 0.5; }
	return v;
}
float lum(vec3 c) { return dot(c, vec3(0.299, 0.587, 0.114)); }
float suave(float x) { x = clamp(x, 0.0, 1.0); return x * x * (3.0 - 2.0 * x); }

// el pigmento se va al papel; lo oscuro queda como trazo de tinta
vec3 al_papel(vec3 c, float k) {
	vec3 lavado = papel * mix(0.5, 1.0, smoothstep(0.08, 0.55, lum(c)));
	return mix(c, lavado, k);
}
vec3 leer_a(vec2 uv) { return a_es_papel ? papel : texture(escena_a, uv).rgb; }

// mancha de acuarela que crece desde `o`: 0 afuera, 1 adentro
float mancha(vec2 uv, vec2 o, float q) {
	float d = length((uv - o) * vec2(1.78, 1.0)) / 1.9;
	float v = d * 0.85 + (fbm(uv * 3.2 + 4.0) - 0.5) * 0.35 + (fbm(uv * 14.0) - 0.5) * 0.06;
	return smoothstep(v - 0.05, v + 0.01, q * 1.15 - 0.05);
}

// una ilustración sobre la página: afuera de su rectángulo hay papel, y sus bordes
// se deshacen en acuarela tanto como diga `deshacer`
vec3 vineta(sampler2D t, vec2 uv, float deshacer, bool es_a) {
	vec3 c = es_a ? leer_a(clamp(uv, 0.0, 1.0)) : texture(t, clamp(uv, 0.0, 1.0)).rgb;
	float d = min(min(uv.x, 1.0 - uv.x) * 1.78, min(uv.y, 1.0 - uv.y));
	d += (fbm(uv * 6.0 + (es_a ? 1.0 : 9.0)) - 0.5) * 0.12 * deshacer;
	float dentro = smoothstep(0.0, 0.02 + 0.22 * deshacer, d - 0.06 * deshacer);
	vec3 borde = al_papel(c, 0.75);
	c = mix(borde, c, smoothstep(0.0, 0.10 + 0.25 * deshacer, d));
	return mix(papel, c, dentro);
}

void fragment() {
	vec2 uv = UV;
	vec3 a = leer_a(uv);
	vec3 b = texture(escena_b, uv).rgb;
	vec3 c = a;
	if (modo == 1) {
		// A se destiñe hacia el papel mientras B florece
		vec3 a2 = al_papel(a, suave(p / 0.6) * 0.9);
		float m1 = mancha(uv, origen, p);          // llega el agua con el trazo
		float m2 = mancha(uv, origen, p - 0.18);   // detrás llega el color
		vec3 b_trazo = al_papel(b, 0.85);
		vec3 bb = mix(b_trazo, b, m2);
		float filo = m1 * (1.0 - m1) * 4.0;        // el pigmento se acumula en el borde
		c = mix(a2, bb, m1) * (1.0 - 0.25 * filo);
	} else if (modo == 2) {
		// la cámara recorre la página: las dos ilustraciones con papel entre medio
		float e = suave(p);
		float alejar = 1.0 + 0.22 * sin(3.14159 * p);   // se abre un poco para ver la página
		vec2 cuv = (uv - 0.5) * alejar + 0.5;
		float hueco = 1.30;
		vec2 ua = cuv + vec2(lado * e * hueco, 0.0);
		vec2 ub = cuv - vec2(lado * (1.0 - e) * hueco, 0.0);
		float des = sin(3.14159 * p);
		vec3 ca = vineta(escena_a, ua, des, true);
		vec3 cb = vineta(escena_b, ub, des, false);
		bool en_a = ua.x >= -0.02 && ua.x <= 1.02;
		bool en_b = ub.x >= -0.02 && ub.x <= 1.02;
		c = papel;
		if (en_a) c = ca;
		if (en_b) c = cb;
		// trazos sueltos de tinta en el papel entre las dos (notas del cronista)
		float tinta = smoothstep(0.78, 0.82, fbm(cuv * vec2(40.0, 6.0) + 2.0)) * 0.25 * des;
		if (!en_a && !en_b) c *= 1.0 - tinta;
	} else if (modo == 3) {
		// la runa estalla en luz y de ese blanco azulado sale la otra escena
		float g = pow(sin(3.14159 * p), 2.0);
		float d = length((uv - origen) * vec2(1.78, 1.0));
		float halo = exp(-d * 1.6);
		c = mix(a, b, suave((p - 0.42) / 0.16));
		c = mix(c, vec3(0.92, 0.98, 1.0), g * 0.55 * halo);
		c += runa * g * (0.35 + 0.65 * halo);
	} else if (modo == 4) {
		// barrido rápido con estela
		float e = suave(p);
		float estela = sin(3.14159 * p) * 0.06;
		vec3 acum = vec3(0.0);
		for (int k = 0; k < 9; k++) {
			float s = (float(k) / 8.0 - 0.5) * estela;
			vec2 q = uv + vec2(lado * (e + s), 0.0);
			acum += q.x <= 1.0 ? leer_a(q) : texture(escena_b, q - vec2(1.0, 0.0)).rgb;
		}
		c = acum / 9.0;
	} else if (modo == 5) {
		// cierre: vuelve al papel y la tinta oscura lo cubre desde los bordes
		vec3 a2 = al_papel(a, suave(p / 0.55) * 0.85);
		float m = mancha(uv, origen, 1.0 - suave((p - 0.35) / 0.65));
		m *= 1.0 - smoothstep(0.88, 0.98, p);
		c = mix(vec3(0.03, 0.025, 0.02), a2, m);
	}
	COLOR = vec4(c, 1.0);
}
