shader_type spatial;
// Material para modelos con runas: usa la textura original y hace emanar luz de las zonas pintadas con el color
// rúnico (turquesa, violeta…). La máscara sale del parecido de cada píxel con `color_runa`.
// `fuerza` 0 = runa apagada, 1 = viva; late lento y se aviva con `avivar` (cuando Eromash se acerca).

uniform sampler2D textura : source_color, filter_linear_mipmap, repeat_enable;
uniform sampler2D normal_tex : hint_normal, filter_linear_mipmap, repeat_enable;
uniform bool usa_normal = false;
uniform vec3 color_runa : source_color = vec3(0.45, 0.84, 0.86);
uniform vec3 color_luz : source_color = vec3(0.45, 0.84, 0.86);
uniform float tolerancia = 0.22;
uniform float fuerza = 1.0;
uniform float avivar = 0.0;
uniform float energia = 4.0;

void fragment() {
	vec4 c = texture(textura, UV);
	ALBEDO = c.rgb;
	if (usa_normal) {
		NORMAL_MAP = texture(normal_tex, UV).rgb;
	}
	// parecido de tono (no de brillo) con el color rúnico
	vec3 a = normalize(c.rgb + 0.001);
	vec3 b = normalize(color_runa);
	float tono = smoothstep(1.0 - tolerancia, 1.0 - tolerancia * 0.3, dot(a, b));
	float claro = smoothstep(0.25, 0.55, max(c.r, max(c.g, c.b)));
	float mascara = tono * claro;
	float pulso = 0.82 + 0.18 * sin(TIME * 1.6);
	EMISSION = color_luz * mascara * energia * fuerza * (pulso + avivar * 0.8);
	ROUGHNESS = 0.85;
}
