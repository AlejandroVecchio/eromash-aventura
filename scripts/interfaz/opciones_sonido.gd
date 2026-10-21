class_name OpcionesSonido
extends ColorRect
## Opciones → Sonido: una barra de 0 a 100 por bus (general, música, ambiente, efectos y voces), como Opciones →
## Video. Todo se aplica al instante y se guarda (lo hace Sonido). Funciona con mouse, teclado y mando; la
## descripción de la barra que tiene el foco (o el mouse encima) aparece al pie. Mover General o Efectos toca un
## sonido de prueba para escuchar el nivel.

signal cerrado

const AZUL := Color(0.45, 0.84, 0.86)
const AMBAR := Color(0.91, 0.72, 0.4)
const GRIS := Color(0.66, 0.7, 0.68)
const PAUSA_PRUEBA := 0.18   ## s entre sonidos de prueba al mover una barra

var _barras := {}          ## clave → HSlider
var _valores := {}         ## clave → Label
var _desc: Label
var _sincronizando := false
var _ultima_prueba := 0.0
var _fuente_titulo: Font


func _init(fuente_titulo: Font) -> void:
	_fuente_titulo = fuente_titulo


func _ready() -> void:
	color = Color(0, 0, 0, 0.6)
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	visible = false
	process_mode = Node.PROCESS_MODE_ALWAYS
	var centro := CenterContainer.new()
	centro.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(centro)
	var panel := PanelContainer.new()
	centro.add_child(panel)
	var v := VBoxContainer.new()
	v.custom_minimum_size = Vector2(760, 0)
	v.add_theme_constant_override("separation", 10)
	panel.add_child(v)

	var t := _texto(v, "sonido_titulo", 34, AMBAR)
	t.add_theme_font_override("font", _fuente_titulo)
	t.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	for b in Sonido.BUSES:
		_barra(v, b[0], b[2], b[3])

	_desc = Label.new()
	_desc.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_desc.custom_minimum_size = Vector2(740, 56)
	_desc.add_theme_color_override("font_color", GRIS)
	_desc.add_theme_font_size_override("font_size", 18)
	v.add_child(_desc)
	var botones := HBoxContainer.new()
	botones.alignment = BoxContainer.ALIGNMENT_CENTER
	botones.add_theme_constant_override("separation", 16)
	v.add_child(botones)
	var rest := Button.new()
	rest.text = tr("sonido_restablecer")
	rest.set_meta("clave", "sonido_restablecer")
	rest.pressed.connect(func():
		Sonido.restablecer()
		_sincronizar())
	botones.add_child(rest)
	var volver := Button.new()
	volver.name = "Volver"
	volver.text = tr("video_volver")
	volver.set_meta("clave", "video_volver")
	volver.pressed.connect(cerrar)
	botones.add_child(volver)


func _texto(padre: Node, clave: String, tam: int, col: Color) -> Label:
	var l := Label.new()
	l.text = tr(clave)
	l.set_meta("clave", clave)
	l.add_theme_font_size_override("font_size", tam)
	l.add_theme_color_override("font_color", col)
	padre.add_child(l)
	return l


func _barra(padre: Node, clave: String, titulo: String, desc: String) -> void:
	var h := HBoxContainer.new()
	h.add_theme_constant_override("separation", 14)
	h.mouse_entered.connect(_describir.bind(desc))
	padre.add_child(h)
	var l := Label.new()
	l.text = tr(titulo)
	l.set_meta("clave", titulo)
	l.custom_minimum_size.x = 330
	l.add_theme_font_size_override("font_size", 20)
	l.mouse_filter = Control.MOUSE_FILTER_PASS
	l.mouse_entered.connect(_describir.bind(desc))
	h.add_child(l)
	var b := HSlider.new()
	b.min_value = 0
	b.max_value = 100
	b.step = 5
	b.custom_minimum_size = Vector2(300, 24)
	b.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	b.value_changed.connect(func(x):
		_valores[clave].text = "%d %%" % int(x)
		if not _sincronizando:
			Sonido.poner_volumen(clave, int(x))
			_probar(clave))
	b.focus_entered.connect(_describir.bind(desc))
	b.mouse_entered.connect(_describir.bind(desc))
	h.add_child(b)
	var n := Label.new()
	n.custom_minimum_size.x = 70
	n.add_theme_color_override("font_color", AZUL)
	n.add_theme_font_size_override("font_size", 20)
	h.add_child(n)
	_barras[clave] = b
	_valores[clave] = n


## Un sonido corto para escuchar el nivel nuevo (solo los buses que tienen algo que se pueda tocar suelto).
func _probar(clave: String) -> void:
	if clave != "general" and clave != "efectos":
		return
	var ahora := Time.get_ticks_msec() / 1000.0
	if ahora - _ultima_prueba < PAUSA_PRUEBA:
		return
	_ultima_prueba = ahora
	Sonido.tocar("runa")


func _describir(clave: String) -> void:
	if _desc:
		_desc.text = tr(clave)


func _sincronizar() -> void:
	_sincronizando = true
	for b in Sonido.BUSES:
		_barras[b[0]].value = Sonido.volumen(b[0])
		_valores[b[0]].text = "%d %%" % Sonido.volumen(b[0])
	_sincronizando = false


func abrir() -> void:
	_sincronizar()
	visible = true
	_describir(Sonido.BUSES[0][3])
	_barras[Sonido.BUSES[0][0]].grab_focus()


func cerrar() -> void:
	visible = false
	cerrado.emit()


func _unhandled_input(ev: InputEvent) -> void:
	if visible and (ev.is_action_pressed("pausa") or ev.is_action_pressed("ui_cancel")):
		get_viewport().set_input_as_handled()
		cerrar()
