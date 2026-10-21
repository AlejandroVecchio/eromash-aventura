shader_type spatial;
// Máscara de selección (Seleccionable): no pinta nada, solo marca en el stencil los píxeles visibles del modelo
// para que el contorno (contorno_seleccion.gdshader, que va después) quede únicamente por fuera de la silueta.

// Sin prueba de profundidad: marca la silueta entera (si no, la ropa en capas de Tripo deja huecos). Lo que tapa
// al modelo igual tapa el contorno, porque el contorno sí la tiene.
render_mode unshaded, cull_disabled, depth_draw_never, depth_test_disabled, shadows_disabled;
stencil_mode write, compare_always, 64;

void fragment() {
	ALBEDO = vec3(0.0);
	ALPHA = 0.0;
}
