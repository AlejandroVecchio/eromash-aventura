# Cinemática 2 — El eco del yelmo y el trato · plan para aprobar

Se ve al elegir «Nueva partida», antes de llegar al Puesto de Eydis. Mismo sistema y mismo estilo que el prólogo (2.5D sobre pergamino, `Cinematica25D`). Sale de `docs/historia-y-cinematicas.md` (Cinemática 2), con los cambios que mandan arriba de todo en esa guía: **el casco queda entero, con la E de pie** (la «grieta» es solo la hendija fina de donde Bera saca la astilla, nunca atraviesa la E) y los nombres de lugares de los mapas. No revela que el rey es Odín: solo se ve un ojo bajo la capucha.

Duración pensada: ~1 min 30 s, 6 planos. Nada de esto está hecho: espera tu visto bueno y las ilustraciones.

## Planos

| # | Plano | Qué se mueve | Quién habla |
|---|---|---|---|
| 1 | **La Arena (picado).** La fosa de arena con sangre, gradas llenas, murallas cerradas de la ciudadela. Eromash de pie sobre la bestia de Helheim caída; bajo ellos, una losa rúnica que empieza a encenderse azul. | La cámara baja desde las gradas hasta Eromash; polvo y antorchas que laten; la losa se enciende. | — (tambores amortiguados) |
| 2 | **Los ojos de la bestia (primerísimo primer plano).** En sus ojos se refleja el brillo azul del casco de Eromash. | Acercamiento lento; la luz del reflejo late; al final la losa se quiebra (temblor + destello). | Bestia: «Otra vez…» |
| 3 | **La cámara del rey (plano medio lateral).** El rey de capa gris, en sombras; solo un ojo brilla bajo la capucha. | Paneo lento; velas que laten. | Rey: «La hoja entró en diagonal, rasgando la sien derecha.» |
| 4 | **El medallón (sobre el hombro de Eromash).** De espaldas, el casco con la E en primer término; sobre el escritorio gira un medallón real. | El medallón brilla al girar; la cámara se acerca por encima del hombro. | Rey: «Yo estuve allí. Llegá al árbol y te devolveré tu nombre.» |
| 5 | **La forja de Bera (plano detalle).** Las tenazas de Bera sacan una astilla negra de la hendija del casco (casco entero, E intacta); de la astilla sale un hilo de humo frío. | Foco que se desplaza del casco a la astilla; brasas de la forja que laten; humo. | Bera: «Esto no es metal quemado, Eromash. Es madera del lecho profundo.» · «Buscá a Eydis, la guardabosques, en los bosques del oeste.» |
| 6 | **La puerta de hierro.** La puerta de la ciudad se abre hacia el camino del oeste; Eromash de espaldas, contra la luz. | La puerta se abre (capa que se desliza), luz que entra, la cámara avanza. Cierre al pergamino y paso al juego en el Puesto de Eydis. | Narrador (opcional): «Con una astilla del lecho del mundo y un nombre por recuperar, Eromash dejó atrás la fosa.» |

Transiciones (las mismas del prólogo): 1→2 acercamiento que florece desde los ojos, 2→3 destello rúnico de la losa que se quiebra, 3→4 corte por la página, 4→5 acuarela desde el medallón, 5→6 la página se desliza hacia el camino, cierre a pergamino.

## Textos (ES / EN, para `textos.csv` y voces)

| Clave | Quién | Español | English |
|---|---|---|---|
| `cine_trato_01` | Bestia | Otra vez… | Again… |
| `cine_trato_02` | Rey | La hoja entró en diagonal, rasgando la sien derecha. | The blade went in at an angle, tearing across the right temple. |
| `cine_trato_03` | Rey | Yo estuve allí. Llegá al árbol y te devolveré tu nombre. | I was there. Reach the tree, and I will give you back your name. |
| `cine_trato_04` | Bera | Esto no es metal quemado, Eromash. Es madera del lecho profundo. | This isn't burnt metal, Eromash. It's wood from the deep bed. |
| `cine_trato_05` | Bera | Buscá a Eydis, la guardabosques, en los bosques del oeste. | Find Eydis, the ranger, in the western woods. |
| `cine_trato_06` | Narrador (opcional) | Con una astilla del lecho del mundo y un nombre por recuperar, Eromash dejó atrás la fosa. | With a splinter from the world's deep bed and a name to reclaim, Eromash left the pit behind. |

Nombres nuevos: `nombre_rey` (El rey / The King), `nombre_bera` (Bera), `nombre_bestia` (Bestia de Helheim / Helheim beast). Voces nuevas: rey (grave, contenido, peligroso), Bera (herrera, firme y cálida), bestia (ronca, agonizante). Con el plan gratuito de ElevenLabs solo hay voces premade; con un plan pago se pueden diseñar.

## Ilustraciones que hacen falta (18 capas, mismas reglas que el prólogo)

Cada plano en tres capas: `fondo` (opaco, completo), `medio` y `frente` (PNG con transparencia real). **Mejor directo en 4K y más anchas que 16:9 (por ejemplo 4400×2160)**, sin papel, viñeta ni manchas pintadas (el pergamino lo pone el juego), y con el mismo estilo de la serie «tinta» del prólogo (tinta negra y marrón, aguadas de acuarela, color al 60–70 %). Luz rúnica en azul `#73D5DB`.

Regla del casco en toda imagen con Eromash: **la E oficial rotada, con las tres puntas hacia arriba (`assets/marca/casco-e.svg`), entera; Eromash nunca se saca el casco**. Lo reviso capa por capa antes de usarla.

Material que ya existe y conviene pasar como referencia:
- Eromash y su casco: `docs/referencias/eromash/`, `assets/marca/casco-e.svg`, `docs/referencias/casco-e.js`; en el repo de la arena, `output/teaser/adjuntar/4-eromash-arena.png` y `output/imagegen/teaser-runas-del-olvido/02-casco-arena.png`.
- La Arena: `juego/img/escenas/arena.png` y `juego/mapas/fondos/arena.png` (repo de la arena).
- El rey: `juego/img/npc/rey.svg` (repo de la arena).

Prompt base (se suma al de cada plano):

> Hand-drawn dark fantasy illustration for a 2.5D motion comic, same style as the EROMASH prologue: expressive black and dark-brown ink lines, hatching, transparent watercolor washes at 60–70% saturation, deep ink-wash shadows. Runic light is cyan blue #73D5DB. Wide 4K canvas wider than 16:9. No paper texture, no vignette, no stains, no text, no logos. Eromash always wears his full helmet shaped as the official E rotated with its three points facing up (see reference), whole and undamaged; never remove or break the helmet.

| Plano | Fondo | Medio | Frente |
|---|---|---|---|
| 1 Arena | Gradas llenas de público, murallas cerradas de la ciudadela, cielo gris, picado desde arriba | Eromash de pie con la espada, sobre la bestia de Helheim caída; losa rúnica bajo ellos con runas azules apagadas | Rejas de hierro y estandartes rotos en primer término, transparente alrededor |
| 2 Ojos | Penumbra cálida de arena y polvo | Primer plano de los ojos de la bestia con el reflejo azul del casco de Eromash | Polvo y arena suspendidos, transparente |
| 3 Rey | Cámara de piedra con tapices y velas | El rey de capa gris en sombras, perfil, un solo ojo que brilla bajo la capucha | Borde de una columna y una vela, transparente |
| 4 Medallón | Escritorio de madera tallada y el rey borroso al fondo | Medallón real girando sobre la mesa | Hombro y casco de Eromash de espaldas (E de pie, entera), transparente |
| 5 Forja | Forja con brasas y herramientas | Casco de Eromash sobre el yunque (entero, E intacta) y las tenazas de Bera sacando una astilla negra con humo frío | Manos y antebrazo de Bera con guante de cuero, transparente |
| 6 Puerta | Camino del oeste hacia los bosques, luz de mañana | Puerta de hierro de la ciudadela abriéndose | Eromash de espaldas en el umbral, capa y casco, transparente |

## Para decidir

1. ¿Va este orden de planos y estos textos? En especial: la línea de Bera que manda a buscar a Eydis y la línea opcional del narrador al final.
2. ¿Las ilustraciones las generás vos (como las del prólogo) o querés que te pase el prompt exacto de cada capa en un archivo aparte?
3. Voces: ¿seguimos con voces premade del plan gratuito para el borrador, o esperamos al plan pago?
4. El prólogo hoy se ve **cada vez** que se abre el juego (se salta manteniendo F). ¿Lo dejamos así o solo la primera vez?
