shader_type spatial;
render_mode unshaded, blend_mix, depth_draw_never, cull_disabled, shadows_disabled;
// Aviso en el piso: marca exactamente la zona que va a pegar. Borde fijo y relleno que crece con `progreso`;
// el último tramo titila (ahora). tipo 0 = círculo, 1 = abanico (medio ángulo `abanico`), 2 = rectángulo.
uniform vec4 color : source_color = vec4(0.88, 0.38, 0.24, 1.0);
uniform int tipo = 0;
uniform float abanico = 1.0;
uniform float progreso = 0.0;

void fragment() {
	vec2 p = UV * 2.0 - 1.0;   // -1..1; el frente es +Y del quad (que en el piso es +Z)
	float dentro = 0.0;
	float borde = 0.0;
	float r = length(p);
	if (tipo == 0) {
		dentro = step(r, 1.0);
		borde = smoothstep(0.90, 0.97, r) * dentro;
		dentro *= step(r, progreso);
	} else if (tipo == 1) {
		float ang = abs(atan(p.x, p.y));
		float en = step(r, 1.0) * step(ang, abanico);
		borde = en * max(smoothstep(0.92, 0.98, r), smoothstep(abanico - 0.06, abanico, ang));
		dentro = en * step(r, progreso);
	} else {
		float en = step(abs(p.x), 1.0) * step(abs(p.y), 1.0);
		borde = en * max(smoothstep(0.9, 0.97, abs(p.x)), smoothstep(0.96, 0.99, abs(p.y)));
		dentro = en * step((p.y + 1.0) * 0.5, progreso);
	}
	float titila = progreso > 0.85 ? 0.6 + 0.4 * step(0.5, fract(TIME * 8.0)) : 1.0;
	float a = max(borde * 0.95, dentro * 0.35) * titila;
	if (a < 0.01) {
		discard;
	}
	ALBEDO = color.rgb * (1.0 + borde);
	ALPHA = a;
}
