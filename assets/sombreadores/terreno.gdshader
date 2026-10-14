shader_type spatial;
// Suelo de Eldervald: mezcla las texturas pintadas según pesos guardados en el vértice.
// COLOR.r = camino, COLOR.g = musgo, COLOR.b = ribera, COLOR.a = zona enferma; UV2.x = losas.
// Lo que queda bajo el agua usa el lecho del río; las pendientes fuertes, roca.

uniform sampler2D tex_base : source_color, filter_linear_mipmap_anisotropic, repeat_enable;
uniform sampler2D tex_camino : source_color, filter_linear_mipmap_anisotropic, repeat_enable;
uniform sampler2D tex_musgo : source_color, filter_linear_mipmap_anisotropic, repeat_enable;
uniform sampler2D tex_ribera : source_color, filter_linear_mipmap_anisotropic, repeat_enable;
uniform sampler2D tex_enferma : source_color, filter_linear_mipmap_anisotropic, repeat_enable;
uniform sampler2D tex_losas : source_color, filter_linear_mipmap_anisotropic, repeat_enable;
uniform sampler2D tex_lecho : source_color, filter_linear_mipmap_anisotropic, repeat_enable;
uniform sampler2D tex_roca : source_color, filter_linear_mipmap_anisotropic, repeat_enable;
uniform float escala = 0.16;     // repeticiones por metro (1 / 6 m)
uniform float nivel_agua = -1.6;

varying vec3 pos_mundo;
varying vec3 normal_mundo;

void vertex() {
	pos_mundo = (MODEL_MATRIX * vec4(VERTEX, 1.0)).xyz;
	normal_mundo = normalize((MODEL_MATRIX * vec4(NORMAL, 0.0)).xyz);
}

// Dos muestras con escalas distintas para que no se note la repetición.
vec3 muestra(sampler2D t, vec2 uv) {
	vec3 a = texture(t, uv).rgb;
	vec3 b = texture(t, uv * 0.37 + vec2(0.31, 0.17)).rgb;
	return mix(a, b, 0.35);
}

void fragment() {
	vec2 uv = pos_mundo.xz * escala;
	vec3 c = muestra(tex_base, uv);
	c = mix(c, muestra(tex_musgo, uv * 1.2), COLOR.g);
	c = mix(c, muestra(tex_ribera, uv), COLOR.b);
	c = mix(c, muestra(tex_enferma, uv), COLOR.a);
	c = mix(c, muestra(tex_camino, uv * 1.4), COLOR.r);
	c = mix(c, muestra(tex_losas, uv * 0.8), clamp(UV2.x, 0.0, 1.0));
	float bajo = smoothstep(nivel_agua + 0.6, nivel_agua - 0.4, pos_mundo.y);
	c = mix(c, muestra(tex_lecho, uv), bajo);
	float pendiente = 1.0 - normal_mundo.y;
	float roca = smoothstep(0.28, 0.5, pendiente);
	c = mix(c, muestra(tex_roca, pos_mundo.xy * 0.12 + pos_mundo.zy * 0.12), roca);
	ALBEDO = c;
	ROUGHNESS = 0.92;
	SPECULAR = 0.2;
}
