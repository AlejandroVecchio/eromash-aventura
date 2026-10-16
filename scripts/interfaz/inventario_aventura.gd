class_name InventarioAventura
extends Control

signal cerrar
signal usar_pocion(tipo: String)

var seleccionado := ""
var _contenido: Panel
var _visor: VisorPersonaje
var _cuadricula: GridContainer
var _ranuras: Dictionary = {}
var _busqueda: LineEdit
var _filtro: OptionButton
var _orden: OptionButton
var _detalle: Label
var _estado: Label
var _valores: Label
var _cantidad: Label
var _equipar: Button
var _quitar: Button


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_to_group("bloquea_clic_combate")
	var oscuro := ColorRect.new()
	oscuro.color = Color(0.02, 0.04, 0.03, 0.82)
	oscuro.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(oscuro)
	_contenido = Panel.new()
	_contenido.size = Vector2(1760, 970)
	_contenido.add_theme_stylebox_override("panel", EstiloRunico.panel())
	add_child(_contenido)
	var marca := TextureRect.new()
	marca.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	marca.texture = load("res://assets/marca/e.svg")
	marca.position = Vector2(30, 22)
	marca.size = Vector2(40, 45)
	marca.set_deferred("size", Vector2(40, 45))
	marca.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	_contenido.add_child(marca)
	var titulo := EstiloRunico.texto(_contenido, "inv_titulo", 32)
	titulo.position = Vector2(90, 24)
	var salir := EstiloRunico.boton(_contenido, "inv_cerrar", func(): cerrar.emit())
	salir.position = Vector2(1540, 22)
	salir.size = Vector2(190, 45)
	var equipo := EstiloRunico.texto(_contenido, "inv_equipo", 24, EstiloRunico.AMBAR)
	equipo.position = Vector2(30, 95)
	var bolsa := EstiloRunico.texto(_contenido, "inv_bolsa", 24, EstiloRunico.AMBAR)
	bolsa.position = Vector2(795, 95)
	var sello := TextureRect.new()
	sello.texture = load("res://assets/interfaz/vegvisir.svg")
	sello.position = Vector2(185, 300)
	sello.size = Vector2(350, 350)
	sello.modulate.a = 0.22
	sello.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_contenido.add_child(sello)
	var piso := Control.new()
	piso.position = Vector2(180, 758)
	piso.size = Vector2(370, 28)
	piso.mouse_filter = Control.MOUSE_FILTER_IGNORE
	piso.draw.connect(func():
		var puntos := PackedVector2Array()
		for i in 81:
			var angulo := TAU * i / 80.0
			puntos.append(Vector2(185 + cos(angulo) * 150, 14 + sin(angulo) * 12))
		piso.draw_polyline(puntos, Color(EstiloRunico.AZUL, 0.35), 1, true))
	_contenido.add_child(piso)
	_visor = VisorPersonaje.new()
	_visor.position = Vector2(170, 150)
	_visor.size = Vector2(390, 650)
	_contenido.add_child(_visor)
	for i in DatosEquipo.RANURAS.size():
		var ranura: String = DatosEquipo.RANURAS[i]
		var x := 30.0 if i < 7 else 610.0
		var y := 150.0 + (i % 7) * 97.0
		var etiqueta := EstiloRunico.texto(_contenido, "inv_" + ranura, 15, EstiloRunico.SUAVE)
		etiqueta.position = Vector2(x, y)
		_ranuras[ranura] = Vector2(x, y + 22)
	var vista_controles := HBoxContainer.new()
	vista_controles.position = Vector2(170, 830)
	_contenido.add_child(vista_controles)
	EstiloRunico.boton(vista_controles, "inv_girar_izq", func(): _visor.modelo.rotate_y(-0.3))
	EstiloRunico.boton(vista_controles, "inv_girar_der", func(): _visor.modelo.rotate_y(0.3))
	EstiloRunico.boton(vista_controles, "inv_alejar", func(): _visor.cambiar_zoom(-0.2))
	EstiloRunico.boton(vista_controles, "inv_acercar", func(): _visor.cambiar_zoom(0.2))
	EstiloRunico.boton(vista_controles, "inv_restablecer", func(): _visor.restablecer())
	var ayuda := EstiloRunico.texto(_contenido, "inv_visor_ayuda", 14, EstiloRunico.SUAVE)
	ayuda.position = Vector2(30, 896)
	var visual := EstiloRunico.texto(_contenido, "inv_modelo_actual", 14, EstiloRunico.SUAVE)
	visual.position = Vector2(30, 924)
	_busqueda = LineEdit.new()
	_busqueda.position = Vector2(795, 145)
	_busqueda.size = Vector2(355, 44)
	_busqueda.text_changed.connect(func(_t): _refrescar_bolsa())
	_contenido.add_child(_busqueda)
	_filtro = OptionButton.new()
	_filtro.position = Vector2(1165, 145)
	_filtro.size = Vector2(250, 44)
	_filtro.item_selected.connect(func(_i): _refrescar_bolsa())
	_contenido.add_child(_filtro)
	_orden = OptionButton.new()
	_orden.position = Vector2(1430, 145)
	_orden.size = Vector2(290, 44)
	_orden.item_selected.connect(func(_i): _refrescar_bolsa())
	_contenido.add_child(_orden)
	var forro := Panel.new()
	forro.position = Vector2(785, 205)
	forro.size = Vector2(945, 470)
	forro.add_theme_stylebox_override("panel", EstiloRunico.panel(Color("25271e"), Color("6e7158")))
	_contenido.add_child(forro)
	_cuadricula = GridContainer.new()
	_cuadricula.position = Vector2(805, 225)
	_cuadricula.columns = 10
	_cuadricula.add_theme_constant_override("h_separation", 10)
	_cuadricula.add_theme_constant_override("v_separation", 12)
	_contenido.add_child(_cuadricula)
	_cantidad = EstiloRunico.texto(_contenido, "", 16, EstiloRunico.AMBAR)
	_cantidad.position = Vector2(800, 635)
	_detalle = EstiloRunico.texto(_contenido, "inv_elegir", 26)
	_detalle.position = Vector2(795, 700)
	_estado = EstiloRunico.texto(_contenido, "", 16, EstiloRunico.AMBAR)
	_estado.position = Vector2(795, 740)
	_valores = EstiloRunico.texto(_contenido, "", 20)
	_valores.position = Vector2(795, 775)
	var acciones := HBoxContainer.new()
	acciones.position = Vector2(795, 870)
	_contenido.add_child(acciones)
	_equipar = EstiloRunico.boton(acciones, "inv_equipar", _equipar_seleccion)
	_quitar = EstiloRunico.boton(acciones, "inv_quitar", _quitar_seleccion)
	var ayuda_bolsa := EstiloRunico.texto(_contenido, "inv_bolsa_ayuda", 14, EstiloRunico.SUAVE)
	ayuda_bolsa.position = Vector2(795, 929)
	Juego.inventario.cambio.connect(_cambio)
	resized.connect(_ajustar)
	_ajustar()
	refrescar_textos()
	hide()


func _ajustar() -> void:
	if not _contenido:
		return
	var escala := minf((size.x - 40) / 1760, (size.y - 40) / 970)
	_contenido.scale = Vector2.ONE * maxf(escala, 0.3)
	_contenido.position = (size - _contenido.size * _contenido.scale) * 0.5


func abrir() -> void:
	show()
	refrescar_textos()
	_refrescar()
	if Controles.usando_mando:
		(_cuadricula.get_child(0) as Control).grab_focus()
	else:
		_busqueda.grab_focus()


func refrescar_textos() -> void:
	for n in find_children("*", "", true, false):
		if n.has_meta("clave"):
			if n is Label:
				n.text = tr(n.get_meta("clave"))
			elif n is Button:
				n.text = tr(n.get_meta("clave"))
	_busqueda.placeholder_text = tr("inv_buscar")
	var filtro := _filtro.selected
	_filtro.clear()
	for clave in ["inv_todo", "inv_armaduras", "inv_armas", "inv_amuletos", "inv_consumibles"]:
		_filtro.add_item(tr(clave))
	_filtro.select(maxi(0, filtro))
	var orden := _orden.selected
	_orden.clear()
	for clave in ["inv_orden_tipo", "inv_orden_nombre"]:
		_orden.add_item(tr(clave))
	_orden.select(maxi(0, orden))
	_detallar()


func _cambio() -> void:
	if visible:
		_refrescar.call_deferred()


func _refrescar() -> void:
	for n in _contenido.get_children():
		if n is CeldaEquipo:
			n.free()
	for ranura in _ranuras:
		var celda := _celda(Juego.inventario.equipo[ranura], ranura, false)
		celda.position = _ranuras[ranura]
		celda.size = Vector2(110, 70)
		_contenido.add_child(celda)
	_refrescar_bolsa()
	_detallar()


func _celda(id: String, ranura: String, bolsa: bool) -> CeldaEquipo:
	var celda := CeldaEquipo.new()
	celda.id_pieza = id
	celda.ranura = ranura
	celda.en_bolsa = bolsa
	celda.elegir.connect(func(elegido):
		seleccionado = elegido
		_detallar())
	celda.alternar.connect(_alternar)
	celda.soltar.connect(_mover)
	return celda


func _refrescar_bolsa() -> void:
	for n in _cuadricula.get_children():
		n.free()
	var ids: Array[String] = []
	for id in Juego.inventario.ids_bolsa():
		if not _busqueda.text.is_empty() and not _busqueda.text.to_lower() in tr("pieza_" + id).to_lower():
			continue
		var ranura: String = DatosEquipo.CATALOGO.get(id, {}).get("ranura", "consumible")
		if _filtro.selected == 1 and ranura in ["arma", "amuleto", "consumible"]:
			continue
		if _filtro.selected == 2 and ranura != "arma":
			continue
		if _filtro.selected == 3 and ranura != "amuleto":
			continue
		if _filtro.selected == 4 and ranura != "consumible":
			continue
		ids.append(id)
	ids.sort_custom(func(a: String, b: String):
		if _orden.selected == 1:
			return tr("pieza_" + a).naturalnocasecmp_to(tr("pieza_" + b)) < 0
		return a.naturalnocasecmp_to(b) < 0)
	for id in ids:
		var ranura: String = DatosEquipo.CATALOGO.get(id, {}).get("ranura", "consumible")
		var celda := _celda(id, ranura, true)
		_cuadricula.add_child(celda)
		if id.begins_with("pocion_"):
			celda.text = "%s\n×%d" % [tr("inv_" + id), Juego.inventario.pociones[id.trim_prefix("pocion_")]]
	for i in maxi(0, DatosEquipo.CAPACIDAD - ids.size()):
		_cuadricula.add_child(_celda("", "", true))
	_cantidad.text = tr("inv_capacidad") % [Juego.inventario.ids_bolsa().size(), DatosEquipo.CAPACIDAD]


func _detallar() -> void:
	if not _equipar:
		return
	_equipar.disabled = seleccionado == "" or seleccionado == "casco_base"
	_quitar.disabled = not Juego.inventario.equipado(seleccionado) or seleccionado == "casco_base"
	_detalle.text = tr("pieza_" + seleccionado) if seleccionado != "" else tr("inv_elegir")
	_estado.text = ""
	_valores.text = ""
	if seleccionado == "":
		return
	var puesto := Juego.inventario.equipado(seleccionado)
	_estado.text = tr("inv_puesto" if puesto else "inv_guardado")
	_equipar.disabled = _equipar.disabled or puesto
	_equipar.text = tr("inv_usar" if seleccionado.begins_with("pocion_") else "inv_equipar")
	if seleccionado.begins_with("pocion_"):
		_valores.text = tr("inv_pocion_efecto")
		return
	var a := Juego.inventario.valores()
	var b := Juego.inventario.valores(seleccionado)
	_valores.text = tr("inv_comparar") % [22 * a.dano, 22 * b.dano, a.velocidad, b.velocidad, a.armadura, b.armadura]


func _alternar(id: String) -> void:
	seleccionado = id
	if id.begins_with("pocion_"):
		usar_pocion.emit(id.trim_prefix("pocion_"))
	elif Juego.inventario.equipado(id):
		_quitar_seleccion()
	else:
		_equipar_seleccion()


func _mover(id: String, destino: String) -> void:
	seleccionado = id
	if destino == "bolsa":
		_quitar_seleccion()
	else:
		Juego.inventario.equipar(id, destino)
	Juego.guardar()


func _equipar_seleccion() -> void:
	if seleccionado.begins_with("pocion_"):
		usar_pocion.emit(seleccionado.trim_prefix("pocion_"))
	elif Juego.inventario.equipar(seleccionado):
		Juego.guardar()


func _quitar_seleccion() -> void:
	if not DatosEquipo.CATALOGO.has(seleccionado):
		return
	if Juego.inventario.quitar(DatosEquipo.CATALOGO[seleccionado].ranura):
		_busqueda.text = ""
		_filtro.select(0)
		Juego.guardar()
	else:
		_estado.text = tr("inv_no_quitar")
