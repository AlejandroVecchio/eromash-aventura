# Sistema de selección

Pedido por Alejandro el 21/10/2026: los NPC se seleccionan con un clic, se marcan con un borde blanco y una luz un poco más notoria, solo miran a Eromash mientras están seleccionados (antes giraban todo el tiempo) y aparece un recuadro con su retrato. Es la base para todo lo que venga después sobre «lo que tengo elegido» (enemigos con su vida, criaturas, objetos, acciones sobre el objetivo).

## Cómo se usa en el juego

| Acción | Teclado y mouse | Mando |
|---|---|---|
| Ver qué se puede seleccionar | pasar el mouse por encima: borde blanco suave | — |
| Seleccionar | clic izquierdo sobre el NPC (ese clic no ataca) | hablarle (Y) |
| Deseleccionar | clic izquierdo en otra parte del mundo, la ✕ del recuadro, o alejarse más de 18 m | alejarse |

Hablarle a un NPC con F también lo selecciona. Seleccionado, el borde se afirma, late despacio y el modelo gana un brillo leve en los bordes; el recuadro de arriba a la izquierda muestra retrato, nombre y rol, y sigue a la vista durante el diálogo.

## Piezas

| Qué | Dónde |
|---|---|
| Estado global: qué está seleccionado y qué tiene el mouse encima; rayo del mouse, clic, deselección | `scripts/autoload/seleccion.gd` (autoload `Seleccion`) |
| Componente que hace seleccionable a su padre: zona de clic, nombre, rol, retrato, borde | `scripts/interaccion/seleccionable.gd` (`Seleccionable`, un `Area3D`) |
| Recuadro con el retrato | `scripts/interfaz/marco_seleccion.gd` (`MarcoSeleccion`, lo crea `InterfazAventura`) |
| Borde y brillo | `assets/sombreadores/mascara_seleccion.gdshader` → `contorno_seleccion.gdshader` → `brillo_seleccion.gdshader` |
| Retratos | `assets/interfaz/retratos/<id>.png` |
| Textos | `rol_<id>`, `nombre_herido`, `seleccion_cerrar` en `herramientas/textos.py` |
| Prueba sin pantalla | guion `seleccion` en `scripts/pruebas/prueba.gd` |

### Cómo funciona

- **Zona de clic**: cada `Seleccionable` tiene una cápsula en la capa de física 16 (`Seleccion.CAPA`), que no choca con nada. El rayo del mouse busca esa capa y también la 1 (mundo), así una casa o el piso delante del NPC lo tapan.
- **Clic sin atacar**: el atacar del héroe sale del mismo clic izquierdo. Cuando el clic elige algo con `consume_clic = true`, `Seleccion.tomo_clic()` queda en verdadero un instante y `Heroe` ignora ese ataque (igual que con los botones de la interfaz, grupo `bloquea_clic_combate`).
- **Borde**: va en `material_overlay` de todas las mallas del padre (modelo y arma). Primero una máscara que no pinta nada y marca la silueta en el stencil (valor 64); después el modelo agrandado unos píxeles de pantalla, recortado por esa máscara, así queda solo el filo de afuera (la ropa en capas de Tripo hacía que un contorno común se viera adentro); con el NPC seleccionado se suma un brillo aditivo en los bordes. El grosor está en píxeles: se ve igual de cerca y de lejos. Lo que tapa al NPC también tapa el borde. Cuesta dos o tres pasadas de dibujo, y solo sobre lo que está marcado, por eso no se cuelga de Opciones → Video.
- **Deselección automática**: si lo seleccionado se esconde (un NPC que cambia de lugar), sale del árbol o queda a más de `distancia_max` de Eromash.
- **Pausa y menús**: con el juego en pausa o el mouse capturado (girando la cámara) no se marca nada.

## NPC

`NPC._poner_seleccion()` arma su `Seleccionable` solo: nombre `nombre_<id>`, rol `rol_<id>` (si existe la clave), retrato `assets/interfaz/retratos/<id>.png` (o `retrato_ruta`) y alto del modelo. El NPC mira a Eromash solo mientras `seleccion.es_actual()` o mientras le está hablando (una línea de diálogo suya con Eromash cerca); si no, vuelve despacio a su giro original.

Los trabajadores y el herido usan el retrato `trabajador.png`.

## Sumar algo seleccionable

```gdscript
var s := Seleccionable.new()
s.id = "lobo"
s.nombre_clave = "nombre_lobo"          # textos.csv
s.subtitulo_clave = "rol_lobo"          # opcional
s.retrato = load("res://assets/interfaz/retratos/lobo.png")
s.alto = 1.1
s.ancho = 0.7
s.consume_clic = false                  # en un enemigo el clic selecciona y además ataca
add_child(s)                            # hijo del nodo que se marca
```

Para reaccionar: las señales `seleccionado` / `deseleccionado` del propio `Seleccionable`, `Seleccion.cambio(actual)` para la interfaz, o `Seleccion.actual` para preguntar. Desde código: `Seleccion.elegir(s)` y `Seleccion.limpiar()`.

Para mostrar más datos en el recuadro (vida, estado, nivel), sumar campos al `Seleccionable` (o una referencia al nodo con esos datos) y dibujarlos en `MarcoSeleccion.mostrar()` / `_refrescar()`.

## Retratos

Recortes de cabeza y hombros (256×256) de las hojas 2D de cada NPC que están en el repo de la arena, `C:/eromash-juego/output/Personajes/NPC 2D/` (`eydis-v1.png`, `orm-v1.png`, `svanhild-frente-v1.png`, `trabajador-cuadrilla-v1.png`). El fondo gris de la hoja se cambió por un degradé oscuro verde azulado del estilo de la interfaz. Para uno nuevo: mismo tamaño, cara arriba del centro, fondo oscuro, guardado como `assets/interfaz/retratos/<id>.png`.

## Qué falta o queda abierto

- Con mando no hay forma de elegir sin hablar (por ejemplo, ciclar objetivos cercanos con un botón): se decide cuando haya enemigos seleccionables.
- No hay puntero propio al pasar por encima (hay propuestas en `docs/referencias/punteros/`).
- El NPC gira el cuerpo entero hacia Eromash; mover solo la cabeza (un `LookAtModifier3D` sobre el hueso `Head`) quedaría más natural.
