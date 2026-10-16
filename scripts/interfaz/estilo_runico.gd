class_name EstiloRunico
extends RefCounted

const AZUL := Color("73d5db")
const CREMA := Color("eee6d1")
const AMBAR := Color("e9b765")
const SUAVE := Color("acb9a8")
const FONDO := Color("15231d")


static func panel(color := FONDO, borde := Color("697762"), margen := 16) -> StyleBoxFlat:
	var estilo := StyleBoxFlat.new()
	estilo.bg_color = color
	estilo.border_color = borde
	estilo.set_border_width_all(1)
	estilo.set_content_margin_all(margen)
	return estilo


static func texto(padre: Node, clave: String, tam := 18, color := CREMA) -> Label:
	var etiqueta := Label.new()
	etiqueta.text = TranslationServer.translate(clave)
	etiqueta.set_meta("clave", clave)
	etiqueta.add_theme_font_size_override("font_size", tam)
	etiqueta.add_theme_color_override("font_color", color)
	etiqueta.mouse_filter = Control.MOUSE_FILTER_IGNORE
	padre.add_child(etiqueta)
	return etiqueta


static func boton(padre: Node, clave: String, accion: Callable) -> Button:
	var b := Button.new()
	b.text = TranslationServer.translate(clave)
	b.set_meta("clave", clave)
	b.add_to_group("bloquea_clic_combate")
	b.pressed.connect(accion)
	padre.add_child(b)
	return b


static func imagen(id: String) -> Texture2D:
	var pieza: Dictionary = DatosEquipo.CATALOGO.get(id, {})
	if not pieza.has("imagen"):
		return null
	return load("res://assets/interfaz/equipo/" + pieza.imagen + ".png") as Texture2D
