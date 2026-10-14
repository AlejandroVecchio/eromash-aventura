shader_type spatial;
render_mode cull_disabled;
// Zarzas espectrales del santuario: ramas que se mecen solas, violeta frío con brillo en las espinas.
// `onda` sube cuando algo las toca (ondulación espectral) y baja sola.
uniform vec3 color : source_color = vec3(0.30, 0.20, 0.36);
uniform vec3 brillo : source_color = vec3(0.67, 0.53, 0.77);
uniform float onda = 0.0;
uniform float fase = 0.0;

varying float altura;

void vertex() {
	altura = VERTEX.y;
	float h = max(VERTEX.y, 0.0);
	float t = TIME * (0.8 + onda * 3.0) + fase;
	VERTEX.x += sin(t + h * 1.7) * 0.12 * h * (1.0 + onda * 2.0);
	VERTEX.z += cos(t * 0.8 + h * 1.3) * 0.08 * h * (1.0 + onda * 2.0);
}

void fragment() {
	float vena = 0.5 + 0.5 * sin(altura * 9.0 + TIME * 2.0);
	ALBEDO = color;
	EMISSION = brillo * (0.6 + vena * 0.8 + onda * 3.0);
	ROUGHNESS = 0.6;
}
