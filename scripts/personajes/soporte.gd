class_name Soporte
extends StaticBody3D
## Soporte pétreo del Claro: menhir que sostiene una atadura del Ciervo Hueco. Si el ciervo lo embiste, se rompe
## y la atadura se corta. Vuelve a estar entero si se reinicia el encuentro (antes de vencer al ciervo).

signal roto(soporte: Soporte)

const ENTERO := "res://assets/modelos/escenario/soporte-petreo.glb"
const ROTO := "res://assets/modelos/escenario/soporte-petreo-roto.glb"

var entero := true
var luz: LuzRunica
var _modelo: Node3D
var _roto: Node3D
var _forma: CollisionShape3D


func _ready() -> void:
	add_to_group("soporte")
	_modelo = load(ENTERO).instantiate()
	add_child(_modelo)
	Animaciones.ajustar_altura(_modelo, 3.2)
	_roto = load(ROTO).instantiate()
	add_child(_roto)
	Animaciones.ajustar_altura(_roto, 1.4)
	_roto.visible = false
	_forma = CollisionShape3D.new()
	var c := CylinderShape3D.new()
	c.radius = 0.75
	c.height = 3.2
	_forma.shape = c
	_forma.position.y = 1.6
	add_child(_forma)
	luz = LuzRunica.new()
	luz.color = LuzRunica.VIOLETA
	luz.alcance = 6.0
	luz.energia = 1.6
	luz.motas = 16
	luz.position.y = 1.8
	add_child(luz)
	luz.encender_modelo(_modelo, Color(0.67, 0.53, 0.77), 0.25, 3.0)


func romper() -> void:
	if not entero:
		return
	entero = false
	Sonido.tocar("romper")
	_modelo.visible = false
	_roto.visible = true
	_forma.shape.height = 1.4
	_forma.position.y = 0.7
	luz.fuerza = 0.0
	var destello := OmniLight3D.new()
	destello.light_color = LuzRunica.VIOLETA
	destello.omni_range = 10.0
	destello.light_energy = 6.0
	destello.position.y = 1.5
	add_child(destello)
	var t := create_tween()
	t.tween_property(destello, "light_energy", 0.0, 0.8)
	t.tween_callback(destello.queue_free)
	roto.emit(self)


func reiniciar() -> void:
	entero = true
	_modelo.visible = true
	_roto.visible = false
	_forma.shape.height = 3.2
	_forma.position.y = 1.6
	luz.fuerza = 1.0
