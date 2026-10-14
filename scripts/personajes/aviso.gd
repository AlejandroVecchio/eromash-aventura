class_name Aviso
extends MeshInstance3D
## Marca en el piso de un ataque que viene: forma exacta de lo que pega y cuenta regresiva.

enum { CIRCULO, ABANICO, RECTANGULO }

var forma := CIRCULO
var radio := 2.0
var medio_angulo := 0.9        ## abanico, en radianes
var largo := 6.0               ## rectángulo
var ancho := 2.0
var duracion := 1.0
var _t := 0.0
var _mat: ShaderMaterial


func _ready() -> void:
	var q := QuadMesh.new()
	q.orientation = PlaneMesh.FACE_Y
	if forma == RECTANGULO:
		q.size = Vector2(ancho, largo)
		q.center_offset = Vector3(0, 0, largo * 0.5)
	else:
		q.size = Vector2(radio * 2.0, radio * 2.0)
	mesh = q
	_mat = ShaderMaterial.new()
	_mat.shader = load("res://assets/sombreadores/aviso.gdshader")
	_mat.set_shader_parameter("tipo", forma)
	_mat.set_shader_parameter("abanico", medio_angulo)
	material_override = _mat
	cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	position.y += 0.08


func _process(dt: float) -> void:
	_t += dt
	_mat.set_shader_parameter("progreso", clampf(_t / duracion, 0.0, 1.0))


## ¿El punto (en el mundo) cae dentro de la zona marcada?
func contiene(p: Vector3) -> bool:
	var l := global_transform.affine_inverse() * p
	var v := Vector2(l.x, l.z)
	match forma:
		CIRCULO:
			return v.length() <= radio
		ABANICO:
			return v.length() <= radio and absf(atan2(v.x, v.y)) <= medio_angulo
		_:
			return absf(v.x) <= ancho * 0.5 and v.y >= 0.0 and v.y <= largo
