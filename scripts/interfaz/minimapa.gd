class_name Minimapa
extends Control
## Minimapa de arriba a la derecha: el mapa ilustrado de Eldervald alrededor de Eromash, con el norte arriba,
## la flecha del héroe, hacia dónde mira la cámara y el objetivo. Lo no explorado queda bajo una niebla que se
## despeja al caminar y se guarda con la partida (Juego.niebla).

const MAPA := "res://assets/interfaz/mapa-eldervald.png"
const LADO := 220.0          ## px en pantalla
const VISTA := 60.0          ## metros desde el centro hasta el borde del minimapa
const CELDA := 2.0           ## metros por celda de niebla
const RADIO_VISTA := 24.0    ## metros que se despejan alrededor de Eromash
const BORDE_SUAVE := 8.0
const NIEBLA := Color(0.04, 0.06, 0.06)
const AZUL := Color(0.45, 0.84, 0.86)
const AMBAR := Color(0.91, 0.72, 0.4)
const ROJO := Color(0.78, 0.25, 0.18)

var heroe: Node3D
var camara: Camara

var _mapa: Texture2D
var _niebla: Image
var _tex_niebla: ImageTexture
var _celdas := Vector2i.ZERO
var _ultimo := Vector2(INF, INF)
var _t := 0.0


func _ready() -> void:
	custom_minimum_size = Vector2(LADO, LADO)
	size = custom_minimum_size
	clip_contents = true
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	_mapa = load(MAPA)
	_celdas = Vector2i(ceili(Datos.ANCHO / CELDA) + 1, ceili(Datos.ALTO / CELDA) + 1)
	var datos := PackedByteArray()
	if Juego.niebla.size() == _celdas.x * _celdas.y:
		datos = Juego.niebla
	else:
		datos.resize(_celdas.x * _celdas.y)
		datos.fill(255)
	_niebla = Image.create_from_data(_celdas.x, _celdas.y, false, Image.FORMAT_L8, datos)
	_tex_niebla = ImageTexture.create_from_image(_a_rgba())


## La niebla se guarda como un byte por celda (255 = sin explorar); para dibujarla se pasa a color con alfa.
func _a_rgba() -> Image:
	var img := Image.create(_celdas.x, _celdas.y, false, Image.FORMAT_RGBA8)
	var d := _niebla.get_data()
	var out := PackedByteArray()
	out.resize(d.size() * 4)
	var r := int(NIEBLA.r * 255)
	var g := int(NIEBLA.g * 255)
	var b := int(NIEBLA.b * 255)
	for i in d.size():
		out[i * 4] = r
		out[i * 4 + 1] = g
		out[i * 4 + 2] = b
		out[i * 4 + 3] = d[i]
	img.set_data(_celdas.x, _celdas.y, false, Image.FORMAT_RGBA8, out)
	return img


func _celda_de(p: Vector2) -> Vector2:
	return (p + Vector2(Datos.ANCHO, Datos.ALTO) * 0.5) / CELDA


func _process(dt: float) -> void:
	if heroe == null:
		return
	_t += dt
	var p := Vector2(heroe.global_position.x, heroe.global_position.z)
	if _t > 0.25 and p.distance_to(_ultimo) > 1.0:
		_t = 0.0
		_ultimo = p
		_despejar(p)
	queue_redraw()


func _despejar(p: Vector2) -> void:
	var c := _celda_de(p)
	var r := (RADIO_VISTA + BORDE_SUAVE) / CELDA
	var cambio := false
	for y in range(maxi(0, floori(c.y - r)), mini(_celdas.y, ceili(c.y + r) + 1)):
		for x in range(maxi(0, floori(c.x - r)), mini(_celdas.x, ceili(c.x + r) + 1)):
			var d := Vector2(x, y).distance_to(c) * CELDA
			var a := int(clampf((d - RADIO_VISTA) / BORDE_SUAVE, 0.0, 1.0) * 255.0)
			var antes := _niebla.get_pixel(x, y).r8
			if a < antes:
				_niebla.set_pixel(x, y, Color8(a, a, a))
				cambio = true
	if cambio:
		_tex_niebla.update(_a_rgba())
		Juego.niebla = _niebla.get_data()


## Metros del mundo → px dentro del minimapa.
func _a_pantalla(p: Vector2, centro: Vector2) -> Vector2:
	return Vector2(LADO, LADO) * 0.5 + (p - centro) * (LADO * 0.5 / VISTA)


func _draw() -> void:
	if heroe == null:
		return
	var centro := Vector2(heroe.global_position.x, heroe.global_position.z)
	var todo := Rect2(Vector2.ZERO, Vector2(LADO, LADO))
	draw_rect(todo, NIEBLA)
	# el mapa ilustrado: 1 px del mapa = Datos.ESCALA m
	var px_centro := centro / Datos.ESCALA + Datos.CENTRO_MAPA
	var medio_px := VISTA / Datos.ESCALA
	draw_texture_rect_region(_mapa, todo, Rect2(px_centro - Vector2(medio_px, medio_px), Vector2(medio_px, medio_px) * 2.0))
	# niebla
	var c := _celda_de(centro)
	var medio_c := VISTA / CELDA
	draw_texture_rect_region(_tex_niebla, todo, Rect2(c - Vector2(medio_c, medio_c), Vector2(medio_c, medio_c) * 2.0))
	# hacia dónde mira la cámara
	if camara:
		var mira := Vector2(-sin(camara.giro), -cos(camara.giro))
		var m := Vector2(LADO, LADO) * 0.5
		var a := mira.rotated(0.55) * 46.0
		var b := mira.rotated(-0.55) * 46.0
		draw_colored_polygon(PackedVector2Array([m, m + a, m + b]), Color(AZUL, 0.16))
	# objetivo (si cae afuera, queda pegado al borde)
	var o := Juego.donde_objetivo()
	if o != Vector3.INF:
		var q := _a_pantalla(Vector2(o.x, o.z), centro)
		var adentro := todo.grow(-8).has_point(q)
		q = q.clamp(Vector2(8, 8), Vector2(LADO - 8, LADO - 8))
		var t := 7.0 if adentro else 5.0
		draw_colored_polygon(PackedVector2Array([q + Vector2(0, -t), q + Vector2(t, 0), q + Vector2(0, t), q + Vector2(-t, 0)]), AZUL)
	# Eromash: flecha hacia donde mira (el modelo mira a +Z)
	var ry := heroe.global_rotation.y
	var f := Vector2(sin(ry), cos(ry))
	var l := f.orthogonal()
	var m2 := Vector2(LADO, LADO) * 0.5
	var flecha := PackedVector2Array([m2 + f * 12.0, m2 - f * 8.0 + l * 8.0, m2 - f * 4.0, m2 - f * 8.0 - l * 8.0])
	draw_colored_polygon(flecha, ROJO)
	flecha.append(flecha[0])
	draw_polyline(flecha, Color(0.95, 0.92, 0.85), 1.5, true)
	# marco y norte
	draw_rect(todo, Color(AMBAR, 0.7), false, 2.0)
	var fuente := get_theme_default_font()
	draw_string(fuente, Vector2(LADO * 0.5 - 5, 16), tr("minimapa_norte"), HORIZONTAL_ALIGNMENT_LEFT, -1, 14, AMBAR)
