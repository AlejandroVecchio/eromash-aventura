# MVP de Eldervald — cómo está armado

Esqueleto jugable de la cadena EL-01 a EL-07 (`docs/misiones-principales-eldervald.md`) sobre el mapa `docs/mapas/eldervald.png`. Todo se arma por código al abrir `escenas/principal.tscn`: no hay escenas grandes hechas a mano, así un cambio de lugar o de misión se hace en un solo script.

## Cómo se juega

| Acción | Teclado y mouse | Mando |
|---|---|---|
| Moverse / correr | WASD o flechas / Shift | stick izquierdo / L3 |
| Saltar (esquiva todo aviso del piso) | Espacio | A |
| Esquivar (dirección de movimiento; quieto retrocede) | Alt | B |
| Atacar / bloquear | clic izquierdo / Ctrl izquierdo | X o RT / LB o LT |
| Interactuar / hablar | F | Y |
| Lente del Eco | R | RB |
| Envainar | X | R3 |
| Diario con el croquis | J o Tab | Back |
| Girar e inclinar la cámara (hasta quedar paralela al héroe) | mantener clic derecho (o la rueda) y mover el mouse; Q / E | stick derecho |
| Contador de FPS | F3 | — |
| Pausa (guardar, calidad, idioma) | Esc | Start |

Las acciones están en `scripts/autoload/controles.gd`; el código nunca lee teclas sueltas.

El HUD muestra vida y resistencia, con pistas que cambian entre teclado y mando. La esquiva consume resistencia y permite cancelar partes de los ataques. Estadísticas, ventanas y límites actuales: `docs/combate.md`.

## Mapa de archivos

| Qué | Dónde |
|---|---|
| Estado, misiones, banderas, diario, guardado (`user://partida.json`) | `scripts/autoload/juego.gd` |
| Calidad gráfica (baja/media/alta) e idioma (`user://opciones.cfg`) | `scripts/autoload/calidad.gd` |
| Sonidos (CC0 de `assets/audio/sfx/`) | `scripts/autoload/sonido.gd` |
| Capturas y pruebas sin pantalla | `scripts/autoload/captura.gd`, `scripts/pruebas/prueba.gd`, `herramientas/capturar.sh` |
| Escena principal: arma todo y conecta la lógica de cada misión | `scripts/mundo/eldervald.gd` |
| Datos del mapa (lugares, caminos, ríos, quebrada, puentes; 1 px = 0,33 m) | `scripts/mundo/datos.gd` |
| Terreno, agua, vegetación | `scripts/mundo/terreno.gd`, `agua.gd`, `vegetacion.gd` |
| Lugares y objetos de cada misión | `scripts/mundo/escenario.gd` |
| Luz rúnica (luz + motas + brillo del modelo) | `scripts/mundo/luz_runica.gd`, `assets/sombreadores/runico.gdshader` |
| Diálogos y en qué lugar está cada NPC según la misión | `scripts/mundo/guion.gd` |
| Héroe, cámara, NPC, enemigos, Ciervo Hueco, soportes, avisos del piso | `scripts/personajes/` |
| Interacción, Lente del Eco y marcas reveladas | `scripts/interaccion/` |
| Interfaz (objetivo, salud, diálogo, jefe, diario, pausa, título, cierre) | `scripts/interfaz/hud.gd` |
| Textos ES/EN | `textos/textos.csv` (se genera con `herramientas/textos.py`) |

## Animaciones

Todos los humanoides (Eromash, Eydis, Orm, Svanhild, trabajadores, Errantes) comparten esqueleto: al importar, cada `.glb` se reasigna al perfil humanoide de Godot con `assets/modelos/mapa-humano.tres`, y por eso usan las animaciones del héroe. Para sumar un pack de animaciones nuevo alcanza con importarlo con el mismo mapa de huesos y agregarlo en `Animaciones.dar_animaciones()`.

- El lobo se anima por código (patas, cola, cuello) hasta que tenga sus propias animaciones; el esqueleto de las patas traseras todavía tiene pesos rotos.
- El Custodio no tiene esqueleto: se inclina entero.

## Qué es provisorio

- **Ciervo Hueco**: armado con formas simples y el Núcleo real entre las astas. Si aparece `assets/modelos/enemigos/ciervo-hueco.glb`, se usa ese.
- **Lente del Eco** (en mano) y **rueda del aserradero**: provisorios hechos por código.
- Las cinemáticas son diálogos con fundido; no hay cámaras de cine todavía.
- La esquiva ya tiene física, costo y cancelaciones; su animación usa un paso provisional hasta recibir los cuatro clips direccionales de Mixamo (`docs/combate.md`).
- El mundo tarda en armarse (unos 20 s en una PC normal): falta optimizar el escenario y los NPC.

## Pruebas sin pantalla

Banco de combate separado de la campaña: abrir `escenas/prueba_combate.tscn` y F6. V cambia el multiplicador de ataque entre 0,5× y 2,5×; T repone al héroe y recrea dos errantes. No guarda la partida. Para pruebas automáticas en Windows:

```powershell
& C:/Godot/Godot_v4.7.2-stable_win64_console.exe --headless --path . res://escenas/prueba_combate.tscn --fixed-fps 60 -- --pruebas-combate
```

La batería comprueba impactos reales, combo, cancelaciones, esquiva, resistencia, paredes, pendiente, caída, frecuencias físicas, enemigo real, interacciones, pausa, idiomas y entradas de teclado/mando. Sale con código 1 si falla alguna comprobación.

```
herramientas/revisar.sh                    # que compilen todos los scripts
herramientas/capturar.sh res://escenas/principal.tscn salida.png 45 1280 720 --guion=claro --calidad=1
```

Guiones: `inicio`, `puesto`, `carro`, `refugio`, `eikholt`, `casa`, `paso`, `claro`, `jefe` (pelea con el Ciervo ya empezada), `aserradero`, `santuario` (ponen la partida en ese punto) y `recorrido` (marca la cadena entera y saca una foto por misión). Cada proceso usa unos 3 GB: correr de a uno.
