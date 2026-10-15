class_name Activador
extends Node
## Despierta lo que está cerca de Eromash y duerme lo que está lejos: NPC, enemigos, el Ciervo, las zarzas y las
## luces rúnicas. Dormido no piensa, no se anima y no suelta partículas; así se puede llenar el bosque de cosas
## sin que el juego vaya más lento. La distancia sale de Opciones → Video ("Distancia de entidades" y, para las
## luces, "Distancia de luces"). Va con un margen para que algo en el borde no se prenda y apague todo el tiempo.

const CADA := 0.2      ## segundos entre revisiones
const MARGEN := 6.0    ## m de más para volver a dormirse

var _t := 0.0
var _despiertos := {}  ## nodo → bool


func _ready() -> void:
	add_to_group("activador")


func _process(dt: float) -> void:
	_t += dt
	if _t < CADA:
		return
	_t = 0.0
	var heroe := get_tree().get_first_node_in_group("heroe") as Node3D
	if heroe == null:
		return
	var h := heroe.global_position
	var r_ent := Calidad.radio_entidades()
	var r_luz := Calidad.distancia_luces()
	for n in get_tree().get_nodes_in_group("despertable"):
		var nodo := n as Node3D
		if nodo == null or not nodo.is_inside_tree():
			continue
		var r := r_luz if nodo is LuzRunica else r_ent
		var d := nodo.global_position.distance_to(h)
		var antes: bool = _despiertos.get(nodo, true)
		var ahora := d < (r + MARGEN if antes else r)
		if nodo.has_method("seguir_despierto") and nodo.seguir_despierto():
			ahora = true
		if ahora == antes and _despiertos.has(nodo):
			continue
		_despiertos[nodo] = ahora
		if nodo.has_method("cercania"):
			nodo.cercania(ahora)
		else:
			despertar_generico(nodo, ahora)


## Para personajes: sin proceso ni animación mientras duermen (siguen visibles, quietos en su lugar).
static func despertar_generico(nodo: Node, cerca: bool) -> void:
	nodo.set_process(cerca)
	nodo.set_physics_process(cerca)
	for ap in nodo.find_children("*", "AnimationPlayer", true, false):
		(ap as AnimationPlayer).active = cerca


## Cuántos están despiertos ahora (para el contador de F3).
func despiertos() -> int:
	var n := 0
	for k in _despiertos:
		if is_instance_valid(k) and _despiertos[k]:
			n += 1
	return n
