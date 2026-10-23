class_name RuedaAgua
extends Node3D
## Rueda de agua del aserradero (modelos de Tripo): la rueda gira sobre el eje de su soporte y la canaleta llega
## desde río arriba y vuelca sobre ella. El origen del nodo es el centro del eje; su -Z apunta río arriba.
## Duerme lejos de Eromash (grupo `despertable`): sin proceso no gira.

const DIAMETRO := 5.0     ## m de la rueda
const SOPORTE := 8.5      ## escala del soporte: deja entre los caballetes lugar para el cubo de la rueda
const VUELTAS := 0.6      ## radianes por segundo

## Medidas del modelo del soporte (en sus unidades): centro del eje y la franja de la canaleta.
const EJE := Vector3(0.0, 0.358, 0.356)
const CANAL_X := 0.1      ## la canaleta y sus patas van por el medio; los caballetes, más afuera
const CANAL_PIE := 0.1    ## donde apoyan las patas de la canaleta
const CANAL_BASE := 0.37  ## de acá para arriba es la canaleta (el eje queda justo debajo)
const RUEDA_CENTRO := 0.4805  ## alto del eje en el modelo de la rueda (que gira sobre su Z)

var _giro: Node3D


func _init() -> void:
	var escala_rueda := DIAMETRO / (RUEDA_CENTRO * 2.0)
	var soporte: Node3D = load("res://assets/modelos/escenario/soporte-canaleta.glb").instantiate()
	add_child(soporte)
	soporte.scale = Vector3.ONE * SOPORTE
	soporte.position = -EJE * SOPORTE
	# la canaleta del modelo pasa casi a la altura del eje: se sube hasta que la rueda quepa debajo
	var radio := RUEDA_CENTRO * escala_rueda / SOPORTE
	var subir := EJE.y + radio + 0.025 - 0.385
	for mi in soporte.find_children("*", "MeshInstance3D", true, false):
		_subir_canaleta(mi as MeshInstance3D, subir)
	_giro = Node3D.new()
	_giro.name = "Giro"
	add_child(_giro)
	var rueda: Node3D = load("res://assets/modelos/escenario/rueda-aserradero.glb").instantiate()
	_giro.add_child(rueda)
	rueda.scale = Vector3.ONE * escala_rueda
	rueda.rotation.y = PI * 0.5   # su eje pasa a ser el X, como el del soporte
	rueda.position = Vector3(0, -RUEDA_CENTRO * escala_rueda, 0)


func _ready() -> void:
	add_to_group("despertable")


func _process(dt: float) -> void:
	# el agua cae arriba desde la canaleta (-Z) y empuja la parte de arriba hacia +Z
	_giro.rotation.x += dt * VUELTAS


## Sube la canaleta `alto` (en unidades del modelo) y estira sus patas para que sigan llegando al piso.
func _subir_canaleta(mi: MeshInstance3D, alto: float) -> void:
	var malla := ArrayMesh.new()
	for s in mi.mesh.get_surface_count():
		var a := mi.mesh.surface_get_arrays(s)
		var v: PackedVector3Array = a[Mesh.ARRAY_VERTEX]
		var estirar := (CANAL_BASE + alto - CANAL_PIE) / (CANAL_BASE - CANAL_PIE)
		for i in v.size():
			var p := v[i]
			if absf(p.x) >= CANAL_X or p.y < CANAL_PIE:
				continue
			if p.y >= CANAL_BASE:
				v[i].y = p.y + alto
			elif p.z < EJE.z - 0.02:
				v[i].y = CANAL_PIE + (p.y - CANAL_PIE) * estirar
		a[Mesh.ARRAY_VERTEX] = v
		malla.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, a)
		malla.surface_set_material(s, mi.mesh.surface_get_material(s))
	mi.mesh = malla
