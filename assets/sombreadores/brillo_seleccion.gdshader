shader_type spatial;
// Brillo de selección (Seleccionable): luz suave en los bordes del modelo, por encima de su material, para que
// se note más que el resto de la escena. Va como `next_pass` del contorno.

render_mode unshaded, blend_add, cull_back, depth_draw_never, shadows_disabled;

uniform vec4 color : source_color = vec4(1.0, 1.0, 1.0, 1.0);
uniform float fuerza = 0.35;
uniform float caida = 2.5;

void fragment() {
	float borde = pow(1.0 - clamp(dot(NORMAL, VIEW), 0.0, 1.0), caida);
	ALBEDO = color.rgb;
	ALPHA = (0.06 + borde) * fuerza;
}
