extends Node
## Registra las acciones del juego (teclado, mouse y mando). El código usa siempre acciones, nunca teclas sueltas:
## cambiar un control o sumar uno nuevo se hace solo acá.

signal dispositivo_cambio

var usando_mando := false

const NOMBRES_BOTONES := {
	JOY_BUTTON_A: "A", JOY_BUTTON_B: "B", JOY_BUTTON_X: "X", JOY_BUTTON_Y: "Y",
	JOY_BUTTON_LEFT_SHOULDER: "LB", JOY_BUTTON_RIGHT_SHOULDER: "RB",
	JOY_BUTTON_LEFT_STICK: "L3", JOY_BUTTON_RIGHT_STICK: "R3",
	JOY_BUTTON_BACK: "Back", JOY_BUTTON_START: "Start",
}

const TECLAS := {
	"mover_izquierda": [KEY_A, KEY_LEFT],
	"mover_derecha": [KEY_D, KEY_RIGHT],
	"mover_arriba": [KEY_W, KEY_UP],
	"mover_abajo": [KEY_S, KEY_DOWN],
	"correr": [KEY_SHIFT],
	"saltar": [KEY_SPACE],
	"esquivar": [KEY_ALT],
	"interactuar": [KEY_F],
	"lente": [KEY_R],
	"envainar": [KEY_X],
	"diario": [KEY_J, KEY_TAB],
	"bloquear": [KEY_CTRL],
	"camara_izquierda": [KEY_Q],
	"camara_derecha": [KEY_E],
	"pausa": [KEY_ESCAPE],
	"ver_fps": [KEY_F3],
}

const BOTONES_MANDO := {
	"saltar": [JOY_BUTTON_A],
	"atacar": [JOY_BUTTON_X],
	"interactuar": [JOY_BUTTON_Y],
	"esquivar": [JOY_BUTTON_B],
	"envainar": [JOY_BUTTON_RIGHT_STICK],
	"lente": [JOY_BUTTON_RIGHT_SHOULDER],
	"bloquear": [JOY_BUTTON_LEFT_SHOULDER],
	"correr": [JOY_BUTTON_LEFT_STICK],
	"diario": [JOY_BUTTON_BACK],
	"pausa": [JOY_BUTTON_START],
}

const EJES_MANDO := [
	["camara_arriba", JOY_AXIS_RIGHT_Y, -1.0],
	["camara_abajo", JOY_AXIS_RIGHT_Y, 1.0],
	["mover_izquierda", JOY_AXIS_LEFT_X, -1.0],
	["mover_derecha", JOY_AXIS_LEFT_X, 1.0],
	["mover_arriba", JOY_AXIS_LEFT_Y, -1.0],
	["mover_abajo", JOY_AXIS_LEFT_Y, 1.0],
	["camara_izquierda", JOY_AXIS_RIGHT_X, -1.0],
	["camara_derecha", JOY_AXIS_RIGHT_X, 1.0],
	["atacar", JOY_AXIS_TRIGGER_RIGHT, 1.0],
	["bloquear", JOY_AXIS_TRIGGER_LEFT, 1.0],
]


func _ready() -> void:
	for accion in TECLAS:
		_asegurar(accion)
		for tecla in TECLAS[accion]:
			var ev := InputEventKey.new()
			ev.physical_keycode = tecla
			InputMap.action_add_event(accion, ev)
	_boton_mouse("atacar", MOUSE_BUTTON_LEFT)
	for accion in BOTONES_MANDO:
		_asegurar(accion)
		for b in BOTONES_MANDO[accion]:
			var ev := InputEventJoypadButton.new()
			ev.button_index = b
			InputMap.action_add_event(accion, ev)
	for e in EJES_MANDO:
		_asegurar(e[0])
		var ev := InputEventJoypadMotion.new()
		ev.axis = e[1]
		ev.axis_value = e[2]
		InputMap.action_add_event(e[0], ev)


func _asegurar(accion: String) -> void:
	if not InputMap.has_action(accion):
		InputMap.add_action(accion, 0.25)


func _boton_mouse(accion: String, boton: MouseButton) -> void:
	_asegurar(accion)
	var ev := InputEventMouseButton.new()
	ev.button_index = boton
	InputMap.action_add_event(accion, ev)


## Texto corto de la tecla de una acción para los carteles ("F", "R"…).
func tecla(accion: String) -> String:
	if usando_mando:
		for ev in InputMap.action_get_events(accion):
			if ev is InputEventJoypadButton:
				return NOMBRES_BOTONES.get((ev as InputEventJoypadButton).button_index, "?")
	for ev in InputMap.action_get_events(accion):
		if ev is InputEventKey:
			return OS.get_keycode_string((ev as InputEventKey).physical_keycode)
		if ev is InputEventMouseButton:
			return tr("tecla_clic_izq") if (ev as InputEventMouseButton).button_index == MOUSE_BUTTON_LEFT else tr("tecla_clic_der")
	return "?"


func _input(ev: InputEvent) -> void:
	var mando := usando_mando
	if ev is InputEventJoypadButton or (ev is InputEventJoypadMotion and absf((ev as InputEventJoypadMotion).axis_value) > 0.3):
		mando = true
	elif ev is InputEventKey or ev is InputEventMouseButton:
		mando = false
	if mando != usando_mando:
		usando_mando = mando
		dispositivo_cambio.emit()
