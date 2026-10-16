extends SceneTree
# Mide cuánto avanza cada clip del Universal Animation Library con movimiento de raíz (la versión _RM).
# Se usa una sola vez para anotar las velocidades naturales en Animaciones (el clip sin _RM se queda en el lugar).
# Uso: godot --headless --path . -s herramientas/medir_ual.gd -- "C:/ruta/UAL1_Standard_RM.glb"
func _init() -> void:
	var ruta: String = OS.get_cmdline_user_args()[0]
	var doc := GLTFDocument.new()
	var estado := GLTFState.new()
	var err := doc.append_from_file(ruta, estado)
	if err != OK:
		print("No se pudo leer ", ruta, ": ", error_string(err))
		quit()
		return
	var escena := doc.generate_scene(estado)
	var ap: AnimationPlayer = escena.find_children("*", "AnimationPlayer", true, false)[0]
	for nombre in ap.get_animation_list():
		var a := ap.get_animation(nombre)
		var mejor := Vector3.ZERO
		var hay := false
		for t in a.get_track_count():
			if a.track_get_type(t) != Animation.TYPE_POSITION_3D:
				continue
			var hueso := String(a.track_get_path(t).get_subname(0)) if a.track_get_path(t).get_subname_count() > 0 else ""
			if hueso != "root":
				continue
			var n := a.track_get_key_count(t)
			var d: Vector3 = (a.track_get_key_value(t, n - 1) as Vector3) - (a.track_get_key_value(t, 0) as Vector3)
			mejor = d
			hay = true
		if hay:
			print("RM ", nombre, " dur=", snappedf(a.length, 0.01), " avance=", mejor.snapped(Vector3.ONE * 0.001), " m/s=", snappedf(Vector2(mejor.x, mejor.z).length() / a.length, 0.01), " dy=", snappedf(mejor.y, 0.01))
		else:
			print("RM ", nombre, " dur=", snappedf(a.length, 0.01), " (sin pista root)")
	quit()
