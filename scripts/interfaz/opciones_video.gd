class_name OpcionesVideo
extends ColorRect
## Opciones → Video, al estilo de WoW: un preset arriba (Bajo, Medio, Alto, Ultra, Personalizado) y cada ajuste
## de 1 a 10 abajo; tocar uno pasa a Personalizado. Abajo, la pantalla (modo, sincronización vertical, límite de
## cuadros y escala de renderizado). Todo se aplica al instante y se guarda. Funciona con mouse, teclado y mando;
## la descripción del ajuste que tiene el foco (o el mouse encima) aparece al pie.

signal cerrado

const CREMA := Color(0.93, 0.9, 0.82)
const AZUL := Color(0.45, 0.84, 0.86)
const AMBAR := Color(0.91, 0.72, 0.4)
const GRIS := Color(0.66, 0.7, 0.68)

var _preset: OptionButton
var _barras := {}          ## clave → HSlider
var _valores := {}         ## clave → Label
var _modo: OptionButton
var _vsync: CheckButton
var _fps: OptionButton
var _escala: HSlider
var _escala_txt: Label
var _desc: Label
var _sincronizando := false
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

	var t := _texto(v, "video_titulo", 34, AMBAR)
	t.add_theme_font_override("font", _fuente_titulo)
	t.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER

	# preset
	var fila := _fila(v, "video_preset", "video_preset_desc")
	_preset = OptionButton.new()
	_preset.custom_minimum_size.x = 300
	for k in Calidad.PRESET_TEXTO:
		_preset.add_item(tr(k))
	_preset.item_selected.connect(func(i):
		if not _sincronizando:
			Calidad.poner_preset(i)
			_sincronizar())
	_preset.focus_entered.connect(_describir.bind("video_preset_desc"))
	fila.add_child(_preset)

	# ajustes de 1 a 10
	var lista := ScrollContainer.new()
	lista.custom_minimum_size = Vector2(0, 430)
	lista.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	v.add_child(lista)
	var filas := VBoxContainer.new()
	filas.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	filas.add_theme_constant_override("separation", 6)
	lista.add_child(filas)
	for a in Calidad.AJUSTES:
		_barra(filas, a[0], a[1], a[2])

	# pantalla
	var sub := _texto(filas, "video_pantalla", 24, AMBAR)
	sub.add_theme_font_override("font", _fuente_titulo)
	var fm := _fila(filas, "video_modo", "video_modo_desc")
	_modo = OptionButton.new()
	_modo.custom_minimum_size.x = 300
	for m in Calidad.MODOS_VENTANA:
		_modo.add_item(tr("video_modo_" + m))
	_modo.item_selected.connect(func(_i): _pantalla())
	_modo.focus_entered.connect(_describir.bind("video_modo_desc"))
	fm.add_child(_modo)
	var fv := _fila(filas, "video_vsync", "video_vsync_desc")
	_vsync = CheckButton.new()
	_vsync.toggled.connect(func(_b): _pantalla())
	_vsync.focus_entered.connect(_describir.bind("video_vsync_desc"))
	fv.add_child(_vsync)
	var ff := _fila(filas, "video_fps", "video_fps_desc")
	_fps = OptionButton.new()
	_fps.custom_minimum_size.x = 300
	for l in Calidad.LIMITES_FPS:
		_fps.add_item(tr("video_sin_limite") if l == 0 else str(l))
	_fps.item_selected.connect(func(_i): _pantalla())
	_fps.focus_entered.connect(_describir.bind("video_fps_desc"))
	ff.add_child(_fps)
	var fe := _fila(filas, "video_escala", "video_escala_desc")
	_escala = HSlider.new()
	_escala.min_value = 50
	_escala.max_value = 100
	_escala.step = 5
	_escala.custom_minimum_size = Vector2(240, 24)
	_escala.value_changed.connect(func(_x):
		_escala_txt.text = "%d %%" % int(_escala.value)
		_pantalla())
	_escala.focus_entered.connect(_describir.bind("video_escala_desc"))
	fe.add_child(_escala)
	_escala_txt = Label.new()
	_escala_txt.custom_minimum_size.x = 60
	fe.add_child(_escala_txt)

	# descripción y botones
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
	rest.text = tr("video_restablecer")
	rest.set_meta("clave", "video_restablecer")
	rest.pressed.connect(func():
		Calidad.poner_preset(Calidad.ALTO)
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


func _fila(padre: Node, titulo: String, desc: String) -> HBoxContainer:
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
	return h


func _barra(padre: Node, clave: String, titulo: String, desc: String) -> void:
	var h := _fila(padre, titulo, desc)
	var b := HSlider.new()
	b.min_value = 1
	b.max_value = 10
	b.step = 1
	b.tick_count = 10
	b.ticks_on_borders = true
	b.custom_minimum_size = Vector2(300, 24)
	b.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	b.value_changed.connect(func(x):
		_valores[clave].text = str(int(x))
		if not _sincronizando:
			Calidad.poner_nivel(clave, int(x))
			_sincronizar())
	b.focus_entered.connect(_describir.bind(desc))
	b.mouse_entered.connect(_describir.bind(desc))
	h.add_child(b)
	var n := Label.new()
	n.custom_minimum_size.x = 40
	n.add_theme_color_override("font_color", AZUL)
	n.add_theme_font_size_override("font_size", 20)
	h.add_child(n)
	_barras[clave] = b
	_valores[clave] = n


func _describir(clave: String) -> void:
	if _desc:
		_desc.text = tr(clave)


func _pantalla() -> void:
	if _sincronizando:
		return
	Calidad.poner_pantalla(_modo.selected, _vsync.button_pressed, Calidad.LIMITES_FPS[_fps.selected], int(_escala.value))


## Pone los controles como está la configuración (al abrir y cuando un preset cambia todo).
func _sincronizar() -> void:
	_sincronizando = true
	_preset.selected = Calidad.preset
	for a in Calidad.AJUSTES:
		_barras[a[0]].value = Calidad.nivel(a[0])
		_valores[a[0]].text = str(Calidad.nivel(a[0]))
	_modo.selected = Calidad.modo_ventana
	_vsync.button_pressed = Calidad.vsync
	_fps.selected = maxi(0, Calidad.LIMITES_FPS.find(Calidad.limite_fps))
	_escala.value = Calidad.escala
	_escala_txt.text = "%d %%" % Calidad.escala
	_sincronizando = false


## Textos de las listas desplegables al cambiar de idioma (las etiquetas las refresca la interfaz).
func refrescar() -> void:
	for i in Calidad.PRESET_TEXTO.size():
		_preset.set_item_text(i, tr(Calidad.PRESET_TEXTO[i]))
	for i in Calidad.MODOS_VENTANA.size():
		_modo.set_item_text(i, tr("video_modo_" + Calidad.MODOS_VENTANA[i]))
	_fps.set_item_text(0, tr("video_sin_limite"))


func abrir() -> void:
	_sincronizar()
	visible = true
	_describir("video_preset_desc")
	_preset.grab_focus()


func cerrar() -> void:
	visible = false
	cerrado.emit()


func _unhandled_input(ev: InputEvent) -> void:
	if visible and (ev.is_action_pressed("pausa") or ev.is_action_pressed("ui_cancel")):
		get_viewport().set_input_as_handled()
		cerrar()
