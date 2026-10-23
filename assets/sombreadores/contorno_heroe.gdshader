shader_type spatial;
// Contorno exterior de Eromash, solo donde algo lo tapa. Las piezas de adentro no se marcan.
// Para retocarlo: grosor (ancho), corte (0.25), arcilla/runico/0.22, saturación (0.42), brillo (EMISSION y 0.82).
// Mapa de esos números: docs/mvp.md, sección «Cámara y contorno».
render_mode unshaded, cull_disabled, depth_draw_never, depth_test_inverted, blend_mix, shadows_disabled, fog_disabled;

uniform float fuerza = 0.0;

void fragment() {
	if (fuerza <= 0.001) {
		discard;
	}
	float frente = abs(dot(normalize(NORMAL), normalize(VIEW)));
	// De canto con la cámara: el borde del cuerpo. Un ancho chico deja afuera correas, placas y el escudo.
	float ancho = max(fwidth(frente) * 1.25, 0.035);
	float borde = 1.0 - smoothstep(0.0, ancho, frente);
	if (borde < 0.25) {
		discard;
	}
	vec3 runico = vec3(0.451, 0.835, 0.859);
	vec3 arcilla = vec3(0.62, 0.56, 0.48);
	vec3 col = mix(arcilla, runico, 0.22);
	float luz = dot(col, vec3(0.30, 0.52, 0.18));
	col = mix(vec3(luz), col, 0.42);
	ALBEDO = col;
	EMISSION = col * 0.08 * fuerza;
	ALPHA = borde * fuerza * 0.82;
}
