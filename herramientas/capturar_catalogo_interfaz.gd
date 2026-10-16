extends SceneTree
## Miniaturas de modelos existentes para la maqueta, sin alterar assets ni partidas.

func _initialize() -> void:
	call_deferred("_capturar")


func _capturar() -> void:
	var visor := SubViewport.new()
	visor.size = Vector2i(256, 256)
	visor.transparent_bg = true
	visor.own_world_3d = true
	visor.render_target_update_mode = SubViewport.UPDATE_ALWAYS
	root.add_child(visor)
	var mundo := WorldEnvironment.new()
	mundo.environment = Environment.new()
	mundo.environment.background_mode = Environment.BG_COLOR
	mundo.environment.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	mundo.environment.ambient_light_color = Color("d7dfd7")
	mundo.environment.ambient_light_energy = 0.8
	visor.add_child(mundo)
	var luz := DirectionalLight3D.new()
	luz.rotation_degrees = Vector3(-35, -25, 0)
	luz.light_energy = 1.4
	visor.add_child(luz)
	var camara := Camera3D.new()
	camara.projection = Camera3D.PROJECTION_ORTHOGONAL
	visor.add_child(camara)
	camara.current = true
	for nombre in ["pechera", "brazo-armadura", "botas", "capa", "espada", "escudo"]:
		var archivo: String = nombre + "-eromash-base" if nombre != "brazo-armadura" else "brazo-armadura-eromash"
		var modelo := load("res://assets/modelos/personaje/" + archivo + ".glb").instantiate() as Node3D
		visor.add_child(modelo)
		var caja := AABB()
		var primera := true
		for nodo in modelo.find_children("*", "MeshInstance3D", true, false):
			var malla := nodo as MeshInstance3D
			var limite := malla.global_transform * malla.get_aabb()
			caja = limite if primera else caja.merge(limite)
			primera = false
		var centro := caja.get_center()
		var tamano := maxf(caja.size.x, maxf(caja.size.y, caja.size.z))
		camara.size = tamano * 1.35
		camara.position = centro + Vector3(0.28, 0.12, 1.0) * tamano * 3.0
		camara.look_at(centro)
		for i in 3:
			await process_frame
		await RenderingServer.frame_post_draw
		var salida: String = "res://docs/referencias/catalogo-" + nombre + ".png"
		var error := visor.get_texture().get_image().save_png(salida)
		print(salida, " resultado=", error)
		if error != OK:
			quit(error)
			return
		modelo.queue_free()
		await process_frame
	quit()
