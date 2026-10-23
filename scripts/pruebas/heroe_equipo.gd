extends Heroe
## El banco usa el controlador y el único esqueleto del héroe original.
const MODULAR := "res://assets/modelos/personaje/prueba_equipo/eromash_modular.glb"
var piezas: Dictionary = {}
var equipado: Dictionary = {"pechera": true, "cinturon": true, "hombros": true, "brazales": true, "guantes": true, "piernas": true, "botas": true, "capa": true, "espada": true, "escudo": true}

func _physics_process(dt: float) -> void:
	var bloqueo_previo := bloqueado
	if get_viewport().gui_get_hovered_control() != null and Input.is_action_pressed("atacar"):
		bloqueado = true
	super._physics_process(dt)
	bloqueado = bloqueo_previo
	for clave in ["espada", "escudo"]:
		if not equipado[clave]:
			for nombre in [clave, clave + "_guardada", clave + "_guardado"]:
				if _mallas.has(nombre): _mallas[nombre].hide()

func _cargar_modelo() -> void:
	super._cargar_modelo()
	var destino: Skeleton3D = modelo.find_children("*", "Skeleton3D", true, false)[0]
	var paquete: Node3D = load(MODULAR).instantiate()
	add_child(paquete)
	paquete.transform = modelo.transform
	var origen: Skeleton3D = paquete.find_children("*", "Skeleton3D", true, false)[0]
	# Añadir los huesos auxiliares de la capa al único esqueleto activo.
	for i in origen.get_bone_count():
		var nombre := origen.get_bone_name(i)
		if destino.find_bone(nombre) >= 0: continue
		destino.add_bone(nombre)
		var indice := destino.find_bone(nombre)
		var padre := origen.get_bone_parent(i)
		if padre >= 0: destino.set_bone_parent(indice, destino.find_bone(origen.get_bone_name(padre)))
		destino.set_bone_rest(indice, origen.get_bone_rest(i))
		destino.reset_bone_pose(indice)
	for nodo in paquete.find_children("*", "MeshInstance3D", true, false):
		var m := nodo as MeshInstance3D
		var clave := String(m.name)
		m.reparent(modelo, true)
		m.skeleton = m.get_path_to(destino)
		m.visibility_range_end = 60.0
		piezas[clave] = m
	paquete.queue_free()
	for nombre in ["eromash", "relleno"]:
		var original := modelo.find_child(nombre, true, false) as Node3D
		if original: original.hide()
	actualizar_equipo()

func cambiar_equipo(clave: String, activo: bool) -> void:
	equipado[clave] = activo
	if clave in ["espada", "escudo"]:
		_armas(armado, clave)
		if not activo:
			for nombre in [clave, clave + "_guardada", clave + "_guardado"]:
				if _mallas.has(nombre): _mallas[nombre].hide()
	actualizar_equipo()

func actualizar_equipo() -> void:
	for clave in equipado:
		_ver("pieza_" + clave, equipado[clave])
	_ver("pieza_tabardo", equipado.cinturon)
	for clave in piezas:
		if String(clave).begins_with("pieza_capa"): _ver(clave, equipado.capa)
	_ver("fijo_casco", true)
	_ver("base_torso", not equipado.pechera)
	_ver("base_brazos", not equipado.brazales)
	_ver("original_mangas", equipado.brazales)
	_ver("base_manos", not equipado.guantes)
	_ver("base_piernas", not equipado.piernas)
	_ver("original_pantalon", equipado.piernas)
	_ver("base_botas", not equipado.botas)

func _ver(nombre: String, activo: bool) -> void:
	if piezas.has(nombre): piezas[nombre].visible = activo

func contraste(activo: bool) -> void:
	var material := StandardMaterial3D.new()
	material.albedo_color = Color(0.02, 0.85, 0.65)
	material.roughness = 0.85
	for clave in piezas:
		if String(clave).begins_with("base_"):
			piezas[clave].material_override = material if activo else null
