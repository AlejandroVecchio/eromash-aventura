shader_type spatial;
// Contorno de selección (Seleccionable): el modelo se vuelve a dibujar un poco más grande y el stencil que dejó
// mascara_seleccion.gdshader recorta todo lo que cae sobre el modelo: queda solo el borde de la silueta. El
// grosor se mide en píxeles de pantalla, así se ve igual de cerca y de lejos.
// `latido` > 0 hace respirar el borde (seleccionado); 0 lo deja quieto (mouse encima).

render_mode unshaded, cull_disabled, depth_draw_never, shadows_disabled;
stencil_mode read, compare_not_equal, 64;

uniform vec4 color : source_color = vec4(1.0, 1.0, 1.0, 0.9);
uniform float grosor = 2.5;
uniform float latido = 0.0;

void vertex() {
	vec4 clip = PROJECTION_MATRIX * MODELVIEW_MATRIX * vec4(VERTEX, 1.0);
	vec3 n = mat3(MODELVIEW_MATRIX) * NORMAL;
	vec2 nc = (PROJECTION_MATRIX * vec4(n, 0.0)).xy;
	float l = length(nc);
	if (l > 0.0001) {
		nc /= l;
	}
	float g = grosor * (1.0 + latido * 0.15 * sin(TIME * 3.0));
	clip.xy += nc * g * 2.0 / VIEWPORT_SIZE * clip.w;
	POSITION = clip;
}

void fragment() {
	ALBEDO = color.rgb;
	ALPHA = color.a * (1.0 - latido * 0.15 + latido * 0.15 * sin(TIME * 3.0));
}
