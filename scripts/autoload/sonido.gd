extends Node
## Efectos de sonido del MVP con los CC0 de `assets/audio/sfx/` (créditos en `assets/audio/CREDITOS.md`).
## Uso: `Sonido.tocar("golpe")`. Cada nombre puede tener varias variantes y se elige una al azar.

const SFX := "res://assets/audio/sfx/"
const EFECTOS := {
	"esquiva": ["aire-corto"],
	"golpe": ["hoja", "metal"],
	"bloqueo": ["metal", "clavada"],
	"herido": ["aire-corto"],
	"lente": ["hechizo-1", "hechizo-2"],
	"runa": ["gema-1", "gema-2", "gema-3", "gema-4"],
	"revelar": ["transformar-1", "transformar-2"],
	"mision": ["campana-1", "campana-2", "campana-3"],
	"diario": ["gema-2"],
	"romper": ["quiebre"],
	"aviso_jefe": ["aire-largo"],
	"jefe": ["gong-1", "gong-2"],
	"trueno": ["trueno"],
	"muerte": ["grietas"],
}
const VOLUMEN := {"ambiente": -14.0, "golpe": -6.0, "mision": -8.0, "jefe": -4.0, "trueno": -6.0}

var _cache := {}
var _canales: Array[AudioStreamPlayer] = []
var _ambiente: AudioStreamPlayer


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	if DisplayServer.get_name() == "headless":
		return
	for i in 8:
		var p := AudioStreamPlayer.new()
		p.bus = "Master"
		add_child(p)
		_canales.append(p)
	_ambiente = AudioStreamPlayer.new()
	add_child(_ambiente)
	Juego.mensaje.connect(func(clave: String):
		if clave == "mision_nueva":
			tocar("mision")
		elif clave == "diario_nuevo":
			tocar("diario"))


func _cargar(archivo: String) -> AudioStream:
	if not _cache.has(archivo):
		_cache[archivo] = load(SFX + archivo + ".ogg")
	return _cache[archivo]


func tocar(nombre: String, volumen_db := 0.0) -> void:
	if _canales.is_empty() or not EFECTOS.has(nombre):
		return
	var s := _cargar(EFECTOS[nombre].pick_random())
	if s == null:
		return
	var libre: AudioStreamPlayer = _canales[0]
	for p in _canales:
		if not p.playing:
			libre = p
			break
	libre.stream = s
	libre.volume_db = VOLUMEN.get(nombre, -8.0) + volumen_db
	libre.pitch_scale = randf_range(0.94, 1.06)
	libre.play()


## Fondo del bosque en bucle.
func ambiente(encender := true) -> void:
	if _ambiente == null:
		return
	if not encender:
		_ambiente.stop()
		return
	var s := _cargar("ambiente")
	if s is AudioStreamOggVorbis:
		(s as AudioStreamOggVorbis).loop = true
	_ambiente.stream = s
	_ambiente.volume_db = VOLUMEN.ambiente
	if not _ambiente.playing:
		_ambiente.play()


func _process(_dt: float) -> void:
	if _ambiente == null:
		return
	# El autoload sigue andando en pausa: si no, el bosque tapa el menú.
	_ambiente.stream_paused = get_tree().paused
