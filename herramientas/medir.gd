extends SceneTree
## Lista, para cada .glb que se le pase, el tamaño (caja), los huesos y las animaciones.
## godot --headless --path . -s herramientas/medir.gd -- res://a.glb res://b.glb
func _init() -> void:
	for ruta in OS.get_cmdline_user_args():
		var escena: Node = load(ruta).instantiate()
		root.add_child(escena)
		var caja := AABB()
		var primera := true
		var tris := 0
		for m in escena.find_children("*", "MeshInstance3D", true, false):
			var mi: MeshInstance3D = m
			var c := mi.global_transform * mi.get_aabb()
			caja = c if primera else caja.merge(c)
			primera = false
			for s in mi.mesh.get_surface_count():
				var arr := mi.mesh.surface_get_arrays(s)
				var idx = arr[Mesh.ARRAY_INDEX]
				tris += (idx.size() if idx != null else arr[Mesh.ARRAY_VERTEX].size()) / 3
		var huesos := 0
		for k in escena.find_children("*", "Skeleton3D", true, false):
			huesos = (k as Skeleton3D).get_bone_count()
		var anims: Array = []
		for a in escena.find_children("*", "AnimationPlayer", true, false):
			for n in (a as AnimationPlayer).get_animation_list():
				anims.append("%s(%.1f)" % [n, (a as AnimationPlayer).get_animation(n).length])
		print("%s | tam=%s pos=%s | tris=%d | huesos=%d | anims=%s" % [ruta.get_file(), caja.size, caja.position, tris, huesos, anims])
		escena.free()
	quit()
