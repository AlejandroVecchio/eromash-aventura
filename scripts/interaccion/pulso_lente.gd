class_name PulsoLente
extends Node3D
## La onda de la Lente del Eco: un anillo de luz azul rúnica que se abre y se apaga, y un destello en el aire.

const DURACION := 1.1
const RADIO := 10.0

var _t := 0.0
var _anillo: MeshInstance3D
var _mat: StandardMaterial3D
var _luz: OmniLight3D


func _ready() -> void:
	_anillo = MeshInstance3D.new()
	var t := TorusMesh.new()
	t.inner_radius = 0.92
	t.outer_radius = 1.0
	t.rings = 48
	t.ring_segments = 6
	_anillo.mesh = t
	_mat = StandardMaterial3D.new()
	_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	_mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	_mat.albedo_color = Color(LuzRunica.AZUL, 0.8)
	_mat.emission_enabled = true
	_mat.emission = LuzRunica.AZUL
	_mat.emission_energy_multiplier = 4.0
	_anillo.material_override = _mat
	_anillo.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	add_child(_anillo)
	_luz = OmniLight3D.new()
	_luz.light_color = LuzRunica.AZUL
	_luz.omni_range = 8.0
	_luz.light_energy = 3.0
	add_child(_luz)


func _process(dt: float) -> void:
	_t += dt
	var f := clampf(_t / DURACION, 0.0, 1.0)
	var r := lerpf(0.5, RADIO, 1.0 - pow(1.0 - f, 3.0))
	_anillo.scale = Vector3(r, 1.0, r)
	_anillo.position.y = -0.9
	_mat.albedo_color.a = 0.8 * (1.0 - f)
	_luz.light_energy = 3.0 * (1.0 - f)
	if f >= 1.0:
		queue_free()
