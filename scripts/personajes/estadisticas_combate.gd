class_name EstadisticasCombate
extends Resource
## Valores por personaje. Se duplican para que equipo/mejoras no alteren a otros humanoides.

@export var dano_equipo: float = 1.0
@export var armadura_equipo: float = 0.0

@export_range(0.5, 2.5, 0.05) var velocidad_ataque: float = 1.0
@export_range(1.0, 500.0, 1.0) var stamina_maxima: float = 100.0
@export_range(0.0, 100.0, 1.0) var regeneracion_stamina: float = 28.0
@export_range(0.0, 3.0, 0.05) var espera_regeneracion: float = 0.75
@export_range(1.0, 100.0, 1.0) var costo_esquiva: float = 30.0
@export_range(1.0, 100.0, 1.0) var costo_ataque: float = 12.0
@export_range(1.0, 100.0, 1.0) var costo_ataque_guardia: float = 20.0
@export_range(0.1, 100.0, 0.1) var consumo_guardia: float = 8.0
@export_range(1.0, 5.0, 0.1) var distancia_esquiva: float = 3.0
@export_range(0.25, 0.8, 0.01) var duracion_esquiva: float = 0.4
@export_range(0.0, 0.5, 0.01) var pausa_esquiva: float = 0.12


func multiplicador_ataque() -> float:
	return clampf(velocidad_ataque, 0.5, 2.5)
