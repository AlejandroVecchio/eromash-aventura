extends Node3D
## Laboratorio aislado. No cambia el inventario ni la escena principal.
const HEROE_PRUEBA = preload("res://scripts/pruebas/heroe_equipo.gd")
var heroe: Heroe
var camara: Camara
var casillas: Dictionary = {}

func _ready() -> void:
	TranslationServer.add_translation(load("res://textos/prueba_equipo.es.translation"))
	TranslationServer.add_translation(load("res://textos/prueba_equipo.en.translation"))
	var ambiente := WorldEnvironment.new()
	var env := Environment.new()
	env.background_mode = Environment.BG_COLOR
	env.background_color = Color("202a33")
	env.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	env.ambient_light_color = Color("d4e2ef")
	env.ambient_light_energy = 0.7
	current_environment(ambiente, env)
	var luz := DirectionalLight3D.new()
	luz.rotation_degrees = Vector3(-45, -35, 0)
	luz.light_energy = 1.5
	luz.shadow_enabled = false
	add_child(luz)
	var suelo := StaticBody3D.new()
	suelo.collision_layer = 1 | 8
	add_child(suelo)
	var forma := CollisionShape3D.new()
	var caja := BoxShape3D.new()
	caja.size = Vector3(30, 0.2, 30)
	forma.shape = caja
	forma.position.y = -0.1
	suelo.add_child(forma)
	for x in range(-7, 8):
		for z in range(-7, 8):
			var m := MeshInstance3D.new()
			var plano := PlaneMesh.new()
			plano.size = Vector2(2, 2)
			m.mesh = plano
			m.position = Vector3(x * 2, 0, z * 2)
			m.visibility_range_end = 60
			var mat := StandardMaterial3D.new()
			mat.albedo_color = Color("424d53") if (x + z) % 2 == 0 else Color("38434a")
			mat.roughness = 1.0
			m.material_override = mat
			add_child(m)
	heroe = HEROE_PRUEBA.new()
	heroe.name = "HeroePrueba"
	add_child(heroe)
	camara = Camara.new()
	camara.objetivo = heroe
	camara.zoom = -0.4
	camara.zoom_obj = -0.4
	camara.giro = 0.0
	camara.giro_obj = 0.0
	heroe.camara = camara
	add_child(camara)
	_panel()
	print("PRUEBA_EQUIPO_LISTA piezas=", heroe.piezas.size())
	if OS.get_cmdline_user_args().has("verificar_equipo"):
		_verificar.call_deferred()
	if OS.get_cmdline_user_args().has("capturar_equipo"):
		_capturar.call_deferred()

func current_environment(nodo: WorldEnvironment, env: Environment) -> void:
	nodo.environment = env
	add_child(nodo)

func _physics_process(_dt: float) -> void:
	if heroe and (absf(heroe.position.x) > 14 or absf(heroe.position.z) > 14 or heroe.position.y < -3):
		heroe.position = Vector3.ZERO
		heroe.velocity = Vector3.ZERO

func _panel() -> void:
	var lienzo := CanvasLayer.new()
	add_child(lienzo)
	var panel := PanelContainer.new()
	panel.position = Vector2(18, 18)
	panel.custom_minimum_size.x = 285
	lienzo.add_child(panel)
	var estilo := StyleBoxFlat.new()
	estilo.bg_color = Color(0.035, 0.06, 0.075, 0.96)
	estilo.border_color = Color("73d5db")
	estilo.set_border_width_all(1)
	estilo.set_content_margin_all(16)
	panel.add_theme_stylebox_override("panel", estilo)
	var fila := VBoxContainer.new()
	fila.add_theme_constant_override("separation", 6)
	panel.add_child(fila)
	var titulo := Label.new()
	titulo.text = tr("pe_titulo")
	titulo.add_theme_font_size_override("font_size", 22)
	fila.add_child(titulo)
	var casco := Label.new()
	casco.text = tr("pe_casco")
	fila.add_child(casco)
	for clave in heroe.equipado:
		var c := CheckBox.new()
		c.text = tr("pe_" + clave)
		c.button_pressed = true
		c.focus_mode = Control.FOCUS_NONE
		c.toggled.connect(func(activo: bool): heroe.cambiar_equipo(clave, activo))
		fila.add_child(c)
		casillas[clave] = c
	for activo in [true, false]:
		var b := Button.new()
		b.text = tr("pe_todo" if activo else "pe_nada")
		b.focus_mode = Control.FOCUS_NONE
		b.pressed.connect(func():
			for c in casillas.values(): c.button_pressed = activo)
		fila.add_child(b)
	var contraste := CheckBox.new()
	contraste.text = tr("pe_contraste")
	contraste.focus_mode = Control.FOCUS_NONE
	contraste.toggled.connect(heroe.contraste)
	fila.add_child(contraste)
	var ayuda := Label.new()
	ayuda.text = tr("pe_ayuda")
	ayuda.add_theme_font_size_override("font_size", 13)
	fila.add_child(ayuda)

func _verificar() -> void:
	await get_tree().process_frame
	await get_tree().process_frame
	assert(heroe.modelo.find_children("*", "Skeleton3D", true, false).size() == 1)
	for clave in heroe.equipado:
		heroe.cambiar_equipo(clave, false)
	assert(heroe.piezas.base_manos.visible and not heroe.piezas.pieza_guantes.visible)
	assert(heroe.piezas.base_torso.visible and not heroe.piezas.pieza_pechera.visible)
	for clave in heroe.equipado:
		heroe.cambiar_equipo(clave, true)
	assert(not heroe.piezas.base_manos.visible and heroe.piezas.pieza_guantes.visible)
	var esqueleto: Skeleton3D = heroe.modelo.find_children("*", "Skeleton3D", true, false)[0]
	assert(esqueleto.find_bone("Capa_Raiz") >= 0)
	for m in heroe.piezas.values():
		assert(m.get_node(m.skeleton) == esqueleto)
		for i in m.skin.get_bind_count():
			assert(esqueleto.find_bone(m.skin.get_bind_name(i)) >= 0)
	var inicio := heroe.position
	Input.action_press("mover_arriba")
	Input.action_press("correr")
	for i in 30: await get_tree().physics_frame
	Input.action_release("mover_arriba")
	Input.action_release("correr")
	assert(heroe.position.distance_to(inicio) > 0.3)
	print("PRUEBA_EQUIPO_OK esqueleto unico, bindings, capa, alternancia y movimiento")
	get_tree().quit()

func _capturar() -> void:
	await get_tree().create_timer(2.0).timeout
	heroe.bloqueado = true
	DirAccess.make_dir_recursive_absolute("res://docs/referencias/prueba_equipo")
	for estado in [true, false]:
		for clave in heroe.equipado: heroe.cambiar_equipo(clave, estado)
		for c in casillas.values(): c.set_pressed_no_signal(estado)
		await get_tree().process_frame
		await RenderingServer.frame_post_draw
		get_viewport().get_texture().get_image().save_png("res://docs/referencias/prueba_equipo/" + ("equipado.png" if estado else "base.png"))
	for clave in heroe.equipado: heroe.cambiar_equipo(clave, true)
	for c in casillas.values(): c.set_pressed_no_signal(true)
	camara.giro_obj = PI
	await get_tree().create_timer(0.3).timeout
	await RenderingServer.frame_post_draw
	get_viewport().get_texture().get_image().save_png("res://docs/referencias/prueba_equipo/capa.png")
	print("CAPTURAS_EQUIPO_LISTAS")
	get_tree().quit()
