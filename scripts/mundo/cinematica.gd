class_name Cinematica
extends Node
## Una cinemática hecha con el motor: cámara propia con planos y cortes, franjas de cine, subtítulos ES/EN
## y sucesos en el tiempo (luces, animaciones, sonidos, cambios de estado). Se arma por código, plano por plano,
## siguiendo la guía de `docs/historia-y-cinematicas.md`, y se reproduce sobre el mundo que ya está cargado.
##
##   var c := Cinematica.new()
##   c.plano(2.5, desde, mirar_desde, hasta, mirar_hasta, 40.0)   # dura 2,5 s, la cámara viaja de un punto a otro
##   c.linea(1.0, "eromash", "dlg_runa_paso", 3.0)                # subtítulo a 1 s del principio, durante 3 s
##   c.al(0.5, func(): luz.fuerza = 1.0, true)                    # true = cambia el estado: corre aunque se salte
##   c.reproducir(self, camara_del_juego, hud, heroe)
##
## Saltar: mantener «interactuar» (F / Y). Los sucesos marcados como estado se aplican igual, así saltar
## nunca deja la partida a medias.

signal termino

const FRANJA := 0.11          ## alto de cada franja de cine (fracción de la pantalla)
const ENTRA := 0.6            ## segundos que tardan las franjas en entrar y salir
const SALTAR_MANTENER := 0.8  ## segundos manteniendo «interactuar» para saltar
const VUELTA := 1.4           ## segundos que tarda la cámara en volver a la del juego al final

var _planos: Array[Dictionary] = []   ## {ini, dur, desde, mirar_desde, hasta, mirar_hasta, fov, curva}
var _sucesos: Array[Dictionary] = []  ## {t, f, estado, hecho}
var _lineas: Array[Dictionary] = []   ## {t, dur, quien, clave}
var _total := 0.0
var _t := 0.0
var _activa := false
var _saltada := false
var _mantener := 0.0
var _vuelta := -1.0
var _vuelta_desde: Transform3D

var _cam: Camera3D
var _cam_juego: Camara
var _hud: Hud
var _heroe: Heroe
var _capa: CanvasLayer
var _arriba: ColorRect
var _abajo: ColorRect
var _nombre: Label
var _texto: Label
var _pista: Label
var _negro: ColorRect
var entrar_de_negro := false   ## true: arranca en negro y se aclara (cuando antes hubo un fundido del juego)


## Un plano: la cámara viaja de `desde` a `hasta` mirando de `mirar_desde` a `mirar_hasta`. Los planos van uno
## detrás de otro (corte seco entre planos). `curva`: 0 = lineal, 1 = arranca y frena suave.
func plano(dur: float, desde: Vector3, mirar_desde: Vector3, hasta := Vector3.INF, mirar_hasta := Vector3.INF, fov := 45.0, curva := 1.0) -> float:
	var ini := _total
	_planos.append({"ini": ini, "dur": dur, "desde": desde, "mirar_desde": mirar_desde,
		"hasta": desde if hasta == Vector3.INF else hasta,
		"mirar_hasta": mirar_desde if mirar_hasta == Vector3.INF else mirar_hasta, "fov": fov, "curva": curva})
	_total += dur
	return ini


## Un suceso en el segundo `t` desde el principio. `estado` = cambia la partida: se aplica aunque se salte.
func al(t: float, f: Callable, estado := false) -> void:
	_sucesos.append({"t": t, "f": f, "estado": estado, "hecho": false})


## Un subtítulo: quién habla (clave nombre_<quien>) y la clave del texto en textos.csv.
func linea(t: float, quien: String, clave: String, dur: float) -> void:
	_lineas.append({"t": t, "dur": dur, "quien": quien, "clave": clave})


func duracion() -> float:
	return _total


func reproducir(padre: Node, cam_juego: Camara, hud: Hud, heroe: Heroe) -> void:
	_cam_juego = cam_juego
	_hud = hud
	_heroe = heroe
	_sucesos.sort_custom(func(a, b): return a.t < b.t)
	padre.add_child(self)
	_cam = Camera3D.new()
	_cam.far = 600.0
	add_child(_cam)
	_armar_capa()
	if _heroe:
		_heroe.bloqueado = true
	if _hud:
		_hud.visible = false
	_cam_juego.pausada = true
	_activa = true
	_t = 0.0
	_aplicar_plano(0.0)
	_cam.make_current()


func _armar_capa() -> void:
	_capa = CanvasLayer.new()
	_capa.layer = 20
	add_child(_capa)
	var raiz := Control.new()
	raiz.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	raiz.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_capa.add_child(raiz)
	_arriba = _franja(raiz, true)
	_abajo = _franja(raiz, false)
	var caja := VBoxContainer.new()
	caja.set_anchors_and_offsets_preset(Control.PRESET_CENTER_BOTTOM)
	caja.anchor_top = 1.0 - FRANJA - 0.12
	caja.anchor_bottom = 1.0 - FRANJA - 0.02
	caja.anchor_left = 0.15
	caja.anchor_right = 0.85
	caja.offset_left = 0
	caja.offset_right = 0
	caja.offset_top = 0
	caja.offset_bottom = 0
	caja.alignment = BoxContainer.ALIGNMENT_END
	caja.add_theme_constant_override("separation", 4)
	raiz.add_child(caja)
	_nombre = _etiqueta(caja, 20, Hud.AMBAR, Hud.FUENTE_TITULO)
	_texto = _etiqueta(caja, 28, Hud.CREMA, Hud.FUENTE_TEXTO)
	_texto.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_pista = Label.new()
	_pista.set_anchors_and_offsets_preset(Control.PRESET_BOTTOM_RIGHT)
	_pista.anchor_top = 1.0 - FRANJA * 0.5
	_pista.anchor_bottom = 1.0 - FRANJA * 0.5
	_pista.offset_left = -520
	_pista.offset_right = -36
	_pista.offset_top = -12
	_pista.offset_bottom = 12
	_pista.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	_pista.add_theme_font_override("font", load(Hud.FUENTE_TEXTO))
	_pista.add_theme_font_size_override("font_size", 16)
	_pista.add_theme_color_override("font_color", Color(Hud.CREMA, 0.45))
	_pista.text = tr("cine_saltar") % Controles.tecla("interactuar")
	raiz.add_child(_pista)
	_negro = ColorRect.new()
	_negro.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_negro.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_negro.color = Color(0, 0, 0, 1.0 if entrar_de_negro else 0.0)
	raiz.add_child(_negro)
	_mostrar_linea({})


func _franja(raiz: Control, arriba: bool) -> ColorRect:
	var r := ColorRect.new()
	r.color = Color.BLACK
	r.mouse_filter = Control.MOUSE_FILTER_IGNORE
	r.anchor_left = 0.0
	r.anchor_right = 1.0
	r.anchor_top = 0.0 if arriba else 1.0
	r.anchor_bottom = 0.0 if arriba else 1.0
	raiz.add_child(r)
	return r


func _etiqueta(padre: Control, tam: int, color: Color, fuente: String) -> Label:
	var l := Label.new()
	l.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	l.add_theme_font_override("font", load(fuente))
	l.add_theme_font_size_override("font_size", tam)
	l.add_theme_color_override("font_color", color)
	l.add_theme_color_override("font_shadow_color", Color(0, 0, 0, 0.85))
	l.add_theme_constant_override("shadow_offset_x", 0)
	l.add_theme_constant_override("shadow_offset_y", 2)
	l.add_theme_constant_override("shadow_outline_size", 6)
	padre.add_child(l)
	return l


func _process(dt: float) -> void:
	if not _activa:
		return
	if get_tree().paused:
		return
	# saltar manteniendo «interactuar»
	if Input.is_action_pressed("interactuar") and _vuelta < 0.0:
		_mantener += dt
		_pista.modulate.a = 1.0
		if _mantener >= SALTAR_MANTENER:
			_saltar()
			return
	else:
		_mantener = 0.0
	if _vuelta >= 0.0:
		_volver(dt)
		return
	_t += dt
	for s in _sucesos:
		if not s.hecho and s.t <= _t:
			s.hecho = true
			s.f.call()
	_aplicar_plano(_t)
	_mostrar_linea(_linea_en(_t))
	_franjas(1.0 if entrar_de_negro else clampf(_t / ENTRA, 0.0, 1.0))
	if entrar_de_negro:
		_negro.color.a = 1.0 - clampf(_t / 1.0, 0.0, 1.0)
	if _t >= _total:
		_empezar_vuelta()


func _aplicar_plano(t: float) -> void:
	var p: Dictionary = _planos[0]
	for q in _planos:
		if t >= q.ini:
			p = q
	var f := clampf((t - p.ini) / maxf(p.dur, 0.001), 0.0, 1.0)
	f = lerpf(f, f * f * (3.0 - 2.0 * f), p.curva)
	var pos: Vector3 = (p.desde as Vector3).lerp(p.hasta, f)
	var mira: Vector3 = (p.mirar_desde as Vector3).lerp(p.mirar_hasta, f)
	_cam.fov = p.fov
	_cam.global_position = pos
	if not pos.is_equal_approx(mira):
		_cam.look_at(mira, Vector3.UP)


func _linea_en(t: float) -> Dictionary:
	for l in _lineas:
		if t >= l.t and t < l.t + l.dur:
			return l
	return {}


func _mostrar_linea(l: Dictionary) -> void:
	if l.is_empty():
		_nombre.text = ""
		_texto.text = ""
		return
	var quien: String = l.quien
	_nombre.text = tr("nombre_" + quien)
	_texto.text = tr(l.clave)
	var runa := quien == "runa"
	_nombre.add_theme_color_override("font_color", Hud.AZUL if runa else Hud.AMBAR)
	_texto.add_theme_color_override("font_color", Hud.AZUL if runa else Hud.CREMA)
	if Juego.has_signal("hablante"):
		Juego.hablante.emit(quien)


func _franjas(f: float) -> void:
	var a := FRANJA * (f * f * (3.0 - 2.0 * f))
	_arriba.anchor_bottom = a
	_abajo.anchor_top = 1.0 - a


func _saltar() -> void:
	_saltada = true
	for s in _sucesos:
		if not s.hecho:
			s.hecho = true
			if s.estado:
				s.f.call()
	_mostrar_linea({})
	_terminar()


## Al final la cámara viaja hasta donde está la del juego, para devolver el control sin corte.
func _empezar_vuelta() -> void:
	_mostrar_linea({})
	Juego.hablante.emit("")
	_vuelta = 0.0
	_vuelta_desde = _cam.global_transform


func _volver(dt: float) -> void:
	_vuelta += dt
	var f := clampf(_vuelta / VUELTA, 0.0, 1.0)
	var s := f * f * (3.0 - 2.0 * f)
	var destino := _cam_juego.cam.global_transform
	_cam.global_transform = _vuelta_desde.interpolate_with(destino, s)
	_cam.fov = lerpf(_cam.fov, _cam_juego.cam.fov, s)
	_franjas(1.0 - s)
	if f >= 1.0:
		_terminar()


func _terminar() -> void:
	_activa = false
	Juego.hablante.emit("")
	_cam_juego.pausada = false
	_cam_juego.cam.make_current()
	if _hud:
		_hud.visible = true
	if _heroe:
		_heroe.desbloquear_luego()
	termino.emit()
	queue_free()
