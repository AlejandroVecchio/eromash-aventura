class_name CartelLugar
extends Control
## Cartel dorado que anuncia un lugar al llegar. Es la versión para el juego de la animación aprobada en el
## artefacto «Cartel de lugar animado» (opción Chispa): se encienden los rombos, dos chispas dibujan las líneas,
## aparecen el texto de abajo y el nombre en runas, las runas laten y el nombre se descubre. En una tierra nueva o
## una capital, además, detrás se dibuja en un solo trazo, desde los dos costados a la vez, el paisaje de la región
## o el estandarte de la capital.
##
## Uso (desde el HUD, que es un CanvasLayer):
##   var cartel := CartelLugar.new()
##   hud.add_child(cartel)
##   cartel.mostrar_lugar("Eikholt")
##   cartel.mostrar_tierra("Bosque de Eldervald", "eldervald", "ᛖᛚᛞᛖᚱᚹᚨᛚᛞ")
##   cartel.mostrar_regreso("Eikholt")
##   cartel.mostrar_capital("Eikholt", "eikholt")
## Para mirarlo sin jugar: abrir escenas/prueba_cartel.tscn y F6 (F / Y pasa al siguiente).
##
## Todo lo que se puede ajustar está en PARÁMETROS, justo abajo. Los tiempos están en segundos.

signal termino

enum Tipo { LUGAR, TIERRA, REGRESO, CAPITAL }

## Cómo se descubre el nombre (las cuatro opciones del artefacto).
enum Entrada {
	IZQ_A_DER = 1,      ## 1 · barrido de izquierda a derecha
	DER_A_IZQ = 2,      ## 2 · barrido de derecha a izquierda
	CENTRO_AFUERA = 3,  ## 3 · de adentro hacia afuera
	AFUERA_CENTRO = 4,  ## 4 · de afuera hacia adentro
}

# ============================================================================================================
# PARÁMETROS
# ============================================================================================================

## Un bloque por tipo de cartel. Tamaños en píxeles para una pantalla de 1080 de alto (se escalan solos).
##   entrada    cómo se descubre el nombre (ver Entrada arriba)
##   texto      clave de textos.csv del texto de abajo ("" = sin texto: solo la línea corta con un rombo)
##   posicion   "arriba" (debajo del borde superior), "centro" (en la mitad de la pantalla) o "alto" (más arriba
##              que el centro, para que el estandarte de una capital entre entero debajo del título)
##   runas, nombre, sub   tamaño de letra de cada renglón
##   linea      ancho total del renglón de abajo (líneas + rombos + texto)
##   velocidad  multiplica la duración de toda la entrada (1 = como se aprobó; más = más lento)
##   quieto     segundos que queda armado antes de irse
##   salida     segundos que tarda en irse (todo junto)
##   pulso      fuerza del pulso de luz de las runas antes del nombre (1 = suave, 1.6 = fuerte)
##   dibujo     "" = sin dibujo · "region" = paisaje de la región · "estandarte" = estandarte de la capital
const CONFIG := {
	Tipo.LUGAR: {
		"entrada": Entrada.IZQ_A_DER, "texto": "cartel_lugar_descubierto", "posicion": "arriba",
		"runas": 22.0, "nombre": 52.0, "sub": 15.0, "linea": 420.0,
		"velocidad": 1.0, "quieto": 1.8, "salida": 0.9, "pulso": 1.0, "dibujo": "",
	},
	Tipo.TIERRA: {
		"entrada": Entrada.AFUERA_CENTRO, "texto": "cartel_tierra_nueva", "posicion": "centro",
		"runas": 33.0, "nombre": 85.0, "sub": 22.0, "linea": 686.0,
		"velocidad": 1.25, "quieto": 2.2, "salida": 1.0, "pulso": 1.6, "dibujo": "region",
	},
	Tipo.REGRESO: {
		"entrada": Entrada.IZQ_A_DER, "texto": "", "posicion": "arriba",
		"runas": 19.0, "nombre": 44.0, "sub": 13.0, "linea": 247.0,
		"velocidad": 0.65, "quieto": 1.2, "salida": 0.65, "pulso": 1.0, "dibujo": "",
	},
	Tipo.CAPITAL: {
		"entrada": Entrada.AFUERA_CENTRO, "texto": "cartel_capital_descubierta", "posicion": "alto",
		"runas": 33.0, "nombre": 85.0, "sub": 22.0, "linea": 686.0,
		"velocidad": 1.25, "quieto": 2.2, "salida": 1.0, "pulso": 1.6, "dibujo": "estandarte",
	},
}

## La primera parte (rombos, chispas, texto de abajo y runas) va un 25 % más rápida que el resto.
const AGIL := 0.75
## Separación entre letras (en píxeles a 1080, se escala con el tamaño de la letra).
const ESPACIO_RUNAS := 0.47   ## × tamaño de las runas
const ESPACIO_NOMBRE := 0.085 ## × tamaño del nombre
const ESPACIO_SUB := 0.42     ## × tamaño del texto de abajo
## A qué altura queda lo alto del cartel (fracción de la pantalla) en "arriba" y en "alto".
const ALTO_ARRIBA := 0.09
const ALTO_CAPITAL := 0.13

## Dibujo de fondo (tierra nueva y capital)
const DIBUJO_DURA := 7.0        ## segundos que tarda en dibujarse
const DIBUJO_PULSO := 2.0       ## pulso de luz al terminar el dibujo
const DIBUJO_ANCHO := 1152.0    ## ancho del paisaje de una región (píxeles a 1080)
const ESTANDARTE_ALTO := 760.0  ## alto del estandarte de una capital (píxeles a 1080); cuelga desde lo alto de las runas

## Regiones: nombre de la función que arma su paisaje (una por región; ver _paisaje_eldervald()).
const REGIONES := {"eldervald": "_paisaje_eldervald"}
## Capitales: la insignia de cada una (PNG blanco sobre transparente; se tiñe de dorado y se calca su contorno).
const CAPITALES := {
	"eikholt": {"insignia": "res://assets/interfaz/insignias/eikholt.png"},
}

## Colores: el dorado de las runas y el blanco del logo de Eromash.
const ORO := Color("FFD98A")
const ORO_LINEA := Color("C9A45A")
const ORO_BRILLO := Color("B8862E")
const ORO_SUB := Color("E2C894")
const BLANCO := Color("F2EEEA")
const PUNTA := Color("FFF6DC")
const TRAZO_FINAL := Color("FFE7B0")

const FUENTE_RUNAS := "res://assets/marca/fuentes/NotoSansRunic.woff2"
const FUENTE_NOMBRE := "res://assets/marca/fuentes/EromashDisplay-Bold.woff2"
const FUENTE_TEXTO := "res://assets/marca/fuentes/EromashText-Regular.woff2"

# ============================================================================================================

const MASCARA := """
shader_type canvas_item;
// El nombre se descubre con un borde difuso: modo 1 izq→der, 2 der→izq, 3 centro→afuera, 4 afuera→centro.
uniform float frente = 0.0;
uniform int modo = 1;
uniform float ancho = 100.0;
uniform float suave = 0.15;
varying float px;
void vertex() { px = VERTEX.x; }
void fragment() {
	float u = clamp(px / ancho, 0.0, 1.0);
	float w = u;
	if (modo == 2) { w = 1.0 - u; }
	else if (modo == 3) { w = abs(u - 0.5) * 2.0; }
	else if (modo == 4) { w = 1.0 - abs(u - 0.5) * 2.0; }
	COLOR.a *= clamp((frente * (1.0 + suave) - w) / suave, 0.0, 1.0);
}
"""

const RUNAS_DE := {
	"a": "ᚨ", "b": "ᛒ", "c": "ᚲ", "d": "ᛞ", "e": "ᛖ", "f": "ᚠ", "g": "ᚷ", "h": "ᚺ", "i": "ᛁ", "j": "ᛃ",
	"k": "ᚲ", "l": "ᛚ", "m": "ᛗ", "n": "ᚾ", "o": "ᛟ", "p": "ᛈ", "q": "ᚲ", "r": "ᚱ", "s": "ᛋ", "t": "ᛏ",
	"u": "ᚢ", "v": "ᚹ", "w": "ᚹ", "x": "ᚲᛋ", "y": "ᛃ", "z": "ᛉ", "á": "ᚨ", "é": "ᛖ", "í": "ᛁ", "ó": "ᛟ",
	"ú": "ᚢ", "ñ": "ᚾ", "ö": "ᛟ", "ä": "ᚨ", "å": "ᚨ", "ø": "ᛟ", "æ": "ᛖ", " ": "᛫",
}

var _f_runas: Font
var _f_nombre: FontVariation
var _f_texto: Font
var _etiqueta: Label
var _mascara: ShaderMaterial
var _sombra: GradientTexture2D

var _tipo: Tipo = Tipo.LUGAR
var _c: Dictionary = {}
var _runas := ""
var _sub := ""
var _t := 0.0
var _activo := false
var _m := {}   ## momentos de la animación (se calculan al mostrar)

# dibujo de fondo: {principal: Array[PackedVector2Array], fondo: Array[Dictionary], unidad: Vector2 (ancho, alto)}
var _dib := {}
var _insignia: Texture2D


func _ready() -> void:
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	_f_runas = load(FUENTE_RUNAS)
	_f_texto = load(FUENTE_TEXTO)
	_f_nombre = FontVariation.new()
	_f_nombre.base_font = load(FUENTE_NOMBRE)
	_mascara = ShaderMaterial.new()
	var sh := Shader.new()
	sh.code = MASCARA
	_mascara.shader = sh
	_etiqueta = Label.new()
	_etiqueta.material = _mascara
	_etiqueta.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_etiqueta.add_theme_font_override("font", _f_nombre)
	_etiqueta.add_theme_color_override("font_color", BLANCO)
	_etiqueta.add_theme_color_override("font_shadow_color", Color(0, 0, 0, 0.75))
	add_child(_etiqueta)
	var g := Gradient.new()
	g.set_color(0, Color(0.016, 0.03, 0.03, 0.55))
	g.set_color(1, Color(0.016, 0.03, 0.03, 0.0))
	_sombra = GradientTexture2D.new()
	_sombra.gradient = g
	_sombra.fill = GradientTexture2D.FILL_RADIAL
	_sombra.fill_from = Vector2(0.5, 0.5)
	_sombra.fill_to = Vector2(1.0, 0.5)
	visible = false


# ---------- API ----------

func mostrar_lugar(nombre: String, runas := "") -> void:
	mostrar(Tipo.LUGAR, nombre, {"runas": runas})


func mostrar_tierra(nombre: String, region: String, runas := "") -> void:
	mostrar(Tipo.TIERRA, nombre, {"runas": runas, "region": region})


func mostrar_regreso(nombre: String, runas := "") -> void:
	mostrar(Tipo.REGRESO, nombre, {"runas": runas})


func mostrar_capital(nombre: String, capital: String, runas := "") -> void:
	mostrar(Tipo.CAPITAL, nombre, {"runas": runas, "capital": capital})


## opciones: "runas" (si falta, se pasan las letras del nombre a runas), "region", "capital",
## "entrada" (para probar otra Entrada sin tocar CONFIG).
func mostrar(tipo: Tipo, nombre: String, opciones := {}) -> void:
	_tipo = tipo
	_c = (CONFIG[tipo] as Dictionary).duplicate()
	if opciones.has("entrada"):
		_c.entrada = opciones.entrada
	var r: String = opciones.get("runas", "")
	_runas = r if r != "" else a_runas(nombre)
	_sub = tr(_c.texto).to_upper() if _c.texto != "" else ""
	_etiqueta.text = nombre
	_dib = {}
	_insignia = null
	match String(_c.dibujo):
		"region":
			var f: String = REGIONES.get(opciones.get("region", ""), "")
			if f != "":
				_dib = call(f)
		"estandarte":
			var cap: Dictionary = CAPITALES.get(opciones.get("capital", ""), {})
			if not cap.is_empty():
				_insignia = load(cap.insignia)
				_dib = _estandarte(_insignia)
	_calcular_momentos()
	_t = 0.0
	_activo = true
	visible = true
	_ubicar_nombre()
	queue_redraw()


## Duración total del cartel elegido (segundos).
func duracion() -> float:
	return _m.get("total", 0.0)


static func a_runas(texto: String) -> String:
	var s := ""
	for ch in texto.to_lower():
		s += RUNAS_DE.get(ch, "")
	return s


# ---------- tiempos ----------

func _calcular_momentos() -> void:
	var k: float = _c.velocidad
	var v := AGIL
	var m := {}
	m.rombo = 0.45 * v
	m.t0 = 0.25 * v                                   # salen las chispas
	m.dl = 1.1 * k * v                                # lo que tardan en llegar a las puntas
	var ns := _sub.length()
	var mitad_sub := maxi(1, ceili(ns / 2.0))
	m.ps = minf(0.3, 0.9 / mitad_sub) * k * v         # entre letra y letra del texto de abajo
	m.ds = 2.0 * k * v                                # lo que tarda cada letra en aparecer
	m.ts = m.t0 + 0.1                                 # el texto de abajo arranca 0,1 s después de las chispas
	var fin_sub: float = m.ts + (mitad_sub - 1) * m.ps + m.ds if ns > 0 else m.t0 + m.dl
	var nr := _runas.length()
	m.niv = maxi(0, ceili(nr / 2.0) - 1)
	m.pr = 0.2 * k * v
	m.dr = 1.6 * maxf(k, 0.75) * v
	# las runas van un poco más rápido para terminar junto con el texto de abajo
	m.tr = maxf(m.t0 + 0.3, fin_sub - m.dr - m.niv * m.pr) if ns > 0 else m.t0 + 0.1
	m.dn = 1.6 * maxf(k, 0.75)                        # lo que tarda el nombre en descubrirse
	m.vis = 0.375 * m.dn                              # cuándo empieza a verse (arranca suave)
	var fin_arriba: float = m.tr + m.niv * m.pr + 0.6 * m.dr
	m.tn = fin_arriba + 0.15 * k - m.vis              # 0,15 s entre las runas y el nombre
	var dp0 := 0.8 * maxf(k, 0.75)
	var fin_pulso: float = m.tn + m.vis - 0.45 * dp0 + dp0
	m.dp = dp0 * 2.0                                  # pulso de las runas: máximo cuando se ve el nombre
	m.tp = fin_pulso - m.dp
	m.pico = minf(0.9, (m.tn + m.vis - m.tp) / m.dp)
	m.fin_dib = DIBUJO_DURA if not _dib.is_empty() else 0.0
	m.fin = maxf(m.tn + m.dn + _c.quieto, m.fin_dib + DIBUJO_PULSO + 0.3 if not _dib.is_empty() else 0.0)
	m.total = m.fin + _c.salida
	_m = m


func _process(dt: float) -> void:
	if not _activo:
		return
	_t += dt
	_ubicar_nombre()
	queue_redraw()
	if _t >= _m.total:
		_activo = false
		visible = false
		termino.emit()


# ---------- ayudas ----------

func _e() -> float:
	return size.y / 1080.0


static func _tramo(t: float, ini: float, dur: float) -> float:
	return clampf((t - ini) / maxf(dur, 0.0001), 0.0, 1.0)


static func _suave(x: float) -> float:
	return x * x * (3.0 - 2.0 * x)


## Sube de a hasta b en `pico` y baja a c (fracción 0..1 del tramo).
static func _tres(f: float, a: float, b: float, c: float, pico: float) -> float:
	return lerpf(a, b, f / pico) if f < pico else lerpf(b, c, (f - pico) / (1.0 - pico))


static func _borde(i: int, n: int) -> int:
	return mini(i, n - 1 - i)   # 0 en las puntas, crece hacia el centro


func _ancho_texto(f: Font, s: String, tam: int, esp: float) -> float:
	var w := 0.0
	for ch in s:
		w += f.get_string_size(ch, HORIZONTAL_ALIGNMENT_LEFT, -1, tam).x + esp
	return w - esp if s.length() > 0 else 0.0


func _salida() -> float:
	return 1.0 - _suave(_tramo(_t, _m.fin, _c.salida))


# ---------- disposición ----------

func _y_bloque() -> Dictionary:
	var e := _e()
	var r: float = _c.runas * e
	var n: float = _c.nombre * e
	var s: float = _c.sub * e
	var gap := (8.0 if _c.posicion == "arriba" else 14.0) * e
	var extra := 22.0 * e if not _dib.is_empty() and _c.dibujo == "region" else 0.0
	var alto := r + gap + n + gap + extra + s
	var top := size.y * 0.5 - alto * 0.5
	if _c.posicion == "arriba":
		top = size.y * ALTO_ARRIBA
	elif _c.posicion == "alto":
		top = size.y * ALTO_CAPITAL
	var y_r := top + r
	var y_n := y_r + gap + n * 0.92
	var y_p := y_n + gap + extra + s * 0.55
	return {"runas": y_r, "nombre": y_n, "pie": y_p, "top": top, "alto": alto}


func _ubicar_nombre() -> void:
	var e := _e()
	var tam := int(_c.nombre * e)
	_f_nombre.spacing_glyph = int(_c.nombre * ESPACIO_NOMBRE * e)
	_etiqueta.add_theme_font_size_override("font_size", tam)
	_etiqueta.add_theme_constant_override("shadow_offset_y", int(3 * e))
	_etiqueta.size = Vector2.ZERO
	var ms := _etiqueta.get_minimum_size()
	_etiqueta.size = ms
	var y := _y_bloque()
	_etiqueta.position = Vector2(size.x * 0.5 - ms.x * 0.5, y.nombre - ms.y * 0.78)
	# entrada del nombre
	var f := _tramo(_t, _m.get("tn", 0.0), _m.get("dn", 1.0))
	f = 4.0 * f * f * f if f < 0.5 else 1.0 - pow(-2.0 * f + 2.0, 3.0) * 0.5
	_mascara.set_shader_parameter("frente", f)
	_mascara.set_shader_parameter("modo", int(_c.entrada))
	_mascara.set_shader_parameter("ancho", ms.x)
	_mascara.set_shader_parameter("suave", clampf(tam * 1.3 / maxf(ms.x, 1.0), 0.05, 0.6))
	# brillo dorado que se asienta y salida
	var g := _tramo(_t, _m.get("tn", 0.0), _m.get("dn", 1.0) + 0.5)
	var glow := lerpf(0.85, 0.45, _suave(g))
	_etiqueta.add_theme_color_override("font_outline_color", Color(1.0, 0.8, 0.45, 0.22 * glow))
	_etiqueta.add_theme_constant_override("outline_size", int(tam * 0.22 * glow))
	_etiqueta.modulate.a = clampf(g / 0.25, 0.0, 1.0) * _salida()


# ---------- dibujo ----------

func _draw() -> void:
	if not _activo or _m.is_empty():
		return
	var e := _e()
	var y := _y_bloque()
	var cx := size.x * 0.5
	var sal := _salida()
	# sombra detrás de los carteles grandes
	if _c.posicion != "arriba":
		var a := _suave(_tramo(_t, 0.0, 0.6)) * sal
		var w: float = _c.linea * e * 1.25
		var h: float = y.alto * 2.6
		draw_texture_rect(_sombra, Rect2(cx - w * 0.5, y.top + y.alto * 0.5 - h * 0.5, w, h), false, Color(1, 1, 1, a))
	if not _dib.is_empty():
		_dibujo_fondo(e, y, sal)
	_pie(e, y.pie, sal)
	_renglon_runas(e, y.runas, sal)


func _pie(e: float, py: float, sal: float) -> void:
	var cx := size.x * 0.5
	var tam_sub := int(_c.sub * e)
	var esp: float = _c.sub * ESPACIO_SUB * e
	var rombo: float = (_c.sub * 0.5) * e
	var hueco := 12.0 * e
	var ancho_sub := _ancho_texto(_f_texto, _sub, tam_sub, esp) if _sub != "" else 0.0
	var centro: float = ancho_sub + (rombo * 2.0 + hueco * 2.0) * 2.0 if _sub != "" else rombo * 2.0 + hueco * 2.0
	var largo: float = maxf(20.0, (_c.linea * e - centro) * 0.5)
	# rombos
	var fr := _tramo(_t, 0.0, _m.rombo)
	var esc_r := _tres(fr, 0.2, 1.4, 1.0, 0.6)
	var a_r := clampf(fr / 0.6, 0.0, 1.0) * sal
	var rombos: Array = [cx] if _sub == "" else [cx - ancho_sub * 0.5 - hueco - rombo, cx + ancho_sub * 0.5 + hueco + rombo]
	for rx in rombos:
		_rombo(Vector2(rx, py), rombo * esc_r, a_r)
	# líneas: las dibujan dos chispas desde los rombos hacia afuera; al irse se recogen
	var p := _tramo(_t, _m.t0, _m.dl)
	p = 1.0 - pow(1.0 - _suave(p), 1.6)
	var rec := 1.0 - pow(_tramo(_t, _m.fin, _c.salida), 2.0)
	var largo_vis := largo * p * rec
	for lado in [-1.0, 1.0]:
		var ini := Vector2((rombos[0] if lado < 0 else rombos[rombos.size() - 1]) + lado * (rombo + hueco), py)
		var fin := ini + Vector2(lado * largo_vis, 0)
		if largo_vis > 0.5:
			var c_fin := ORO_LINEA.lerp(Color(ORO_LINEA, 0.0), largo_vis / largo)
			draw_polyline_colors(PackedVector2Array([ini, fin]), PackedColorArray([Color(ORO, 0.35), Color(c_fin, c_fin.a * 0.35)]), 5.0 * e)
			draw_polyline_colors(PackedVector2Array([ini, fin]), PackedColorArray([ORO, c_fin]), 1.6 * e, true)
		var chispa := _tramo(_t, _m.t0, _m.dl + 0.08)
		if chispa > 0.0 and chispa < 1.0:
			var a_ch := 1.0 if chispa < 0.94 else (1.0 - chispa) / 0.06
			draw_circle(fin, 9.0 * e, Color(1.0, 0.75, 0.35, 0.25 * a_ch))
			draw_circle(fin, 3.2 * e, Color(PUNTA, a_ch))
	# texto de abajo: de los costados al centro
	if _sub != "":
		var x := cx - ancho_sub * 0.5
		var n := _sub.length()
		for i in n:
			var ch := _sub[i]
			var w := _f_texto.get_string_size(ch, HORIZONTAL_ALIGNMENT_LEFT, -1, tam_sub).x
			var f := _tramo(_t, _m.ts + _borde(i, n) * _m.ps, _m.ds)
			var a := _tres(f, 0.0, 0.9, 1.0, 0.55) * sal
			var brillo := _tres(f, 0.0, 0.8, 0.0, 0.55)
			if a > 0.01 and ch != " ":
				var pos := Vector2(x, py + tam_sub * 0.36)
				if brillo > 0.01:
					draw_string_outline(_f_texto, pos, ch, HORIZONTAL_ALIGNMENT_LEFT, -1, tam_sub, int(tam_sub * 0.5), Color(1.0, 0.82, 0.55, 0.3 * brillo * sal))
				draw_string(_f_texto, pos, ch, HORIZONTAL_ALIGNMENT_LEFT, -1, tam_sub, Color(ORO_SUB, a))
			x += w + esp


func _rombo(c: Vector2, r: float, a: float) -> void:
	if a <= 0.01:
		return
	draw_circle(c, r * 1.6, Color(1.0, 0.85, 0.54, 0.18 * a))
	var pts := PackedVector2Array([c + Vector2(0, -r), c + Vector2(r, 0), c + Vector2(0, r), c + Vector2(-r, 0), c + Vector2(0, -r)])
	draw_polyline(pts, Color(ORO, a), maxf(1.0, r * 0.28), true)


func _renglon_runas(e: float, ry: float, sal: float) -> void:
	var tam := int(_c.runas * e)
	var esp: float = _c.runas * ESPACIO_RUNAS * e
	var ancho := _ancho_texto(_f_runas, _runas, tam, esp)
	var x := size.x * 0.5 - ancho * 0.5
	var n := _runas.length()
	# pulso: las runas laten y el brillo llega al máximo justo cuando se empieza a ver el nombre
	var fp := _tramo(_t, _m.tp, _m.dp)
	var pulso := _tres(fp, 0.0, 1.0, 0.0, _m.pico) if fp > 0.0 and fp < 1.0 else 0.0
	pulso = _suave(pulso) * float(_c.pulso)
	for i in n:
		var ch := _runas[i]
		var w := _f_runas.get_string_size(ch, HORIZONTAL_ALIGNMENT_LEFT, -1, tam).x
		var f := _tramo(_t, _m.tr + _borde(i, n) * _m.pr, _m.dr)
		var a := _tres(f, 0.0, 0.85, 1.0, 0.6) * sal
		var sube := _tres(f, 0.25, 0.08, 0.0, 0.6) * tam * 0.6
		var brillo := _tres(f, 0.0, 1.0, 0.45, 0.6) + pulso * 0.55
		if a > 0.01:
			var pos := Vector2(x, ry + sube)
			draw_string_outline(_f_runas, pos, ch, HORIZONTAL_ALIGNMENT_LEFT, -1, tam, int(tam * (0.55 + pulso * 0.35)), Color(ORO_BRILLO, 0.35 * brillo * a))
			draw_string(_f_runas, pos, ch, HORIZONTAL_ALIGNMENT_LEFT, -1, tam, Color(ORO.lerp(Color.WHITE, 0.25 * pulso), a))
		x += w + esp


# ---------- paisaje / estandarte en un solo trazo ----------

## Avance del dibujo: arranca y termina despacio, como una mano que dibuja.
func _avance_dibujo() -> float:
	var t := _tramo(_t, 0.0, DIBUJO_DURA)
	return (0.5 - 0.5 * cos(PI * t)) * 0.92 + t * 0.08


func _dibujo_fondo(e: float, y: Dictionary, sal: float) -> void:
	var u: Vector2 = _dib.unidad
	var esc: float
	var origen: Vector2
	if _c.dibujo == "region":
		esc = DIBUJO_ANCHO * e / u.x
		var suelo: float = y.pie - (_c.sub * 0.55 + 14.0) * e   # el suelo queda entre el nombre y el renglón de abajo
		origen = Vector2(size.x * 0.5 - u.x * esc * 0.5, suelo - 280.0 * esc)
	else:
		esc = ESTANDARTE_ALTO * e / u.y
		origen = Vector2(size.x * 0.5, y.top - _c.runas * e * 0.35 - 10.0 * esc)   # la vara a la altura de lo alto de las runas
	var M := func(p: Vector2) -> Vector2: return origen + p * esc
	var t := _tramo(_t, 0.0, DIBUJO_DURA)
	var avance := _avance_dibujo()
	var fin_dib: float = _m.fin_dib
	var colorea := _suave(_tramo(_t, fin_dib, DIBUJO_PULSO * 0.45))   # junto con el pulso toma el color del puntero
	var fpul := _tramo(_t, fin_dib, DIBUJO_PULSO)
	var pulso := _suave(_tres(fpul, 0.0, 1.0, 0.0, 0.45)) if fpul > 0.0 and fpul < 1.0 else 0.0
	var principal: Array = _dib.principal
	var largo := _largo(principal)
	var l := avance * largo * 0.5
	var qa := _punto_en(principal, l)
	var qb := _punto_en(principal, largo - l)
	# detalles de fondo, a la par del puntero de su lado
	for d in _dib.fondo:
		var partes: Array = d.partes
		var ld := _largo(partes)
		var col := Color(ORO, (0.18 if d.get("lejos", false) else 0.3) * sal * (1.0 + pulso * 0.6))
		var ancho := 0.9 * esc
		if d.get("ancho", false):
			var h := ld * 0.5 * (1.0 if t >= 1.0 else avance)   # de lado a lado: desde las dos puntas, al ritmo del trazo
			_tramo_de(partes, 0.0, h, col, ancho, M)
			_tramo_de(partes, ld - h, ld, col, ancho, M)
		else:
			var izq: bool = (d.x0 + d.x1) * 0.5 < u.x * 0.5   # los de la izquierda siguen al puntero izquierdo
			var a := 1.0 if t >= 1.0 else clampf((qa.x - d.x0) / (d.x1 - d.x0) if izq else (d.x1 - qb.x) / (d.x1 - d.x0), 0.0, 1.0)
			if izq:
				_tramo_de(partes, 0.0, ld * a, col, ancho, M)
			else:
				_tramo_de(partes, ld * (1.0 - a), ld, col, ancho, M)
	# insignia de la capital: se tiñe de dorado con el pulso
	if _insignia and _dib.has("insignia_rect"):
		var r: Rect2 = _dib.insignia_rect
		draw_texture_rect(_insignia, Rect2(M.call(r.position), r.size * esc), false, Color(ORO, 0.22 * colorea * sal))
	# trazo principal, desde los dos costados a la vez
	var c_trazo := Color(ORO, 0.5).lerp(Color(TRAZO_FINAL, 1.0), colorea)
	c_trazo.a *= sal
	var w := lerpf(1.3, 3.4, colorea) * esc
	if pulso > 0.0:
		var g := Color(ORO_BRILLO, 0.35 * pulso * sal)
		_tramo_de(principal, 0.0, l, g, w + 9.0 * esc * pulso, M)
		_tramo_de(principal, largo - l, largo, g, w + 9.0 * esc * pulso, M)
	_tramo_de(principal, 0.0, l, c_trazo, w, M)
	_tramo_de(principal, largo - l, largo, c_trazo, w, M)
	# las dos puntas que dibujan, con su puntero
	if t < 1.0:
		var seg := largo * 0.03
		_tramo_de(principal, maxf(0.0, l - seg), l, Color(TRAZO_FINAL, sal), 3.4 * esc, M)
		_tramo_de(principal, largo - l, minf(largo, largo - l + seg), Color(TRAZO_FINAL, sal), 3.4 * esc, M)
		for q in [qa, qb]:
			var p: Vector2 = M.call(q)
			draw_circle(p, 14.0 * esc, Color(1.0, 0.78, 0.43, 0.2 * sal))
			draw_circle(p, 7.0 * esc, Color(1.0, 0.85, 0.54, 0.35 * sal))
			draw_circle(p, 3.6 * esc, Color(1.0, 0.95, 0.84, sal))


static func _largo(partes: Array) -> float:
	var s := 0.0
	for p in partes:
		var pts: PackedVector2Array = p
		for i in range(1, pts.size()):
			s += pts[i - 1].distance_to(pts[i])
	return s


static func _punto_en(partes: Array, l: float) -> Vector2:
	var resto := l
	for p in partes:
		var pts: PackedVector2Array = p
		for i in range(1, pts.size()):
			var tr := pts[i - 1].distance_to(pts[i])
			if resto <= tr:
				return pts[i - 1].lerp(pts[i], resto / maxf(tr, 0.0001))
			resto -= tr
	var ult: PackedVector2Array = partes[partes.size() - 1]
	return ult[ult.size() - 1]


## Dibuja la parte del recorrido entre las longitudes `desde` y `hasta` (en unidades del dibujo).
func _tramo_de(partes: Array, desde: float, hasta: float, col: Color, ancho: float, M: Callable) -> void:
	if hasta - desde < 0.01 or col.a <= 0.005:
		return
	var acum := 0.0
	for p in partes:
		var pts: PackedVector2Array = p
		var linea := PackedVector2Array()
		for i in range(1, pts.size()):
			var a := pts[i - 1]
			var b := pts[i]
			var tr := a.distance_to(b)
			var s0 := acum
			var s1 := acum + tr
			acum = s1
			if s1 < desde or s0 > hasta:
				if linea.size() > 1:
					draw_polyline(linea, col, ancho, true)
				linea = PackedVector2Array()
				continue
			var fa := clampf((desde - s0) / maxf(tr, 0.0001), 0.0, 1.0)
			var fb := clampf((hasta - s0) / maxf(tr, 0.0001), 0.0, 1.0)
			if linea.is_empty():
				linea.append(M.call(a.lerp(b, fa)))
			linea.append(M.call(a.lerp(b, fb)))
		if linea.size() > 1:
			draw_polyline(linea, col, ancho, true)


# ---------- dibujos de cada región y capital ----------

## Un recorrido hecho con líneas y curvas (cuadráticas), como un trazo de pluma.
class Pluma:
	var partes: Array = []
	var actual := PackedVector2Array()

	func mover(x: float, y: float) -> void:
		if actual.size() > 1:
			partes.append(actual)
		actual = PackedVector2Array([Vector2(x, y)])

	func linea(x: float, y: float) -> void:
		actual.append(Vector2(x, y))

	func curva(cx: float, cy: float, x: float, y: float) -> void:
		var a: Vector2 = actual[actual.size() - 1]
		var c := Vector2(cx, cy)
		var b := Vector2(x, y)
		var n := maxi(4, int(a.distance_to(b) / 6.0))
		for i in range(1, n + 1):
			var t := float(i) / n
			actual.append(a.lerp(c, t).lerp(c.lerp(b, t), t))

	func ultimo() -> Vector2:
		return actual[actual.size() - 1]

	func cerrar() -> Array:
		if actual.size() > 1:
			partes.append(actual)
		actual = PackedVector2Array()
		return partes


## Eldervald: montañas en los extremos, pinos y el Gran Roble en el centro (lienzo de 1000 × 300, suelo en y=280).
func _paisaje_eldervald() -> Dictionary:
	const B := 280.0
	var p := Pluma.new()
	p.mover(0, B)
	var suelo := func(x2: float, ondula: float) -> void:
		var x1: float = p.ultimo().x
		p.curva((x1 + x2) * 0.5, B - ondula, x2, B)
	var pino := func(x: float, h: float, w: float) -> void:
		var t := w * 0.07
		for q in [[x - t, B], [x - t, B - h * 0.12], [x - w * 0.5, B - h * 0.12], [x - w * 0.2, B - h * 0.4], [x - w * 0.38, B - h * 0.4],
				[x - w * 0.12, B - h * 0.66], [x - w * 0.26, B - h * 0.66], [x, B - h], [x + w * 0.26, B - h * 0.66], [x + w * 0.12, B - h * 0.66],
				[x + w * 0.38, B - h * 0.4], [x + w * 0.2, B - h * 0.4], [x + w * 0.5, B - h * 0.12], [x + t, B - h * 0.12], [x + t, B]]:
			p.linea(q[0], q[1])
	var monte := func(x1: float, x2: float, h: float) -> void:
		var m := (x1 + x2) * 0.5
		var w := x2 - x1
		for q in [[x1 + w * 0.12, B - h * 0.28], [x1 + w * 0.2, B - h * 0.24], [x1 + w * 0.3, B - h * 0.55], [x1 + w * 0.36, B - h * 0.5],
				[m - w * 0.04, B - h * 0.92], [m, B - h], [m + w * 0.06, B - h * 0.86], [m - w * 0.02, B - h * 0.74], [m + w * 0.1, B - h * 0.78],
				[m + w * 0.04, B - h * 0.66], [m + w * 0.16, B - h * 0.6], [x2 - w * 0.22, B - h * 0.42], [x2 - w * 0.14, B - h * 0.46], [x2, B]]:
			p.linea(q[0], q[1])
	var roble := func(x: float) -> void:
		p.linea(x - 24, B)
		p.curva(x - 14, B - 20, x - 14, B - 70)
		p.curva(x - 40, B - 60, x - 62, B - 82)
		var prev := Vector2(x - 62, B - 82)
		for c in [[-100, -104], [-128, -140], [-122, -182], [-98, -214], [-62, -240], [-20, -252], [22, -250], [62, -236], [96, -210], [120, -176], [124, -138], [102, -106], [66, -94]]:
			var nxt := Vector2(x + c[0] * 0.9, B + c[1])
			var mid := (prev + nxt) * 0.5
			var d := Vector2(nxt.y - prev.y, -(nxt.x - prev.x)) * 0.42
			p.curva(mid.x + d.x, mid.y + d.y, nxt.x, nxt.y)
			prev = nxt
		p.curva(x + 40, B - 70, x + 14, B - 72)
		p.curva(x + 14, B - 20, x + 26, B)
		p.linea(x + 34, B)
		p.curva(x + 44, B - 4, x + 52, B)
	monte.call(0, 170, 240); pino.call(200, 130, 64); pino.call(250, 175, 82); suelo.call(300, 6); pino.call(335, 120, 60); suelo.call(385, 8)
	roble.call(500); suelo.call(612, 8)
	pino.call(650, 165, 78); pino.call(705, 118, 60); suelo.call(740, 5); pino.call(780, 140, 68); monte.call(820, 1000, 270)
	var principal := p.cerrar()

	var fondo: Array = []
	var cresta := func(y0: float, pts: Array, dy: float, lejos: bool) -> void:
		var q := Pluma.new()
		q.mover(0, y0)
		var prev := Vector2(0, y0)
		for c in pts:
			q.curva((prev.x + c[0]) * 0.5, minf(prev.y, c[1]) - dy, c[0], c[1])
			prev = Vector2(c[0], c[1])
		fondo.append({"partes": q.cerrar(), "ancho": true, "lejos": lejos})
	cresta.call(150.0, [[70, 128], [150, 96], [220, 124], [290, 104], [370, 132], [450, 92], [520, 120], [600, 98], [680, 126], [760, 90], [840, 118], [920, 100], [1000, 140]], 10.0, true)
	cresta.call(212.0, [[45, 188], [80, 200], [130, 168], [175, 194], [230, 182], [300, 198], [360, 176], [420, 190], [480, 172], [540, 186], [600, 170], [660, 192], [720, 178], [770, 196], [830, 166], [880, 190], [940, 178], [1000, 206]], 8.0, false)
	var bruma := func(x0: float, y0: float, pts: Array, dy: float, lejos: bool) -> void:
		var q := Pluma.new()
		q.mover(x0, y0)
		var ax := x0
		for c in pts:
			q.curva((ax + c[0]) * 0.5, c[1] - dy, c[0], c[1])
			ax = c[0]
		fondo.append({"partes": q.cerrar(), "ancho": true, "lejos": lejos})
	bruma.call(0.0, 252.0, [[120, 244], [250, 254], [380, 246], [520, 256], [650, 246], [780, 254], [900, 246], [1000, 252]], 7.0, false)
	bruma.call(20.0, 236.0, [[160, 230], [300, 238], [440, 232], [560, 238], [700, 230], [840, 236], [980, 232]], 5.0, true)
	var fila := func(xs: Array, b: float, x0: float, x1: float, lejos: bool) -> void:
		var q := Pluma.new()
		q.mover(xs[0] - 8, b)
		for i in xs.size():
			var x: float = xs[i]
			var h := 22.0 + ((i * 7) % 3) * 8.0
			q.linea(x - 6, b); q.linea(x, b - h); q.linea(x + 6, b)
		fondo.append({"partes": q.cerrar(), "x0": x0, "x1": x1, "lejos": lejos})
	fila.call([392, 410, 424, 441, 456], 266.0, 370.0, 470.0, false)
	fila.call([548, 563, 580, 596, 612], 266.0, 530.0, 630.0, false)
	fila.call([120, 134, 150, 166], 236.0, 100.0, 180.0, true)
	fila.call([850, 866, 880, 896], 236.0, 830.0, 910.0, true)
	# casa larga lejana con humo
	var casa := Pluma.new()
	casa.mover(640, 246); casa.linea(640, 232); casa.linea(652, 222); casa.linea(688, 222); casa.linea(700, 232); casa.linea(700, 246)
	casa.mover(648, 226); casa.linea(644, 218); casa.mover(692, 226); casa.linea(696, 218)
	casa.mover(666, 222); casa.curva(662, 210, 670, 202); casa.curva(678, 194, 672, 184); casa.curva(668, 176, 676, 168)
	fondo.append({"partes": casa.cerrar(), "x0": 620.0, "x1": 720.0})
	# piedras rúnicas al pie del Roble
	for pr in [[440.0, 30.0, 1.0, 420.0, 460.0], [562.0, 24.0, -1.0, 540.0, 580.0]]:
		var x: float = pr[0]
		var h: float = pr[1]
		var q := Pluma.new()
		q.mover(x - 9, 276); q.curva(x - 11, 276 - h * 0.6, x - 5, 276 - h); q.curva(x, 276 - h - 4, x + 5, 276 - h); q.curva(x + 11, 276 - h * 0.6, x + 9, 276)
		q.mover(x, 276 - h * 0.78); q.linea(x, 276 - h * 0.25); q.mover(x, 276 - h * 0.62); q.linea(x + 5 * pr[2], 276 - h * 0.5)
		fondo.append({"partes": q.cerrar(), "x0": pr[3], "x1": pr[4]})
	# luna creciente
	var luna := Pluma.new()
	luna.mover(318, 34)
	for i in range(1, 25):
		var a := PI * 0.5 + PI * i / 24.0
		luna.linea(318 + cos(a) * 26.0, 60 - sin(a) * 26.0)
	for i in range(1, 25):
		var s := float(i) / 24.0
		luna.linea(318 - 14.0 * sin(PI * s), 86 - 52.0 * s)
	fondo.append({"partes": luna.cerrar(), "x0": 250.0, "x1": 340.0})
	# estrellas, nubes y pájaros
	for st in [[210, 40], [360, 22], [470, 30], [600, 26], [760, 36], [640, 60]]:
		var q := Pluma.new()
		q.mover(st[0], st[1] - 5); q.linea(st[0], st[1] + 5); q.mover(st[0] - 5, st[1]); q.linea(st[0] + 5, st[1])
		fondo.append({"partes": q.cerrar(), "x0": st[0] - 50.0, "x1": st[0] + 10.0})
	for nb in [[150.0, 70.0, 120.0, 300.0], [700.0, 44.0, 690.0, 860.0]]:
		var q := Pluma.new()
		var x: float = nb[0]
		var yy: float = nb[1]
		q.mover(x, yy); q.curva(x + 40, yy - 10, x + 80, yy - 2); q.curva(x + 110, yy - 14, x + 150, yy - 6)
		fondo.append({"partes": q.cerrar(), "x0": nb[2], "x1": nb[3]})
	for pj in [[410, 78], [432, 66], [452, 84], [690, 58], [708, 70], [560, 90]]:
		var q := Pluma.new()
		var x: float = pj[0]
		var yy: float = pj[1]
		q.mover(x - 8, yy); q.curva(x - 4, yy - 5, x, yy); q.curva(x + 4, yy - 5, x + 8, yy)
		fondo.append({"partes": q.cerrar(), "x0": x - 60.0, "x1": x + 20.0})
	var pasto := Pluma.new()
	for x in [70.0, 160.0, 300.0, 390.0, 620.0, 740.0, 860.0, 950.0]:
		pasto.mover(x, 282); pasto.linea(x - 3, 272); pasto.mover(x + 3, 282); pasto.linea(x + 3, 270); pasto.mover(x + 6, 282); pasto.linea(x + 9, 273)
	fondo.append({"partes": pasto.cerrar(), "ancho": true})
	return {"principal": principal, "fondo": fondo, "unidad": Vector2(1000, 300)}


## Estandarte de una capital: la tela colgada de su vara, dibujada desde arriba al centro por los dos lados hasta
## la punta de abajo, y la insignia de la capital calcada adentro (lienzo de 400 × 620, centrado en x = 0; la vara en y = 10).
func _estandarte(insignia: Texture2D) -> Dictionary:
	var p := Pluma.new()
	p.mover(0, 22)
	for q in [[-150, 22], [-150, 500], [0, 600], [150, 500], [150, 22], [0, 22]]:
		p.linea(q[0], q[1])
	var principal := p.cerrar()
	var fondo: Array = []
	# vara con remates
	var vara := Pluma.new()
	vara.mover(-194, 10); vara.linea(194, 10)
	for xr in [-200.0, 200.0]:
		vara.mover(xr + 6, 10)
		for i in range(1, 17):
			var a := TAU * i / 16.0
			vara.linea(xr + cos(a) * 6.0, 10 + sin(a) * 6.0)
	vara.mover(-182, 10); vara.linea(-150, 22); vara.mover(182, 10); vara.linea(150, 22)
	fondo.append({"partes": vara.cerrar(), "ancho": true})
	# borde interior de la tela
	var borde := Pluma.new()
	borde.mover(0, 36)
	for q in [[-136, 36], [-136, 492], [0, 580], [136, 492], [136, 36], [0, 36]]:
		borde.linea(q[0], q[1])
	fondo.append({"partes": borde.cerrar(), "ancho": true, "lejos": true})
	# contorno de la insignia (se calca del PNG)
	var rect := Rect2()
	if insignia:
		var img := insignia.get_image()
		var bm := BitMap.new()
		bm.create_from_image_alpha(img, 0.5)
		var polis := bm.opaque_to_polygons(Rect2i(Vector2i.ZERO, img.get_size()), 2.0)
		var alto := 440.0
		var esc := alto / img.get_height()
		var ancho := img.get_width() * esc
		var o := Vector2(-ancho * 0.5, 80)
		rect = Rect2(o, Vector2(ancho, alto))
		for poly in polis:
			var pts := PackedVector2Array()
			for v in poly:
				pts.append(o + v * esc)
			if pts.size() > 2:
				pts.append(pts[0])
				fondo.append({"partes": [pts], "ancho": true})
	return {"principal": principal, "fondo": fondo, "unidad": Vector2(400, 620), "insignia_rect": rect}
