extends SceneTree
## Render de referencia del héroe existente; no crea ni modifica equipo o partidas.

func _initialize() -> void:
	call_deferred("_capturar")


func _capturar() -> void:
	var visor := SubViewport.new()
	visor.size = Vector2i(640, 960)
	visor.transparent_bg = true
	visor.own_world_3d = true
	visor.render_target_update_mode = SubViewport.UPDATE_ALWAYS
	root.add_child(visor)
	var entorno := WorldEnvironment.new()
	entorno.environment = Environment.new()
	entorno.environment.background_mode = Environment.BG_COLOR
	entorno.environment.background_color = Color(0, 0, 0, 0)
	entorno.environment.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	entorno.environment.ambient_light_color = Color("b9c9c7")
	entorno.environment.ambient_light_energy = 0.65
	visor.add_child(entorno)
	var heroe := (load("res://scripts/personajes/heroe.gd") as GDScript).new() as Node3D
	visor.add_child(heroe)
	heroe.process_mode = Node.PROCESS_MODE_DISABLED
	var anim := heroe.get("anim") as AnimationPlayer
	anim.stop()
	heroe.call("_armas", false)
	var esqueleto := heroe.find_children("*", "Skeleton3D", true, false)[0] as Skeleton3D
	esqueleto.reset_bone_poses()
	# Pose de exhibición exclusiva de este render: brazos abiertos unos 40° respecto del torso.
	for lado in ["Left", "Right"]:
		var brazo := esqueleto.find_bone(lado + "UpperArm")
		var codo := esqueleto.find_bone(lado + "LowerArm")
		var reposo := esqueleto.get_bone_global_rest(brazo)
		var direccion := esqueleto.get_bone_global_rest(codo).origin - reposo.origin
		var direccion_mundo := esqueleto.global_basis * direccion
		var destino_mundo := Vector3(signf(direccion_mundo.x) * 0.64, -0.77, 0).normalized()
		var destino := (esqueleto.global_basis.inverse() * destino_mundo).normalized()
		var giro := Quaternion(direccion.normalized(), destino)
		var padre := esqueleto.get_bone_parent(brazo)
		var orientacion_padre := esqueleto.get_bone_global_rest(padre).basis.get_rotation_quaternion()
		esqueleto.set_bone_pose_rotation(brazo,
			orientacion_padre.inverse() * giro * reposo.basis.get_rotation_quaternion())
	var luz := DirectionalLight3D.new()
	luz.rotation_degrees = Vector3(-35, -25, 0)
	luz.light_color = Color("ead8ba")
	luz.light_energy = 1.3
	visor.add_child(luz)
	var relleno := DirectionalLight3D.new()
	relleno.rotation_degrees = Vector3(-15, 140, 0)
	relleno.light_color = Color("73d5db")
	relleno.light_energy = 0.5
	visor.add_child(relleno)
	var camara := Camera3D.new()
	camara.projection = Camera3D.PROJECTION_ORTHOGONAL
	camara.size = 2.15
	visor.add_child(camara)
	camara.position = Vector3(0.12, 1.03, 4)
	camara.look_at(Vector3(0, 0.96, 0))
	camara.current = true
	for i in 8:
		await process_frame
	await RenderingServer.frame_post_draw
	var ruta := "res://docs/referencias/eromash-retrato-interfaz.png"
	var error := visor.get_texture().get_image().save_png(ruta)
	print("RETRATO ", ruta, " resultado=", error)
	if error != OK:
		quit(error)
		return
	# Vistas reales del modelo para el giro de la maqueta HTML, sin dependencias externas.
	var vistas: Array[Image] = []
	var limites := Rect2i()
	for indice in 36:
		heroe.rotation.y = deg_to_rad(indice * 10.0)
		for cuadro in 2:
			await process_frame
		await RenderingServer.frame_post_draw
		var imagen := visor.get_texture().get_image()
		vistas.append(imagen)
		limites = imagen.get_used_rect() if indice == 0 else limites.merge(imagen.get_used_rect())
	var escala := minf(312.0 / limites.size.x, 470.0 / limites.size.y)
	var ancho := roundi(limites.size.x * escala)
	var alto := roundi(limites.size.y * escala)
	var atlas := Image.create_empty(320 * 12, 480 * 3, false, Image.FORMAT_RGBA8)
	for indice in vistas.size():
		var recorte := vistas[indice].get_region(limites)
		recorte.resize(ancho, alto, Image.INTERPOLATE_LANCZOS)
		var destino := Vector2i((indice % 12) * 320 + (320 - ancho) / 2,
			floori(indice / 12.0) * 480 + 480 - alto)
		atlas.blit_rect(recorte, Rect2i(0, 0, ancho, alto), destino)
	error = atlas.save_png("res://docs/referencias/eromash-giro-interfaz.png")
	print("GIRO 36 vistas, pies alineados, resultado=", error)
	quit(error)
