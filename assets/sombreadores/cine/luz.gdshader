shader_type canvas_item;
render_mode blend_add;

// Luz rúnica que viene de un costado (destellos del monolito sobre la cara).
uniform vec2 centro = vec2(1.0, 0.45);
uniform float radio = 0.7;
uniform float intensidad = 0.0;
uniform vec3 color : source_color = vec3(0.451, 0.835, 0.859);

void fragment() {
	vec2 d = (UV - centro) * vec2(1.78, 1.0);
	float a = 1.0 - smoothstep(0.0, radio, length(d));
	COLOR = vec4(color * a * a * intensidad, 1.0);
}
