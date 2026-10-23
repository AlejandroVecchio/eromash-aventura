extends Node
## Estado de la partida: misiones EL-01 a EL-07, banderas, diario, objetos de misión, lugares y guardado.
## Todo lo que el jugador ve sale de claves de `textos/textos.csv` (ES/EN), nunca de textos sueltos.

signal cambio_estado          ## cambió la misión, el objetivo o una bandera
signal mensaje(clave: String) ## un aviso corto en pantalla
signal dialogo(id: String)    ## pedir que la interfaz muestre un diálogo
signal hablante(quien: String)  ## quién dice la línea que se muestra ("" al cerrar el diálogo): el NPC gesticula
signal fin_demo                ## se completó la cadena: mostrar la pantalla de cierre

const ARCHIVO := "user://partida.json"
const AUTOGUARDADO := 30.0

## Cada misión: objetivos en orden. `hecho` es la bandera que lo completa; `donde`, el lugar del marcador.
const MISIONES := [
	{"id": "EL-01", "objetivos": [
		{"texto": "obj_el01_1", "hecho": "el01_acepto", "donde": "eydis"},
		{"texto": "obj_el01_2", "hecho": "croquis_leido", "donde": ""},
		{"texto": "obj_el01_3", "hecho": "carro_visto", "donde": "carro"},
		{"texto": "obj_el01_4", "hecho": "orm_encontrado", "donde": "orm"},
	]},
	{"id": "EL-02", "objetivos": [
		{"texto": "obj_el02_1", "hecho": "errantes_despejados", "donde": "errantes"},
		{"texto": "obj_el02_2", "hecho": "piedra_puesta", "donde": "piedra_caida"},
		{"texto": "obj_el02_3", "hecho": "runa_refugio", "donde": "runa_refugio"},
		{"texto": "obj_el02_4", "hecho": "fragmento", "donde": "orm"},
	]},
	{"id": "EL-03", "objetivos": [
		{"texto": "obj_el03_1", "hecho": "fragmento_entregado", "donde": "svanhild"},
		{"texto": "obj_el03_2", "hecho": "fragmento_examinado", "donde": "mesa"},
		{"texto": "obj_el03_3", "hecho": "huella_patio", "donde": "losa"},
		{"texto": "obj_el03_4", "hecho": "lente", "donde": "svanhild"},
	]},
	{"id": "EL-04", "objetivos": [
		{"texto": "obj_el04_1", "hecho": "eydis_paso", "donde": "eydis"},
		{"texto": "obj_el04_2", "hecho": "pista_tablon", "donde": "tablon"},
		{"texto": "obj_el04_3", "hecho": "pista_raiz", "donde": "raiz"},
		{"texto": "obj_el04_4", "hecho": "pista_menhir", "donde": "menhir"},
		{"texto": "obj_el04_5", "hecho": "eydis_claro", "donde": "eydis"},
	]},
	{"id": "EL-05", "objetivos": [
		{"texto": "obj_el05_1", "hecho": "anclajes_vistos", "donde": "claro"},
		{"texto": "obj_el05_2", "hecho": "ataduras_rotas", "donde": "ciervo"},
		{"texto": "obj_el05_3", "hecho": "ciervo_vencido", "donde": "ciervo"},
		{"texto": "obj_el05_4", "hecho": "nucleo", "donde": "nucleo"},
	]},
	{"id": "EL-06", "objetivos": [
		{"texto": "obj_el06_1", "hecho": "vuelta_paso", "donde": "pedestal"},
		{"texto": "obj_el06_2", "hecho": "nucleo_puesto", "donde": "pedestal"},
		{"texto": "obj_el06_3", "hecho": "runa_paso", "donde": "pedestal"},
		{"texto": "obj_el06_4", "hecho": "puente_reparado", "donde": "orm"},
	]},
	{"id": "EL-07", "objetivos": [
		{"texto": "obj_el07_1", "hecho": "santuario_llegada", "donde": "santuario"},
		{"texto": "obj_el07_2", "hecho": "sello_visto", "donde": "sello"},
		{"texto": "obj_el07_3", "hecho": "voz_santuario", "donde": "sello"},
		{"texto": "obj_el07_4", "hecho": "calco", "donde": "sello"},
		{"texto": "obj_el07_5", "hecho": "calco_entregado", "donde": "svanhild"},
	]},
]

## Puntos seguros donde reaparece Eromash según la misión en curso.
const REAPARECER := {
	"EL-01": "puesto", "EL-02": "refugio", "EL-03": "eikholt", "EL-04": "paso_sur",
	"EL-05": "claro_entrada", "EL-06": "paso_sur", "EL-07": "aserradero", "fin": "eikholt",
}

var inventario := DatosEquipo.new()

var mision := 0          ## índice en MISIONES; MISIONES.size() = cadena completa
var banderas := {}
var diario: Array = []   ## claves de entradas del diario, en orden
var lugares := {}        ## id → Vector3 (los registra el mundo al armarse)
var lugares_vistos: Array = []
var salud := 100.0
var posicion := Vector3.INF
var cargada := false
var niebla := PackedByteArray()   ## minimapa: un byte por celda de 2 m (255 = sin explorar)
var saltar_titulo := false     ## después de "Nueva partida" la escena se recarga sin volver al título


var de_prueba := false   ## capturas sin pantalla: no se lee ni se pisa la partida del jugador
var _autosave := 0.0


func _ready() -> void:
	for a in OS.get_cmdline_user_args():
		if a.begins_with("--captura=") or a.begins_with("--ver=") or a == "--pruebas-combate" or a == "--practica-combate":
			de_prueba = true
	if not de_prueba:
		cargar()


func _process(dt: float) -> void:
	if de_prueba or not _conviene_guardar():
		return
	_autosave += dt
	if _autosave < AUTOGUARDADO:
		return
	_autosave = 0.0
	guardar()


func _notification(what: int) -> void:
	if what == NOTIFICATION_WM_CLOSE_REQUEST:
		guardar()


# ---------- consultas ----------

func mision_actual() -> Dictionary:
	return MISIONES[mision] if mision < MISIONES.size() else {}


func id_mision() -> String:
	return MISIONES[mision].id if mision < MISIONES.size() else "fin"


func objetivo_actual() -> Dictionary:
	var m := mision_actual()
	if m.is_empty():
		return {}
	for o in m.objetivos:
		if not tiene(o.hecho):
			return o
	return {}


func tiene(b: String) -> bool:
	return banderas.get(b, false) == true


func en(id: String) -> bool:
	return id_mision() == id


## La misión `id` ya terminó.
func completa(id: String) -> bool:
	for i in mision:
		if MISIONES[i].id == id:
			return true
	return mision >= MISIONES.size()


func donde_objetivo() -> Vector3:
	var o := objetivo_actual()
	if o.is_empty() or o.donde == "":
		return Vector3.INF
	return lugares.get(o.donde, Vector3.INF)


func punto_seguro() -> Vector3:
	return lugares.get(REAPARECER.get(id_mision(), "puesto"), Vector3.ZERO)


# ---------- cambios ----------

## Marca una bandera. Si completa el objetivo actual, avanza; si completa la misión, pasa a la siguiente y guarda.
func marcar(b: String, valor := true) -> void:
	if banderas.get(b, false) == valor:
		return
	banderas[b] = valor
	_avanzar()
	cambio_estado.emit()
	guardar()


func _avanzar() -> void:
	while mision < MISIONES.size() and objetivo_actual().is_empty():
		mision += 1
		if mision < MISIONES.size():
			mensaje.emit("mision_nueva")
		else:
			anotar("diario_santuario")
			fin_demo.emit()


func anotar(entrada: String) -> void:
	if entrada in diario:
		return
	diario.append(entrada)
	mensaje.emit("diario_nuevo")
	cambio_estado.emit()


func registrar_lugar(id: String, pos: Vector3) -> void:
	lugares[id] = pos


func descubrir(lugar: String) -> void:
	if lugar in lugares_vistos:
		return
	lugares_vistos.append(lugar)
	mensaje.emit("lugar_" + lugar)
	guardar()


func pedir_dialogo(id: String) -> void:
	dialogo.emit(id)


# ---------- guardado ----------

func guardar() -> void:
	if de_prueba or not _conviene_guardar():
		return
	var datos := {
		"version": 2,
		"inventario": inventario.serializar(),
		"mision": mision,
		"banderas": banderas,
		"diario": diario,
		"lugares_vistos": lugares_vistos,
		"salud": salud,
		"niebla": Marshalls.raw_to_base64(niebla.compress(FileAccess.COMPRESSION_DEFLATE)) if not niebla.is_empty() else "",
		"niebla_largo": niebla.size(),
		"posicion": [posicion.x, posicion.y, posicion.z] if posicion != Vector3.INF else [],
	}
	var texto := JSON.stringify(datos, "\t")
	if texto == "" or not _escribir_atomico(texto):
		return
	_autosave = 0.0


func cargar() -> bool:
	for ruta in [ARCHIVO, ARCHIVO + ".bak", ARCHIVO + ".tmp"]:
		if not _cargar_archivo(ruta):
			continue
		if ruta != ARCHIVO:
			guardar()
			mensaje.emit.call_deferred("partida_recuperada")
		return true
	return false


func hay_partida() -> bool:
	for ruta in [ARCHIVO, ARCHIVO + ".bak", ARCHIVO + ".tmp"]:
		if FileAccess.file_exists(ruta) and _archivo_json(ruta):
			return true
	return false


func nueva_partida() -> void:
	inventario.reiniciar()
	mision = 0
	banderas = {}
	diario = []
	lugares_vistos = []
	salud = 100.0
	niebla = PackedByteArray()
	posicion = Vector3.INF
	cargada = false
	_autosave = 0.0
	if not de_prueba:
		_borrar_archivos_partida()
	cambio_estado.emit()


## Hay algo que perder: una partida ya leída, progreso, o a Eromash ya ubicado en el mundo.
func _conviene_guardar() -> bool:
	return cargada or mision > 0 or not banderas.is_empty() or not diario.is_empty() or salud < 100.0 or posicion != Vector3.INF or not niebla.is_empty()


func _cargar_archivo(ruta: String) -> bool:
	if not FileAccess.file_exists(ruta):
		return false
	var datos = JSON.parse_string(FileAccess.get_file_as_string(ruta))
	if typeof(datos) != TYPE_DICTIONARY:
		return false
	mision = int(datos.get("mision", 0))
	banderas = datos.get("banderas", {})
	diario = datos.get("diario", [])
	lugares_vistos = datos.get("lugares_vistos", [])
	salud = float(datos.get("salud", 100.0))
	niebla = PackedByteArray()
	if str(datos.get("niebla", "")) != "":
		niebla = Marshalls.base64_to_raw(datos.niebla).decompress(int(datos.get("niebla_largo", 0)), FileAccess.COMPRESSION_DEFLATE)
	var p: Array = datos.get("posicion", [])
	posicion = Vector3(p[0], p[1], p[2]) if p.size() == 3 else Vector3.INF
	var equipo_guardado: Variant = datos.get("inventario", {})
	inventario.cargar(equipo_guardado if equipo_guardado is Dictionary else {})
	cargada = true
	return true


## Escribe al lado y recién después reemplaza. La copia anterior queda en .bak si el archivo actual es válido.
func _escribir_atomico(texto: String) -> bool:
	var dir := DirAccess.open("user://")
	if dir == null:
		return false
	var temporal := "partida.json.tmp"
	var f := FileAccess.open("user://" + temporal, FileAccess.WRITE)
	if f == null:
		return false
	f.store_string(texto)
	f.close()
	if not _archivo_json("user://" + temporal):
		dir.remove(temporal)
		return false
	if FileAccess.file_exists(ARCHIVO) and _archivo_json(ARCHIVO):
		dir.remove("partida.json.bak")
		dir.copy("partida.json", "partida.json.bak")
	if FileAccess.file_exists(ARCHIVO):
		dir.remove("partida.json")
	if dir.rename(temporal, "partida.json") == OK:
		return true
	return dir.copy(temporal, "partida.json") == OK


func _archivo_json(ruta: String) -> bool:
	return typeof(JSON.parse_string(FileAccess.get_file_as_string(ruta))) == TYPE_DICTIONARY


func _borrar_archivos_partida() -> void:
	var dir := DirAccess.open("user://")
	if dir == null:
		return
	for nombre in ["partida.json", "partida.json.bak", "partida.json.tmp"]:
		dir.remove(nombre)
