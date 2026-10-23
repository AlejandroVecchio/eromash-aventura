extends SceneTree
# Visor de animaciones: pone clips (del héroe o del pack UAL) sobre un modelo humano y saca una tira por clip,
# con cuadros repartidos a lo largo del clip, de frente (fila 1) y de costado (fila 2).
# Necesita pantalla (no --headless). Uso:
#   godot --path . --resolution 540x720 -s herramientas/ver_animaciones.gd -- SALIDA_DIR clip1,clip2 [cuadros=6] [modelo=heroe|npc]
# Los clips del pack UAL se piden como ual/Nombre (ej. ual/Walk); los del héroe, por su nombre (ej. caminar).
const MODELO_HEROE := "res://assets/modelos/personaje/eromash-completo.glb"
const MODELO_NPC := "res://assets/modelos/npc/eydis.glb"
const UAL := "res://assets/modelos/animaciones/ual/UAL1_Standard.glb"


func _initialize() -> void:
	_correr.call_deferred()


func _correr() -> void:
	var a := OS.get_cmdline_user_args()
	var salida: String = a[0]
	var clips := String(a[1]).split(",")
	var n := int(a[2]) if a.size() > 2 else 6
	var cual: String = a[3] if a.size() > 3 else "heroe"
	DirAccess.make_dir_recursive_absolute(salida)

	var mundo := Node3D.new()
	root.add_child(mundo)
	var luz := DirectionalLight3D.new()
	luz.rotation_degrees = Vector3(-50, -30, 0)
	luz.light_energy = 1.4
	mundo.add_child(luz)
	var amb := WorldEnvironment.new()
	var env := Environment.new()
	env.background_mode = Environment.BG_COLOR
	env.background_color = Color(0.25, 0.28, 0.3)
	env.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	env.ambient_light_color = Color(0.7, 0.72, 0.75)
	env.ambient_light_energy = 0.8
	amb.environment = env
	mundo.add_child(amb)
	var suelo := MeshInstance3D.new()
	var plano := PlaneMesh.new()
	plano.size = Vector2(6, 6)
	suelo.mesh = plano
	mundo.add_child(suelo)

	var ruta_modelo := UAL if cual == "ual" else (MODELO_HEROE if cual == "heroe" else (cual if cual.ends_with(".glb") else MODELO_NPC))
	var modelo: Node3D = load(ruta_modelo).instantiate()
	mundo.add_child(modelo)
	Animaciones.mirar_adelante(modelo)
	Animaciones.ajustar_altura(modelo, 1.85 if cual == "heroe" else 1.75)
	if cual == "heroe" and not OS.get_cmdline_user_args().has("armado"):
		for t in ["espada", "escudo"]:
			var m := modelo.find_child(t, true, false) as Node3D
			if m:
				m.visible = false
	var ap := Animaciones.reproductor(modelo)
	if cual != "ual":
		Animaciones.dar_animaciones(ap)
		if cual == "heroe" and OS.get_cmdline_user_args().has("juego"):
			Animaciones.preparar_heroe(ap, modelo)   # igual que Heroe._cargar_modelo
	var ual: Node = load(UAL).instantiate()
	var ap_ual: AnimationPlayer = ual.find_children("*", "AnimationPlayer", true, false)[0]
	var bib := AnimationLibrary.new()
	var esq_ual: Skeleton3D = ual.find_children("*", "Skeleton3D", true, false)[0]
	var esq_destino: Skeleton3D = modelo.find_children("*", "Skeleton3D", true, false)[0]
	var retarget := Retarget.crear(esq_ual, esq_destino) if cual != "ual" else null
	var directo := cual == "ual" or OS.get_cmdline_user_args().has("directo")   # sin corregir, para comparar
	for nombre in ap_ual.get_animation_list():
		var clip_ual := ap_ual.get_animation(nombre)
		bib.add_animation(nombre, clip_ual if directo else retarget.convertir(clip_ual))
	for v in Animaciones.UAL_VARIANTES:
		bib.add_animation(v, retarget.convertir(ap_ual.get_animation(Animaciones.UAL_VARIANTES[v][0]), Animaciones.UAL_VARIANTES[v][1])) if retarget else null
	ap.add_animation_library("ual", bib)
	if cual == "heroe":
		ap.add_animation_library("meshy", Animaciones.biblioteca_meshy(modelo))

	var cam := Camera3D.new()
	cam.fov = 38
	mundo.add_child(cam)
	cam.make_current()

	for clip in clips:
		if not ap.has_animation(clip):
			print("NO EXISTE ", clip)
			continue
		var anim := ap.get_animation(clip)
		var celdas := []
		for lado in 2:
			if lado == 0:
				cam.position = Vector3(0, 1.0, 3.6)
				cam.rotation_degrees = Vector3(-2, 0, 0)
			else:
				cam.position = Vector3(3.6, 1.0, 0)
				cam.rotation_degrees = Vector3(-2, 90, 0)
			for i in n:
				ap.play(clip)
				ap.seek(anim.length * float(i) / float(n), true)
				ap.pause()
				await process_frame
				await process_frame
				celdas.append(root.get_texture().get_image())
		var w: int = celdas[0].get_width() / 2
		var h: int = celdas[0].get_height()
		var hoja := Image.create(w * n, h * 2, false, Image.FORMAT_RGBA8)
		for i in celdas.size():
			var im: Image = celdas[i]
			im.convert(Image.FORMAT_RGBA8)
			hoja.blit_rect(im, Rect2i(w / 2, 0, w, h), Vector2i((i % n) * w, (i / n) * h))
		hoja.resize(hoja.get_width() / 2, hoja.get_height() / 2, Image.INTERPOLATE_BILINEAR)
		var ruta := "%s/%s.png" % [salida, clip.replace("/", "_")]
		hoja.save_png(ruta)
		print("TIRA ", ruta, " dur=", snappedf(anim.length, 0.01))
	quit()
