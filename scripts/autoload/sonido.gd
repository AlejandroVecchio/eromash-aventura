extends Node
## Efectos de sonido del MVP con los CC0 de `assets/audio/sfx/` (créditos en `assets/audio/CREDITOS.md`).
## Uso: `Sonido.tocar("golpe")`. Cada nombre puede tener varias variantes y se elige una al azar.

const SFX := "res://assets/audio/sfx/"
## Tema del menú de pausa. Se deja el archivo en esa ruta; si no está, la pausa sigue en silencio.
const MUSICA_PAUSA := "res://assets/audio/musica/pausa.ogg"
const MUSICA_PAUSA_MP3 := "res://assets/audio/musica/pausa.mp3"
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
const VOLUMEN := {"ambiente": -14.0, "golpe": -6.0, "mision": -8.0, "jefe": -4.0, "trueno": -6.0, "pausa": -12.0}

var _cache := {}
var _canales: Array[AudioStreamPlayer] = []
var _ambiente: AudioStreamPlayer
var _musica_pausa: AudioStreamPlayer


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
	_musica_pausa = AudioStreamPlayer.new()
	_musica_pausa.name = "MusicaPausa"
	add_child(_musica_pausa)
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


## Suena solo con el menú de pausa abierto. El archivo se deja en `assets/audio/musica/pausa.ogg` (o `.mp3`).
func musica_de_pausa(encender: bool) -> void:
	if _musica_pausa == null:
		return
	if not encender:
		_musica_pausa.stop()
		return
	if _musica_pausa.stream == null and not _cargar_musica_pausa():
		return
	if not _musica_pausa.playing:
		_musica_pausa.play()


func _cargar_musica_pausa() -> bool:
	var ruta := ""
	if ResourceLoader.exists(MUSICA_PAUSA):
		ruta = MUSICA_PAUSA
	elif ResourceLoader.exists(MUSICA_PAUSA_MP3):
		ruta = MUSICA_PAUSA_MP3
	if ruta == "":
		return false
	var s := load(ruta) as AudioStream
	if s == null:
		return false
	if s is AudioStreamOggVorbis:
		(s as AudioStreamOggVorbis).loop = true
	elif s is AudioStreamMP3:
		(s as AudioStreamMP3).loop = true
	_musica_pausa.stream = s
	_musica_pausa.volume_db = VOLUMEN.pausa
	return true
