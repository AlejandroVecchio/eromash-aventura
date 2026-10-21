class_name MarcoSeleccion
extends PanelContainer
## Recuadro de lo seleccionado (arriba a la izquierda, debajo de la región): retrato con doble filo fino, nombre
## y rol. Escucha Seleccion.cambio; con ✕ se deja de seleccionar. Pensado para crecer (vida de un enemigo,
## estado, acciones sobre el objetivo): ver docs/seleccion.md.

const LADO_RETRATO := 92
const FUENTE_TITULO := "res://assets/marca/fuentes/EromashDisplay-Bold.woff2"

var _retrato: TextureRect
var _nombre: Label
var _subtitulo: Label
var _actual: Seleccionable
var _tween: Tween


func _ready() -> void:
	name = "MarcoSeleccion"
	add_to_group("bloquea_clic_combate")   # un clic en el recuadro no ataca ni deselecciona
	position = Vector2(36, 84)
	add_theme_stylebox_override("panel", EstiloRunico.panel(Color(EstiloRunico.FONDO, 0.86), Color("697762"), 10))
	var fila := HBoxContainer.new()
	fila.add_theme_constant_override("separation", 14)
	fila.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(fila)
	# retrato: filo azul rúnico por fuera y uno apagado por dentro
	var filo := PanelContainer.new()
	filo.mouse_filter = Control.MOUSE_FILTER_IGNORE
	filo.add_theme_stylebox_override("panel", EstiloRunico.panel(Color(0, 0, 0, 0), Color(EstiloRunico.AZUL, 0.85), 3))
	fila.add_child(filo)
	var filo_dentro := PanelContainer.new()
	filo_dentro.mouse_filter = Control.MOUSE_FILTER_IGNORE
	filo_dentro.add_theme_stylebox_override("panel", EstiloRunico.panel(Color("0d1613"), Color(EstiloRunico.SUAVE, 0.35), 1))
	filo.add_child(filo_dentro)
	_retrato = TextureRect.new()
	_retrato.custom_minimum_size = Vector2(LADO_RETRATO, LADO_RETRATO)
	_retrato.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	_retrato.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
	_retrato.mouse_filter = Control.MOUSE_FILTER_IGNORE
	filo_dentro.add_child(_retrato)
	var textos := VBoxContainer.new()
	textos.alignment = BoxContainer.ALIGNMENT_CENTER
	textos.custom_minimum_size.x = 210
	textos.add_theme_constant_override("separation", 4)
	textos.mouse_filter = Control.MOUSE_FILTER_IGNORE
	fila.add_child(textos)
	var cabeza := HBoxContainer.new()
	cabeza.mouse_filter = Control.MOUSE_FILTER_IGNORE
	textos.add_child(cabeza)
	_nombre = EstiloRunico.texto(cabeza, "", 24, EstiloRunico.CREMA)
	_nombre.add_theme_font_override("font", load(FUENTE_TITULO))
	_nombre.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	var cerrar := Button.new()
	cerrar.text = "✕"
	cerrar.flat = true
	cerrar.focus_mode = Control.FOCUS_NONE
	cerrar.add_theme_font_size_override("font_size", 14)
	cerrar.add_theme_color_override("font_color", Color(EstiloRunico.SUAVE, 0.8))
	cerrar.add_theme_color_override("font_hover_color", EstiloRunico.AZUL)
	cerrar.add_to_group("bloquea_clic_combate")
	cerrar.pressed.connect(Seleccion.limpiar)
	cabeza.add_child(cerrar)
	# trazo fino rúnico entre el nombre y el rol
	var trazo := ColorRect.new()
	trazo.color = Color(EstiloRunico.AZUL, 0.45)
	trazo.custom_minimum_size = Vector2(0, 1)
	trazo.mouse_filter = Control.MOUSE_FILTER_IGNORE
	textos.add_child(trazo)
	_subtitulo = EstiloRunico.texto(textos, "", 15, EstiloRunico.SUAVE)
	_subtitulo.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_subtitulo.custom_minimum_size.x = 210
	modulate.a = 0.0
	visible = false
	Seleccion.cambio.connect(mostrar)
	_textos_cerrar(cerrar)


func mostrar(s: Seleccionable) -> void:
	_actual = s
	if _tween:
		_tween.kill()
	_tween = create_tween()
	if s == null:
		_tween.tween_property(self, "modulate:a", 0.0, 0.15)
		_tween.tween_callback(func(): visible = false)
		return
	_retrato.texture = s.retrato
	_retrato.get_parent().get_parent().visible = s.retrato != null
	_refrescar()
	visible = true
	position.x = 26
	_tween.set_parallel()
	_tween.tween_property(self, "modulate:a", 1.0, 0.2)
	_tween.tween_property(self, "position:x", 36.0, 0.2).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CUBIC)


func _refrescar() -> void:
	if _actual == null or not is_instance_valid(_actual):
		return
	_nombre.text = _actual.nombre()
	_subtitulo.text = _actual.subtitulo()
	_subtitulo.visible = _subtitulo.text != ""
	reset_size()


func _textos_cerrar(b: Button) -> void:
	b.tooltip_text = tr("seleccion_cerrar")
	b.set_meta("clave_tooltip", "seleccion_cerrar")


func _notification(what: int) -> void:
	if what == NOTIFICATION_TRANSLATION_CHANGED and _nombre:
		_refrescar()
		for b in find_children("*", "Button", true, false):
			if b.has_meta("clave_tooltip"):
				b.tooltip_text = tr(b.get_meta("clave_tooltip"))
