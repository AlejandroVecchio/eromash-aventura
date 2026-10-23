extends Node
## Efectos de sonido del MVP con los CC0 de `assets/audio/sfx/` (créditos en `assets/audio/CREDITOS.md`).
## Uso: `Sonido.tocar("golpe")`. Cada nombre puede tener varias variantes y se elige una al azar.
##
## También es el gestor de volumen: arma los buses (General = Master, y Música, Ambiente, Efectos y Voces que
## mandan a Master), guarda cada volumen de 0 a 100 en la sección [sonido] de user://opciones.cfg y lo aplica al
## arrancar. Opciones → Sonido (`scripts/interfaz/opciones_sonido.gd`) los cambia con `poner_volumen()`.
## Todo reproductor nuevo va a uno de estos buses (nunca directo a Master): la música a "Musica", las voces a
## "Voces". Los buses propios de las voces de las cinemáticas (Narrador, Guardian) se mandan solos a "Voces".

signal volumen_cambio

## Los buses en el orden del menú: clave en el cfg, nombre del bus, título y descripción (claves de textos.csv).
const BUSES := [
	["general", "Master", "son_general", "son_general_desc"],
	["musica", "Musica", "son_musica", "son_musica_desc"],
	["ambiente", "Ambiente", "son_ambiente", "son_ambiente_desc"],
	["efectos", "Efectos", "son_efectos", "son_efectos_desc"],
	["voces", "Voces", "son_voces", "son_voces_desc"],
]
const POR_DEFECTO := {"general": 100, "musica": 80, "ambiente": 80, "efectos": 100, "voces": 100}
## Buses que arman otros scripts para las voces (con sus efectos); se cuelgan de "Voces".
const BUSES_DE_VOZ := ["Narrador", "Guardian"]

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
var volumenes := POR_DEFECTO.duplicate()   ## clave → 0..100
var _de_prueba := false                     ## capturas sin pantalla: no se guarda
var _musica_pausa: AudioStreamPlayer


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	for a in OS.get_cmdline_user_args():
		if a.begins_with("--captura="):
			_de_prueba = true
	_armar_buses()
	_cargar_volumenes()
	AudioServer.bus_layout_changed.connect(_colgar_voces.call_deferred)
	AudioServer.bus_renamed.connect(func(_i, _a, _n): _colgar_voces.call_deferred())
	if DisplayServer.get_name() == "headless":
		return
	for i in 8:
		var p := AudioStreamPlayer.new()
		p.bus = "Efectos"
		add_child(p)
		_canales.append(p)
	_ambiente = AudioStreamPlayer.new()
	_ambiente.bus = "Ambiente"
	add_child(_ambiente)
	_musica_pausa = AudioStreamPlayer.new()
	_musica_pausa.name = "MusicaPausa"
	_musica_pausa.bus = "Musica"
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


# ---------- volumen ----------

func _armar_buses() -> void:
	for b in BUSES.slice(1):
		if AudioServer.get_bus_index(b[1]) != -1:
			continue
		AudioServer.add_bus()
		var i := AudioServer.bus_count - 1
		AudioServer.set_bus_name(i, b[1])
		AudioServer.set_bus_send(i, "Master")


## Las voces de las cinemáticas arman sus buses al vuelo y los mandan a Master: se pasan a "Voces" para que
## respeten su volumen. Corre diferido, después de que el script que los armó termine de configurarlos.
func _colgar_voces() -> void:
	for nombre in BUSES_DE_VOZ:
		var i := AudioServer.get_bus_index(nombre)
		if i != -1 and AudioServer.get_bus_send(i) != &"Voces":
			AudioServer.set_bus_send(i, "Voces")


func _cargar_volumenes() -> void:
	var cfg := ConfigFile.new()
	if not _de_prueba and cfg.load(Calidad.ARCHIVO) == OK:
		for b in BUSES:
			volumenes[b[0]] = clampi(int(cfg.get_value("sonido", b[0], volumenes[b[0]])), 0, 100)
	for b in BUSES:
		_aplicar(b[0])


func _aplicar(clave: String) -> void:
	for b in BUSES:
		if b[0] == clave:
			var i := AudioServer.get_bus_index(b[1])
			var v: int = volumenes[clave]
			AudioServer.set_bus_mute(i, v == 0)
			AudioServer.set_bus_volume_db(i, linear_to_db(v / 100.0) if v > 0 else -80.0)


func volumen(clave: String) -> int:
	return volumenes.get(clave, 100)


## 0 a 100 (0 silencia el bus). Se aplica al instante y se guarda.
func poner_volumen(clave: String, v: int) -> void:
	if not volumenes.has(clave):
		return
	volumenes[clave] = clampi(v, 0, 100)
	_aplicar(clave)
	guardar()
	volumen_cambio.emit()


func restablecer() -> void:
	volumenes = POR_DEFECTO.duplicate()
	for b in BUSES:
		_aplicar(b[0])
	guardar()
	volumen_cambio.emit()


## Escribe solo la sección [sonido]; el resto del archivo es de Calidad.
func guardar() -> void:
	if _de_prueba:
		return
	var cfg := ConfigFile.new()
	cfg.load(Calidad.ARCHIVO)
	for b in BUSES:
		cfg.set_value("sonido", b[0], volumenes[b[0]])
	cfg.save(Calidad.ARCHIVO)


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
