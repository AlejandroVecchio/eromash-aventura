extends Node
## Cartel de prueba para una tanda de PR. Lee la rama en .git y, si está en NOTAS, dice qué hay que mirar.
## En main, en una exportación (no hay .git) y en cualquier otra rama no arma nada: el juego queda igual.
## El archivo es el mismo en toda la tanda, así al unir las PR no choca. Los textos están acá, en los dos
## idiomas, y no en textos.csv: el catálogo ya puede diferir entre ramas y esto no es texto del juego.

const AZUL := Color("73d5db")
const CREMA := Color("eee6d1")
const AMBAR := Color("e9b765")
const SUAVE := Color("acb9a8")

const NOTAS := {
	"mejora/guardado-atomico": {
		"es": "Caminá a otro lugar y cerrá el juego sin apretar Guardar. Al volver, Eromash sigue ahí: la partida se guarda sola al salir y cada 30 segundos. Si el archivo se corta, se recupera la copia anterior.",
		"en": "Walk somewhere else and close the game without pressing Save. When you come back, Eromash is still there: the game saves on quit and every 30 seconds. If the file is cut off, the previous copy is restored.",
	},
	"mejora/opciones-seguras": {
		"es": "Con Esc, cambiá la calidad o el idioma y cerrá el juego. Al abrirlo de nuevo, el ajuste sigue ahí. Si opciones.cfg se corta a mitad de escritura, vuelve el ajuste anterior en vez de olvidarse.",
		"en": "With Esc, change the quality or the language and quit. The next time you open the game, the setting is still there. If opciones.cfg is cut off mid-write, the previous setting comes back instead of being forgotten.",
	},
	"mejora/camara-sin-atravesar": {
		"es": "Acercate a una casa, una roca grande o un tronco y girá la cámara con el clic derecho para dejarla detrás. Se acerca y no atraviesa el objeto.",
		"en": "Walk up to a house, a large rock or a fallen trunk and orbit the camera with the right mouse button so it sits behind it. The camera pulls in and does not pass through.",
	},
	"mejora/golpes-respetan-muros": {
		"es": "Dejá que un lobo o un errante marque el aviso en el piso y ponete del otro lado de una casa, una roca o un tronco. El golpe no llega a través.",
		"en": "Let a wolf or a wanderer mark the warning on the ground and stand on the other side of a house, a rock or a trunk. The hit does not pass through.",
	},
	"mejora/ciervo-respeta-muros": {
		"es": "En la pelea del Ciervo Hueco, ponete detrás de una piedra del borde del claro, entre vos y él. El pisotón, el barrido, las raíces y la embestida no pegan a través.",
		"en": "In the Hollow Stag fight, stand behind one of the stones at the edge of the clearing, between you and him. The stomp, the sweep, the roots and the charge do not hit through it.",
	},
	"mejora/dano-de-caida": {
		"es": "Saltá en llano: no duele. Caete a la quebrada desde el borde. Al tocar el suelo, baja la vida; cuanto más alto, más duele.",
		"en": "Jump on flat ground: it does not hurt. Drop into the ravine from the edge. Landing costs health, and a higher drop hurts more.",
	},
	"mejora/interactuar-de-frente": {
		"es": "Parate donde haya dos cosas al alcance y mirá hacia una. Con interactuar (F, o Y en el mando) Eromash usa la que está mirando, no siempre la más cercana.",
		"en": "Stand where two things are in reach and look at one of them. With interact (F, or Y on a pad) Eromash uses the one he is facing, not always the nearest.",
	},
	"mejora/distancia-al-objetivo": {
		"es": "Mirá el objetivo, arriba a la izquierda. Al lado del texto dice a cuántos metros está. Si te acercás, el número baja.",
		"en": "Look at the objective, at the top left. Next to the text it says how many meters away it is. Walk closer and the number goes down.",
	},
}


func _ready() -> void:
	var nota := _nota_de_esta_rama()
	var captura := get_node_or_null("/root/Captura")
	if nota.is_empty() or (captura != null and captura.has_method("activo") and captura.activo()):
		return
	process_mode = Node.PROCESS_MODE_ALWAYS
	var capa := CanvasLayer.new()
	capa.name = "NotaDeRama"
	capa.layer = 30
	capa.process_mode = Node.PROCESS_MODE_ALWAYS
	add_child(capa)
	var raiz := Control.new()
	raiz.set_anchors_preset(Control.PRESET_FULL_RECT)
	raiz.mouse_filter = Control.MOUSE_FILTER_IGNORE
	capa.add_child(raiz)
	var panel := PanelContainer.new()
	panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
	panel.add_theme_stylebox_override("panel", _panel())
	raiz.add_child(panel)
	var caja := VBoxContainer.new()
	caja.mouse_filter = Control.MOUSE_FILTER_IGNORE
	caja.add_theme_constant_override("separation", 6)
	panel.add_child(caja)
	var en := TranslationServer.get_locale().begins_with("en")
	var titulo := _linea(caja, "What to look for" if en else "Qué mirar", 20, AMBAR, true)
	_linea(caja, _rama_git(), 14, SUAVE, false)
	var cuerpo := _linea(caja, nota["en"] if en else nota["es"], 16, CREMA, false)
	cuerpo.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	var pie := _linea(
		caja,
		"On the main branch this note does not appear." if en else "En la rama principal esta nota no aparece.",
		14,
		Color(SUAVE, 0.8),
		false
	)
	pie.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	for linea in [titulo, cuerpo, pie]:
		linea.custom_minimum_size.x = 460
	get_viewport().size_changed.connect(func() -> void: _colocar(panel))
	_colocar.call_deferred(panel)


func _panel() -> StyleBoxFlat:
	var estilo := StyleBoxFlat.new()
	estilo.bg_color = Color("15231de8")
	estilo.border_color = AZUL
	estilo.set_border_width_all(1)
	estilo.set_content_margin_all(14)
	return estilo


func _nota_de_esta_rama() -> Dictionary:
	return NOTAS.get(_rama_git(), {})


func _rama_git() -> String:
	var raiz := ProjectSettings.globalize_path("res://")
	var git := raiz.path_join(".git")
	var cabeza := ""
	if FileAccess.file_exists(git):
		var linea := FileAccess.get_file_as_string(git).strip_edges()
		if linea.begins_with("gitdir:"):
			var dir := linea.substr(7).strip_edges()
			if not dir.is_absolute_path():
				dir = raiz.path_join(dir)
			cabeza = dir.path_join("HEAD")
	elif DirAccess.dir_exists_absolute(git):
		cabeza = git.path_join("HEAD")
	if cabeza == "" or not FileAccess.file_exists(cabeza):
		return ""
	var texto := FileAccess.get_file_as_string(cabeza).strip_edges()
	const PREFIJO := "ref: refs/heads/"
	if texto.begins_with(PREFIJO):
		return texto.substr(PREFIJO.length())
	return ""


func _linea(padre: Node, texto: String, tam: int, color: Color, titulo: bool) -> Label:
	var etiqueta := Label.new()
	etiqueta.text = texto
	etiqueta.mouse_filter = Control.MOUSE_FILTER_IGNORE
	etiqueta.add_theme_font_size_override("font_size", tam)
	etiqueta.add_theme_color_override("font_color", color)
	var ruta := "res://assets/marca/fuentes/EromashDisplay-Bold.woff2" if titulo else "res://assets/marca/fuentes/EromashText-Regular.woff2"
	var fuente := load(ruta) as Font
	if fuente != null:
		etiqueta.add_theme_font_override("font", fuente)
	padre.add_child(etiqueta)
	return etiqueta


func _colocar(panel: Control) -> void:
	if not is_instance_valid(panel):
		return
	panel.reset_size()
	var s := panel.size
	var v := panel.get_viewport_rect().size
	panel.position = Vector2(v.x - s.x - 28.0, v.y - s.y - 36.0)
