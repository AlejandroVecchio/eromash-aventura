class_name Zarzas
extends Node3D
## Zarzas espectrales que cierran la puerta del Santuario de las Raíces. Se mecen, ondulan si se las ataca o se
## las toca, y no se abren (en el MVP no hay forma de pasar: hace falta el fuego fatuo).

var _materiales: Array[ShaderMaterial] = []
var _onda := 0.0


func _ready() -> void:
	add_to_group("enemigo")  # recibe los golpes de Eromash para reaccionar (no tiene vida)
	var rng := RandomNumberGenerator.new()
	rng.seed = 77
	for i in 26:
		var mi := MeshInstance3D.new()
		var c := CylinderMesh.new()
		var alto := rng.randf_range(1.6, 3.2)
		c.top_radius = 0.01
		c.bottom_radius = rng.randf_range(0.04, 0.09)
		c.height = alto
		c.rings = 10
		c.radial_segments = 5
		mi.mesh = c
		var m := ShaderMaterial.new()
		m.shader = load("res://assets/sombreadores/zarza.gdshader")
		m.set_shader_parameter("fase", rng.randf() * TAU)
		mi.material_override = m
		_materiales.append(m)
		mi.position = Vector3(rng.randf_range(-2.4, 2.4), alto * 0.5 - 0.1, rng.randf_range(-0.5, 0.5))
		mi.rotation = Vector3(rng.randf_range(-0.5, 0.5), rng.randf() * TAU, rng.randf_range(-0.6, 0.6))
		add_child(mi)
	var luz := OmniLight3D.new()
	luz.light_color = LuzRunica.VIOLETA
	luz.omni_range = 5.0
	luz.light_energy = 1.0
	luz.position.y = 1.2
	add_child(luz)


var radio := 2.5


func recibir_golpe(_dano: float, _origen: Vector3) -> void:
	ondular()


func ondular() -> void:
	_onda = 1.0


func _process(dt: float) -> void:
	if _onda > 0.0:
		_onda = maxf(0.0, _onda - dt * 0.8)
		for m in _materiales:
			m.set_shader_parameter("onda", _onda)
