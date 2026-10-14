shader_type spatial;
render_mode unshaded, blend_add, depth_draw_never, cull_disabled;
// Marcas que muestra la Lente del Eco y avisos en el piso: dibujadas con formas, sin texturas.
// tipo 0 = huella de pezuña, 1 = runa, 2 = anillo, 3 = rastro (líneas).
uniform vec4 color : source_color = vec4(0.45, 0.84, 0.86, 1.0);
uniform int tipo = 0;
uniform float energia = 2.2;

float linea(vec2 p, vec2 a, vec2 b, float w) {
	vec2 pa = p - a, ba = b - a;
	float h = clamp(dot(pa, ba) / dot(ba, ba), 0.0, 1.0);
	return 1.0 - smoothstep(w * 0.6, w, length(pa - ba * h));
}

void fragment() {
	vec2 p = UV * 2.0 - 1.0;
	float a = 0.0;
	if (tipo == 0) {
		// dos medias lunas: pezuña hendida
		float l = 1.0 - smoothstep(0.30, 0.36, length((p - vec2(-0.22, 0.0)) * vec2(1.6, 0.9)));
		float r = 1.0 - smoothstep(0.30, 0.36, length((p - vec2(0.22, 0.0)) * vec2(1.6, 0.9)));
		a = max(l, r);
	} else if (tipo == 1) {
		a = max(max(linea(p, vec2(-0.2, -0.7), vec2(-0.2, 0.7), 0.09), linea(p, vec2(-0.2, 0.1), vec2(0.35, -0.45), 0.09)), linea(p, vec2(-0.2, -0.15), vec2(0.35, 0.4), 0.09));
		a = max(a, (1.0 - smoothstep(0.02, 0.06, abs(length(p) - 0.85))) * 0.8);
	} else if (tipo == 2) {
		a = 1.0 - smoothstep(0.03, 0.08, abs(length(p) - 0.85));
	} else {
		a = max(linea(p, vec2(-0.9, -0.2), vec2(0.9, 0.1), 0.06), linea(p, vec2(-0.9, 0.25), vec2(0.9, 0.45), 0.06));
	}
	float pulso = 0.8 + 0.2 * sin(TIME * 2.5);
	ALBEDO = color.rgb * energia * pulso * a;
	ALPHA = a;
}
