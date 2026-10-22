# Hoja de ruta (TO-DO)

Estado del trabajo y lo que falta, por etapa. Las metas están en `docs/objetivos.md`; las ideas propuestas que esperan el visto bueno de Alejandro, en `docs/pendientes.md`. Al cerrar un punto, marcarlo acá en el mismo commit.

Estado al 22/10/2026. **Foco actual: solo Eldervald** (y la Arena para la demo); el resto de la campaña no se construye todavía. Leyenda: ✅ hecho · 🟡 a medias o provisorio · ⬜ sin empezar · 🔵 hecho en un PR que espera revisión.

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
| EL-07 Alguien me espera | 🟡 | Poner la rueda del aserradero en 3D (el modelo ya existe en la carpeta de Tripo, con su soporte y canaleta); vestigio de la mano en el Santuario |

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
| Ciudades que cargan aparte (aprobado por Alejandro el 22/10/2026), para Eikholt y todas las capitales: la ciudad es su propia escena, se carga en segundo plano al cruzar un anillo exterior (~80 m) y se descarga al alejarse más allá de él; desde afuera queda una silueta liviana; los habitantes siguen un horario y al cargar aparecen donde estarían a esa hora; el estado permanente vive en `Juego` | ⬜ | Documento "Eikholt, capital de Eldervald". Depende de decidir si hay ciclo de día y noche; falta definir qué pasa con un enemigo que persigue hasta la puerta y cómo las escenas de misión pisan el horario |
| Mundo por sectores: el bosque (y cada región) dividido en sectores que cargan y descargan según dónde está el jugador, en vez de armar todo Eldervald de una vez (aprobado por Alejandro el 22/10/2026, «toda mejora es bienvenida») | ⬜ | La mejora más grande; necesaria para sumar regiones |
| Niveles de vida de los personajes: cerca, todo (animación, mirada, reacciones); a media distancia, animación más lenta y sin lógica; lejos, quietos o figuras simples | ⬜ | Aprobado el 22/10/2026; clave para los 25 personajes de Eikholt |
| Luz horneada en lo que no se mueve (casas, Roble): solo los faroles cercanos con luz real | ⬜ | Aprobado el 22/10/2026; colgado de Opciones → Video donde corresponda |
| Precompilar materiales y efectos durante la carga, para que entrar a un lugar nuevo no tenga tirones | ⬜ | Aprobado el 22/10/2026 |
| Objetos repetidos dibujados en bloque (barriles, cintas, hongos, huertas) | ⬜ | Aprobado el 22/10/2026 |
| Carga anticipada según hacia dónde va el jugador (un camino que solo lleva a la ciudad empieza a cargarla antes del anillo) | ⬜ | Aprobado el 22/10/2026; parte del sistema de ciudades |

### Cinemáticas

- ⬜ Corregir la historia y el guion de las 13 cinemáticas donde chocan con la campaña completa, que manda desde el 22/10/2026 (afecta al PR #1).

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
- ⬜ Árboles propios en 3D, viejos, enormes y con musgo (referencia: `docs/referencias/eldervald/puesto-eydis-v2.png`, ver `docs/eldervald.md` 9.2).
- ⬜ Identidad 3D propia (casas nórdicas, árboles, interactuables, un hito por zona): propuesta en `docs/pendientes.md`.

### PRs de mejoras chicas, todos esperando revisión

#8 guardado que no queda a medias · #9 opciones de video seguras · #10 cámara que no atraviesa · #11 golpes enemigos que respetan muros · #12 el Ciervo respeta la geometría · #13 daño por caída · #14 interactuar con lo que se mira · #16 distancia al objetivo en metros.

## 2. Demo para Steam

⬜ Todo sin empezar. Alcance decidido (22/10/2026): la Arena de Hrafngard, donde le dan a Eromash la misión de ir al bosque, y después Eldervald. **Duración objetivo: 40 minutos de juego solo en Eldervald** (Alejandro, 22/10/2026), sumando la misión principal y las secundarias, sin contar cofres ni coleccionables; la Arena se suma aparte.

- ⬜ Medir cuánto dura hoy la cadena EL-01 a EL-07 jugándola en la PC.
- ⬜ Elegir las secundarias de la demo (sección 4.2) para llegar a los 40 minutos.

- ⬜ Arena de Hrafngard jugable hasta el trato con el rey (falta diseñar qué se juega ahí).
- ⬜ Paso de la Arena al Puesto de Eydis (cinemática 2 o transición).
- ⬜ Lo del lanzamiento: Steamworks (logros, nube, overlay), prueba en Steam Deck (1280×800, todo con mando), página de tienda con cápsulas, capturas y tráiler, voces con licencia comercial.

## 3. Juego completo

⬜ Sin empezar. El recorrido está en `docs/campana-completa.md` (recuperado el 22/10/2026): 17 tramos, cinco herramientas y siete retornos obligatorios. Manda sobre `docs/historia-y-cinematicas.md` (Alejandro, 22/10/2026).

### Herramientas, en orden

| Herramienta | Dónde se consigue | Qué abre |
|---|---|---|
| Lente del Eco | Eldervald, primera visita (✅ en el MVP) | Huellas, inscripciones y señales ocultas |
| Antorcha Fatua | Monte Eldrakar | Quema barreras espirituales; abre el Santuario de Eldervald |
| Hilo de Resonancia | Eldervald, dentro del Santuario | Conecta mecanismos y estaciones rúnicas |
| Barco reconstruido | Havnskar | Skeldra, accesos costeros y, más tarde, Helheim |
| Lente modificada | Eldrakar, al volver de Skeldra | La ruta marítima oculta a Helheim |

### Recorrido

| # | Región | Qué pasa | Estado del diseño |
|---|---|---|---|
| 1 | Arena de Hrafngard | El trato con el rey | Antecedente; no jugable en el MVP |
| 2 | Eldervald (1.ª visita) | EL-01 a EL-07 | ✅ Fichas completas y jugable |
| 3 | Jarnskald | Acceso inicial a Yggdrasil por la cordillera | ⬜ Sin fichas |
| 4 | Yggdrasil | Árbol aparentemente sano; se abren dos ramas en cualquier orden | ⬜ Sin fichas |
| 5 | Hrimvard (1.ª) | Registros de la red; mecanismo del lago Iskeld que no se puede activar | ⬜ Sin fichas; Astrid y Torvald a ajustar |
| 6 | Monte Eldrakar | Santuarios funerarios; se consigue la Antorcha; marcas de la forja sin entender | ⬜ Sin fichas |
| 7 | Eldervald (2.ª), misiones 8 y 9 | Se queman las zarzas, sección bajo el bosque, Hilo, estación que apunta al lago Iskeld | ⬜ Sin fichas |
| 8 | Hrimvard (2.ª) | Con el Hilo se activa la estación; ruta bajo Jarnskald | ⬜ Sin fichas |
| 9 | Jarnskald subterráneo | Llegada a Valdheim; el brasero encendido; los espíritus reconocen a su rey | ⬜ Sin fichas |
| 10 | Valdheim | Refugio, reclutas, edificios, entrenamiento y fabricación (sin exigir reconstruir todo) | ⬜ Sin fichas ni sistema |
| 11 | Yggdrasil (regreso) | Antorcha + Lente + Hilo identifican a Níðhöggr; la clave está en Skeldra | ⬜ Sin fichas |
| 12 | Havnskar | Reparar el barco: pieza en Jarnskald (Hilo), astillero maldito de Vargstrand (Antorcha), un constructor | ⬜ Constructor y piezas sin definir; Yrsa y el *Cuervo Gris* a consolidar |
| 13 | Islas de Skeldra | El método para ver al parásito: modificar la Lente | ⬜ Sin fichas |
| 14 | Revelación de Odín | Eromash rompe el trato pero sigue | ⬜ Ubicación exacta sin cerrar |
| 15 | Eldrakar (regreso) | Cámara de la forja; Lente modificada | ⬜ Sin fichas |
| 16 | Helheim | Conseguir lo que mantiene expuesto a Níðhöggr | ⬜ Objeto, custodios y jefe sin definir |
| 17 | Raíces de Yggdrasil | Desenlace; Eromash elige su relación con Valdheim | ⬜ Sin fichas |

### Lo que falta definir antes de construir otra región

- Fichas de misión de cada región, como las de Eldervald: personajes, objetos, diálogos y jefes.
- Cómo se expone a Níðhöggr y dónde se enfrenta a Odín.
- El sistema de Valdheim (reclutas, edificios, fabricación).
- El tamaño de la versión 1.0: qué tramos entran y cuáles quedan para después.
- Ubicar en el mapa del mundo Skeldra, Vargstrand y el lago Iskeld.

## 4. Ideas para sumar (propuestas, sin aprobar)

Banco de ideas para elegir. Ninguna está aprobada: antes de construir una, Alejandro la confirma (regla "no adelantarse") y pasa a la sección de su etapa con ⬜. Cada una dice dónde encaja: **MVP**, **Demo** o **Completo**. Las del MVP amplían su alcance actual (`misiones-principales-eldervald.md`, sección 8, deja las secundarias afuera), así que sumarlas es también una decisión de alcance.

### 4.1 Misiones menos directas

Que llegar al objetivo cueste pensar y explorar, sin dejar al jugador perdido: cada paso sigue nombrando una persona, un lugar o una acción.

- **Indicaciones habladas en vez de marcador exacto.** El diario y el minimapa marcan una zona ("al norte del Refugio, cerca del arroyo"), no un punto. Un ajuste de Opciones elige entre marcador exacto, zona o nada. **MVP**
- **Rastreo de verdad en EL-04.** Las huellas del Ciervo se pierden en el agua o en roca; hay que buscar la siguiente con la Lente en un radio. Pistas falsas de otros animales que llevan a un nido o a un cofre. **MVP**
- **Obstáculos en el camino de cada misión.** Un árbol caído obliga a rodear por la quebrada, un puente colgante roto pide buscar otro cruce, una zona de zarzas se rodea por arriba. **MVP**
- **Acertijos rúnicos cortos.** Piedras que hay que encender en orden leyendo una inscripción con la Lente, un mecanismo que se gira hasta que las runas coinciden con el calco. Uno por misión como mucho. **MVP**
- **Conversaciones que piden atención.** Un NPC menciona un detalle ("el carro iba con el eje flojo") que después sirve para encontrar algo; no se marca solo. **MVP**
- **Caminos con más de una forma de resolverse.** En EL-02, despejar a los errantes peleando o encendiendo los faroles del círculo para espantarlos. **MVP**
- **El croquis de Eydis se completa explorando.** El mapa empieza con huecos y se dibuja a medida que se recorre, con trazo de tinta. **MVP**

### 4.2 Misiones secundarias

Chicas, con personajes propios y algo que cuentan del bosque, nunca recados de "traeme 10". Lugares que el MVP ya reserva: Brunvik, Skarnholt, túmulo, caravana y torre.

- **La caravana detenida.** Comerciantes varados por los errantes; protegerlos de noche en el campamento. Desbloquea al primer comerciante. **MVP/Demo**
- **El túmulo que respira.** Un túmulo antiguo con una piedra que habla con su propia esencia (no Runa). Mini mazmorra corta con un jefe menor y un fragmento de historia del bosque, sin pistas del pasado de Eromash. **Demo**
- **La torre del vigía.** Subir a la torre en ruinas, repararle el farol y desbloquear la vista del mapa de la zona. **MVP**
- **El trabajador que falta.** Uno de la cuadrilla de Orm no volvió al Refugio: buscarlo con la Lente siguiendo rastros. Termina bien o mal según lo rápido que se lo encuentre. **MVP**
- **Brunvik y el pozo envenenado.** Un caserío con el agua corrompida; seguir el agua hasta la raíz enferma que la contamina. **Demo**
- **Skarnholt, los leñadores rivales.** Dos familias pelean por un claro; elegir a quién ayudar cambia qué te venden y un diálogo final. **Completo**
- **Las piedras dormidas.** Cinco piedras rúnicas apagadas por el bosque; despertarlas una a una da una pequeña mejora permanente y una línea de su esencia. **MVP**
- **Pedidos de los aldeanos de Eikholt.** Tablero con encargos cortos: cazar un lobo marcado, encontrar una herramienta perdida, escoltar a una niña hasta el Refugio. **MVP/Demo**
- **El cazador de trofeos.** Enemigos élite con nombre en zonas apartadas (por ejemplo, un lobo de zarzal gigante) con botín propio. **Demo**
- **Los pilares del Hilo.** Los dos pilares desconectados cerca de la caravana se pueden investigar con la Lente y dejan una entrada de diario que anticipa el Hilo de Resonancia. **MVP**

### 4.3 Personajes y voces

- **Voces para Eydis, Orm, Svanhild y Eromash** con ElevenLabs (plan pago, uso comercial), en español e inglés, en las líneas principales de cada misión. **MVP**
- **Murmullos para el resto**: frases cortas de saludo, sorpresa y despedida en aldeanos y trabajadores, sin doblar todo. **MVP**
- **Voz propia para cada piedra rúnica**: cada esencia suena distinto (grave, cansada, aguda), con efecto de eco. **MVP**
- **Eromash comenta en voz alta** al descubrir lugares o al quedarse sin pistas ("Las huellas se cortan acá."). Pocas líneas, sobrias. **MVP**
- **Charlas de fondo** entre NPC al pasar (dos trabajadores, Eydis con un guardia). **Demo**
- **Rutinas de día y noche** de los NPC: trabajan, comen, duermen. **Completo**
- **Animales y aldeanos con vida**: ciervos, cuervos y zorros que huyen; niños que corren en Eikholt. **Demo**
- **Compañero opcional**: Eydis acompaña en ciertos tramos y ayuda en la pelea. **Completo**
- **Retratos con expresiones** en el recuadro de diálogo (neutral, preocupado, enojado). **MVP**

### 4.4 Combate y enemigos

- **Más variedad en Eldervald**: errante arquero, lobos que atacan en manada y rodean, custodio que se cubre con corteza y hay que romperla. **MVP/Demo**
- **Enemigos élite** con modificadores (quemadura, veneno, frío) tomados de la arena (`eromash-juego/docs/elites.md`). **Demo**
- **Ataque cargado y golpe de remate** cuando el enemigo queda aturdido. **Demo**
- **Parada perfecta**: bloquear justo a tiempo devuelve el golpe. **Demo**
- **Habilidades rúnicas** que se aprenden de las piedras despertadas (empuje de luz, escudo rúnico), con recarga. **Completo**
- **Un segundo jefe opcional** en el túmulo, con las reglas fijas de los jefes de la arena (aviso en el piso, tope del 35 %, saltar evita todo, nunca tres veces el mismo ataque). **Demo**
- **Dificultad elegible** (Historia, Normal, Difícil). **Demo**

### 4.5 Progresión y botín

- **Niveles y atributos** como en la arena, adaptados a la aventura. **Demo**
- **Botín con rarezas** (común, rara, épica, legendaria) siguiendo `eromash-juego/docs/botin.md`. **Demo**
- **Comerciante y herrero** en Eikholt: comprar, vender, mejorar piezas. **Demo**
- **Equipo que se ve en el cuerpo** al cambiar piezas (sigue del banco `docs/prueba-equipo.md`). **MVP/Demo**
- **Cofres escondidos** que solo muestra la Lente, y cofres con trampa. **MVP**
- **Coleccionables con historia**: tablillas de ruta de Eydis, páginas de registros, runas talladas; cada uno suma una entrada al diario. **MVP**
- **Recetas de pociones** con plantas del bosque. **Completo**

### 4.6 Mundo y exploración

- **Ciclo de día y noche** con niebla y enemigos distintos de noche. **Demo**
- **Clima**: lluvia, niebla espesa, viento en las copas. **Demo**
- **Fogatas como puntos de descanso y guardado**, que reponen pociones y reaparecen enemigos comunes. **MVP**
- **Viaje rápido** entre piedras rúnicas despertadas. **Demo**
- **Cuevas chicas** con oscuridad total y antorcha (criterio de sombras de `direccion-artistica.md`, 5c). **Demo**
- **Nadar o vadear** el río en tramos poco profundos. **Completo**
- **Escalar** salientes marcados con musgo rúnico. **Completo**
- **Pesca o caza** como pausa tranquila. **Completo**

### 4.7 Historia y cinemáticas

- **Cómo jugar la Arena**: la última pelea en la fosa como tutorial de combate, antes del trato con el rey (la Arena ya entra en la demo; esto es una idea de qué hacer en ella). **Demo**
- **Cinemáticas cortas con el motor** para EL-01 (llegada al Puesto), EL-02 (la piedra habla), EL-05 (muerte del Ciervo) y EL-07 (la mano en el Santuario). **MVP**
- **Diario escrito por Eromash**, con su voz, que resume cada misión. **MVP**
- **Final de la demo** con un adelanto del Bastión de Hrimvard. **Demo**

### 4.8 Interfaz y calidad de vida

- **Remapeo de controles** para teclado y mando. **MVP**
- **Accesibilidad**: tamaño de subtítulos, daltonismo para los colores rúnicos, menos sacudida de cámara. **Demo**
- **Modo foto** con la cámara libre (aprovecha el modo admin). **Demo**
- **Varias ranuras de guardado** y guardado automático visible. **MVP**
- **Pantallas de carga con arte e historia** mientras se arma el mundo. **MVP**
- **Brújula rúnica** arriba de la pantalla con los objetivos y lugares cercanos. **MVP**

### 4.9 Steam y lanzamiento

- **Logros** (despertar todas las piedras, vencer al Ciervo sin recibir daño, encontrar todos los coleccionables). **Demo**
- **Nube de Steam** para la partida. **Demo**
- **Tráiler** con escenas del juego y la música propia. **Demo**
- **Prueba con jugadores** (amigos o la comunidad del stream) antes del Next Fest, con un formulario corto. **Demo**
- **Localización a más idiomas** (portugués primero, por la comunidad). **Completo**

## Próximos pasos sugeridos

1. Revisar y unir los PRs abiertos (14 en total), empezando por los chicos (#8–#16), que no chocan con nada.
2. Resolver las preguntas abiertas de `docs/objetivos.md`, sección 5.
3. Pasada jugada del MVP completo en la PC, midiendo FPS con F3 (Paso F).
4. Cerrar los provisorios de las misiones (tabla de arriba).
5. Elegir de la sección 4 qué ideas entran al MVP y cuáles quedan para la demo.
