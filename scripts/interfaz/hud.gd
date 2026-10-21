class_name Hud
extends CanvasLayer
## Interfaz del juego: objetivo, salud, cartel de interacción, mensajes, diálogos, barra del jefe con su aviso,
## diario (J) con el croquis de Eldervald, pausa (Esc), título y cierre del MVP. Todo con textos ES/EN.

signal dialogo_terminado(id: String)
signal empezar(nueva: bool)
signal salir_al_titulo

const FUENTE_TITULO := "res://assets/marca/fuentes/EromashDisplay-Bold.woff2"
const FUENTE_TEXTO := "res://assets/marca/fuentes/EromashText-Regular.woff2"
const FUENTE_TEXTO_M := "res://assets/marca/fuentes/EromashText-Medium.woff2"
const ROJO := Color(0.78, 0.25, 0.18)
const CREMA := Color(0.93, 0.9, 0.82)
const AZUL := Color(0.45, 0.84, 0.86)
const AMBAR := Color(0.91, 0.72, 0.4)
const FONDO := Color(0.06, 0.09, 0.09, 0.82)

var heroe: Heroe
var camara: Camara
var en_dialogo := false
var en_menu := false

var _tema: Theme
var _objetivo_titulo: Label
var _objetivo_texto: Label
var _salud: ProgressBar
var _stamina: ProgressBar
var _stamina_texto: Label
var _salud_texto: Label
var _ayuda_combate: Label
var _stamina_objetivo := 100.0
var _stamina_alerta := 0.0
var _stamina_alerta_clave := "combate_sin_stamina"
var _cartel: Label
var _mensajes: VBoxContainer
var _dialogo: PanelContainer
var _dlg_nombre: Label
var _dlg_texto: Label
var _dlg_pista: Label
var _dlg_id := ""
var _dlg_lineas: Array = []
var _dlg_i := 0
var _dlg_t := 0.0
var _jefe: Control
var _jefe_vida: ProgressBar
var _jefe_aviso: Label
var _jefe_ref: Ciervo
var _diario: Control
var _diario_texto: RichTextLabel
var _diario_mapa: TextureRect
var _marcas_mapa: Control
var _pausa: Control
var _titulo: Control
var _fin: Control
var _negro: ColorRect
var _flecha: Label
var _minimapa: Minimapa
var _fps: Label
var _admin: Label
var _video: OpcionesVideo
var _opciones_idioma: OptionButton
var interfaz: InterfazAventura


func _ready() -> void:
	layer = 10
	process_mode = Node.PROCESS_MODE_ALWAYS
	_tema = _crear_tema()
	var raiz := Control.new()
	raiz.set_anchors_preset(Control.PRESET_FULL_RECT)
	raiz.mouse_filter = Control.MOUSE_FILTER_IGNORE
	raiz.theme = _tema
	add_child(raiz)
	_armar_juego(raiz)
	_armar_dialogo(raiz)
	_armar_jefe(raiz)
	_armar_diario(raiz)
	_armar_pausa(raiz)
	_armar_fin(raiz)
	_armar_titulo(raiz)
	_video = OpcionesVideo.new(load(FUENTE_TITULO))
	raiz.add_child(_video)
	_negro = ColorRect.new()
	_negro.color = Color(0, 0, 0, 0)
	_negro.set_anchors_preset(Control.PRESET_FULL_RECT)
	_negro.mouse_filter = Control.MOUSE_FILTER_IGNORE
	raiz.add_child(_negro)
	Juego.cambio_estado.connect(_actualizar_objetivo)
	Juego.mensaje.connect(func(c):
		if c == "mision_nueva" and Juego.id_mision() != "fin":
			mostrar_mensaje("%s: %s" % [tr(c), tr("mision_" + Juego.id_mision())])
		else:
			mostrar_mensaje(tr(c)))
	Juego.dialogo.connect(abrir_dialogo)
	Calidad.cambio.connect(_actualizar_objetivo)
	Controles.dispositivo_cambio.connect(_actualizar_objetivo)
	_actualizar_objetivo()
	interfaz = InterfazAventura.new()
	interfaz.hud = self
	raiz.add_child(interfaz)


func _crear_tema() -> Theme:
	var t := Theme.new()
	var f := load(FUENTE_TEXTO) as FontFile
	f.fallbacks = [load("res://assets/marca/fuentes/NotoSansRunic.woff2")]
	t.default_font = f
	t.default_font_size = 22
	t.set_color("font_color", "Label", CREMA)
	t.set_color("font_outline_color", "Label", Color(0, 0, 0, 0.8))
	t.set_constant("outline_size", "Label", 4)
	var panel := StyleBoxFlat.new()
	panel.bg_color = FONDO
	panel.border_color = Color(AMBAR, 0.5)
	panel.border_width_top = 2
	panel.corner_radius_top_left = 4
	panel.corner_radius_top_right = 4
	panel.corner_radius_bottom_left = 4
	panel.corner_radius_bottom_right = 4
	panel.content_margin_left = 22
	panel.content_margin_right = 22
	panel.content_margin_top = 14
	panel.content_margin_bottom = 14
	t.set_stylebox("panel", "PanelContainer", panel)
	var boton := StyleBoxFlat.new()
	boton.bg_color = Color(0.12, 0.17, 0.16, 0.95)
	boton.border_color = Color(AMBAR, 0.6)
	boton.set_border_width_all(1)
	boton.set_corner_radius_all(3)
	boton.content_margin_left = 18
	boton.content_margin_right = 18
	boton.content_margin_top = 10
	boton.content_margin_bottom = 10
	var boton_h := boton.duplicate() as StyleBoxFlat
	boton_h.bg_color = Color(0.2, 0.28, 0.26, 0.95)
	boton_h.border_color = AZUL
	t.set_stylebox("normal", "Button", boton)
	t.set_stylebox("hover", "Button", boton_h)
	t.set_stylebox("focus", "Button", boton_h)
	t.set_stylebox("pressed", "Button", boton_h)
	t.set_color("font_color", "Button", CREMA)
	t.set_color("font_hover_color", "Button", AZUL)
	t.set_color("font_focus_color", "Button", AZUL)
	t.set_font_size("font_size", "Button", 24)
	var barra := StyleBoxFlat.new()
	barra.bg_color = Color(0.05, 0.05, 0.05, 0.8)
	barra.set_corner_radius_all(2)
	t.set_stylebox("background", "ProgressBar", barra)
	return t


func _etiqueta(padre: Node, tam := 22, color := CREMA, titulo := false) -> Label:
	var l := Label.new()
	l.add_theme_font_size_override("font_size", tam)
	l.add_theme_color_override("font_color", color)
	if titulo:
		l.add_theme_font_override("font", load(FUENTE_TITULO))
	l.mouse_filter = Control.MOUSE_FILTER_IGNORE
	padre.add_child(l)
	return l


# ---------- en juego ----------

func _armar_juego(raiz: Control) -> void:
	_minimapa = Minimapa.new()
	_minimapa.anchor_left = 1.0
	_minimapa.anchor_right = 1.0
	_minimapa.offset_left = -Minimapa.LADO - 30
	_minimapa.offset_right = -30
	_minimapa.offset_top = 30
	_minimapa.offset_bottom = 30 + Minimapa.LADO
	raiz.add_child(_minimapa)
	# contador de cuadros por segundo (F3), abajo a la derecha
	_fps = _etiqueta(raiz, 18, AZUL)
	_fps.anchor_left = 1.0
	_fps.anchor_right = 1.0
	_fps.anchor_top = 1.0
	_fps.anchor_bottom = 1.0
	_fps.offset_left = -560
	_fps.offset_right = -30
	_fps.offset_top = -76
	_fps.offset_bottom = -24
	_fps.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	_fps.visible = false
	_admin = _etiqueta(raiz, 18, AMBAR, true)
	_admin.set_anchors_preset(Control.PRESET_CENTER_TOP)
	_admin.offset_left = -460
	_admin.offset_right = 460
	_admin.offset_top = 16
	_admin.offset_bottom = 48
	_admin.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_admin.visible = false
	var obj := VBoxContainer.new()
	obj.position = Vector2(36, 30)
	obj.mouse_filter = Control.MOUSE_FILTER_IGNORE
	raiz.add_child(obj)
	_objetivo_titulo = _etiqueta(obj, 20, AMBAR, true)
	_objetivo_texto = _etiqueta(obj, 22)
	_objetivo_texto.custom_minimum_size.x = 520
	_objetivo_texto.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	var teclas := _etiqueta(obj, 15, Color(CREMA, 0.55))
	teclas.name = "Teclas"
	teclas.text = ""
	# salud
	var sal := VBoxContainer.new()
	sal.set_anchors_preset(Control.PRESET_BOTTOM_LEFT)
	sal.position = Vector2(36, -164)
	sal.mouse_filter = Control.MOUSE_FILTER_IGNORE
	raiz.add_child(sal)
	var nombre := _etiqueta(sal, 18, CREMA, true)
	nombre.text = "EROMASH"
	_salud_texto = _etiqueta(sal, 15, CREMA)
	_salud = ProgressBar.new()
	_salud.custom_minimum_size = Vector2(320, 18)
	_salud.show_percentage = false
	var lleno := StyleBoxFlat.new()
	lleno.bg_color = ROJO
	lleno.set_corner_radius_all(2)
	_salud.add_theme_stylebox_override("fill", lleno)
	sal.add_child(_salud)
	_stamina_texto = _etiqueta(sal, 15, AMBAR)
	_stamina = ProgressBar.new()
	_stamina.custom_minimum_size = Vector2(320, 12)
	_stamina.show_percentage = false
	var energia := StyleBoxFlat.new()
	energia.bg_color = AMBAR
	energia.set_corner_radius_all(2)
	_stamina.add_theme_stylebox_override("fill", energia)
	sal.add_child(_stamina)
	_ayuda_combate = _etiqueta(sal, 14, Color(CREMA, 0.75))
	# cartel de interacción
	_cartel = _etiqueta(raiz, 26, CREMA)
	_cartel.set_anchors_preset(Control.PRESET_CENTER_BOTTOM)
	_cartel.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_cartel.position = Vector2(-300, -170)
	_cartel.size = Vector2(600, 40)
	# mensajes
	_mensajes = VBoxContainer.new()
	_mensajes.set_anchors_preset(Control.PRESET_CENTER_TOP)
	_mensajes.position = Vector2(-400, 110)
	_mensajes.size = Vector2(800, 200)
	_mensajes.alignment = BoxContainer.ALIGNMENT_BEGIN
	_mensajes.mouse_filter = Control.MOUSE_FILTER_IGNORE
	raiz.add_child(_mensajes)
	# flecha hacia el objetivo cuando queda fuera de pantalla
	_flecha = _etiqueta(raiz, 34, AZUL, true)
	_flecha.text = "➤"
	_flecha.visible = false


func conectar_heroe(h: Heroe, c: Camara) -> void:
	heroe = h
	camara = c
	_minimapa.heroe = h
	_minimapa.camara = c
	h.salud_cambio.connect(func(v, m):
		_salud.max_value = m
		_salud.value = v
		_salud_texto.text = tr("combate_salud") % [ceili(v), int(m)])
	h.stamina_cambio.connect(func(v, m):
		_stamina.max_value = m
		_stamina_objetivo = v
		_actualizar_recursos())
	h.stamina_insuficiente.connect(func(clave: String):
		_stamina_alerta = 0.6
		_stamina_alerta_clave = clave)
	h.cerca_cambio.connect(_mostrar_cartel)
	_salud.max_value = Heroe.SALUD_MAX
	_salud.value = h.salud
	_stamina.max_value = h.estadisticas.stamina_maxima
	_stamina.value = h.stamina
	_stamina_objetivo = h.stamina
	_actualizar_recursos()


func _mostrar_cartel(n: Node) -> void:
	if n == null or en_dialogo:
		_cartel.text = ""
		return
	_cartel.text = "[%s]  %s" % [Controles.tecla("interactuar"), tr(n.texto)]


func _actualizar_objetivo() -> void:
	if _objetivo_titulo == null:
		return
	var id := Juego.id_mision()
	if id == "fin":
		_objetivo_titulo.text = tr("mision_fin")
		_objetivo_texto.text = tr("obj_fin")
	else:
		_objetivo_titulo.text = "%s · %s" % [id, tr("mision_" + id)]
		var o := Juego.objetivo_actual()
		_objetivo_texto.text = tr(o.get("texto", ""))
	var teclas := _objetivo_titulo.get_parent().get_node("Teclas") as Label
	teclas.text = tr("ayuda_teclas") % [Controles.tecla("interactuar"), Controles.tecla("lente"), Controles.tecla("diario")]
	_actualizar_recursos()


func _actualizar_recursos() -> void:
	if heroe == null:
		return
	_salud_texto.text = tr("combate_salud") % [ceili(heroe.salud), int(Heroe.SALUD_MAX)]
	_stamina_texto.text = tr("combate_stamina") % [floori(heroe.stamina), int(heroe.estadisticas.stamina_maxima)]
	_ayuda_combate.text = tr("combate_ayuda") % [Controles.tecla("esquivar"), Controles.tecla("saltar")]


func mostrar_mensaje(texto: String, color := AMBAR) -> void:
	if texto == "" or _mensajes == null:
		return
	var l := _etiqueta(_mensajes, 26, color, true)
	l.text = texto
	l.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	l.custom_minimum_size.x = 800
	var t := create_tween()
	l.modulate.a = 0.0
	t.tween_property(l, "modulate:a", 1.0, 0.3)
	t.tween_interval(3.2)
	t.tween_property(l, "modulate:a", 0.0, 0.8)
	t.tween_callback(l.queue_free)


func _process(dt: float) -> void:
	if heroe and not get_tree().paused:
		_stamina_alerta = maxf(0.0, _stamina_alerta - dt)
		_stamina.value = move_toward(_stamina.value, _stamina_objetivo, dt * 220.0)
		var sin_energia := heroe.stamina < minf(heroe.estadisticas.costo_esquiva, heroe.estadisticas.costo_ataque)
		_stamina.modulate = Color(1, 0.45, 0.3) if _stamina_alerta > 0.0 else (Color(0.7, 0.7, 0.7) if sin_energia else Color.WHITE)
		_ayuda_combate.text = tr(_stamina_alerta_clave) if _stamina_alerta > 0.0 else tr("combate_ayuda") % [Controles.tecla("esquivar"), Controles.tecla("saltar")]
		if heroe.admin:
			_ayuda_combate.text = tr("admin_ayuda") % [Controles.tecla("saltar"), Controles.tecla("bloquear"), Controles.tecla("correr")]
	if _admin:
		_admin.visible = heroe != null and heroe.admin
		if _admin.visible:
			_admin.text = tr("admin_marca") % Controles.tecla("modo_admin")
	if en_dialogo:
		_dlg_t += dt
		var total := tr(_dlg_lineas[_dlg_i][1]).length() if _dlg_i < _dlg_lineas.size() else 0
		_dlg_texto.visible_characters = int(_dlg_t * 55.0) if _dlg_t * 55.0 < total else -1
	_flecha_objetivo()
	if _fps.visible:
		var r := RenderingServer
		var tri := r.get_rendering_info(RenderingServer.RENDERING_INFO_TOTAL_PRIMITIVES_IN_FRAME)
		var act := get_tree().get_first_node_in_group("activador") as Activador
		_fps.text = (tr("fps") % [Engine.get_frames_per_second(), dt * 1000.0]) + "\n" + tr("fps_detalle") % [
			r.get_rendering_info(RenderingServer.RENDERING_INFO_TOTAL_DRAW_CALLS_IN_FRAME),
			r.get_rendering_info(RenderingServer.RENDERING_INFO_TOTAL_OBJECTS_IN_FRAME),
			"%.2f M" % (tri / 1000000.0) if tri >= 1000000 else "%d k" % (tri / 1000),
			act.despiertos() if act else 0]


func _flecha_objetivo() -> void:
	_flecha.visible = false
	if camara == null or heroe == null or en_menu or en_dialogo:
		return
	var p := Juego.donde_objetivo()
	if p == Vector3.INF:
		return
	var cam := camara.cam
	var vp := get_viewport().get_visible_rect().size
	var detras := cam.is_position_behind(p + Vector3(0, 2, 0))
	var sp := cam.unproject_position(p + Vector3(0, 2, 0))
	var dentro := not detras and sp.x > 60 and sp.y > 60 and sp.x < vp.x - 60 and sp.y < vp.y - 60
	if dentro:
		return
	var centro := vp * 0.5
	var dir := (sp - centro).normalized()
	if detras:
		dir = -dir
	var borde := centro + dir * minf(vp.x * 0.45, vp.y * 0.42) / maxf(absf(dir.x) * 0.6 + absf(dir.y), 0.6)
	_flecha.visible = true
	_flecha.position = borde - Vector2(17, 20)
	_flecha.rotation = dir.angle()
	_flecha.pivot_offset = Vector2(17, 20)


# ---------- diálogos ----------

func _armar_dialogo(raiz: Control) -> void:
	_dialogo = PanelContainer.new()
	_dialogo.set_anchors_preset(Control.PRESET_CENTER_BOTTOM)
	_dialogo.position = Vector2(-560, -260)
	_dialogo.custom_minimum_size = Vector2(1120, 170)
	_dialogo.visible = false
	raiz.add_child(_dialogo)
	var v := VBoxContainer.new()
	v.add_theme_constant_override("separation", 8)
	_dialogo.add_child(v)
	_dlg_nombre = _etiqueta(v, 22, AMBAR, true)
	_dlg_texto = _etiqueta(v, 26)
	_dlg_texto.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_dlg_texto.custom_minimum_size.x = 1070
	_dlg_pista = _etiqueta(v, 16, Color(CREMA, 0.5))
	_dlg_pista.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT


func abrir_dialogo(id: String) -> void:
	if not Guion.DIALOGOS.has(id) or en_dialogo:
		return
	_dlg_id = id
	_dlg_lineas = Guion.DIALOGOS[id].lineas
	_dlg_i = 0
	en_dialogo = true
	_dialogo.visible = true
	_cartel.text = ""
	if heroe:
		heroe.bloqueado = true
	_mostrar_linea()


func _mostrar_linea() -> void:
	var l: Array = _dlg_lineas[_dlg_i]
	var quien: String = l[0]
	Juego.hablante.emit(quien)
	_dlg_nombre.text = tr("nombre_" + quien)
	_dlg_nombre.add_theme_color_override("font_color", AZUL if quien == "runa" else AMBAR)
	_dlg_texto.text = tr(l[1])
	_dlg_texto.add_theme_color_override("font_color", AZUL if quien == "runa" else CREMA)
	_dlg_t = 0.0
	_dlg_pista.text = "[%s]  %s" % [Controles.tecla("interactuar"), tr("dialogo_seguir")]


func _avanzar_dialogo() -> void:
	if _dlg_texto.visible_characters != -1:
		_dlg_t = 999.0
		return
	_dlg_i += 1
	if _dlg_i < _dlg_lineas.size():
		_mostrar_linea()
		return
	en_dialogo = false
	_dialogo.visible = false
	Juego.hablante.emit("")
	if heroe:
		heroe.desbloquear_luego()
	var id := _dlg_id
	_dlg_id = ""
	dialogo_terminado.emit(id)


# ---------- jefe ----------

func _armar_jefe(raiz: Control) -> void:
	# abajo al centro: arriba a la izquierda está el objetivo y abajo a la izquierda la salud de Eromash
	_jefe = VBoxContainer.new()
	_jefe.anchor_left = 0.5
	_jefe.anchor_right = 0.5
	_jefe.anchor_top = 1.0
	_jefe.anchor_bottom = 1.0
	_jefe.offset_left = -280
	_jefe.offset_right = 280
	_jefe.offset_top = -150
	_jefe.offset_bottom = -36
	_jefe.alignment = BoxContainer.ALIGNMENT_END
	_jefe.visible = false
	_jefe.mouse_filter = Control.MOUSE_FILTER_IGNORE
	raiz.add_child(_jefe)
	var n := _etiqueta(_jefe, 26, CREMA, true)
	n.text = ""
	n.name = "Nombre"
	n.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_jefe_vida = ProgressBar.new()
	_jefe_vida.custom_minimum_size = Vector2(560, 16)
	_jefe_vida.show_percentage = false
	var lleno := StyleBoxFlat.new()
	lleno.bg_color = Color(0.67, 0.53, 0.77)
	_jefe_vida.add_theme_stylebox_override("fill", lleno)
	_jefe.add_child(_jefe_vida)
	_jefe_aviso = _etiqueta(_jefe, 26, Color(0.95, 0.55, 0.35), true)
	_jefe_aviso.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_jefe.move_child(_jefe_aviso, 0)


func mostrar_jefe(c: Ciervo) -> void:
	_jefe_ref = c
	_jefe.visible = c != null
	if c:
		(_jefe.get_node("Nombre") as Label).text = tr("nombre_ciervo")
		_jefe_vida.max_value = Ciervo.VIDA
		if not c.ataque_anunciado.is_connected(_anuncio_jefe):
			c.ataque_anunciado.connect(_anuncio_jefe)


func _anuncio_jefe(n: String, a: String) -> void:
	_jefe_aviso.text = "%s — %s" % [tr(n), tr(a)]
	var t := create_tween()
	_jefe_aviso.modulate.a = 1.0
	t.tween_interval(2.0)
	t.tween_property(_jefe_aviso, "modulate:a", 0.0, 0.5)


func _physics_process(_dt: float) -> void:
	if _jefe_ref and _jefe.visible:
		_jefe_vida.value = _jefe_ref.vida
		var atado := _jefe_ref.atados()
		(_jefe.get_node("Nombre") as Label).text = tr("nombre_ciervo") + ("   " + tr("jefe_ataduras") % atado if atado > 0 else "")


# ---------- diario ----------

func _armar_diario(raiz: Control) -> void:
	_diario = PanelContainer.new()
	_diario.set_anchors_preset(Control.PRESET_FULL_RECT)
	_diario.offset_left = 80
	_diario.offset_right = -80
	_diario.offset_top = 60
	_diario.offset_bottom = -60
	_diario.visible = false
	raiz.add_child(_diario)
	var h := HBoxContainer.new()
	h.add_theme_constant_override("separation", 28)
	_diario.add_child(h)
	var mapa_caja := Control.new()
	mapa_caja.custom_minimum_size = Vector2(1000, 650)
	h.add_child(mapa_caja)
	_diario_mapa = TextureRect.new()
	_diario_mapa.texture = load("res://assets/interfaz/mapa-eldervald.png")
	_diario_mapa.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	_diario_mapa.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT
	_diario_mapa.size = Vector2(1000, 650)
	mapa_caja.add_child(_diario_mapa)
	_marcas_mapa = Control.new()
	_marcas_mapa.size = Vector2(1000, 650)
	mapa_caja.add_child(_marcas_mapa)
	var v := VBoxContainer.new()
	v.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	h.add_child(v)
	var t := _etiqueta(v, 34, AMBAR, true)
	t.name = "Titulo"
	_diario_texto = RichTextLabel.new()
	_diario_texto.bbcode_enabled = true
	_diario_texto.size_flags_vertical = Control.SIZE_EXPAND_FILL
	_diario_texto.add_theme_font_size_override("normal_font_size", 21)
	_diario_texto.add_theme_font_override("bold_font", load(FUENTE_TEXTO_M))
	v.add_child(_diario_texto)


func abrir_diario() -> void:
	if en_dialogo or en_menu and not _diario.visible:
		return
	_diario.visible = not _diario.visible
	en_menu = _diario.visible
	get_tree().paused = en_menu
	if not _diario.visible:
		return
	if Juego.en("EL-01") and Juego.tiene("el01_acepto"):
		Juego.marcar("croquis_leido")
	(_diario.find_child("Titulo", true, false) as Label).text = tr("diario_titulo")
	var s := ""
	var id := Juego.id_mision()
	if id != "fin":
		s += "[color=#e9b765][b]%s · %s[/b][/color]\n%s\n\n" % [id, tr("mision_" + id), tr(Juego.objetivo_actual().get("texto", ""))]
	s += "[color=#e9b765][b]%s[/b][/color]\n" % tr("diario_entradas")
	for e in Juego.diario:
		s += "• %s\n\n" % tr(e)
	_diario_texto.text = s
	_marcas_mapa_dibujar()


## Marca en el croquis dónde está Eromash, el objetivo y los lugares conocidos.
func _marcas_mapa_dibujar() -> void:
	for c in _marcas_mapa.get_children():
		c.queue_free()
	var tex := _diario_mapa.texture
	var esc := minf(1000.0 / tex.get_width(), 650.0 / tex.get_height())
	var off := (Vector2(1000, 650) - Vector2(tex.get_width(), tex.get_height()) * esc) * 0.5
	var a_mapa := func(p: Vector3) -> Vector2:
		var px := Vector2(p.x / Datos.ESCALA + Datos.CENTRO_MAPA.x, p.z / Datos.ESCALA + Datos.CENTRO_MAPA.y)
		return off + px * esc
	if heroe:
		var e := _etiqueta(_marcas_mapa, 28, ROJO, true)
		e.text = "E"
		e.position = a_mapa.call(heroe.global_position) - Vector2(9, 18)
	var obj := Juego.donde_objetivo()
	if obj != Vector3.INF:
		var o := _etiqueta(_marcas_mapa, 30, AZUL, true)
		o.text = "◆"
		o.position = a_mapa.call(obj) - Vector2(11, 20)
	# croquis de Eydis: el último tramo conocido (el carro y la senda del Refugio)
	if Juego.tiene("el01_acepto") and not Juego.completa("EL-01"):
		for p in [[612, 400], [560, 335], [470, 318]]:
			var c := _etiqueta(_marcas_mapa, 22, AMBAR, true)
			c.text = "✕" if p[0] == 612 else "·"
			c.position = off + Vector2(p[0], p[1]) * esc - Vector2(8, 14)


# ---------- pausa ----------

func _armar_pausa(raiz: Control) -> void:
	_pausa = _menu(raiz, "pausa_titulo", [
		["pausa_seguir", func(): cerrar_pausa()],
		["pausa_guardar", func():
			Juego.guardar()
			mostrar_mensaje(tr("partida_guardada"))],
		["pausa_titulo_menu", func():
			cerrar_pausa()
			salir_al_titulo.emit()],
		["pausa_salir", func(): get_tree().quit()],
	])
	var opciones := _pausa.find_child("Botones", true, false) as VBoxContainer
	var video := Button.new()
	video.name = "Video"
	video.text = tr("menu_video")
	video.set_meta("clave", "menu_video")
	video.pressed.connect(func(): abrir_video(video))
	opciones.add_child(video)
	_opciones_idioma = OptionButton.new()
	_opciones_idioma.add_item("Español")
	_opciones_idioma.add_item("English")
	_opciones_idioma.selected = 0 if Calidad.idioma == "es" else 1
	_opciones_idioma.item_selected.connect(func(i):
		Calidad.poner_idioma("es" if i == 0 else "en")
		_refrescar_textos())
	opciones.add_child(_opciones_idioma)


func _menu(raiz: Control, titulo: String, botones: Array) -> Control:
	var fondo := ColorRect.new()
	fondo.color = Color(0, 0, 0, 0.55)
	fondo.set_anchors_preset(Control.PRESET_FULL_RECT)
	fondo.visible = false
	raiz.add_child(fondo)
	var centro := CenterContainer.new()
	centro.set_anchors_preset(Control.PRESET_FULL_RECT)
	fondo.add_child(centro)
	var p := PanelContainer.new()
	centro.add_child(p)
	var v := VBoxContainer.new()
	v.name = "Botones"
	v.custom_minimum_size.x = 420
	v.add_theme_constant_override("separation", 12)
	p.add_child(v)
	var t := _etiqueta(v, 38, AMBAR, true)
	t.text = tr(titulo)
	t.set_meta("clave", titulo)
	t.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	for b in botones:
		var bt := Button.new()
		bt.text = tr(b[0])
		bt.set_meta("clave", b[0])
		bt.pressed.connect(b[1])
		v.add_child(bt)
	return fondo


func _refrescar_textos() -> void:
	for n in find_children("*", "", true, false):
		if n.has_meta("clave"):
			if n is Button:
				(n as Button).text = tr(n.get_meta("clave"))
			elif n is Label:
				(n as Label).text = tr(n.get_meta("clave"))
	_video.refrescar()
	if interfaz:
		interfaz.refrescar()
	_actualizar_objetivo()


func abrir_pausa() -> void:
	if en_dialogo or _titulo.visible or _fin.visible:
		return
	if _diario.visible:
		abrir_diario()
		return
	_pausa.visible = true
	en_menu = true
	get_tree().paused = true
	Sonido.musica_de_pausa(true)
	(_pausa.find_child("Botones", true, false).get_child(1) as Button).grab_focus()


## Abre Opciones → Video; al cerrarlo vuelve el foco al botón que lo abrió (para jugar con mando).
func abrir_video(desde: Control) -> void:
	_video.abrir()
	if not _video.cerrado.is_connected(_video_cerrado):
		_video.cerrado.connect(_video_cerrado)
	_video.set_meta("desde", desde)


func _video_cerrado() -> void:
	var desde: Control = _video.get_meta("desde", null)
	if desde and desde.is_visible_in_tree():
		desde.grab_focus()


func cerrar_pausa() -> void:
	Sonido.musica_de_pausa(false)
	_pausa.visible = false
	en_menu = false
	get_tree().paused = false


# ---------- título y cierre ----------

func _armar_titulo(raiz: Control) -> void:
	_titulo = ColorRect.new()
	(_titulo as ColorRect).color = Color(0.03, 0.05, 0.05, 0.92)
	_titulo.set_anchors_preset(Control.PRESET_FULL_RECT)
	_titulo.visible = false
	raiz.add_child(_titulo)
	var centro := CenterContainer.new()
	centro.set_anchors_preset(Control.PRESET_FULL_RECT)
	_titulo.add_child(centro)
	var v := VBoxContainer.new()
	v.add_theme_constant_override("separation", 16)
	v.alignment = BoxContainer.ALIGNMENT_CENTER
	centro.add_child(v)
	var logo := TextureRect.new()
	logo.texture = load("res://assets/marca/logotipo.png")
	logo.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	logo.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	logo.custom_minimum_size = Vector2(840, 376)
	v.add_child(logo)
	var sub := _etiqueta(v, 34, AZUL, true)
	sub.text = tr("juego_subtitulo")
	sub.set_meta("clave", "juego_subtitulo")
	sub.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	var botones := VBoxContainer.new()
	botones.name = "BotonesTitulo"
	botones.custom_minimum_size.x = 420
	botones.add_theme_constant_override("separation", 10)
	var caja := CenterContainer.new()
	caja.add_child(botones)
	v.add_child(caja)
	for b in [["titulo_continuar", func(): _empezar(false)], ["titulo_nueva", func(): _empezar(true)], ["menu_video", func(): abrir_video(_titulo.find_child("menu_video", true, false))], ["pausa_salir", func(): get_tree().quit()]]:
		var bt := Button.new()
		bt.text = tr(b[0])
		bt.set_meta("clave", b[0])
		bt.name = b[0]
		bt.pressed.connect(b[1])
		botones.add_child(bt)
	var aviso := _etiqueta(v, 16, Color(CREMA, 0.5))
	aviso.text = tr("titulo_mvp")
	aviso.set_meta("clave", "titulo_mvp")
	aviso.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER


func mostrar_titulo() -> void:
	_titulo.visible = true
	en_menu = true
	get_tree().paused = true
	var cont := _titulo.find_child("titulo_continuar", true, false) as Button
	cont.visible = Juego.hay_partida()
	(cont if cont.visible else _titulo.find_child("titulo_nueva", true, false) as Button).grab_focus()


func _empezar(nueva: bool) -> void:
	_titulo.visible = false
	en_menu = false
	get_tree().paused = false
	empezar.emit(nueva)


func _armar_fin(raiz: Control) -> void:
	_fin = _menu(raiz, "fin_titulo", [
		["fin_seguir", func():
			_fin.visible = false
			en_menu = false
			get_tree().paused = false],
		["pausa_salir", func(): get_tree().quit()],
	])
	var v := _fin.find_child("Botones", true, false) as VBoxContainer
	var texto := _etiqueta(v, 22)
	texto.text = tr("fin_texto")
	texto.set_meta("clave", "fin_texto")
	texto.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	texto.custom_minimum_size.x = 620
	v.move_child(texto, 1)


func mostrar_fin() -> void:
	_fin.visible = true
	en_menu = true
	get_tree().paused = true


# ---------- transiciones ----------

func fundido(a_negro: bool, dur := 0.6) -> Tween:
	var t := create_tween()
	t.tween_property(_negro, "color:a", 1.0 if a_negro else 0.0, dur)
	return t


func _unhandled_input(ev: InputEvent) -> void:
	if _video.visible:
		return
	if en_dialogo and (ev.is_action_pressed("interactuar") or ev.is_action_pressed("atacar") or ev.is_action_pressed("saltar") or ev.is_action_pressed("ui_accept")):
		get_viewport().set_input_as_handled()
		_avanzar_dialogo()
		return
	if ev.is_action_pressed("ver_fps"):
		_fps.visible = not _fps.visible
		get_viewport().set_input_as_handled()
		return
	if ev.is_action_pressed("pausa"):
		if _pausa.visible:
			cerrar_pausa()
		else:
			abrir_pausa()
		get_viewport().set_input_as_handled()
	elif ev.is_action_pressed("diario") and not _pausa.visible and not _titulo.visible and not _fin.visible:
		abrir_diario()
		get_viewport().set_input_as_handled()
