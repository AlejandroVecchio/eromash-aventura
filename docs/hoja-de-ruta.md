# Hoja de ruta (TO-DO)

Estado del trabajo y lo que falta, por etapa. Las metas están en `docs/objetivos.md`; las ideas propuestas que esperan el visto bueno de Alejandro, en `docs/pendientes.md`. Al cerrar un punto, marcarlo acá en el mismo commit.

Estado al 22/10/2026. Leyenda: ✅ hecho · 🟡 a medias o provisorio · ⬜ sin empezar · 🔵 hecho en un PR que espera revisión.

## 1. MVP de Eldervald

### Las siete misiones

Las siete están armadas en `scripts/autoload/juego.gd` (objetivos) y `scripts/mundo/eldervald.gd` (lógica), con diálogos ES/EN y pantalla de cierre del MVP. Revisado leyendo el código; falta una pasada jugada de punta a punta en la PC (ver Paso F).

| Misión | Estado | Lo que falta |
|---|---|---|
| EL-01 El camino que dejó de ser seguro | 🟡 | Arte final del Puesto y del carro |
| EL-02 Una voz bajo la piedra | 🟡 | Evacuación como secuencia (hoy diálogo con fundido) |
| EL-03 Lo que queda en el asta | 🟡 | Lente del Eco en mano es provisoria (hecha por código) |
| EL-04 Las huellas del guardián | 🟡 | Arte de la tala y la quebrada |
| EL-05 El Ciervo Hueco | 🟡 | Animaciones del Ciervo (hoy por código); el Núcleo entre las astas durante la pelea |
| EL-06 Un camino para los vivos | ✅ | Tiene la cinemática piloto (`_cine_nucleo`, `_cine_puente`) |
| EL-07 Alguien me espera | 🟡 | Rueda del aserradero provisoria; vestigio de la mano en el Santuario |

### Orden de construcción (`misiones-principales-eldervald.md`, sección 7)

- ✅ Paso A: recorrido básico, caminos, ríos, puentes y bloqueos.
- ✅ Paso B: Puesto, carro, Refugio, Eydis, Orm y trabajadores, primer contacto rúnico.
- ✅ Paso C: Eikholt, Casa de las Lindes, Svanhild, lente e inscripción.
- 🟡 Paso D: Paso, tala, quebrada, Claro, soportes, Ciervo y pedestal. Funciona; falta terminar arte y animaciones.
- 🟡 Paso E: corredor oriental, aserradero, Santuario cerrado, calco y cierre. Funciona; falta arte.
- ⬜ Paso F: acabado (luz y materiales de la guía en todos los lugares) y prueba de la cadena completa jugando: guardar y cargar, entradas anticipadas, morir y volver desde cada extremo.

### Sistemas

| Sistema | Estado | Dónde |
|---|---|---|
| Movimiento del héroe (trote, sprint, caminar, salto) | ✅ | `docs/personaje-heroe.md` |
| Combate (combo, guardia, esquiva con resistencia, cancelaciones) | ✅ | `docs/combate.md` |
| Esquivas direccionales con animación propia | 🟡 | Esperan clips; el `Roll` del banco sirve para adelante |
| Cámara | ✅ | 🔵 PR #10: que se acerque cuando algo se interpone |
| Interacción y Lente del Eco | ✅ | 🔵 PR #14: usar lo que se está mirando |
| Selección de NPC con retrato | 🔵 | PR #4, `docs/seleccion.md` |
| HUD, bolsa de 40 casillas, equipo por ranuras, visor 3D | ✅ | `docs/interfaz-aventura.md` |
| Equipo que se ve en el cuerpo (piezas que se cambian) | 🟡 | Banco de prueba armado (`docs/prueba-equipo.md`); no está en la campaña |
| Menú principal (Continuar, Nueva, Cargar) | 🔵 | PR #2 |
| Opciones → Video (Bajo a Ultra, ajustes 1–10) | ✅ | 🔵 PR #9: guardado seguro |
| Opciones → Sonido y volumen por buses | 🔵 | PR #3 |
| Guardado de la partida | ✅ | 🔵 PR #8: que no quede a medias |
| Puntero rúnico del mouse | 🔵 | PR #7 (falta elegir entre las cuatro opciones) |
| Sistema de cinemáticas con el motor | ✅ | `docs/mvp.md`, sección Cinemáticas |
| Animaciones humanas (banco de 44 clips) | ✅ | `docs/banco-animaciones.md` |
| Animaciones del lobo y el Ciervo | 🟡 | Por código hasta tener clips |
| Rendimiento (distancias, Activador, LOD, oclusión) | ✅ | Falta medir FPS en la PC; el mundo tarda ~20 s en armarse |
| Pruebas sin pantalla (combate 118, interfaz 90) | ✅ | `docs/mvp.md`, Pruebas sin pantalla |

### Cinemáticas

- ✅ Guion: las 13 reescritas para seguir la historia (🔵 PR #1).
- 🟡 Cinemática 1, el prólogo: textos y voces de prueba listos; rumbo del 18/10: clips hechos con IA de video externa y Godot los reproduce. Faltan los clips y el reproductor.
- ⬜ Cinemática 2 (la Arena y el trato) y las del MVP que no son la piloto.
- ⬜ Voces definitivas: las de prueba son del plan gratuito de ElevenLabs y no se pueden usar comercialmente.

### Sonido y música

- ✅ Dirección sonora aprobada (21/10/2026) y catálogo de prompts por tipo de sonido.
- ✅ Efectos CC0 provisorios conectados (`assets/audio/sfx/`).
- ⬜ Música, ambientes y efectos propios: los genera Alejandro con ElevenLabs a partir del catálogo; después se integran.
- ⬜ Música adaptativa (ambiente → exploración → tensión → combate).

### Arte

- ✅ Modelos 3D: Eromash, Eydis, Orm, Svanhild, armas, enemigos, Ciervo, Roble, Santuario, pedestal, piedras rúnicas (`docs/assets.md`).
- 🔵 PR #6: sombras al aire libre que dejan ver y faroles con sombra.
- 🔵 PR #5: pies que no patinan.
- ⬜ Identidad 3D propia (casas nórdicas, árboles, interactuables, un hito por zona): propuesta en `docs/pendientes.md`.

### PRs de mejoras chicas, todos esperando revisión

#8 guardado que no queda a medias · #9 opciones de video seguras · #10 cámara que no atraviesa · #11 golpes enemigos que respetan muros · #12 el Ciervo respeta la geometría · #13 daño por caída · #14 interactuar con lo que se mira · #16 distancia al objetivo en metros.

## 2. Demo para Steam

⬜ Todo sin empezar, y la etapa misma está propuesta (`docs/objetivos.md`). Lo que haría falta: decidir el alcance, Steamworks (logros, nube, overlay), prueba en Steam Deck (1280×800, todo con mando), página de tienda con cápsulas, capturas y tráiler, voces con licencia comercial.

## 3. Juego completo

⬜ Sin empezar. Primero hay que definir el orden de las regiones después de Eldervald.

## Próximos pasos sugeridos

1. Revisar y unir los PRs abiertos (14 en total), empezando por los chicos (#8–#16), que no chocan con nada.
2. Resolver las preguntas abiertas de `docs/objetivos.md`, sección 5.
3. Pasada jugada del MVP completo en la PC, midiendo FPS con F3 (Paso F).
4. Cerrar los provisorios de las misiones (tabla de arriba).
