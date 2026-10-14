extends Node3D
## Prueba: el suelo, el agua y el bosque desde arriba (para comparar con el mapa).

func _ready() -> void:
	var t0 := Time.get_ticks_msec()
	var terreno := Terreno.new()
	add_child(terreno)
	terreno.armar()
	print("terreno ms ", Time.get_ticks_msec() - t0)
	var agua := Agua.new()
	add_child(agua)
	agua.armar(terreno)
	var veg := Vegetacion.new()
	add_child(veg)
	veg.armar(terreno)
	print("vegetacion ms ", Time.get_ticks_msec() - t0)
	var cam := Camera3D.new()
	add_child(cam)
	var vista := OS.get_environment("VISTA")
	if vista == "cerca":
		var p := Datos.m(830, 560)
		cam.position = Vector3(p.x, 30, p.y + 25)
		cam.look_at(Vector3(p.x, 0, p.y))
	else:
		cam.projection = Camera3D.PROJECTION_ORTHOGONAL
		cam.size = 340
		cam.position = Vector3(0, 200, 0.01)
		cam.look_at(Vector3.ZERO)
	var luz := DirectionalLight3D.new()
	luz.rotation_degrees = Vector3(-55, 30, 0)
	luz.shadow_enabled = true
	add_child(luz)
	var env := WorldEnvironment.new()
	var e := Environment.new()
	e.background_mode = Environment.BG_COLOR
	e.background_color = Color(0.3, 0.35, 0.38)
	e.ambient_light_color = Color(0.6, 0.7, 0.7)
	e.ambient_light_energy = 0.6
	env.environment = e
	add_child(env)
