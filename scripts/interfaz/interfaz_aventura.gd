class_name InterfazAventura
extends Control
## Integración del HUD y la bolsa, conservando diario, diálogo, jefe, video y título existentes.

const RUNAS := {"atacar": "ᛏ", "bloquear": "ᛉ", "esquivar": "ᚱ", "lente": "ᛈ"}
var hud: Hud
var inventario: InventarioAventura
var _barra: HBoxContainer
var _grupo_juego: Control
var _botones: Array[Button] = []
var _pociones: Array[Button] = []
var _popup: PopupMenu
var _posicion_barra := 0
var _objetivos_plegados := false
var _plegar: Button
var _bolsa: Button
var _diario: Button
var _enlaces: HBoxContainer
var marco_seleccion: MarcoSeleccion


func _ready() -> void:
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	process_mode = Node.PROCESS_MODE_ALWAYS
	_grupo_juego = Control.new()
	_grupo_juego.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_grupo_juego.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(_grupo_juego)
	var objetivo := hud._objetivo_titulo.get_parent() as Control
	objetivo.set_anchors_preset(Control.PRESET_TOP_RIGHT)
	objetivo.position = Vector2(-395, 280)
	objetivo.custom_minimum_size.x = 355
	hud._objetivo_texto.custom_minimum_size.x = 355
	hud._objetivo_texto.add_theme_font_size_override("font_size", 20)
	hud._objetivo_titulo.add_theme_font_size_override("font_size", 19)
	hud._objetivo_titulo.custom_minimum_size.x = 355
	hud._objetivo_titulo.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	var ayuda := objetivo.get_node("Teclas") as Label
	ayuda.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	ayuda.custom_minimum_size.x = 355
	var zona := EstiloRunico.texto(_grupo_juego, "hud_region", 26, EstiloRunico.CREMA)
	zona.position = Vector2(36, 30)
	_plegar = EstiloRunico.boton(_grupo_juego, "hud_plegar", func():
		_objetivos_plegados = not _objetivos_plegados
		hud._objetivo_texto.visible = not _objetivos_plegados
		ayuda.visible = not _objetivos_plegados)
	_plegar.set_anchors_preset(Control.PRESET_TOP_RIGHT)
	_plegar.position = Vector2(-395, 230)
	_plegar.add_theme_font_size_override("font_size", 15)
	var salud := hud._salud.get_parent() as Control
	salud.set_anchors_preset(Control.PRESET_CENTER_BOTTOM)
	salud.position = Vector2(-650, -165)
	hud._salud.custom_minimum_size = Vector2(240, 12)
	hud._stamina.custom_minimum_size = Vector2(240, 8)
	hud._ayuda_combate.visible = false
	salud.set_deferred("size", Vector2(240, 0))
	objetivo.set_deferred("size", Vector2(355, 0))
	_barra = HBoxContainer.new()
	_barra.set_anchors_preset(Control.PRESET_CENTER_BOTTOM)
	_barra.position = Vector2(-340, -128)
	_barra.add_theme_constant_override("separation", 8)
	_barra.add_to_group("bloquea_clic_combate")
	_grupo_juego.add_child(_barra)
	for i in 4:
		var boton := Button.new()
		boton.custom_minimum_size = Vector2(112, 88)
		boton.add_theme_font_size_override("font_size", 16)
		boton.add_theme_stylebox_override("normal", EstiloRunico.panel(Color("17271f"), Color("778671"), 6))
		boton.add_theme_stylebox_override("hover", EstiloRunico.panel(Color("25392d"), EstiloRunico.AZUL, 6))
		var runa := EstiloRunico.texto(boton, "", 32)
		runa.name = "Runa"
		runa.add_theme_font_override("font", load("res://assets/marca/fuentes/NotoSansRunic.woff2"))
		runa.position = Vector2(0, 8)
		runa.size = Vector2(112, 40)
		runa.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		var tecla := EstiloRunico.texto(boton, "", 14, EstiloRunico.SUAVE)
		tecla.name = "Tecla"
		tecla.position = Vector2(0, 56)
		tecla.size = Vector2(112, 22)
		tecla.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		boton.button_down.connect(func(): _accion(i, true))
		boton.button_up.connect(func(): _accion(i, false))
		boton.gui_input.connect(func(ev):
			if ev is InputEventMouseButton and ev.pressed and ev.button_index == MOUSE_BUTTON_RIGHT:
				_configurar(i, boton))
		_barra.add_child(boton)
		_botones.append(boton)
	for i in 2:
		var futura := Button.new()
		futura.text = "◇"
		futura.custom_minimum_size = Vector2(70, 88)
		futura.disabled = true
		futura.tooltip_text = tr("hud_futuro")
		futura.set_meta("clave_tooltip", "hud_futuro")
		_barra.add_child(futura)
	for tipo in ["vida", "resistencia"]:
		var boton := Button.new()
		boton.custom_minimum_size = Vector2(110, 88)
		boton.add_theme_font_size_override("font_size", 15)
		boton.pressed.connect(func(): beber(tipo))
		_barra.add_child(boton)
		_pociones.append(boton)
	_enlaces = HBoxContainer.new()
	_grupo_juego.add_child(_enlaces)
	_bolsa = EstiloRunico.boton(_enlaces, "inv_bolsa", alternar_inventario)
	_diario = EstiloRunico.boton(_enlaces, "diario_titulo", func(): hud.abrir_diario())
	_bolsa.add_theme_font_size_override("font_size", 16)
	_diario.add_theme_font_size_override("font_size", 16)
	_popup = PopupMenu.new()
	_popup.process_mode = Node.PROCESS_MODE_ALWAYS
	add_child(_popup)
	_popup.id_pressed.connect(_elegir_accion)
	_popup.popup_hide.connect(func():
		if not inventario.visible:
			_reanudar())
	# recuadro de lo seleccionado: queda a la vista también durante el diálogo
	marco_seleccion = MarcoSeleccion.new()
	add_child(marco_seleccion)
	inventario = InventarioAventura.new()
	add_child(inventario)
	inventario.cerrar.connect(cerrar_inventario)
	inventario.usar_pocion.connect(beber)
	Juego.inventario.cambio.connect(refrescar)
	Calidad.cambio.connect(refrescar)
	Controles.dispositivo_cambio.connect(refrescar)
	hud._cartel.position.y = -210
	refrescar()
	resized.connect(_ajustar_juego)
	_ajustar_juego()


func _ajustar_juego() -> void:
	if not _barra:
		return
	var escala := minf(1.0, size.x / 1440.0)
	_barra.scale = Vector2.ONE * escala
	_barra.position = Vector2(size.x * 0.5 - 340 * escala, size.y - 128 * escala)
	var salud := hud._salud.get_parent() as Control
	salud.scale = Vector2.ONE * escala
	salud.position = Vector2(size.x * 0.5 - 650 * escala, size.y - 165 * escala)
	var objetivo := hud._objetivo_titulo.get_parent() as Control
	objetivo.position = Vector2(size.x - 395, 335)
	objetivo.set_deferred("size", Vector2(355, 0))
	_plegar.position = Vector2(size.x - 395, 275)
	_enlaces.position = Vector2(size.x - 310, size.y - (220.0 * escala if size.x < 1500 else 66.0))


func refrescar() -> void:
	if not _bolsa:
		return
	for n in _grupo_juego.find_children("*", "Label", true, false):
		if n.has_meta("clave") and str(n.get_meta("clave")) != "":
			n.text = tr(n.get_meta("clave"))
	for n in _barra.get_children():
		if n.has_meta("clave_tooltip"):
			n.tooltip_text = tr(n.get_meta("clave_tooltip"))
	for i in _botones.size():
		var accion: String = Juego.inventario.barra[i]
		(_botones[i].get_node("Runa") as Label).text = RUNAS[accion]
		(_botones[i].get_node("Tecla") as Label).text = Controles.tecla(accion)
		_botones[i].tooltip_text = tr("hud_" + accion) + "\n" + tr("hud_cambiar_barra")
	_bolsa.text = "%s · %s" % [Controles.tecla("inventario"), tr("inv_bolsa")]
	_diario.text = "%s · %s" % [Controles.tecla("diario"), tr("diario_titulo")]
	_plegar.text = tr("hud_plegar")
	inventario.refrescar_textos()
	_actualizar_pociones()


func _process(dt: float) -> void:
	if not is_instance_valid(hud):
		return
	_grupo_juego.visible = not hud.en_menu and not hud.en_dialogo
	if hud.en_menu:
		marco_seleccion.visible = false
	elif Seleccion.actual and not marco_seleccion.visible:
		marco_seleccion.mostrar(Seleccion.actual)
	var salud := hud._salud.get_parent() as Control
	salud.visible = _grupo_juego.visible
	if not get_tree().paused and Juego.inventario.espera_pocion > 0:
		Juego.inventario.espera_pocion = maxf(0, Juego.inventario.espera_pocion - dt)
	_actualizar_pociones()
	if not hud.heroe:
		return
	for i in _botones.size():
		var accion: String = Juego.inventario.barra[i]
		var activo := (accion == "atacar" and hud.heroe.atacando()) or (accion == "esquivar" and hud.heroe.esquivando) or (accion == "bloquear" and hud.heroe.bloqueando)
		_botones[i].modulate = EstiloRunico.AZUL if activo else Color.WHITE


func _actualizar_pociones() -> void:
	for i in _pociones.size():
		var tipo := "vida" if i == 0 else "resistencia"
		var segundos := ceili(Juego.inventario.espera_pocion)
		_pociones[i].text = "%s\n%s ×%d%s" % [Controles.tecla("pocion_" + tipo), tr("hud_pocion_" + tipo), Juego.inventario.pociones[tipo], "\n%ds" % segundos if segundos > 0 else ""]
		_pociones[i].disabled = segundos > 0 or int(Juego.inventario.pociones[tipo]) <= 0


func _accion(indice: int, pulsada: bool) -> void:
	if hud.heroe and not hud.en_menu and not hud.en_dialogo:
		hud.heroe.pedir_accion_interfaz(Juego.inventario.barra[indice], pulsada)


func _configurar(indice: int, boton: Button) -> void:
	if hud.en_menu or hud.en_dialogo or not hud.heroe or hud.heroe.muerto or hud.heroe.bloqueado:
		return
	_posicion_barra = indice
	_popup.clear()
	for accion in DatosEquipo.ACCIONES:
		_popup.add_item(tr("hud_" + accion))
	hud.heroe.pedir_accion_interfaz("bloquear", false)
	hud.en_menu = true
	get_tree().paused = true
	_popup.position = Vector2i(boton.get_global_rect().position + Vector2(0, -180))
	_popup.popup()


func _elegir_accion(indice: int) -> void:
	var accion: String = DatosEquipo.ACCIONES[indice]
	var anterior := Juego.inventario.barra.find(accion)
	Juego.inventario.barra[anterior] = Juego.inventario.barra[_posicion_barra]
	Juego.inventario.barra[_posicion_barra] = accion
	Juego.inventario.cambio.emit()
	Juego.guardar()


func alternar_inventario() -> void:
	if inventario.visible:
		cerrar_inventario()
		return
	if hud.en_menu or hud.en_dialogo or not hud.heroe or hud.heroe.muerto or hud.heroe.bloqueado:
		return
	hud.heroe.pedir_accion_interfaz("bloquear", false)
	hud.en_menu = true
	get_tree().paused = true
	inventario.abrir()


func cerrar_inventario() -> void:
	inventario.hide()
	_reanudar()


func _reanudar() -> void:
	hud.en_menu = false
	if hud.heroe:
		hud.heroe.bloqueado = true
		hud.heroe.desbloquear_luego()
	get_tree().paused = false


func beber(tipo: String) -> void:
	var h := hud.heroe
	if not h or h.muerto or hud.en_dialogo or tipo not in Juego.inventario.pociones:
		return
	if Juego.inventario.espera_pocion > 0 or int(Juego.inventario.pociones[tipo]) <= 0:
		return
	if (tipo == "vida" and h.salud >= Heroe.SALUD_MAX) or (tipo == "resistencia" and h.stamina >= h.estadisticas.stamina_maxima):
		return
	if tipo == "vida":
		h.curar(40)
	else:
		h.stamina = minf(h.estadisticas.stamina_maxima, h.stamina + 40)
		h.stamina_cambio.emit(h.stamina, h.estadisticas.stamina_maxima)
	Juego.inventario.pociones[tipo] -= 1
	Juego.inventario.espera_pocion = 5.0
	Juego.inventario.cambio.emit()
	Juego.guardar()
	hud.mostrar_mensaje(tr("hud_pocion_usada"))


func _input(ev: InputEvent) -> void:
	if inventario.visible:
		if ev.is_action_pressed("pausa") or ev.is_action_pressed("ui_cancel"):
			cerrar_inventario()
			get_viewport().set_input_as_handled()
		elif ev is InputEventKey and ev.is_action_pressed("inventario") and not inventario._busqueda.has_focus():
			cerrar_inventario()
			get_viewport().set_input_as_handled()
		return
	if hud.en_menu or hud.en_dialogo:
		return
	if ev.is_action_pressed("inventario"):
		alternar_inventario()
		get_viewport().set_input_as_handled()
	for tipo in ["vida", "resistencia"]:
		if ev.is_action_pressed("pocion_" + tipo):
			beber(tipo)
			get_viewport().set_input_as_handled()
