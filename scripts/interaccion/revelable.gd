class_name Revelable
extends Node3D
## Algo que la Lente del Eco puede mostrar: huellas, marcas de ataduras, inscripciones. Solo responde dentro del
## alcance de la lente y cuando `condicion` lo permite; al revelarse muestra sus marcas y llama `al_revelar`.

@export var radio_lente := 9.0
@export var color := LuzRunica.AZUL
@export var permanente := true    ## las marcas quedan visibles después de revelarse

var condicion: Callable = func(): return true
var al_revelar: Callable = func(): pass
var marcas: Array[Node3D] = []
var revelado := false


func _ready() -> void:
	add_to_group("revelable")
	for m in marcas:
		m.visible = revelado


func agregar_marca(m: Node3D) -> void:
	marcas.append(m)
	add_child(m)
	m.visible = revelado


func revelar() -> bool:
	if not condicion.call():
		return false
	revelado = true
	Sonido.tocar("revelar")
	for m in marcas:
		m.visible = true
		var t := create_tween()
		m.scale = Vector3.ONE * 0.2
		t.tween_property(m, "scale", Vector3.ONE, 0.6).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	al_revelar.call()
	if not permanente:
		get_tree().create_timer(8.0).timeout.connect(func():
			for m in marcas:
				m.visible = false)
	return true


## Marca luminosa plana en el piso o en una superficie (huella, runa, señal de atadura).
static func marca(tipo: String, color_marca: Color, tam := 1.0) -> MeshInstance3D:
	var mi := MeshInstance3D.new()
	var q := QuadMesh.new()
	q.size = Vector2(tam, tam)
	q.orientation = PlaneMesh.FACE_Y
	mi.mesh = q
	var m := ShaderMaterial.new()
	m.shader = load("res://assets/sombreadores/marca.gdshader")
	m.set_shader_parameter("color", color_marca)
	m.set_shader_parameter("tipo", {"huella": 0, "runa": 1, "anillo": 2, "rastro": 3}.get(tipo, 0))
	mi.material_override = m
	mi.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	return mi
