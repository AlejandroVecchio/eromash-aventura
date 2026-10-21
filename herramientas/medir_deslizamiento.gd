extends Node
# Mide cuánto patinan los pies del héroe en situaciones de movimiento: con el pie apoyado (el más bajo, pegado
# al piso) su punto en el mundo no debería moverse. Da la velocidad media del pie apoyado en m/s (0 = sin patinar).
# Uso: godot --headless --path . --fixed-fps 60 res://herramientas/medir_deslizamiento.tscn [-- caso1,caso2]
# Con pantalla (xvfb-run, sin --headless) y `fotos=DIR` como segundo argumento guarda cada cuadro de costado.
# Casos: caminar, correr, atacar_caminando, atacar_corriendo, frenar, aterrizar_corriendo, atacar_quieto.

const CASOS := ["caminar", "correr", "atacar_caminando", "atacar_corriendo", "frenar", "aterrizar_corriendo", "atacar_quieto"]
const CONTACTO := 0.05   ## m sobre el pie más bajo del caso para contarlo como apoyado

var heroe: Heroe
var esq: Skeleton3D
var huesos := []
var _fotos := ""   ## carpeta donde guardar los cuadros (vacío: no saca fotos)
var _nombre_caso := ""
var _cuadro := 0
var _camara: Camera3D
var _pies := []   ## puntas y talones en el mundo, tomados después de las capas del esqueleto (skeleton_updated)


func _ready() -> void:
	_correr.call_deferred()


func _correr() -> void:
	var pedidos := CASOS
	var args := OS.get_cmdline_user_args()
	if not args.is_empty():
		pedidos = Array(String(args[0]).split(","))
	if args.size() > 1 and String(args[1]).begins_with("fotos="):
		_fotos = String(args[1]).trim_prefix("fotos=")
		DirAccess.make_dir_recursive_absolute(_fotos)
		_escenario()
	var piso := StaticBody3D.new()
	var forma := CollisionShape3D.new()
	var caja := BoxShape3D.new()
	caja.size = Vector3(400, 1, 400)
	forma.shape = caja
	forma.position.y = -0.5
	piso.add_child(forma)
	add_child(piso)
	Juego.de_prueba = true
	for caso in pedidos:
		await _caso(caso)
	get_tree().quit()


## Luz, cielo, un piso a cuadros (para ver si el pie se mueve contra el suelo) y una cámara de costado.
func _escenario() -> void:
	var luz := DirectionalLight3D.new()
	luz.rotation_degrees = Vector3(-50, 30, 0)
	luz.shadow_enabled = true
	add_child(luz)
	var amb := WorldEnvironment.new()
	var env := Environment.new()
	env.background_mode = Environment.BG_COLOR
	env.background_color = Color(0.22, 0.25, 0.27)
	env.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	env.ambient_light_color = Color(0.7, 0.72, 0.75)
	env.ambient_light_energy = 0.7
	amb.environment = env
	add_child(amb)
	var img := Image.create(2, 2, false, Image.FORMAT_RGB8)
	img.set_pixel(0, 0, Color(0.55, 0.55, 0.5))
	img.set_pixel(1, 1, Color(0.55, 0.55, 0.5))
	img.set_pixel(1, 0, Color(0.35, 0.36, 0.33))
	img.set_pixel(0, 1, Color(0.35, 0.36, 0.33))
	var mat := StandardMaterial3D.new()
	mat.albedo_texture = ImageTexture.create_from_image(img)
	mat.texture_filter = BaseMaterial3D.TEXTURE_FILTER_NEAREST
	mat.uv1_scale = Vector3(100, 100, 1)   # cuadros de 1 m
	var piso := MeshInstance3D.new()
	var plano := PlaneMesh.new()
	plano.size = Vector2(400, 400)
	piso.mesh = plano
	piso.material_override = mat
	add_child(piso)
	_camara = Camera3D.new()
	_camara.fov = 40
	add_child(_camara)


func _foto() -> void:
	if _fotos == "" or heroe == null:
		return
	var h := heroe.global_position
	_camara.global_position = h + Vector3(5.5, 1.3, 0)
	_camara.look_at(h + Vector3(0, 0.9, 0))
	await RenderingServer.frame_post_draw
	get_viewport().get_texture().get_image().save_png("%s/%s_%04d.png" % [_fotos, _nombre_caso, _cuadro])
	_cuadro += 1


func _nuevo_heroe() -> void:
	if heroe:
		heroe.queue_free()
		await get_tree().physics_frame
	Juego.salud = Heroe.SALUD_MAX
	heroe = Heroe.new()
	add_child(heroe)
	heroe.position = Vector3(0, 0.05, 0)
	esq = heroe.modelo.find_children("*", "Skeleton3D", true, false)[0]
	huesos = [esq.find_bone("LeftToes"), esq.find_bone("RightToes"), esq.find_bone("LeftFoot"), esq.find_bone("RightFoot")]
	esq.skeleton_updated.connect(_tomar_pies)
	for i in 20:
		await get_tree().physics_frame


func _tomar_pies() -> void:
	_pies.clear()
	for h in huesos:
		_pies.append(esq.global_transform * esq.get_bone_global_pose(h).origin)


func _soltar_todo() -> void:
	for a in ["mover_arriba", "correr", "atacar", "saltar"]:
		Input.action_release(a)


func _pulsar(a: String) -> void:
	Input.action_press(a)
	await get_tree().physics_frame
	await get_tree().physics_frame
	Input.action_release(a)


## Corre `segundos` midiendo; `cada` cuadro llama a `paso(t)` para manejar las entradas.
func _medir(segundos: float, paso: Callable) -> Dictionary:
	var muestras := []
	var t := 0.0
	while t < segundos:
		await paso.call(t)
		await get_tree().physics_frame
		await _foto()
		t += 1.0 / 60.0
		if _pies.is_empty():
			continue
		muestras.append({"pies": _pies.duplicate(), "v": Vector2(heroe.velocity.x, heroe.velocity.z).length(), "anim": heroe.anim.current_animation, "esc": heroe.anim.speed_scale})
	if OS.has_environment("DEPURAR"):
		for m in muestras.slice(0, muestras.size(), 3):
			print("  y ", "%.3f %.3f %.3f %.3f" % [m.pies[0].y, m.pies[1].y, m.pies[2].y, m.pies[3].y], " v %.2f esc %.2f " % [m.v, m.esc], m.anim)
	# pie apoyado: el punto más bajo entre puntas y talones, si está cerca del piso del caso
	var minimo := INF
	for m in muestras:
		for p in m.pies:
			minimo = minf(minimo, (p as Vector3).y)
	var patina := 0.0
	var apoyado := 0.0
	var v_media := 0.0
	for i in range(1, muestras.size()):
		v_media += muestras[i].v
		var mejor := -1
		for k in 4:
			var p: Vector3 = muestras[i].pies[k]
			if p.y <= minimo + CONTACTO and (mejor < 0 or p.y < (muestras[i].pies[mejor] as Vector3).y):
				mejor = k
		if mejor < 0:
			continue
		var a: Vector3 = muestras[i - 1].pies[mejor]
		var b: Vector3 = muestras[i].pies[mejor]
		patina += Vector2(b.x - a.x, b.z - a.z).length()
		if OS.has_environment("DEPURAR"):
			print("  %d pie %d desliza %.3f v %.2f esc %.2f %s" % [i, mejor, Vector2(b.x - a.x, b.z - a.z).length(), muestras[i].v, muestras[i].esc, muestras[i].anim])
		apoyado += 1.0 / 60.0
	var anims := {}
	for m in muestras:
		anims[m.anim] = true
	return {"total": patina, "patina": patina / maxf(apoyado, 0.001), "apoyado": apoyado, "v": v_media / maxf(1, muestras.size() - 1), "anims": anims.keys()}


func _caso(caso: String) -> void:
	_nombre_caso = caso
	_cuadro = 0
	await _nuevo_heroe()
	_soltar_todo()
	var r := {}
	match caso:
		"caminar":
			Input.action_press("mover_arriba")
			await _medir(1.0, func(_t): pass)
			r = await _medir(2.0, func(_t): pass)
		"fases":
			# qué fase de cada clip de paso deja los pies más cerca de la guardia (para frenar sin arrastrarlos)
			heroe.set_physics_process(false)
			heroe.anim.play("guardia")
			heroe.anim.seek(0.0, true)
			await get_tree().process_frame
			await get_tree().process_frame
			var base := _pies.duplicate()
			for clip in ["caminar_armado", "correr_armado", "ual/Walk", "ual/Jog_Fwd"]:
				var fila := []
				var largo := heroe.anim.get_animation(clip).length
				for i in 20:
					heroe.anim.play(clip, 0.0)
					heroe.anim.seek(largo * i / 20.0, true)
					await get_tree().process_frame
					await get_tree().process_frame
					var d := 0.0
					for k in 4:
						var a: Vector3 = _pies[k] - base[k]
						d += Vector2(a.x, a.z).length()
					fila.append("%.2f:%.2f" % [i / 20.0, d])
				print(clip, "  ", " ".join(fila))
			return
		"correr":
			Input.action_press("mover_arriba")
			Input.action_press("correr")
			await _medir(1.0, func(_t): pass)
			r = await _medir(2.0, func(_t): pass)
		"atacar_caminando", "atacar_corriendo":
			Input.action_press("mover_arriba")
			if caso == "atacar_corriendo":
				Input.action_press("correr")
			await _medir(1.2, func(_t): pass)
			var ultimo := [-1.0]
			r = await _medir(2.4, func(t):
				if t - ultimo[0] > 0.45:
					ultimo[0] = t
					await _pulsar("atacar"))
		"atacar_quieto":
			var ultimo := [-1.0]
			r = await _medir(2.4, func(t):
				if t - ultimo[0] > 0.45:
					ultimo[0] = t
					await _pulsar("atacar"))
		"frenar":
			Input.action_press("mover_arriba")
			Input.action_press("correr")
			await _medir(1.5, func(_t): pass)
			_soltar_todo()
			r = await _medir(1.0, func(_t): pass)
		"aterrizar_corriendo":
			Input.action_press("mover_arriba")
			Input.action_press("correr")
			await _medir(1.2, func(_t): pass)
			await _pulsar("saltar")
			while heroe.en_aire or not heroe.is_on_floor():
				await get_tree().physics_frame
			r = await _medir(0.6, func(_t): pass)
	_soltar_todo()
	print("%-20s patina %.2f m/s, %.2f m en total (pie apoyado %.2f s), avance medio %.2f m/s  %s" % [caso, r.patina, r.total, r.apoyado, r.v, r.anims])
