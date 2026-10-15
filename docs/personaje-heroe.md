# Eromash: el personaje jugable

Cómo se mueve y se comporta el héroe. Sale del prototipo anterior (three.js, `aventura/src/personaje/completo.js` del repo de la arena), que ya estaba ajustado a mano y probado: **en Godot se rehace igual**, con estos mismos números, salvo que Alejandro pida cambiarlos.

Actualización autorizada del 15/10/2026: combate con esquiva, resistencia, cancelaciones y velocidad de ataque por estadísticas. Las secciones de combate de este documento incluyen ese cambio. Detalles, pruebas y animaciones pendientes en `docs/combate.md`.

## Modelo

- Archivo: `assets/modelos/personaje/eromash-completo.glb` (hecho con Tripo y armado en Blender).
- Esqueleto Mixamo de 65 huesos (en Godot: `mixamorig_Hips`, `mixamorig_HeadTop_End`, etc.).
- Mallas: `eromash` (cuerpo), `espada`, `escudo`, `relleno`, y dos copias que **no se dibujan**: `espada_guardada` (cadera, un poco el muslo, como una vaina que cuelga) y `escudo_guardado` (espalda). Solo dicen dónde va cada arma cuando está guardada, cuadro a cuadro. Si traen el dato `ajuste` (matriz 4×4 en los extras del nodo, hecha en Blender) se usa esa transformación de la mano al lugar de guardado; si no, se calcula con cuatro vértices bien separados (mismo orden de vértices en las dos mallas) y se verifica con el resto.
- Altura en el juego: 1,85 m. Escalar por las posiciones de reposo de los huesos (cabeza y punta del pie), no por la malla: en el archivo tienen escalas distintas.
- Piezas sueltas de equipo para el sistema de armaduras: `assets/modelos/personaje/` (casco, capa, pechera, brazo, botas, espada, escudo).
- El casco es **siempre la E oficial rotada, con las tres puntas arriba** (`assets/marca/casco-e.svg`). Nunca se pierde ni se deforma.

### Animaciones del archivo (34)

abrir_cofre, abrir_puerta, ataque, ataque2, beber, bloquear, bloqueo, caminar, caminar_armado, correr, correr_armado, descanso, descanso2, desenvainar, envainar, golpe, golpe2, golpe3, grito, guardia, guardia_mirar, guardia_mirar2, hechizo, levantar, levantar_armado, mecanismo, morir, palanca, patada, salto_armado, salto_libre, soltar_bloqueo, tomar, trepar.

- **Se reproducen una vez** (no en bucle): ataque, ataque2, patada, bloquear, soltar_bloqueo, golpe/2/3, morir, grito, hechizo, envainar, desenvainar, guardia_mirar/2, descanso/2, salto_libre, salto_armado, trepar y todas las interacciones.
- **Sin avance propio** (lo pone el juego): ataque, ataque2, patada, bloquear, golpe/2/3, grito, hechizo, envainar, desenvainar, los dos saltos y todas las interacciones. Se saca **solo el avance que la animación acumula de punta a punta**, sin recentrar la cadera: los golpes de Mixamo empiezan y terminan en la guardia, y recentrarlos hace que los pies se deslicen al volver.
- **Caminar y correr**: se les saca el avance hacia adelante y la velocidad de reproducción se ajusta a la velocidad real (velocidad / velocidad natural del clip), entre 0,6× y 2,2×.
- Al importar se pueden descartar las pistas de escala y posición que no cambian en todo el clip (Blender las exporta para los 65 huesos y son dos tercios de las pistas).

## Dos modos

- **ARMADO**: espada en la mano derecha y escudo en la izquierda. Quieto respira en guardia; a los 6 s mira a los costados (`guardia_mirar` o `guardia_mirar2` al azar); si sigue quieto 4 s más, envaina solo. Camina y corre en guardia (`caminar_armado`, `correr_armado`), ataca y bloquea.
- **LIBRE**: espada colgada en la cadera izquierda y escudo en la espalda. Descansa con `descanso`/`descanso2` que rotan al azar (70 % de cambiar a la otra al terminar), camina y corre más suelto, e interactúa con el mundo.
- Atacar o bloquear sin armas las saca primero (rápido); interactuar armado las guarda primero, salvo las interacciones que tienen variante armada (`levantar` → `levantar_armado`).
- Tras atacar o bloquear hay **5 s de combate**: se queda en guardia sin mirar a los costados ni envainar.
- Moverse corta el mirar a los costados.

## Armas: envainar y desenvainar

Las armas son mallas rígidas que pasan de la mano a su lugar de guardado con una transición corta (0,22 s) en el momento justo en que la mano llega a la vaina o a la espalda. Segundos del clip, medidos en Blender:

| Clip | Escudo | Espada |
|---|---|---|
| envainar | 1,2 | 1,25 |
| desenvainar | 0,31 | 0,5 |

Cuando guarda o saca para hacer otra cosa (atacar, interactuar) va 1,5× más rápido.

## Movimiento

| Constante | Valor |
|---|---|
| Caminar | 2,4 m/s |
| Correr (sprint) | 6,5 m/s |
| Giro hacia donde camina | 12 (amortiguado) |
| Gravedad | 24 m/s² |
| Altura del salto | 1,3 m |
| Aceleración | amortiguado a 10 |
| Bloqueando | 0,3× de caminar |

- Pasa a la animación de correr desde 3,2 m/s; por debajo de 0,35 m/s está quieto.
- Si sale por un borde más alto que 0,45 m, cae con gravedad (usa el clip de salto desde la mitad del vuelo).

## Salto

El clip **sigue a la física**: no se reproduce solo, se lo pone en el segundo que corresponde según el tiempo en el aire.

| Clip | Aire (del impulso al toque) | Suelo (amortiguar) | Duración del amortiguar |
|---|---|---|---|
| salto_libre | 0,38 → 1,08 | 1,08 → 1,67 | 0,45 s |
| salto_armado | 0,17 → 0,79 | 0,79 → 0,96 | 0,2 s |

En el aire: `tiempo = aire[0] + (t_aire / vuelo) × (aire[1] − aire[0])`, con `vuelo = 2·√(2·g·h) / g`. Al tocar el piso: recorre el tramo de suelo durante el amortiguar. Usa el clip armado o libre según el modo.

## Ataque

- Combo de dos golpes: `ataque` y, si se vuelve a atacar dentro de **1,2 s** de terminar el anterior, `ataque2`.
- Velocidad de reproducción 1,15; se puede mover a **0,35×** mientras ataca; fundido 0,08 s.
- Velocidad efectiva: `1,15 × estadisticas.velocidad_ataque`. El multiplicador se fija al comenzar cada golpe; el impacto sigue el tiempo del clip. No acelera esquiva, caminar ni interacciones.
- Un clic tiene memoria de 0,22 s. En recuperación permite encadenar al alcanzar el 72 % del clip, sin esperar todo el final. Los clics demasiado tempranos caducan.
- Esquivar cancela preparación y recuperación. Entre `momento − 0,06` y `momento + 0,07` del clip hay compromiso; la entrada de esquiva puede esperar hasta 0,22 s a que abra la ventana.
- Cancelar borra eventos de daño y combo pendientes. El bloqueo puede cortar recuperación después de `momento + 0,07`.
- Un golpe recibido sin bloquear interrumpe el ataque y reproduce una reacción corta de 0,42 s. Las interacciones de misión conservan sus eventos.
- Los impactos respetan alcance, arco frontal, desnivel máximo de 2,5 m y obstáculos sólidos.
- Patada (prueba): se mueve a 0,2×.

## Bloqueo

- Mientras se mantiene el botón: `bloquear` (entrada), después `bloqueo` en bucle; al soltar, `soltar_bloqueo` (vuelve a la guardia dando el paso con el pie que retrocedió, sin arrastrarlo).
- Se mueve a 0,3× de caminar.
- Atacar sale del bloqueo; mantener el botón permite volver al escudo durante la recuperación del ataque.

## Esquiva y resistencia

- Alt en teclado; B en mando. Envainar en mando pasa a R3 (en teclado sigue X).
- Movimiento relativo a la cámara; sin dirección retrocede. Conserva orientación y normaliza diagonales.
- Distancia de 3 m en 0,4 s, con impulso inicial y frenado. Usa `move_and_slide`, colisiones con escenario y enemigos, y sigue pendientes. Salir de un borde termina la esquiva y activa caída.
- Invulnerabilidad entre 0,06 y 0,26 s de la esquiva base. El inicio y la recuperación son vulnerables. Pausa de 0,12 s al terminar; no puede cancelarse a sí misma ni iniciarse en el aire, muerto o en diálogo.
- Resistencia máxima 100; costo 30; regeneración 28/s después de 0,75 s desde el gasto. No regenera durante esquiva, bloqueo, muerte o diálogo. En esta entrega atacar y correr no consumen resistencia.
- Se repone al revivir o cargar una escena; todavía no se persiste como estadística de inventario. Se muestra en el HUD y avisa al intentar esquivar sin suficiente resistencia.
- Valores editables en `assets/datos/combate_heroe.tres`. El héroe duplica el recurso al entrar, para que las mejoras no modifiquen otros personajes.
- Animación provisional: aprovecha `bloquear`/`caminar`, con descenso e inclinación suaves. No es una animación definitiva de paso lateral o rodada. Los GLB direccionales previstos en `docs/combate.md` la reemplazan al iniciar.

## Interacciones

Se para frente al objeto (a la distancia que define el objeto), mirándolo, y queda quieto. Cada objeto dice qué animación usa y en qué segundo pasa lo suyo (se abre el cofre, baja la palanca…).

Recorte de cada clip (segundos del archivo, sin la espera quieta de Mixamo):

| Clip | Desde | Hasta | Velocidad |
|---|---|---|---|
| levantar | 0,79 | 4,13 | 2,4× |
| levantar_armado | 0,79 | 4,13 | 2,4× |
| tomar | 0,13 | 4,46 | 1× |
| abrir_cofre | 0,71 | 4,04 | 1× |
| abrir_puerta | 0,04 | 4,46 | 1× |
| palanca | 0,71 | 4,71 | 1× |
| mecanismo | 0,13 | 6,33 | 1× |
| beber | 1,88 | 5,79 | 1× |

**Trepar**: la animación sube el cuerpo entero; al terminar, la raíz se mueve a donde quedó la cadera (x, z) y a la altura de la repisa, y arranca el descanso **sin fundido** (la pose anterior está armada sobre la raíz de abajo).

## Otros

- Recibir golpe: `golpe`, `golpe2` o `golpe3` al azar, quieto, fundido 0,06.
- Morir: `morir` con fundido 0,15; se queda tirado hasta revivir (vuelve a guardia o descanso con fundido 0,4).
- `grito` y `hechizo`: quieto, sacan las armas si hace falta.
- Mientras muere o trepa no se aceptan entradas; mientras está en el aire no ataca, ni bloquea ni interactúa.
- El salto evita los ataques del MVP marcados como rasantes; ya no concede inmunidad universal por estar en el aire. La embestida del ciervo se evade por desplazamiento o por la ventana de esquiva.
