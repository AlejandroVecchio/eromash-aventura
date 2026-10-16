class_name CeldaEquipo
extends Button

signal elegir(id: String)
signal alternar(id: String)
signal soltar(id: String, destino: String)

var id_pieza := ""
var ranura := ""
var en_bolsa := false


func _ready() -> void:
	add_to_group("bloquea_clic_combate")
	custom_minimum_size = Vector2(78, 78)
	add_theme_font_size_override("font_size", 13)
	add_theme_stylebox_override("normal", EstiloRunico.panel(Color("1b241b"), Color("46533e"), 5))
	add_theme_stylebox_override("hover", EstiloRunico.panel(Color("2b392b"), EstiloRunico.SUAVE, 5))
	add_theme_stylebox_override("focus", EstiloRunico.panel(Color.TRANSPARENT, EstiloRunico.AZUL, 5))
	expand_icon = true
	icon_alignment = HORIZONTAL_ALIGNMENT_CENTER
	icon = EstiloRunico.imagen(id_pieza)
	if icon == null:
		text = tr("inv_" + ranura).substr(0, 2).to_upper() if id_pieza != "" else "◇"
	tooltip_text = tr("pieza_" + id_pieza) if id_pieza != "" else tr("inv_vacia")
	pressed.connect(func():
		if id_pieza != "":
			elegir.emit(id_pieza))
	gui_input.connect(_entrada)


func _entrada(ev: InputEvent) -> void:
	if ev is InputEventMouseButton and ev.pressed and id_pieza != "":
		if ev.button_index == MOUSE_BUTTON_RIGHT or (ev.button_index == MOUSE_BUTTON_LEFT and ev.double_click):
			accept_event()
			alternar.emit(id_pieza)


func _get_drag_data(_pos: Vector2) -> Variant:
	if id_pieza == "" or ranura == "casco" or id_pieza.begins_with("pocion_"):
		return null
	var vista := TextureRect.new()
	vista.texture = icon
	vista.custom_minimum_size = Vector2(64, 64)
	vista.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	vista.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	set_drag_preview(vista)
	return {"id": id_pieza, "dueno": Juego.inventario}


func _can_drop_data(_pos: Vector2, datos: Variant) -> bool:
	if not datos is Dictionary or datos.get("dueno") != Juego.inventario:
		return false
	var id := str(datos.get("id", ""))
	if not DatosEquipo.CATALOGO.has(id):
		return false
	if en_bolsa:
		return Juego.inventario.equipado(id) and Juego.inventario.ids_bolsa().size() < DatosEquipo.CAPACIDAD and id != "casco_base"
	return ranura != "casco" and DatosEquipo.CATALOGO[id].ranura == ranura and id in Juego.inventario.bolsa


func _drop_data(_pos: Vector2, datos: Variant) -> void:
	if _can_drop_data(_pos, datos):
		soltar.emit(str(datos.id), "bolsa" if en_bolsa else ranura)
