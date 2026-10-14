class_name Interactuable
extends Node3D
## Algo con lo que Eromash puede interactuar (F / Y). Muestra un cartel con `texto` cuando está cerca y
## `condicion` lo permite. Al usarlo, el héroe hace la animación `animacion` y en `momento` se llama `accion`.

@export var texto := "accion_hablar"
@export var radio := 2.6
@export var animacion := ""
@export var momento := 0.6

var condicion: Callable = func(): return true
var accion: Callable = func(_h): pass


func _ready() -> void:
	add_to_group("interactuable")


func disponible() -> bool:
	return visible and condicion.call()


func usar(heroe: Heroe) -> void:
	if animacion == "":
		accion.call(heroe)
	else:
		heroe.interactuar_con(self, animacion, momento, func(): accion.call(heroe))
