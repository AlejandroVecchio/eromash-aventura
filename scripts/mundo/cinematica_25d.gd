class_name Cinematica25D
extends CanvasLayer
## Cinemática 2.5D de libro ilustrado (prólogo): ilustraciones en capas (fondo, medio, frente) sobre pergamino.
## Cada plano se arma en su propio SubViewport: la cámara recorre la imagen y cada capa la sigue con su propio
## factor (lo cercano se mueve y crece más), con revelado boceto → color, runas que brillan y se apagan, fuego que
## late y bruma. Entre planos, un compositor mezcla las dos escenas (acuarela que florece, recorrido por la página,
## destello rúnico, barrido, cierre a tinta). Encima: polvo, bordes aguados, pergamino fijo, subtítulos (tr) y voces.
## Todo se dibuja a 1920×1080 en un SubViewport y se muestra escalado a la ventana.
##
##   var c := Cinematica25D.new(CinePrologo.datos())
##   c.termino.connect(...)
##   c.reproducir(self)
##
## Saltar: mantener «interactuar» (F / Y). Los datos de cada cinemática van en su propio archivo (ver cine_prologo.gd).

signal termino

const ANCHO := 1920.0
const ALTO := 1080.0
const SALTAR_MANTENER := 0.8   ## segundos manteniendo «interactuar» para saltar
const SOMBREADORES := "res://assets/sombreadores/cine/"
const VOCES := "res://assets/audio/voces/"
const POLVO := 70              ## motas de polvo en Alto (se ajusta con Opciones → Video → Partículas)

var _d: Dictionary
var _planos: Array
var _pases: Array
var _inicios: Array[float] = []
var _fin_imagen := 0.0
var _total := 0.0
var _g := 0.0
var _activa := false
var _mantener := 0.0
var _idioma := "es"

var _cuadro: SubViewport          ## donde se compone todo a 1920×1080
var _ranuras: Array[SubViewport] = []
var _estados := {}                ## índice de plano → {capas, luz}
var _mezcla: ShaderMaterial
var _bordes: ShaderMaterial   ## tramos del perímetro aguados hacia el pergamino
var _texto: Label
var _nombre: Label
var _franja: TextureRect
var _pista: Label
var _sonadas := {}
var _voces: Array[AudioStreamPlayer] = []
var _3d_antes := false           ## el mundo 3D no se dibuja detrás mientras dura


func _init(datos: Dictionary) -> void:
	_d = datos
	_planos = datos.planos
	_pases = datos.pases


func duracion() -> float:
	return _total


func reproducir(padre: Node) -> void:
	layer = 40
	process_mode = Node.PROCESS_MODE_ALWAYS   # sigue aunque el juego quede en pausa detrás
	_idioma = "en" if TranslationServer.get_locale().begins_with("en") else "es"
	var t0 := 0.0
	for i in _planos.size():
		_inicios.append(t0)
		if i < _planos.size() - 1:
			t0 += _planos[i].dur - _pases[i].dur
	_fin_imagen = _inicios[-1] + _planos[-1].dur
	_total = _fin_imagen + _planos[-1].get("negro", 0.0)
	_buses()
	_3d_antes = padre.get_viewport().disable_3d
	padre.get_viewport().disable_3d = true
	padre.add_child(self)
	_armar()
	_activa = true
	_actualizar()


# ---------- armado ----------

func _armar() -> void:
	var fondo := ColorRect.new()
	fondo.color = Color.BLACK
	fondo.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	fondo.mouse_filter = Control.MOUSE_FILTER_STOP   # tapa el juego y su interfaz mientras dura
	add_child(fondo)
	_cuadro = SubViewport.new()
	_cuadro.size = Vector2i(int(ANCHO), int(ALTO))
	_cuadro.disable_3d = true
	_cuadro.render_target_update_mode = SubViewport.UPDATE_ALWAYS
	add_child(_cuadro)
	var vista := TextureRect.new()
	vista.texture = _cuadro.get_texture()
	vista.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	vista.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	vista.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	vista.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(vista)
	for k in 2:
		var vp := SubViewport.new()
		vp.size = Vector2i(int(ANCHO), int(ALTO))
		vp.disable_3d = true
		vp.render_target_update_mode = SubViewport.UPDATE_ALWAYS
		_cuadro.add_child(vp)
		_ranuras.append(vp)
	var lienzo := ColorRect.new()
	lienzo.size = Vector2(ANCHO, ALTO)
	_mezcla = _material("transicion")
	lienzo.material = _mezcla
	_cuadro.add_child(lienzo)
	if Calidad.particulas_activas():
		_cuadro.add_child(_polvo())
	var arriba := CanvasLayer.new()
	_cuadro.add_child(arriba)
	for s in ["bordes", "pergamino"]:
		var r := ColorRect.new()
		r.size = Vector2(ANCHO, ALTO)
		r.material = _material(s)
		if s == "bordes":
			_bordes = r.material
		arriba.add_child(r)
	_subtitulos(arriba)


func _material(nombre: String) -> ShaderMaterial:
	var m := ShaderMaterial.new()
	m.shader = load(SOMBREADORES + nombre + ".gdshader")
	return m


func _polvo() -> CPUParticles2D:
	var polvo := CPUParticles2D.new()
	polvo.amount = Calidad.cuantas(POLVO)
	polvo.lifetime = 9.0
	polvo.preprocess = 9.0
	polvo.emission_shape = CPUParticles2D.EMISSION_SHAPE_RECTANGLE
	polvo.emission_rect_extents = Vector2(ANCHO, ALTO) / 2.0
	polvo.position = Vector2(ANCHO, ALTO) / 2.0
	polvo.direction = Vector2(0.4, -1.0)
	polvo.spread = 40.0
	polvo.gravity = Vector2.ZERO
	polvo.initial_velocity_min = 6.0
	polvo.initial_velocity_max = 18.0
	polvo.scale_amount_min = 1.0
	polvo.scale_amount_max = 3.0
	var rampa := Gradient.new()
	rampa.set_color(0, Color(1.0, 0.9, 0.7, 0.0))
	rampa.add_point(0.3, Color(1.0, 0.9, 0.7, 0.5))
	rampa.set_color(rampa.get_point_count() - 1, Color(1.0, 0.9, 0.7, 0.0))
	polvo.color_ramp = rampa
	var mat := CanvasItemMaterial.new()
	mat.blend_mode = CanvasItemMaterial.BLEND_MODE_ADD
	polvo.material = mat
	return polvo


func _subtitulos(arriba: CanvasLayer) -> void:
	# franja negra tenue detrás del subtítulo, para que se lea también sobre el boceto
	_franja = TextureRect.new()
	var grad := Gradient.new()
	grad.set_color(0, Color(0, 0, 0, 0.0))
	grad.add_point(0.45, Color(0, 0, 0, 0.5))
	grad.set_color(grad.get_point_count() - 1, Color(0, 0, 0, 0.6))
	var gt := GradientTexture2D.new()
	gt.gradient = grad
	gt.fill_to = Vector2(0, 1)
	gt.width = 4
	gt.height = 128
	_franja.texture = gt
	_franja.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	_franja.stretch_mode = TextureRect.STRETCH_SCALE
	_franja.position = Vector2(0, ALTO * 0.72)
	_franja.size = Vector2(ANCHO, ALTO * 0.28)
	arriba.add_child(_franja)
	_nombre = _etiqueta(arriba, Hud.FUENTE_TITULO, 28, Hud.AMBAR, ALTO * 0.775, ALTO * 0.05)
	_texto = _etiqueta(arriba, Hud.FUENTE_TEXTO, 40, Hud.CREMA, ALTO * 0.80, ALTO * 0.14)
	_pista = _etiqueta(arriba, Hud.FUENTE_TEXTO, 18, Color(Hud.CREMA, 0.45), ALTO * 0.945, ALTO * 0.04)
	_pista.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	_pista.position.x = ANCHO * 0.5
	_pista.size.x = ANCHO * 0.47
	_pista.add_theme_constant_override("outline_size", 6)
	_pista.text = tr("cine_saltar") % Controles.tecla("interactuar")


func _etiqueta(padre: Node, fuente: String, tam: int, color: Color, y: float, alto: float) -> Label:
	var l := Label.new()
	l.position = Vector2(ANCHO * 0.12, y)
	l.size = Vector2(ANCHO * 0.76, alto)
	l.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	l.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	l.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	l.add_theme_font_override("font", load(fuente))
	l.add_theme_font_size_override("font_size", tam)
	l.add_theme_color_override("font_color", color)
	l.add_theme_color_override("font_outline_color", Color(0.08, 0.05, 0.03, 0.85))
	l.add_theme_constant_override("outline_size", 12)
	l.add_theme_color_override("font_shadow_color", Color(0, 0, 0, 0.5))
	l.add_theme_constant_override("shadow_offset_y", 3)
	padre.add_child(l)
	return l


## Arma el plano i en su ranura (i % 2), borrando lo que hubiera.
func _armar_plano(i: int) -> void:
	var cfg: Dictionary = _planos[i]
	var vp := _ranuras[i % 2]
	for h in vp.get_children():
		h.queue_free()
	for k in _estados.keys():
		if k % 2 == i % 2:
			_estados.erase(k)
	var capas: Array[Sprite2D] = []
	var revelado := load(SOMBREADORES + "revelado.gdshader") as Shader
	for j in cfg.capas.size():
		var c: Dictionary = cfg.capas[j]
		var s := Sprite2D.new()
		s.texture = load(_d.carpeta + "p%02d_%s.png" % [i + 1, c.capa])
		var m := ShaderMaterial.new()
		m.shader = revelado
		m.set_shader_parameter("origen", c.o)
		m.set_shader_parameter("ondulacion", c.get("ond", 0.0))
		m.set_shader_parameter("deriva", c.get("der", 0.0))
		m.set_shader_parameter("limite_cielo", c.get("cielo", 0.5))
		m.set_shader_parameter("umbral_color", c.get("umbral", 2.0))
		m.set_shader_parameter("intensidad", c.get("intensidad", 0.8))
		s.material = m
		vp.add_child(s)
		capas.append(s)
		if j == 0 and cfg.has("bruma") and Calidad.brillos():
			var bruma := ColorRect.new()
			bruma.size = Vector2(ANCHO, ALTO)
			bruma.material = _material("niebla")
			bruma.material.set_shader_parameter("centro", cfg.bruma.centro)
			bruma.material.set_shader_parameter("fuerza", cfg.bruma.fuerza)
			vp.add_child(bruma)
	var luz: ColorRect = null
	if cfg.has("luz"):
		luz = ColorRect.new()
		luz.size = Vector2(ANCHO, ALTO)
		luz.material = _material("luz")
		luz.material.set_shader_parameter("centro", cfg.luz.centro)
		luz.material.set_shader_parameter("radio", cfg.luz.radio)
		vp.add_child(luz)
	_estados[i] = {"capas": capas, "luz": luz}


# Narrador: un poco más grave, cuerpo en los graves, compresión y sala grande. Guardián: sala chica y cercana.
func _buses() -> void:
	for nombre_bus in ["Narrador", "Guardian"]:
		if AudioServer.get_bus_index(nombre_bus) != -1:
			continue
		AudioServer.add_bus()
		var i := AudioServer.bus_count - 1
		AudioServer.set_bus_name(i, nombre_bus)
		AudioServer.set_bus_send(i, "Master")
		var eq := AudioEffectEQ6.new()
		var comp := AudioEffectCompressor.new()
		comp.threshold = -18.0
		comp.ratio = 3.0
		var sala := AudioEffectReverb.new()
		if nombre_bus == "Narrador":
			var tono := AudioEffectPitchShift.new()
			tono.pitch_scale = 0.91
			AudioServer.add_bus_effect(i, tono)
			eq.set_band_gain_db(0, 3.0)    # 32 Hz
			eq.set_band_gain_db(1, 3.5)    # 100 Hz
			eq.set_band_gain_db(5, -1.5)   # 10 kHz
			sala.room_size = 0.75
			sala.damping = 0.6
			sala.wet = 0.16
			sala.predelay_msec = 40.0
		else:
			eq.set_band_gain_db(1, 1.5)
			sala.room_size = 0.35
			sala.damping = 0.7
			sala.wet = 0.10
		sala.dry = 1.0
		AudioServer.add_bus_effect(i, eq)
		AudioServer.add_bus_effect(i, comp)
		AudioServer.add_bus_effect(i, sala)
		AudioServer.set_bus_volume_db(i, 1.5)


# ---------- tiempo ----------

func _process(dt: float) -> void:
	if not _activa:
		return
	if Input.is_action_pressed("interactuar"):
		_mantener += dt
		_pista.modulate.a = 2.2
		if _mantener >= SALTAR_MANTENER:
			_terminar()
			return
	else:
		_mantener = 0.0
		_pista.modulate.a = 1.0
	_g += dt
	if _g >= _total:
		_terminar()
		return
	_actualizar()


func _actualizar() -> void:
	# planos vivos ahora (uno, o dos durante una transición)
	var vivos: Array[int] = []
	for i in _planos.size():
		if _g >= _inicios[i] and _g < _inicios[i] + _planos[i].dur:
			vivos.append(i)
	if vivos.is_empty():
		vivos.append(_planos.size() - 1)
	for i in vivos:
		if not _estados.has(i):
			_armar_plano(i)
		_mover(i, _g - _inicios[i])
	var a: int = vivos[0]
	_mezcla.set_shader_parameter("escena_a", _ranuras[a % 2].get_texture())
	_mezcla.set_shader_parameter("a_es_papel", false)
	var pase: Dictionary = {}
	var p := 0.0
	if vivos.size() > 1:
		pase = _pases[a]
		p = (_g - _inicios[a + 1]) / pase.dur
		_mezcla.set_shader_parameter("escena_b", _ranuras[(a + 1) % 2].get_texture())
	elif a == 0 and _g < _d.inicio.dur:
		pase = _d.inicio
		p = _g / pase.dur
		_mezcla.set_shader_parameter("a_es_papel", true)
		_mezcla.set_shader_parameter("escena_b", _ranuras[0].get_texture())
	elif a == _planos.size() - 1 and _g > _fin_imagen - _pases[-1].dur:
		pase = _pases[-1]
		p = (_g - (_fin_imagen - pase.dur)) / pase.dur
	_mezcla.set_shader_parameter("modo", pase.get("modo", 0))
	_mezcla.set_shader_parameter("p", clampf(p, 0.0, 1.0))
	_mezcla.set_shader_parameter("origen", pase.get("origen", Vector2(0.5, 0.5)))
	_mezcla.set_shader_parameter("lado", pase.get("lado", 1.0))
	# en el cierre a tinta los bordes no aclaran el negro
	var cierre := 0.0 if _g < _fin_imagen - _pases[-1].dur else clampf((_g - (_fin_imagen - _pases[-1].dur)) / _pases[-1].dur, 0.0, 1.0)
	_bordes.set_shader_parameter("fuerza", 0.7 * (1.0 - cierre))
	_lineas(vivos)


func _lineas(vivos: Array[int]) -> void:
	_texto.text = ""
	_nombre.text = ""
	var alfa := 0.0
	for i in vivos:
		var t := _g - _inicios[i]
		for l in _planos[i].lineas:
			var clave: String = l[0]
			var quien: String = l[1]
			var entra: float = l[2]
			var dura: float = l[3]
			if t >= entra and t < entra + dura:
				_texto.text = tr(clave)
				_nombre.text = "" if quien == "narrador" else tr("nombre_" + quien)
				alfa = minf(_suave((t - entra) / 0.4), _suave((entra + dura - t) / 0.4))
			if t >= entra and not _sonadas.has(clave):
				_sonadas[clave] = true
				_hablar(clave, quien)
	_texto.modulate.a = alfa
	_nombre.modulate.a = alfa
	_franja.modulate.a = alfa


func _hablar(clave: String, quien: String) -> void:
	var ruta := VOCES + "%s-%s.mp3" % [clave, _idioma]
	if not ResourceLoader.exists(ruta):
		return
	var r := AudioStreamPlayer.new()
	r.stream = load(ruta)
	r.bus = "Narrador" if quien == "narrador" else "Guardian"
	add_child(r)
	r.finished.connect(r.queue_free)
	r.play()
	_voces.append(r)


func _terminar() -> void:
	if not _activa:
		return
	_activa = false
	for r in _voces:
		if is_instance_valid(r):
			r.stop()
	get_viewport().disable_3d = _3d_antes
	termino.emit()
	queue_free()


# ---------- cada plano ----------

func _suave(x: float) -> float:
	x = clampf(x, 0.0, 1.0)
	return x * x * (3.0 - 2.0 * x)


## Parpadeo determinista entre 0 y 1.
func _parpadeo(tt: float, semilla: float) -> float:
	return clampf(0.55 + 0.35 * sin(tt * 11.0 + semilla) * sin(tt * 4.3 + semilla * 2.0) + 0.2 * sin(tt * 27.0 + semilla * 3.0), 0.0, 1.0)


## Runas: [brillo, apagado]. `marcas`: cuándo empiezan a fallar y cuándo se apagan.
func _runa(modo: String, tt: float, marcas: Array) -> Array:
	match modo:
		"fallan":   # brillan, empiezan a fallar y se apagan
			var apagado := _suave((tt - marcas[1]) / 1.6)
			var b := 0.55 * (0.8 + 0.2 * _parpadeo(tt, 1.0))
			if tt > marcas[0]:
				b *= 1.0 if _parpadeo(tt * 1.7, 4.0) > 0.45 else 0.15
			return [b * (1.0 - apagado), apagado]
		"se_quiebra":   # bajo la mano: tiembla y pierde el fulgor hasta gris carbón
			var apagado := _suave((tt - 3.2) / 1.6)
			var b := 0.6 * (0.85 + 0.15 * _parpadeo(tt, 2.0))
			if tt > 2.0:
				b *= 1.0 if _parpadeo(tt * 2.1, 7.0) > 0.4 else 0.1
			return [b * (1.0 - apagado), apagado]
		"destellos":   # destellos intermitentes sobre la cara
			var p := _parpadeo(tt * 0.9, 3.0)
			var b := 0.75 * (p if p > 0.5 else p * 0.2)
			return [b, 0.6 - 0.6 * p]
	return [0.0, 0.0]


func _camara(cfg: Dictionary, tt: float) -> Dictionary:
	var dur: float = cfg.dur
	var f := clampf(tt / dur, 0.0, 1.0)
	# acelerado (travelling hacia la garra) o suave al arrancar y al llegar
	var te := dur * (pow(f, 2.2) if cfg.get("acelera", false) else _suave(f))
	var claves: Array = cfg.camara
	for i in range(claves.size() - 1):
		var a: Array = claves[i]
		var b: Array = claves[i + 1]
		if te <= b[0] or i == claves.size() - 2:
			var k := clampf((te - a[0]) / (b[0] - a[0]), 0.0, 1.0)
			return {"mira": (a[1] as Vector2).lerp(b[1], k), "zoom": lerpf(a[2], b[2], k)}
	return {"mira": claves[0][1], "zoom": claves[0][2]}


func _mover(i: int, t: float) -> void:
	var e: Dictionary = _estados[i]
	var cfg: Dictionary = _planos[i]
	var cam := _camara(cfg, t)
	var f := clampf(t / cfg.dur, 0.0, 1.0)
	var temblor := Vector2.ZERO
	if cfg.has("temblor"):
		var tb: Dictionary = cfg.temblor
		var env := _suave((t - tb.t0) / 0.3) * (1.0 - _suave((t - tb.t1) / 1.5))
		temblor = Vector2(sin(t * 53.0) + sin(t * 31.0) * 0.6, cos(t * 47.0) + sin(t * 23.0) * 0.6) * tb.px * env
	var capas: Array = e.capas
	for j in capas.size():
		var c: Dictionary = cfg.capas[j]
		var s: Sprite2D = capas[j]
		var tw := float(s.texture.get_width())
		var th := float(s.texture.get_height())
		var z: float = cam.zoom * c.k * (1.0 + c.get("avance", 0.0) * _suave(f))
		var escala: float = maxf(ANCHO / tw, ALTO / th) * z
		var mira: Vector2 = Vector2(0.5, 0.5) + (cam.mira - Vector2(0.5, 0.5)) * c.m
		# que el borde de la imagen nunca entre en cuadro
		var mx := 0.5 - ANCHO / (2.0 * tw * escala)
		var my := 0.5 - ALTO / (2.0 * th * escala)
		mira.x = clampf(mira.x, 0.5 - mx, 0.5 + mx)
		mira.y = clampf(mira.y, 0.5 - my, 0.5 + my)
		s.scale = Vector2(escala, escala)
		var extra: Vector2 = temblor * float(c.m)
		extra.y -= c.get("sube", 0.0) * _suave(f)
		extra.y += sin(t * 1.6 * TAU) * c.get("vaiven", 0.0)
		s.position = Vector2(ANCHO, ALTO) / 2.0 + (Vector2(0.5, 0.5) - mira) * Vector2(tw, th) * escala + extra
		var m := s.material as ShaderMaterial
		m.set_shader_parameter("progreso", _suave((t - c.r0) / c.rd))
		if c.has("runa"):
			var r := _runa(c.runa, t, cfg.get("runa_t", [3.7, 6.0]))
			m.set_shader_parameter("brillo_runa", r[0])
			m.set_shader_parameter("apagado_runa", r[1])
			if e.luz:
				(e.luz.material as ShaderMaterial).set_shader_parameter("intensidad", r[0] * 0.22)
		if c.has("fuego"):
			m.set_shader_parameter("fuego", c.fuego * (0.5 + 0.5 * _parpadeo(t * 1.3, float(j))))
