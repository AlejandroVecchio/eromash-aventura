class_name Guion
extends RefCounted
## El guion del MVP (docs/misiones-principales-eldervald.md): los diálogos, qué dice cada NPC según la etapa,
## dónde está cada uno y qué pasa al terminar cada conversación. Las líneas son claves de textos.csv.

## Cada diálogo: lista de [hablante, clave]. `fin` es el nombre de la bandera que marca al terminar.
const DIALOGOS := {
	"eydis_inicio": {"lineas": [
		["eydis", "dlg_eydis_inicio_1"], ["eydis", "dlg_eydis_inicio_2"], ["eromash", "dlg_eydis_inicio_3"],
		["eydis", "dlg_eydis_inicio_4"], ["eydis", "dlg_eydis_inicio_5"]], "fin": "el01_acepto", "diario": "diario_croquis"},
	"eydis_espera": {"lineas": [["eydis", "dlg_eydis_espera"]]},
	"carro": {"lineas": [["eromash", "dlg_carro_1"], ["eromash", "dlg_carro_2"]], "fin": "carro_visto"},
	"orm_encuentro": {"lineas": [["orm", "dlg_orm_encuentro_1"], ["eromash", "dlg_orm_encuentro_2"], ["orm", "dlg_orm_encuentro_3"]], "fin": "orm_encontrado"},
	"orm_errantes": {"lineas": [["orm", "dlg_orm_errantes"]]},
	"orm_piedra": {"lineas": [["orm", "dlg_orm_piedra"]]},
	"eydis_refugio": {"lineas": [["eydis", "dlg_eydis_refugio"]]},
	"runa_refugio": {"lineas": [
		["runa", "dlg_runa_refugio_1"], ["eromash", "dlg_runa_refugio_2"], ["eydis", "dlg_runa_refugio_3"],
		["runa", "dlg_runa_refugio_4"]], "fin": "runa_refugio"},
	"orm_fragmento": {"lineas": [["orm", "dlg_orm_fragmento_1"], ["eydis", "dlg_orm_fragmento_2"]], "fin": "fragmento", "diario": "diario_fragmento"},
	"trabajador": {"lineas": [["trabajador", "dlg_trabajador_1"]]},
	"herido": {"lineas": [["trabajador", "dlg_herido_1"]]},
	"svanhild_inicio": {"lineas": [
		["svanhild", "dlg_svanhild_inicio_1"], ["eromash", "dlg_svanhild_inicio_2"], ["svanhild", "dlg_svanhild_inicio_3"],
		["svanhild", "dlg_svanhild_inicio_4"]], "fin": "fragmento_entregado"},
	"svanhild_mesa": {"lineas": [["svanhild", "dlg_svanhild_mesa"]]},
	"svanhild_asta": {"lineas": [
		["svanhild", "dlg_svanhild_asta_1"], ["eromash", "dlg_svanhild_asta_2"], ["svanhild", "dlg_svanhild_asta_3"],
		["svanhild", "dlg_svanhild_asta_4"]]},
	"svanhild_patio": {"lineas": [["svanhild", "dlg_svanhild_patio"]]},
	"svanhild_lente": {"lineas": [["svanhild", "dlg_svanhild_lente_1"], ["svanhild", "dlg_svanhild_lente_2"]], "fin": "lente", "diario": "diario_lente"},
	"svanhild_espera": {"lineas": [["svanhild", "dlg_svanhild_espera"]]},
	"eydis_eikholt": {"lineas": [["eydis", "dlg_eydis_eikholt"]]},
	"orm_eikholt": {"lineas": [["orm", "dlg_orm_eikholt"]]},
	"eydis_paso": {"lineas": [["eydis", "dlg_eydis_paso_1"], ["eydis", "dlg_eydis_paso_2"], ["orm", "dlg_eydis_paso_3"]], "fin": "eydis_paso"},
	"orm_paso": {"lineas": [["orm", "dlg_orm_paso"]]},
	"eydis_rastro": {"lineas": [["eydis", "dlg_eydis_rastro"]]},
	"eydis_claro": {"lineas": [["eydis", "dlg_eydis_claro_1"], ["eromash", "dlg_eydis_claro_2"], ["eydis", "dlg_eydis_claro_3"]], "fin": "eydis_claro"},
	"eydis_antes_jefe": {"lineas": [["eydis", "dlg_eydis_antes_jefe"]]},
	"eydis_ciervo": {"lineas": [["eydis", "dlg_eydis_ciervo"]]},
	"eydis_vuelta": {"lineas": [["eydis", "dlg_eydis_vuelta"]]},
	"runa_paso": {"lineas": [["eromash", "dlg_runa_paso"]], "fin": "runa_paso"},
	"orm_puente": {"lineas": [["orm", "dlg_orm_puente_1"], ["orm", "dlg_orm_puente_2"]]},
	"eydis_marca": {"lineas": [
		["eydis", "dlg_eydis_marca_1"], ["eromash", "dlg_eydis_marca_2"], ["eydis", "dlg_eydis_marca_3"],
		["eromash", "dlg_eydis_marca_4"], ["eydis", "dlg_eydis_marca_5"]], "fin": "puente_reparado", "diario": "diario_marca"},
	"eydis_despues": {"lineas": [["eydis", "dlg_eydis_despues"]]},
	"orm_despues": {"lineas": [["orm", "dlg_orm_despues"]]},
	"runa_santuario": {"lineas": [["runa", "dlg_runa_santuario_1"], ["eromash", "dlg_runa_santuario_2"], ["runa", "dlg_runa_santuario_3"]], "fin": "voz_santuario"},
	"svanhild_calco": {"lineas": [["svanhild", "dlg_svanhild_calco_1"], ["eromash", "dlg_svanhild_calco_2"]], "fin": "calco_entregado"},
	"svanhild_final": {"lineas": [["svanhild", "dlg_svanhild_final"]]},
	"salida_norte": {"lineas": [["eromash", "dlg_salida_norte"]]},
	"zarzas": {"lineas": [["eromash", "dlg_zarzas"]]},
}


## Qué conversación tiene cada NPC ahora.
static func dialogo_de(npc: String) -> String:
	var m := Juego.id_mision()
	var o := Juego.objetivo_actual()
	var hecho: String = o.get("hecho", "")
	match npc:
		"eydis":
			if m == "EL-01":
				return "eydis_inicio" if hecho == "el01_acepto" else "eydis_espera"
			if m == "EL-02":
				return "eydis_refugio"
			if m == "EL-03":
				return "eydis_eikholt"
			if m == "EL-04":
				if hecho == "eydis_paso":
					return "eydis_paso"
				if hecho == "eydis_claro":
					return "eydis_claro"
				return "eydis_rastro"
			if m == "EL-05":
				return "eydis_antes_jefe" if not Juego.tiene("ciervo_vencido") else "eydis_ciervo"
			if m == "EL-06":
				return "eydis_vuelta"
			return "eydis_despues"
		"orm":
			if m == "EL-01":
				return "orm_encuentro"
			if m == "EL-02":
				if hecho == "errantes_despejados":
					return "orm_errantes"
				if hecho in ["piedra_puesta", "runa_refugio"]:
					return "orm_piedra"
				return "orm_fragmento"
			if m == "EL-03":
				return "orm_eikholt"
			if m in ["EL-04", "EL-05"]:
				return "orm_paso"
			if m == "EL-06":
				return "orm_puente" if hecho == "puente_reparado" else "orm_paso"
			return "orm_despues"
		"svanhild":
			if m == "EL-03":
				if hecho == "fragmento_entregado":
					return "svanhild_inicio"
				if hecho == "fragmento_examinado":
					return "svanhild_mesa"
				if hecho == "huella_patio":
					return "svanhild_patio"
				return "svanhild_lente"
			if m == "EL-07" and hecho == "calco_entregado":
				return "svanhild_calco"
			if m == "fin":
				return "svanhild_final"
			return "svanhild_espera"
		"herido":
			return "herido"
	return "trabajador"


## Dónde está cada NPC según la etapa (id de lugar; los que no se ven devuelven "").
static func lugar_de(npc: String) -> String:
	var m := Juego.id_mision()
	var o := Juego.objetivo_actual()
	var hecho: String = o.get("hecho", "")
	match npc:
		"eydis":
			if m == "EL-01":
				return "eydis_puesto"
			if m == "EL-02":
				return "eydis_refugio" if not Juego.tiene("runa_refugio") else "eydis_refugio_salida"
			if m == "EL-03":
				return "eydis_eikholt"
			if m == "EL-04":
				if Juego.tiene("pista_menhir"):
					return "eydis_claro"
				return "eydis_paso"
			if m == "EL-05":
				return "eydis_claro" if not Juego.tiene("ciervo_vencido") else "eydis_ciervo"
			return "eydis_paso"
		"orm":
			if m in ["EL-01", "EL-02"]:
				return "orm_refugio"
			if m == "EL-03":
				return "orm_eikholt"
			if m in ["EL-04", "EL-05"]:
				return "orm_paso"
			return "orm_puente" if Juego.tiene("puente_reparado") else "orm_paso"
		"svanhild":
			if m == "EL-03" and hecho == "huella_patio":
				return "svanhild_patio"
			return "svanhild_casa"
		"trabajadores":
			if m in ["EL-01", "EL-02"] and not Juego.tiene("runa_refugio"):
				return "refugio"
			if m in ["EL-02", "EL-03"]:
				return "eikholt"
			if Juego.tiene("puente_reparado") or m == "fin":
				return "puente"
			return "paso"
	return ""
