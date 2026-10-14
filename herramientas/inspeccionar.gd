extends SceneTree
# Muestra la estructura de un GLB: nodos, huesos y animaciones. Uso:
# godot --headless --path . -s herramientas/inspeccionar.gd -- res://assets/modelos/personaje/eromash-completo.glb
func _init():
	var ruta = OS.get_cmdline_user_args()[0]
	var escena = load(ruta).instantiate()
	_listar(escena, 0)
	for n in escena.find_children("*", "Skeleton3D", true, false):
		var sk: Skeleton3D = n
		print("ESQUELETO ", sk.name, " huesos=", sk.get_bone_count())
		var nombres = []
		for i in sk.get_bone_count(): nombres.append(sk.get_bone_name(i))
		print("  ", ", ".join(nombres))
	for n in escena.find_children("*", "AnimationPlayer", true, false):
		var ap: AnimationPlayer = n
		for a in ap.get_animation_list():
			var an = ap.get_animation(a)
			print("ANIM ", a, " dur=", snapped(an.length, 0.01), " pistas=", an.get_track_count())
		var w = ap.get_animation(ap.get_animation_list()[0])
		for t in min(6, w.get_track_count()):
			print("   pista ", w.track_get_path(t), " tipo=", w.track_get_type(t))
	for n in escena.find_children("*", "MeshInstance3D", true, false):
		var m: MeshInstance3D = n
		print("MALLA ", m.name, " aabb=", m.get_aabb(), " skin=", m.skin != null)
	quit()

func _listar(n, d):
	if d < 4: print("  ".repeat(d), n.name, " (", n.get_class(), ")")
	for c in n.get_children(): _listar(c, d + 1)
