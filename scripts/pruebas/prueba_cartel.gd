extends Control
## Para mirar los carteles de lugar sin jugar: abrir escenas/prueba_cartel.tscn y F6.
## «Interactuar» (F / Y) pasa al siguiente. Los parámetros se editan en scripts/interfaz/cartel_lugar.gd (CONFIG).
## Sin pantalla: herramientas/capturar.sh res://escenas/prueba_cartel.tscn salida.png 200 1920 1080 --guion=cartel_tierra

const CASOS := [
	[CartelLugar.Tipo.LUGAR, "Eikholt", {}, "prueba_cartel_lugar"],
	[CartelLugar.Tipo.TIERRA, "Bosque de Eldervald", {"region": "eldervald", "runas": "ᛖᛚᛞᛖᚱᚹᚨᛚᛞ"}, "prueba_cartel_tierra"],
	[CartelLugar.Tipo.REGRESO, "Eikholt", {}, "prueba_cartel_regreso"],
	[CartelLugar.Tipo.CAPITAL, "Eikholt", {"capital": "eikholt"}, "prueba_cartel_capital"],
]

var cartel: CartelLugar
var ayuda: Label
var i := 0


func _ready() -> void:
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	var fondo := ColorRect.new()
	fondo.color = Color("0C1312")
	fondo.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(fondo)
	cartel = CartelLugar.new()
	add_child(cartel)
	ayuda = Label.new()
	ayuda.set_anchors_and_offsets_preset(Control.PRESET_BOTTOM_WIDE)
	ayuda.offset_top = -48
	ayuda.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	ayuda.add_theme_color_override("font_color", Color(0.93, 0.9, 0.82, 0.5))
	add_child(ayuda)
	cartel.termino.connect(func(): get_tree().create_timer(1.0).timeout.connect(_mostrar))
	var g := Captura.guion
	if g.begins_with("cartel_"):
		i = ["cartel_lugar", "cartel_tierra", "cartel_regreso", "cartel_capital"].find(g)
		_mostrar.call_deferred()
		var t := get_tree()
		for k in 10:
			var s := 0.6 + k * 1.3
			t.create_timer(s).timeout.connect(func(): Captura.foto(Captura.salida.get_basename() + "_%d.png" % k, 1))
		return
	_mostrar.call_deferred()


func _mostrar() -> void:
	var c: Array = CASOS[i % CASOS.size()]
	cartel.mostrar(c[0], c[1], c[2])
	ayuda.text = tr("prueba_cartel_ayuda") % [Controles.tecla("interactuar"), tr(c[3])]


func _unhandled_input(ev: InputEvent) -> void:
	if ev.is_action_pressed("interactuar"):
		i += 1
		_mostrar()
