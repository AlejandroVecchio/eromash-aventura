class_name DatosEquipo
extends RefCounted
## Única fuente del equipo, bolsa, consumibles y barra. Los IDs se guardan, nunca nodos o recursos.

signal cambio

const CAPACIDAD := 40
const RANURAS := ["casco", "hombros", "pechera", "capa", "brazales", "guantes", "arma", "amuleto", "cinturon", "piernas", "botas", "anillo_1", "anillo_2", "escudo"]
const ACCIONES := ["atacar", "bloquear", "esquivar", "lente"]
const CATALOGO := {
	"casco_base": {"ranura": "casco"},
	"hombros_base": {"ranura": "hombros", "imagen": "brazo-armadura"},
	"pechera_base": {"ranura": "pechera", "imagen": "pechera"},
	"capa_base": {"ranura": "capa", "imagen": "capa"},
	"brazales_base": {"ranura": "brazales", "imagen": "brazo-armadura"},
	"guantes_base": {"ranura": "guantes"},
	"cinturon_base": {"ranura": "cinturon"},
	"piernas_base": {"ranura": "piernas"},
	"botas_base": {"ranura": "botas", "imagen": "botas"},
	"espada_base": {"ranura": "arma", "imagen": "espada", "dano": 1.0, "velocidad": 1.0},
	"escudo_base": {"ranura": "escudo", "imagen": "escudo"},
	"espada_caminante": {"ranura": "arma", "imagen": "espada", "dano": 0.85, "velocidad": 1.2},
	"pechera_linde": {"ranura": "pechera", "imagen": "pechera", "armadura": 4.0},
	"botas_senda": {"ranura": "botas", "imagen": "botas", "armadura": 2.0},
	"amuleto_linde": {"ranura": "amuleto", "armadura": 3.0},
}

var equipo: Dictionary = {}
var bolsa: Array[String] = []
var pociones := {"vida": 3, "resistencia": 2}
var barra: Array[String] = ["atacar", "bloquear", "esquivar", "lente"]
var espera_pocion := 0.0


func _init() -> void:
	reiniciar()


func reiniciar() -> void:
	equipo.clear()
	for ranura in RANURAS:
		equipo[ranura] = ""
	for id in CATALOGO:
		if str(id).ends_with("_base"):
			equipo[CATALOGO[id].ranura] = id
	bolsa.assign(["espada_caminante", "pechera_linde", "botas_senda", "amuleto_linde"])
	pociones = {"vida": 3, "resistencia": 2}
	barra.assign(ACCIONES)
	espera_pocion = 0.0
	cambio.emit()


func ids_bolsa() -> Array[String]:
	var ids: Array[String] = bolsa.duplicate()
	for tipo in pociones:
		if int(pociones[tipo]) > 0:
			ids.append("pocion_" + tipo)
	return ids


func equipado(id: String) -> bool:
	return id != "" and id in equipo.values()


func equipar(id: String, destino := "") -> bool:
	if not CATALOGO.has(id) or id not in bolsa:
		return false
	var ranura: String = CATALOGO[id].ranura
	if ranura == "casco" or (destino != "" and destino != ranura):
		return false
	var anterior: String = equipo[ranura]
	bolsa.erase(id)
	if anterior != "":
		bolsa.append(anterior)
	equipo[ranura] = id
	cambio.emit()
	return true


func quitar(ranura: String) -> bool:
	if ranura == "casco" or not equipo.has(ranura) or equipo[ranura] == "" or ids_bolsa().size() >= CAPACIDAD:
		return false
	bolsa.append(equipo[ranura])
	equipo[ranura] = ""
	cambio.emit()
	return true


func valores(reemplazo := "") -> Dictionary:
	var actual: Dictionary = equipo.duplicate()
	if CATALOGO.has(reemplazo):
		actual[CATALOGO[reemplazo].ranura] = reemplazo
	var total := {"dano": 0.45, "velocidad": 1.0, "armadura": 0.0}
	for id in actual.values():
		if not CATALOGO.has(id):
			continue
		var pieza: Dictionary = CATALOGO[id]
		total.armadura += float(pieza.get("armadura", 0.0))
		if pieza.ranura == "arma":
			total.dano = pieza.get("dano", 1.0)
			total.velocidad = pieza.get("velocidad", 1.0)
	return total


func serializar() -> Dictionary:
	return {"equipo": equipo.duplicate(), "bolsa": bolsa.duplicate(), "pociones": pociones.duplicate(), "barra": barra.duplicate(), "espera_pocion": espera_pocion}


func cargar(datos: Dictionary) -> void:
	reiniciar()
	if datos.is_empty():
		return
	var origen: Variant = datos.get("equipo", {})
	var guardada: Variant = datos.get("bolsa", [])
	if not origen is Dictionary or not guardada is Array:
		return
	var usados: Array[String] = ["casco_base"]
	for ranura in RANURAS:
		if ranura == "casco":
			continue
		var id := str(origen.get(ranura, ""))
		if CATALOGO.has(id) and CATALOGO[id].ranura == ranura and id not in usados:
			equipo[ranura] = id
			usados.append(id)
		else:
			equipo[ranura] = ""
	bolsa.clear()
	for valor in guardada:
		var id := str(valor)
		if CATALOGO.has(id) and id not in usados and bolsa.size() < CAPACIDAD - 2:
			bolsa.append(id)
			usados.append(id)
	var p: Variant = datos.get("pociones", {})
	if p is Dictionary:
		for tipo in pociones:
			pociones[tipo] = clampi(int(p.get(tipo, 0)), 0, 99)
	var orden: Variant = datos.get("barra", [])
	if orden is Array and orden.size() == ACCIONES.size():
		var unicas: Array[String] = []
		for accion in orden:
			if str(accion) in ACCIONES and str(accion) not in unicas:
				unicas.append(str(accion))
		if unicas.size() == ACCIONES.size():
			barra.assign(unicas)
	espera_pocion = clampf(float(datos.get("espera_pocion", 0.0)), 0, 5)
	cambio.emit()
