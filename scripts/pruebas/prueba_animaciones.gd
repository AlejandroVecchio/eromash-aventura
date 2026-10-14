extends Node3D
## Prueba: el héroe y los modelos humanos con la misma animación.

const MODELOS := [
	["res://assets/modelos/personaje/eromash-completo.glb", 1.85],
	["res://assets/modelos/npc/eydis.glb", 1.72],
	["res://assets/modelos/npc/orm.glb", 1.78],
	["res://assets/modelos/npc/svanhild.glb", 1.82],
	["res://assets/modelos/npc/trabajador.glb", 1.75],
	["res://assets/modelos/enemigos/errante-helheim.glb", 2.05],
]
@export var animacion := "caminar"
@export var momento := 0.5

func _ready() -> void:
	var anim := OS.get_environment("ANIM")
	if anim != "":
		animacion = anim
	var x := -5.0
	for d in MODELOS:
		var m: Node3D = load(d[0]).instantiate()
		add_child(m)
		m.position.x = x
		x += 2.0
		var ap := Animaciones.reproductor(m)
		if OS.get_environment("SINANIM") == "":
			Animaciones.dar_animaciones(ap)
		Animaciones.ajustar_altura(m, d[1])
		if ap.has_animation(animacion):
			ap.play(animacion)
		ap.seek(momento, true)
		ap.pause()
	var cam := Camera3D.new()
	add_child(cam)
	cam.position = Vector3(0, 1.4, 6.5)
	cam.fov = 40
	cam.look_at(Vector3(0, 1.0, 0))
	var luz := DirectionalLight3D.new()
	add_child(luz)
	luz.rotation_degrees = Vector3(-40, 30, 0)
	var env := WorldEnvironment.new()
	var e := Environment.new()
	e.background_mode = Environment.BG_COLOR
	e.background_color = Color(0.5, 0.55, 0.6)
	e.ambient_light_color = Color.WHITE
	e.ambient_light_energy = 0.6
	env.environment = e
	add_child(env)
