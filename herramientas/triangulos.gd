extends SceneTree
## Cuenta triángulos de cada modelo de assets/modelos (para controlar los topes de rendimiento).
## Uso: godot --headless --path . -s herramientas/triangulos.gd
func _init() -> void:
	var filas: Array = []
	for carpeta in ["res://assets/modelos/escenario/", "res://assets/modelos/objetos/", "res://assets/modelos/npc/", "res://assets/modelos/enemigos/", "res://assets/modelos/armas/", "res://assets/modelos/personaje/", "res://assets/modelos/kit/naturaleza/", "res://assets/modelos/kit/aldea/", "res://assets/modelos/kit/objetos/"]:
		for f in DirAccess.get_files_at(carpeta):
			if not (f.ends_with(".glb") or f.ends_with(".gltf")):
				continue
			var e: Node = load(carpeta + f).instantiate()
			var t := 0
			for mi in e.find_children("*", "MeshInstance3D", true, false):
				var m: Mesh = (mi as MeshInstance3D).mesh
				if m:
					for s in m.get_surface_count():
						var a := m.surface_get_arrays(s)
						var idx: PackedInt32Array = a[Mesh.ARRAY_INDEX]
						t += idx.size() / 3 if idx.size() > 0 else (a[Mesh.ARRAY_VERTEX] as PackedVector3Array).size() / 3
			filas.append([t, carpeta.trim_prefix("res://assets/modelos/") + f])
			e.free()
	filas.sort_custom(func(x, y): return x[0] > y[0])
	for r in filas:
		print("TRI %7d  %s" % r)
	quit()
