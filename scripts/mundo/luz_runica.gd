class_name LuzRunica
extends Node3D
## La luz que emana de una runa: luz local que ilumina el suelo y lo que hay cerca, late despacio, suelta motas
## que suben y se aviva cuando Eromash se acerca. `fuerza`: 0 apagada, 1 viva. Lo caro baja con la calidad.

const AZUL := Color(0.45, 0.84, 0.86)
const VIOLETA := Color(0.67, 0.53, 0.77)
const AMBAR := Color(0.91, 0.72, 0.4)

@export var color := AZUL
@export var alcance := 7.0
@export var energia := 2.2
@export var fuerza := 1.0:
	set(v):
		fuerza = v
		_aplicar()
@export var motas := 24

var luz: OmniLight3D
var particulas: GPUParticles3D
var materiales: Array[ShaderMaterial] = []   ## materiales rúnicos de la malla, para avivarlos junto con la luz
var _avivar := 0.0
var _fase := randf() * TAU


func _ready() -> void:
	luz = OmniLight3D.new()
	# Sobre el musgo verde el cian de la runa se ve verde: la luz que cae al piso va un poco más azul.
	luz.light_color = Color(0.32, 0.66, 1.0) if color.is_equal_approx(AZUL) else color
	luz.omni_range = alcance
	luz.omni_attenuation = 1.4
	luz.shadow_enabled = false
	luz.light_specular = 0.3
	add_child(luz)
	if motas > 0:
		_crear_motas()
	Calidad.cambio.connect(_aplicar)
	_aplicar()


func _crear_motas() -> void:
	particulas = GPUParticles3D.new()
	particulas.amount = Calidad.cuantas(motas)
	particulas.lifetime = 3.5
	particulas.preprocess = 3.0
	particulas.visibility_aabb = AABB(Vector3(-3, -1, -3), Vector3(6, 7, 6))
	var pm := ParticleProcessMaterial.new()
	pm.emission_shape = ParticleProcessMaterial.EMISSION_SHAPE_SPHERE
	pm.emission_sphere_radius = 0.9
	pm.direction = Vector3.UP
	pm.spread = 25.0
	pm.initial_velocity_min = 0.25
	pm.initial_velocity_max = 0.6
	pm.gravity = Vector3(0, 0.05, 0)
	pm.scale_min = 0.5
	pm.scale_max = 1.0
	var curva := CurveTexture.new()
	var c := Curve.new()
	c.add_point(Vector2(0, 0))
	c.add_point(Vector2(0.2, 1))
	c.add_point(Vector2(1, 0))
	curva.curve = c
	pm.scale_curve = curva
	particulas.process_material = pm
	var q := QuadMesh.new()
	q.size = Vector2(0.07, 0.07)
	var m := StandardMaterial3D.new()
	m.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	m.billboard_mode = BaseMaterial3D.BILLBOARD_ENABLED
	m.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	m.albedo_color = Color(color, 0.9)
	m.emission_enabled = true
	m.emission = color
	m.emission_energy_multiplier = 3.0
	q.material = m
	particulas.draw_pass_1 = q
	add_child(particulas)


func _aplicar() -> void:
	if luz == null:
		return
	luz.visible = fuerza > 0.01
	if particulas:
		particulas.emitting = fuerza > 0.3 and Calidad.nivel >= Calidad.MEDIA
		particulas.amount = maxi(1, Calidad.cuantas(motas))
	for m in materiales:
		m.set_shader_parameter("fuerza", fuerza)


func _process(dt: float) -> void:
	if luz == null or fuerza <= 0.01:
		return
	var heroe := get_tree().get_first_node_in_group("heroe") as Node3D
	var objetivo := 0.0
	if heroe:
		objetivo = clampf(1.0 - (heroe.global_position.distance_to(global_position) - 2.0) / 6.0, 0.0, 1.0)
	_avivar = lerpf(_avivar, objetivo, 1.0 - exp(-3.0 * dt))
	_fase += dt
	var pulso := 0.85 + 0.15 * sin(_fase * 1.6)
	luz.light_energy = energia * fuerza * (pulso + _avivar * 0.6)
	for m in materiales:
		m.set_shader_parameter("avivar", _avivar)


## Cambia los materiales de `modelo` por el material rúnico, conservando su textura, y los liga a esta luz.
func encender_modelo(modelo: Node, color_pintado := Color(-1, 0, 0), tolerancia := 0.22, energia_malla := 4.0) -> void:
	var c := color if color_pintado.r < 0.0 else color_pintado
	for n in modelo.find_children("*", "MeshInstance3D", true, false):
		var mi: MeshInstance3D = n
		for s in mi.mesh.get_surface_count():
			var base := mi.get_active_material(s) as BaseMaterial3D
			if base == null:
				continue
			var sm := ShaderMaterial.new()
			sm.shader = load("res://assets/sombreadores/runico.gdshader")
			sm.set_shader_parameter("textura", base.albedo_texture)
			if base.normal_enabled and base.normal_texture:
				sm.set_shader_parameter("normal_tex", base.normal_texture)
				sm.set_shader_parameter("usa_normal", true)
			sm.set_shader_parameter("color_runa", Vector3(c.r, c.g, c.b))
			sm.set_shader_parameter("color_luz", Vector3(color.r, color.g, color.b))
			sm.set_shader_parameter("tolerancia", tolerancia)
			sm.set_shader_parameter("energia", energia_malla)
			sm.set_shader_parameter("fuerza", fuerza)
			mi.set_surface_override_material(s, sm)
			materiales.append(sm)
