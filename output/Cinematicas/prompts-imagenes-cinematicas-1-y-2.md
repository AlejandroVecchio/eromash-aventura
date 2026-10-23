# Prompts de imágenes — Cinemática 1 (Prólogo) y Cinemática 2 (La Arena y el trato)

Para generar todas las ilustraciones de las dos cinemáticas y después animarlas con una IA de video (Kling, Runway, Luma, Veo) o con Immersity.

- **Cinemática 1, «El susurro de las raíces»:** 10 planos.
- **Cinemática 2, «El eco del yelmo y el trato»:** 8 planos.
- **Total:** 18 planos.

Cada plano lleva **4 imágenes**: la final y sus 3 capas de profundidad (72 en total), más una versión en tinta opcional.

## Cómo usar este documento

1. En cada imagen pegá **siempre** el PROMPT MAESTRO de abajo y después el prompt específico de esa imagen.
2. Cada prompt es **completo y se usa solo**: las capas describen la escena entera como contexto y piden pintar solo su parte. Para que coincidan mejor, generá primero la FINAL y subila como referencia al generar sus capas; si tu IA no acepta referencias, los prompts igual funcionan solos.
3. **En toda imagen donde aparezca Eromash, adjuntá sus imágenes de referencia** (`docs/referencias/eromash/`): `estilo-frente.png` siempre, y según el plano `estilo-espalda.png` (de espaldas), `estilo-perfil-derecho.png` o `estilo-perfil-izquierdo.png` (de perfil). Si tu IA acepta solo una, usá la que coincida con el ángulo del plano. Pedile que lo **redibuje en el estilo del prompt** («same character, same design and colors, redrawn in ink and watercolor»). El casco es la E roja con las tres puntas hacia arriba, entera; nunca se lo saca.
4. **Nombres de archivo:** `c1_p01_final.png`, `c1_p01_fondo.png`, `c1_p01_medio.png`, `c1_p01_frente.png`… y para la Arena `c2_p01_…`.

### Las 4 imágenes de cada plano

| Archivo | Qué es | Medidas | Fondo |
|---|---|---|---|
| `_final` | La ilustración completa, como se ve en la cinemática. Es la que se anima con la IA de video. | **3840 × 2160** (16:9). Si la IA no llega, la máxima en 16:9 (mínimo 1920 × 1080). | Opaco, completo. |
| `_fondo` | Solo lo lejano: cielo, montañas, horizonte, arquitectura de fondo. Sin personajes ni objetos del medio y del frente; **el hueco donde estaban se rellena** con lo que habría detrás. | **4608 × 2160** (más ancha que 16:9, 10 % de margen a cada lado para paneos). Si la IA no permite, 21:9. | Opaco, completo. |
| `_medio` | El sujeto principal y lo que está a media distancia, **aislado**. | 3840 × 2160, misma posición y escala que en la final. | **Magenta liso #FF00FF** (lo recorto yo). Sin sombra proyectada sobre el magenta. |
| `_frente` | Solo lo más cercano a cámara (ramas, pasto, rejas, polvo, hombros), **aislado**. | 3840 × 2160, misma posición y escala que en la final. | **Magenta liso #FF00FF**. |

Uso magenta y no verde porque el verde aparece en los bosques. Si la IA permite PNG con transparencia real, mejor todavía.

---

## PROMPT MAESTRO (pegar al principio de cada imagen)

```
EROMASH — "Whisper of the Runes". Illustration for a 2.5D motion-comic cinematic of a Norse dark-fantasy video game.

STYLE: hand-drawn dark fantasy book illustration. Confident, expressive black and dark-brown ink linework with
variable line weight, visible pen hatching and cross-hatching in the shadows, a few loose construction strokes.
Transparent watercolor washes over the ink, local colors at 60–70 % saturation, slightly warmed, deep ink-wash
shadows, softer and lighter atmospheric distance. Painterly but readable silhouettes. Feels like a page of an
ancient Norse legend book brought to life. Reference mood: the RuneScape Dragonwilds prologue, Arcane-style
painted key art, old Scandinavian book illustrations.

COLOR AND LIGHT: muted forest greens (#30443B, #68704B), earth browns (#4C3C32, #78684E), stone grey (#737C77),
blue-green shadows (#182C2B). The signature light of the game is RUNIC BLUE: runes and ancient magic glow cyan
blue #73D5DB with an almost white core #D8F6F7 and a deeper #2F8FA0 halo; use it only where something runic or
magical is happening. Warm amber #E9B765 only for hearth fires, lanterns and village windows. Ember red #E0603C
only for things from Helheim, used sparingly. No other saturated colors.

COMPOSITION AND DEPTH: cinematic 16:9 framing, built in three clear depth planes — a distant background, a
midground with the main subject, and a close foreground element that partially frames the shot — so it can be
animated with parallax and camera moves. Clear focal point, strong value contrast between planes, atmospheric
perspective (far = lighter and bluer). Leave some breathing room at the edges for camera movement.

RUNIC ESSENCE (the soul of the game, must be visible in every image): runes are angular, carved, futhark-like
glyphs (invented, never readable words or letters) cut into stone, bark, iron or cloth. Healthy runes glow RUNIC
BLUE #73D5DB with an almost white core #D8F6F7 and a deeper #2F8FA0 halo; their light spills onto nearby surfaces,
mist and faces, and small blue motes float around them. Dying runes flicker in broken segments, then turn
charcoal grey with a last ember red #E0603C in the grooves. Village protection runes are painted amber #E9B765.
Every image contains at least one clear runic element; the blue glow is the brightest, most saturated color in
the frame.

NEVER: no text, no letters, no logos, no watermarks, no signatures, no UI, no frames or borders, no paper texture,
no vignette, no burnt edges, no stains painted on the image (the game adds the parchment), no photorealism, no 3D
render look, no anime, no cartoon, no cel shading, no glossy plastic surfaces, no airbrush gradients, no neon.

EROMASH (only when he appears — match the attached character reference exactly): a tall, broad, heavily built
gladiator. HELMET: the official E helmet, a tall angular RED helmet shaped like the letter E rotated so its three
points face UP like a crown, with a dark eye slit where only two small pale glowing eyes are visible, a thin
scratch-scar near the top left; whole, never removed, never broken, never deformed. ARMOR: red tabard with lighter
red-pink trim and a hanging red banner panel at the front with a gold rune-like mark, two brown leather straps
crossing the chest with a round GOLD medallion bearing an E in the center, layered steel pauldrons and arm plates
(left pauldron with red tally scratches), brown leather gloves, red diamond gems on the bracers, brown leather belt
with gold buckle and pouches, brown leather tassets with metal studs, steel knee and shin plates, dark brown
undersuit, big brown leather boots. Keep these colors and shapes, redrawn in the ink-and-watercolor style.
```

---

## CINEMÁTICA 1 — El susurro de las raíces (Prólogo)

Se ve al abrir el juego y antes de cada partida nueva. Va de lo gigante (el Fresno del Mundo) a lo íntimo (una mano sobre una runa), después a la amenaza (Eldervald) y termina en la Arena. Los textos de cada plano son los de `output/Cinematica 1/subtitulos.md`.

### C1 · P01 — Los nueve mundos
*Narrador: «Desde antes de la memoria, Yggdrasil sostiene los nueve mundos.»*
Movimiento sugerido: la cámara baja lentamente desde el cielo hacia la copa.

**FINAL**
```
Epic establishing shot of Yggdrasil, the World Ash, at dawn: a colossal ash tree so immense that its crown
spreads above the clouds like a second sky, its trunk rising from beyond far mountain ranges. Around and
beneath its branches, faint suggestions of other worlds float among the clouds as distant islands of rock
and light (subtle, painterly, not literal planets). A sea of clouds and mountain peaks below. Warm golden
dawn light behind the crown, cool blue-grey shadows in the valleys. Foreground: dark silhouetted pine
branches framing the top-left corner. The crown is healthy and green. Awe, scale, silence.
RUNIC DETAILS: Enormous runic channels are carved into Yggdrasil's bark and glow runic blue #73D5DB like veins of light running up the trunk into the crown; faint blue rune circles hover around the floating world-islands; thin threads of blue runic light descend from the roots into the mountains below; a few drifting blue rune motes in the air.
```
**FONDO — capa lejana (4608 × 2160, opaca)**
```
SCENE CONTEXT (this describes the whole shot; paint ONLY the layer requested below):
Epic establishing shot of Yggdrasil, the World Ash, at dawn: a colossal ash tree so immense that its crown
spreads above the clouds like a second sky, its trunk rising from beyond far mountain ranges. Around and
beneath its branches, faint suggestions of other worlds float among the clouds as distant islands of rock
and light (subtle, painterly, not literal planets). A sea of clouds and mountain peaks below. Warm golden
dawn light behind the crown, cool blue-grey shadows in the valleys. Foreground: dark silhouetted pine
branches framing the top-left corner. The crown is healthy and green. Awe, scale, silence.
RUNIC DETAILS: Enormous runic channels are carved into Yggdrasil's bark and glow runic blue #73D5DB like veins of light running up the trunk into the crown; faint blue rune circles hover around the floating world-islands; thin threads of blue runic light descend from the roots into the mountains below; a few drifting blue rune motes in the air.

PAINT ONLY THE FAR BACKGROUND LAYER: the far distance: the sky, the dawn glow, the floating world-islands, the clouds and the far mountain ranges. Remove the tree trunk and crown and repaint the sky and clouds behind them seamlessly. Everything that belongs to the midground subject and the foreground is NOT painted; where they would be, paint what lies behind them (continuous sky, terrain, walls), so the layer is complete with no holes. Wide panoramic canvas 4608x2160 (wider than 16:9): extend the scenery naturally to both sides, same horizon height and perspective as the shot. Opaque, full frame.
```
**MEDIO — capa del sujeto (3840 × 2160, sobre magenta)**
```
SCENE CONTEXT (this describes the whole shot; paint ONLY the layer requested below):
Epic establishing shot of Yggdrasil, the World Ash, at dawn: a colossal ash tree so immense that its crown
spreads above the clouds like a second sky, its trunk rising from beyond far mountain ranges. Around and
beneath its branches, faint suggestions of other worlds float among the clouds as distant islands of rock
and light (subtle, painterly, not literal planets). A sea of clouds and mountain peaks below. Warm golden
dawn light behind the crown, cool blue-grey shadows in the valleys. Foreground: dark silhouetted pine
branches framing the top-left corner. The crown is healthy and green. Awe, scale, silence.
RUNIC DETAILS: Enormous runic channels are carved into Yggdrasil's bark and glow runic blue #73D5DB like veins of light running up the trunk into the crown; faint blue rune circles hover around the floating world-islands; thin threads of blue runic light descend from the roots into the mountains below; a few drifting blue rune motes in the air.

PAINT ONLY THE MIDGROUND LAYER: Yggdrasil (trunk and full crown) and the nearest clouds wrapping its trunk. Same placement, size and perspective as in the shot (16:9, 3840x2160). Everything else is a perfectly flat, solid pure magenta #FF00FF background: no sky, no extra ground, no cast shadows or glow spilling onto the magenta, clean crisp outer edges.
```
**FRENTE — capa cercana (3840 × 2160, sobre magenta)**
```
SCENE CONTEXT (this describes the whole shot; paint ONLY the layer requested below):
Epic establishing shot of Yggdrasil, the World Ash, at dawn: a colossal ash tree so immense that its crown
spreads above the clouds like a second sky, its trunk rising from beyond far mountain ranges. Around and
beneath its branches, faint suggestions of other worlds float among the clouds as distant islands of rock
and light (subtle, painterly, not literal planets). A sea of clouds and mountain peaks below. Warm golden
dawn light behind the crown, cool blue-grey shadows in the valleys. Foreground: dark silhouetted pine
branches framing the top-left corner. The crown is healthy and green. Awe, scale, silence.
RUNIC DETAILS: Enormous runic channels are carved into Yggdrasil's bark and glow runic blue #73D5DB like veins of light running up the trunk into the crown; faint blue rune circles hover around the floating world-islands; thin threads of blue runic light descend from the roots into the mountains below; a few drifting blue rune motes in the air.

PAINT ONLY THE CLOSE FOREGROUND LAYER: the dark pine branches framing the top-left corner and a few needles drifting. These elements are very close to the camera, partially cut by the frame edges, slightly larger and darker than the rest of the scene, as in the shot (16:9, 3840x2160). Everything else is a perfectly flat, solid pure magenta #FF00FF background with clean crisp edges.
```
**TINTA — versión solo línea (3840 × 2160, opcional, para que se dibuje)**
```
Epic establishing shot of Yggdrasil, the World Ash, at dawn: a colossal ash tree so immense that its crown
spreads above the clouds like a second sky, its trunk rising from beyond far mountain ranges. Around and
beneath its branches, faint suggestions of other worlds float among the clouds as distant islands of rock
and light (subtle, painterly, not literal planets). A sea of clouds and mountain peaks below. Warm golden
dawn light behind the crown, cool blue-grey shadows in the valleys. Foreground: dark silhouetted pine
branches framing the top-left corner. The crown is healthy and green. Awe, scale, silence.
RUNIC DETAILS: Enormous runic channels are carved into Yggdrasil's bark and glow runic blue #73D5DB like veins of light running up the trunk into the crown; faint blue rune circles hover around the floating world-islands; thin threads of blue runic light descend from the roots into the mountains below; a few drifting blue rune motes in the air.

Render this exact shot ONLY as the finished black and dark-brown ink drawing: confident pen lines, contours, hatching and cross-hatching for shadows, a few construction strokes, on plain warm off-white paper color #EDE3CC. No watercolor, no color, no washes, no glow, no gradients. Same composition and framing as the color version.
```

### C1 · P02 — Las raíces bajo las tierras de los hombres
*Narrador: «Sus raíces corren bajo las tierras de los hombres, y las runas talladas en la piedra guardan sus caminos.»*
Movimiento sugerido: travelling lateral a ras de suelo, siguiendo el camino.

**FINAL**
```
A cutaway view of the land like an illustration in an old chronicle: on the surface, a winding dirt road
through farmland and forest, with small Norse farmsteads with turf roofs and smoke from chimneys; standing
along the road, tall carved runestones glowing softly in runic blue #73D5DB. Below the surface, in a
cross-section of earth and rock, enormous ancient roots of Yggdrasil run horizontally under the road, and
thin threads of runic blue light connect each runestone down to the roots. Calm, protected, everything in
balance. Foreground: tall grass and a fence post at the bottom edge.
RUNIC DETAILS: Every roadside runestone has angular futhark-like glyphs carved deep and glowing runic blue #73D5DB with an almost white core, spilling soft blue light onto the road; the giant roots underground have glowing rune grooves along them and the blue threads pulse between stones and roots like a network; small amber #E9B765 protection runes are painted on the farmstead doorframes.
```
**FONDO — capa lejana (4608 × 2160, opaca)**
```
SCENE CONTEXT (this describes the whole shot; paint ONLY the layer requested below):
A cutaway view of the land like an illustration in an old chronicle: on the surface, a winding dirt road
through farmland and forest, with small Norse farmsteads with turf roofs and smoke from chimneys; standing
along the road, tall carved runestones glowing softly in runic blue #73D5DB. Below the surface, in a
cross-section of earth and rock, enormous ancient roots of Yggdrasil run horizontally under the road, and
thin threads of runic blue light connect each runestone down to the roots. Calm, protected, everything in
balance. Foreground: tall grass and a fence post at the bottom edge.
RUNIC DETAILS: Every roadside runestone has angular futhark-like glyphs carved deep and glowing runic blue #73D5DB with an almost white core, spilling soft blue light onto the road; the giant roots underground have glowing rune grooves along them and the blue threads pulse between stones and roots like a network; small amber #E9B765 protection runes are painted on the farmstead doorframes.

PAINT ONLY THE FAR BACKGROUND LAYER: the far landscape and sky: distant hills, forest line, farmsteads on the horizon, smoke columns. No road, no runestones, no roots cross-section. Everything that belongs to the midground subject and the foreground is NOT painted; where they would be, paint what lies behind them (continuous sky, terrain, walls), so the layer is complete with no holes. Wide panoramic canvas 4608x2160 (wider than 16:9): extend the scenery naturally to both sides, same horizon height and perspective as the shot. Opaque, full frame.
```
**MEDIO — capa del sujeto (3840 × 2160, sobre magenta)**
```
SCENE CONTEXT (this describes the whole shot; paint ONLY the layer requested below):
A cutaway view of the land like an illustration in an old chronicle: on the surface, a winding dirt road
through farmland and forest, with small Norse farmsteads with turf roofs and smoke from chimneys; standing
along the road, tall carved runestones glowing softly in runic blue #73D5DB. Below the surface, in a
cross-section of earth and rock, enormous ancient roots of Yggdrasil run horizontally under the road, and
thin threads of runic blue light connect each runestone down to the roots. Calm, protected, everything in
balance. Foreground: tall grass and a fence post at the bottom edge.
RUNIC DETAILS: Every roadside runestone has angular futhark-like glyphs carved deep and glowing runic blue #73D5DB with an almost white core, spilling soft blue light onto the road; the giant roots underground have glowing rune grooves along them and the blue threads pulse between stones and roots like a network; small amber #E9B765 protection runes are painted on the farmstead doorframes.

PAINT ONLY THE MIDGROUND LAYER: the road with the glowing runestones and the earth cross-section with the giant roots and the blue light threads. Same placement, size and perspective as in the shot (16:9, 3840x2160). Everything else is a perfectly flat, solid pure magenta #FF00FF background: no sky, no extra ground, no cast shadows or glow spilling onto the magenta, clean crisp outer edges.
```
**FRENTE — capa cercana (3840 × 2160, sobre magenta)**
```
SCENE CONTEXT (this describes the whole shot; paint ONLY the layer requested below):
A cutaway view of the land like an illustration in an old chronicle: on the surface, a winding dirt road
through farmland and forest, with small Norse farmsteads with turf roofs and smoke from chimneys; standing
along the road, tall carved runestones glowing softly in runic blue #73D5DB. Below the surface, in a
cross-section of earth and rock, enormous ancient roots of Yggdrasil run horizontally under the road, and
thin threads of runic blue light connect each runestone down to the roots. Calm, protected, everything in
balance. Foreground: tall grass and a fence post at the bottom edge.
RUNIC DETAILS: Every roadside runestone has angular futhark-like glyphs carved deep and glowing runic blue #73D5DB with an almost white core, spilling soft blue light onto the road; the giant roots underground have glowing rune grooves along them and the blue threads pulse between stones and roots like a network; small amber #E9B765 protection runes are painted on the farmstead doorframes.

PAINT ONLY THE CLOSE FOREGROUND LAYER: the tall grass and the fence post at the bottom edge. These elements are very close to the camera, partially cut by the frame edges, slightly larger and darker than the rest of the scene, as in the shot (16:9, 3840x2160). Everything else is a perfectly flat, solid pure magenta #FF00FF background with clean crisp edges.
```
**TINTA — versión solo línea (3840 × 2160, opcional, para que se dibuje)**
```
A cutaway view of the land like an illustration in an old chronicle: on the surface, a winding dirt road
through farmland and forest, with small Norse farmsteads with turf roofs and smoke from chimneys; standing
along the road, tall carved runestones glowing softly in runic blue #73D5DB. Below the surface, in a
cross-section of earth and rock, enormous ancient roots of Yggdrasil run horizontally under the road, and
thin threads of runic blue light connect each runestone down to the roots. Calm, protected, everything in
balance. Foreground: tall grass and a fence post at the bottom edge.
RUNIC DETAILS: Every roadside runestone has angular futhark-like glyphs carved deep and glowing runic blue #73D5DB with an almost white core, spilling soft blue light onto the road; the giant roots underground have glowing rune grooves along them and the blue threads pulse between stones and roots like a network; small amber #E9B765 protection runes are painted on the farmstead doorframes.

Render this exact shot ONLY as the finished black and dark-brown ink drawing: confident pen lines, contours, hatching and cross-hatching for shadows, a few construction strokes, on plain warm off-white paper color #EDE3CC. No watercolor, no color, no washes, no glow, no gradients. Same composition and framing as the color version.
```

### C1 · P03 — La copa verde, las raíces en sombra
*Narrador: «Su copa sigue verde. Nadie mira lo que pasa en sus raíces.»*
Movimiento sugerido: la cámara desciende por el tronco desde la luz hacia la oscuridad de la base.

**FINAL**
```
Vertical sense of descent in a 16:9 frame: the upper part shows the lush, glowing green underside of
Yggdrasil's crown lit by sunlight; the eye travels down the massive bark of the trunk, carved with ancient
runes, into the base where gigantic roots plunge into a dark misty chasm. At the base, the shadows are
cold and the bark looks dry and greyish, and a faint unhealthy darkness seeps between the roots (no monster
visible, only a hint that something is wrong). Foreground: hanging moss strands on the right edge.
RUNIC DETAILS: A spiral of carved runes climbs the trunk: bright runic blue #73D5DB near the healthy crown, getting weaker lower down, flickering in broken segments, and completely dark and cracked at the roots, where only a few dying blue sparks remain.
```
**FONDO — capa lejana (4608 × 2160, opaca)**
```
SCENE CONTEXT (this describes the whole shot; paint ONLY the layer requested below):
Vertical sense of descent in a 16:9 frame: the upper part shows the lush, glowing green underside of
Yggdrasil's crown lit by sunlight; the eye travels down the massive bark of the trunk, carved with ancient
runes, into the base where gigantic roots plunge into a dark misty chasm. At the base, the shadows are
cold and the bark looks dry and greyish, and a faint unhealthy darkness seeps between the roots (no monster
visible, only a hint that something is wrong). Foreground: hanging moss strands on the right edge.
RUNIC DETAILS: A spiral of carved runes climbs the trunk: bright runic blue #73D5DB near the healthy crown, getting weaker lower down, flickering in broken segments, and completely dark and cracked at the roots, where only a few dying blue sparks remain.

PAINT ONLY THE FAR BACKGROUND LAYER: the misty depth and the far parts of the trunk and the chasm, the sky glimpsed through the crown. Everything that belongs to the midground subject and the foreground is NOT painted; where they would be, paint what lies behind them (continuous sky, terrain, walls), so the layer is complete with no holes. Wide panoramic canvas 4608x2160 (wider than 16:9): extend the scenery naturally to both sides, same horizon height and perspective as the shot. Opaque, full frame.
```
**MEDIO — capa del sujeto (3840 × 2160, sobre magenta)**
```
SCENE CONTEXT (this describes the whole shot; paint ONLY the layer requested below):
Vertical sense of descent in a 16:9 frame: the upper part shows the lush, glowing green underside of
Yggdrasil's crown lit by sunlight; the eye travels down the massive bark of the trunk, carved with ancient
runes, into the base where gigantic roots plunge into a dark misty chasm. At the base, the shadows are
cold and the bark looks dry and greyish, and a faint unhealthy darkness seeps between the roots (no monster
visible, only a hint that something is wrong). Foreground: hanging moss strands on the right edge.
RUNIC DETAILS: A spiral of carved runes climbs the trunk: bright runic blue #73D5DB near the healthy crown, getting weaker lower down, flickering in broken segments, and completely dark and cracked at the roots, where only a few dying blue sparks remain.

PAINT ONLY THE MIDGROUND LAYER: the main trunk with its carvings and the big roots. Same placement, size and perspective as in the shot (16:9, 3840x2160). Everything else is a perfectly flat, solid pure magenta #FF00FF background: no sky, no extra ground, no cast shadows or glow spilling onto the magenta, clean crisp outer edges.
```
**FRENTE — capa cercana (3840 × 2160, sobre magenta)**
```
SCENE CONTEXT (this describes the whole shot; paint ONLY the layer requested below):
Vertical sense of descent in a 16:9 frame: the upper part shows the lush, glowing green underside of
Yggdrasil's crown lit by sunlight; the eye travels down the massive bark of the trunk, carved with ancient
runes, into the base where gigantic roots plunge into a dark misty chasm. At the base, the shadows are
cold and the bark looks dry and greyish, and a faint unhealthy darkness seeps between the roots (no monster
visible, only a hint that something is wrong). Foreground: hanging moss strands on the right edge.
RUNIC DETAILS: A spiral of carved runes climbs the trunk: bright runic blue #73D5DB near the healthy crown, getting weaker lower down, flickering in broken segments, and completely dark and cracked at the roots, where only a few dying blue sparks remain.

PAINT ONLY THE CLOSE FOREGROUND LAYER: the hanging moss strands on the right edge. These elements are very close to the camera, partially cut by the frame edges, slightly larger and darker than the rest of the scene, as in the shot (16:9, 3840x2160). Everything else is a perfectly flat, solid pure magenta #FF00FF background with clean crisp edges.
```
**TINTA — versión solo línea (3840 × 2160, opcional, para que se dibuje)**
```
Vertical sense of descent in a 16:9 frame: the upper part shows the lush, glowing green underside of
Yggdrasil's crown lit by sunlight; the eye travels down the massive bark of the trunk, carved with ancient
runes, into the base where gigantic roots plunge into a dark misty chasm. At the base, the shadows are
cold and the bark looks dry and greyish, and a faint unhealthy darkness seeps between the roots (no monster
visible, only a hint that something is wrong). Foreground: hanging moss strands on the right edge.
RUNIC DETAILS: A spiral of carved runes climbs the trunk: bright runic blue #73D5DB near the healthy crown, getting weaker lower down, flickering in broken segments, and completely dark and cracked at the roots, where only a few dying blue sparks remain.

Render this exact shot ONLY as the finished black and dark-brown ink drawing: confident pen lines, contours, hatching and cross-hatching for shadows, a few construction strokes, on plain warm off-white paper color #EDE3CC. No watercolor, no color, no washes, no glow, no gradients. Same composition and framing as the color version.
```

### C1 · P04 — Los guardianes
*Narrador: «Durante siglos, los guardianes mantuvieron viva esa luz.»*
Movimiento sugerido: acercamiento lento al círculo de piedras.

**FINAL**
```
At the foot of Yggdrasil, among its colossal roots, a circle of tall carved monoliths whose runes glow
bright runic blue #73D5DB. Three hooded guardians in grey-green wool robes and leather, old and dignified,
tend the stones: one touches a rune, one holds a lantern with blue light, one kneels reading carvings.
Mist at ground level lit blue by the runes. The colossal roots arch over the scene like the ribs of a
cathedral. Foreground: a big root curving across the bottom-left corner.
RUNIC DETAILS: The monoliths are covered in carved bands of glyphs glowing bright runic blue #73D5DB; a rune circle inscribed in the ground connects all the stones with lines of blue light; the guardians' robes have embroidered runic borders glowing faintly; the lantern holds a small floating glowing rune instead of a flame; blue motes rise from the stones.
```
**FONDO — capa lejana (4608 × 2160, opaca)**
```
SCENE CONTEXT (this describes the whole shot; paint ONLY the layer requested below):
At the foot of Yggdrasil, among its colossal roots, a circle of tall carved monoliths whose runes glow
bright runic blue #73D5DB. Three hooded guardians in grey-green wool robes and leather, old and dignified,
tend the stones: one touches a rune, one holds a lantern with blue light, one kneels reading carvings.
Mist at ground level lit blue by the runes. The colossal roots arch over the scene like the ribs of a
cathedral. Foreground: a big root curving across the bottom-left corner.
RUNIC DETAILS: The monoliths are covered in carved bands of glyphs glowing bright runic blue #73D5DB; a rune circle inscribed in the ground connects all the stones with lines of blue light; the guardians' robes have embroidered runic borders glowing faintly; the lantern holds a small floating glowing rune instead of a flame; blue motes rise from the stones.

PAINT ONLY THE FAR BACKGROUND LAYER: the colossal roots arching in the background and the misty depth. Everything that belongs to the midground subject and the foreground is NOT painted; where they would be, paint what lies behind them (continuous sky, terrain, walls), so the layer is complete with no holes. Wide panoramic canvas 4608x2160 (wider than 16:9): extend the scenery naturally to both sides, same horizon height and perspective as the shot. Opaque, full frame.
```
**MEDIO — capa del sujeto (3840 × 2160, sobre magenta)**
```
SCENE CONTEXT (this describes the whole shot; paint ONLY the layer requested below):
At the foot of Yggdrasil, among its colossal roots, a circle of tall carved monoliths whose runes glow
bright runic blue #73D5DB. Three hooded guardians in grey-green wool robes and leather, old and dignified,
tend the stones: one touches a rune, one holds a lantern with blue light, one kneels reading carvings.
Mist at ground level lit blue by the runes. The colossal roots arch over the scene like the ribs of a
cathedral. Foreground: a big root curving across the bottom-left corner.
RUNIC DETAILS: The monoliths are covered in carved bands of glyphs glowing bright runic blue #73D5DB; a rune circle inscribed in the ground connects all the stones with lines of blue light; the guardians' robes have embroidered runic borders glowing faintly; the lantern holds a small floating glowing rune instead of a flame; blue motes rise from the stones.

PAINT ONLY THE MIDGROUND LAYER: the circle of glowing monoliths and the three guardians, with the blue mist at their feet. Same placement, size and perspective as in the shot (16:9, 3840x2160). Everything else is a perfectly flat, solid pure magenta #FF00FF background: no sky, no extra ground, no cast shadows or glow spilling onto the magenta, clean crisp outer edges.
```
**FRENTE — capa cercana (3840 × 2160, sobre magenta)**
```
SCENE CONTEXT (this describes the whole shot; paint ONLY the layer requested below):
At the foot of Yggdrasil, among its colossal roots, a circle of tall carved monoliths whose runes glow
bright runic blue #73D5DB. Three hooded guardians in grey-green wool robes and leather, old and dignified,
tend the stones: one touches a rune, one holds a lantern with blue light, one kneels reading carvings.
Mist at ground level lit blue by the runes. The colossal roots arch over the scene like the ribs of a
cathedral. Foreground: a big root curving across the bottom-left corner.
RUNIC DETAILS: The monoliths are covered in carved bands of glyphs glowing bright runic blue #73D5DB; a rune circle inscribed in the ground connects all the stones with lines of blue light; the guardians' robes have embroidered runic borders glowing faintly; the lantern holds a small floating glowing rune instead of a flame; blue motes rise from the stones.

PAINT ONLY THE CLOSE FOREGROUND LAYER: the big root curving across the bottom-left corner. These elements are very close to the camera, partially cut by the frame edges, slightly larger and darker than the rest of the scene, as in the shot (16:9, 3840x2160). Everything else is a perfectly flat, solid pure magenta #FF00FF background with clean crisp edges.
```
**TINTA — versión solo línea (3840 × 2160, opcional, para que se dibuje)**
```
At the foot of Yggdrasil, among its colossal roots, a circle of tall carved monoliths whose runes glow
bright runic blue #73D5DB. Three hooded guardians in grey-green wool robes and leather, old and dignified,
tend the stones: one touches a rune, one holds a lantern with blue light, one kneels reading carvings.
Mist at ground level lit blue by the runes. The colossal roots arch over the scene like the ribs of a
cathedral. Foreground: a big root curving across the bottom-left corner.
RUNIC DETAILS: The monoliths are covered in carved bands of glyphs glowing bright runic blue #73D5DB; a rune circle inscribed in the ground connects all the stones with lines of blue light; the guardians' robes have embroidered runic borders glowing faintly; the lantern holds a small floating glowing rune instead of a flame; blue motes rise from the stones.

Render this exact shot ONLY as the finished black and dark-brown ink drawing: confident pen lines, contours, hatching and cross-hatching for shadows, a few construction strokes, on plain warm off-white paper color #EDE3CC. No watercolor, no color, no washes, no glow, no gradients. Same composition and framing as the color version.
```

### C1 · P05 — Las runas se apagan
*Narrador: «Pero ahora, al pie del Fresno, las runas parpadean… y se apagan, una tras otra.»*
Movimiento sugerido: paneo lento de izquierda a derecha por la fila de monolitos.

**FINAL**
```
The same circle of monoliths at the foot of Yggdrasil, closer, at dusk. A row of three tall runestones from
left to right: the left one still glows runic blue #73D5DB, the middle one flickers weakly with cracks of
light, the right one has gone dark — its carved runes turned charcoal grey with a faint ash-red ember glow
#E0603C dying in the grooves. The mist is now grey. Cold, ominous atmosphere. Foreground: dry fallen leaves
and a broken lantern on the ground at the bottom.
RUNIC DETAILS: The left stone's glyphs blaze runic blue #73D5DB; the middle stone's runes flicker in broken segments with blue sparks falling off; the right stone's runes are dead charcoal grey with a dying ember red #E0603C in the grooves; the glowing rune circle on the ground is broken where it reaches the dead stone; a few blue motes fall and fade out.
```
**FONDO — capa lejana (4608 × 2160, opaca)**
```
SCENE CONTEXT (this describes the whole shot; paint ONLY the layer requested below):
The same circle of monoliths at the foot of Yggdrasil, closer, at dusk. A row of three tall runestones from
left to right: the left one still glows runic blue #73D5DB, the middle one flickers weakly with cracks of
light, the right one has gone dark — its carved runes turned charcoal grey with a faint ash-red ember glow
#E0603C dying in the grooves. The mist is now grey. Cold, ominous atmosphere. Foreground: dry fallen leaves
and a broken lantern on the ground at the bottom.
RUNIC DETAILS: The left stone's glyphs blaze runic blue #73D5DB; the middle stone's runes flicker in broken segments with blue sparks falling off; the right stone's runes are dead charcoal grey with a dying ember red #E0603C in the grooves; the glowing rune circle on the ground is broken where it reaches the dead stone; a few blue motes fall and fade out.

PAINT ONLY THE FAR BACKGROUND LAYER: the dark roots and dusk sky behind the stones. Everything that belongs to the midground subject and the foreground is NOT painted; where they would be, paint what lies behind them (continuous sky, terrain, walls), so the layer is complete with no holes. Wide panoramic canvas 4608x2160 (wider than 16:9): extend the scenery naturally to both sides, same horizon height and perspective as the shot. Opaque, full frame.
```
**MEDIO — capa del sujeto (3840 × 2160, sobre magenta)**
```
SCENE CONTEXT (this describes the whole shot; paint ONLY the layer requested below):
The same circle of monoliths at the foot of Yggdrasil, closer, at dusk. A row of three tall runestones from
left to right: the left one still glows runic blue #73D5DB, the middle one flickers weakly with cracks of
light, the right one has gone dark — its carved runes turned charcoal grey with a faint ash-red ember glow
#E0603C dying in the grooves. The mist is now grey. Cold, ominous atmosphere. Foreground: dry fallen leaves
and a broken lantern on the ground at the bottom.
RUNIC DETAILS: The left stone's glyphs blaze runic blue #73D5DB; the middle stone's runes flicker in broken segments with blue sparks falling off; the right stone's runes are dead charcoal grey with a dying ember red #E0603C in the grooves; the glowing rune circle on the ground is broken where it reaches the dead stone; a few blue motes fall and fade out.

PAINT ONLY THE MIDGROUND LAYER: the three monoliths with their different rune states and the grey mist. Same placement, size and perspective as in the shot (16:9, 3840x2160). Everything else is a perfectly flat, solid pure magenta #FF00FF background: no sky, no extra ground, no cast shadows or glow spilling onto the magenta, clean crisp outer edges.
```
**FRENTE — capa cercana (3840 × 2160, sobre magenta)**
```
SCENE CONTEXT (this describes the whole shot; paint ONLY the layer requested below):
The same circle of monoliths at the foot of Yggdrasil, closer, at dusk. A row of three tall runestones from
left to right: the left one still glows runic blue #73D5DB, the middle one flickers weakly with cracks of
light, the right one has gone dark — its carved runes turned charcoal grey with a faint ash-red ember glow
#E0603C dying in the grooves. The mist is now grey. Cold, ominous atmosphere. Foreground: dry fallen leaves
and a broken lantern on the ground at the bottom.
RUNIC DETAILS: The left stone's glyphs blaze runic blue #73D5DB; the middle stone's runes flicker in broken segments with blue sparks falling off; the right stone's runes are dead charcoal grey with a dying ember red #E0603C in the grooves; the glowing rune circle on the ground is broken where it reaches the dead stone; a few blue motes fall and fade out.

PAINT ONLY THE CLOSE FOREGROUND LAYER: the dry leaves and the broken lantern at the bottom. These elements are very close to the camera, partially cut by the frame edges, slightly larger and darker than the rest of the scene, as in the shot (16:9, 3840x2160). Everything else is a perfectly flat, solid pure magenta #FF00FF background with clean crisp edges.
```
**TINTA — versión solo línea (3840 × 2160, opcional, para que se dibuje)**
```
The same circle of monoliths at the foot of Yggdrasil, closer, at dusk. A row of three tall runestones from
left to right: the left one still glows runic blue #73D5DB, the middle one flickers weakly with cracks of
light, the right one has gone dark — its carved runes turned charcoal grey with a faint ash-red ember glow
#E0603C dying in the grooves. The mist is now grey. Cold, ominous atmosphere. Foreground: dry fallen leaves
and a broken lantern on the ground at the bottom.
RUNIC DETAILS: The left stone's glyphs blaze runic blue #73D5DB; the middle stone's runes flicker in broken segments with blue sparks falling off; the right stone's runes are dead charcoal grey with a dying ember red #E0603C in the grooves; the glowing rune circle on the ground is broken where it reaches the dead stone; a few blue motes fall and fade out.

Render this exact shot ONLY as the finished black and dark-brown ink drawing: confident pen lines, contours, hatching and cross-hatching for shadows, a few construction strokes, on plain warm off-white paper color #EDE3CC. No watercolor, no color, no washes, no glow, no gradients. Same composition and framing as the color version.
```

### C1 · P06 — La mano sobre la runa
*Guardián: «La savia corre…»*
Movimiento sugerido: acercamiento muy lento al contacto; la mano y la piedra se mueven juntas.

**FINAL**
```
Extreme close-up: the weathered, trembling hand of an old guardian, sleeve of grey wool, resting its
fingertips on a carved rune on a mossy monolith. The rune under the fingers is cracking; its golden-blue
glow is draining away into dull charcoal grey, with a last thin line of runic blue light along the crack.
Moss and tiny white flowers in the stone's crevices. Background: blurred, out-of-focus roots and other
standing stones in mist. Shallow depth of field feeling, but still ink and watercolor.
RUNIC DETAILS: The carved rune under the fingers is deep and angular, with runic blue #73D5DB light leaking out through its cracks and touching the guardian's fingertips; smaller runes around it on the stone are already dim and grey.
```
**FONDO — capa lejana (4608 × 2160, opaca)**
```
SCENE CONTEXT (this describes the whole shot; paint ONLY the layer requested below):
Extreme close-up: the weathered, trembling hand of an old guardian, sleeve of grey wool, resting its
fingertips on a carved rune on a mossy monolith. The rune under the fingers is cracking; its golden-blue
glow is draining away into dull charcoal grey, with a last thin line of runic blue light along the crack.
Moss and tiny white flowers in the stone's crevices. Background: blurred, out-of-focus roots and other
standing stones in mist. Shallow depth of field feeling, but still ink and watercolor.
RUNIC DETAILS: The carved rune under the fingers is deep and angular, with runic blue #73D5DB light leaking out through its cracks and touching the guardian's fingertips; smaller runes around it on the stone are already dim and grey.

PAINT ONLY THE FAR BACKGROUND LAYER: the blurred roots, mist and distant stones. Everything that belongs to the midground subject and the foreground is NOT painted; where they would be, paint what lies behind them (continuous sky, terrain, walls), so the layer is complete with no holes. Wide panoramic canvas 4608x2160 (wider than 16:9): extend the scenery naturally to both sides, same horizon height and perspective as the shot. Opaque, full frame.
```
**MEDIO — capa del sujeto (3840 × 2160, sobre magenta)**
```
SCENE CONTEXT (this describes the whole shot; paint ONLY the layer requested below):
Extreme close-up: the weathered, trembling hand of an old guardian, sleeve of grey wool, resting its
fingertips on a carved rune on a mossy monolith. The rune under the fingers is cracking; its golden-blue
glow is draining away into dull charcoal grey, with a last thin line of runic blue light along the crack.
Moss and tiny white flowers in the stone's crevices. Background: blurred, out-of-focus roots and other
standing stones in mist. Shallow depth of field feeling, but still ink and watercolor.
RUNIC DETAILS: The carved rune under the fingers is deep and angular, with runic blue #73D5DB light leaking out through its cracks and touching the guardian's fingertips; smaller runes around it on the stone are already dim and grey.

PAINT ONLY THE MIDGROUND LAYER: the monolith surface with the rune and the hand and sleeve together (they move as one). Same placement, size and perspective as in the shot (16:9, 3840x2160). Everything else is a perfectly flat, solid pure magenta #FF00FF background: no sky, no extra ground, no cast shadows or glow spilling onto the magenta, clean crisp outer edges.
```
**FRENTE — capa cercana (3840 × 2160, sobre magenta)**
```
SCENE CONTEXT (this describes the whole shot; paint ONLY the layer requested below):
Extreme close-up: the weathered, trembling hand of an old guardian, sleeve of grey wool, resting its
fingertips on a carved rune on a mossy monolith. The rune under the fingers is cracking; its golden-blue
glow is draining away into dull charcoal grey, with a last thin line of runic blue light along the crack.
Moss and tiny white flowers in the stone's crevices. Background: blurred, out-of-focus roots and other
standing stones in mist. Shallow depth of field feeling, but still ink and watercolor.
RUNIC DETAILS: The carved rune under the fingers is deep and angular, with runic blue #73D5DB light leaking out through its cracks and touching the guardian's fingertips; smaller runes around it on the stone are already dim and grey.

PAINT ONLY THE CLOSE FOREGROUND LAYER: a few out-of-focus moss tendrils at the left edge. These elements are very close to the camera, partially cut by the frame edges, slightly larger and darker than the rest of the scene, as in the shot (16:9, 3840x2160). Everything else is a perfectly flat, solid pure magenta #FF00FF background with clean crisp edges.
```
**TINTA — versión solo línea (3840 × 2160, opcional, para que se dibuje)**
```
Extreme close-up: the weathered, trembling hand of an old guardian, sleeve of grey wool, resting its
fingertips on a carved rune on a mossy monolith. The rune under the fingers is cracking; its golden-blue
glow is draining away into dull charcoal grey, with a last thin line of runic blue light along the crack.
Moss and tiny white flowers in the stone's crevices. Background: blurred, out-of-focus roots and other
standing stones in mist. Shallow depth of field feeling, but still ink and watercolor.
RUNIC DETAILS: The carved rune under the fingers is deep and angular, with runic blue #73D5DB light leaking out through its cracks and touching the guardian's fingertips; smaller runes around it on the stone are already dim and grey.

Render this exact shot ONLY as the finished black and dark-brown ink drawing: confident pen lines, contours, hatching and cross-hatching for shadows, a few construction strokes, on plain warm off-white paper color #EDE3CC. No watercolor, no color, no washes, no glow, no gradients. Same composition and framing as the color version.
```

### C1 · P07 — El rostro del guardián
*Guardián: «…pero las piedras han olvidado su lenguaje.» · Narrador: «Nadie sabe qué las está silenciando.»*
Movimiento sugerido: acercamiento lento a la cara; destellos azules intermitentes desde la derecha.

**FINAL**
```
Close-up portrait of the old hooded guardian, grey beard, deep wrinkles, worried eyes looking down at the
stones, face half in shadow. His face is lit from the right side by flickering runic blue light from an
out-of-frame monolith, the left side in deep ink shadow. Behind him, out of focus, other monoliths standing
dark. Foreground: the edge of a dark monolith on the right side of the frame with a faint blue rune.
RUNIC DETAILS: Flickering runic blue #73D5DB light paints his face from the right; a small runic amulet on a cord at his neck glows faintly blue; a vertical column of carved glyphs on the monolith edge pulses weakly; tiny blue reflections in his eyes.
```
**FONDO — capa lejana (4608 × 2160, opaca)**
```
SCENE CONTEXT (this describes the whole shot; paint ONLY the layer requested below):
Close-up portrait of the old hooded guardian, grey beard, deep wrinkles, worried eyes looking down at the
stones, face half in shadow. His face is lit from the right side by flickering runic blue light from an
out-of-frame monolith, the left side in deep ink shadow. Behind him, out of focus, other monoliths standing
dark. Foreground: the edge of a dark monolith on the right side of the frame with a faint blue rune.
RUNIC DETAILS: Flickering runic blue #73D5DB light paints his face from the right; a small runic amulet on a cord at his neck glows faintly blue; a vertical column of carved glyphs on the monolith edge pulses weakly; tiny blue reflections in his eyes.

PAINT ONLY THE FAR BACKGROUND LAYER: the out-of-focus dark monoliths and roots behind him. Everything that belongs to the midground subject and the foreground is NOT painted; where they would be, paint what lies behind them (continuous sky, terrain, walls), so the layer is complete with no holes. Wide panoramic canvas 4608x2160 (wider than 16:9): extend the scenery naturally to both sides, same horizon height and perspective as the shot. Opaque, full frame.
```
**MEDIO — capa del sujeto (3840 × 2160, sobre magenta)**
```
SCENE CONTEXT (this describes the whole shot; paint ONLY the layer requested below):
Close-up portrait of the old hooded guardian, grey beard, deep wrinkles, worried eyes looking down at the
stones, face half in shadow. His face is lit from the right side by flickering runic blue light from an
out-of-frame monolith, the left side in deep ink shadow. Behind him, out of focus, other monoliths standing
dark. Foreground: the edge of a dark monolith on the right side of the frame with a faint blue rune.
RUNIC DETAILS: Flickering runic blue #73D5DB light paints his face from the right; a small runic amulet on a cord at his neck glows faintly blue; a vertical column of carved glyphs on the monolith edge pulses weakly; tiny blue reflections in his eyes.

PAINT ONLY THE MIDGROUND LAYER: the guardian (head, hood, shoulders). Same placement, size and perspective as in the shot (16:9, 3840x2160). Everything else is a perfectly flat, solid pure magenta #FF00FF background: no sky, no extra ground, no cast shadows or glow spilling onto the magenta, clean crisp outer edges.
```
**FRENTE — capa cercana (3840 × 2160, sobre magenta)**
```
SCENE CONTEXT (this describes the whole shot; paint ONLY the layer requested below):
Close-up portrait of the old hooded guardian, grey beard, deep wrinkles, worried eyes looking down at the
stones, face half in shadow. His face is lit from the right side by flickering runic blue light from an
out-of-frame monolith, the left side in deep ink shadow. Behind him, out of focus, other monoliths standing
dark. Foreground: the edge of a dark monolith on the right side of the frame with a faint blue rune.
RUNIC DETAILS: Flickering runic blue #73D5DB light paints his face from the right; a small runic amulet on a cord at his neck glows faintly blue; a vertical column of carved glyphs on the monolith edge pulses weakly; tiny blue reflections in his eyes.

PAINT ONLY THE CLOSE FOREGROUND LAYER: the edge of the monolith on the right with its faint blue rune. These elements are very close to the camera, partially cut by the frame edges, slightly larger and darker than the rest of the scene, as in the shot (16:9, 3840x2160). Everything else is a perfectly flat, solid pure magenta #FF00FF background with clean crisp edges.
```
**TINTA — versión solo línea (3840 × 2160, opcional, para que se dibuje)**
```
Close-up portrait of the old hooded guardian, grey beard, deep wrinkles, worried eyes looking down at the
stones, face half in shadow. His face is lit from the right side by flickering runic blue light from an
out-of-frame monolith, the left side in deep ink shadow. Behind him, out of focus, other monoliths standing
dark. Foreground: the edge of a dark monolith on the right side of the frame with a faint blue rune.
RUNIC DETAILS: Flickering runic blue #73D5DB light paints his face from the right; a small runic amulet on a cord at his neck glows faintly blue; a vertical column of carved glyphs on the monolith edge pulses weakly; tiny blue reflections in his eyes.

Render this exact shot ONLY as the finished black and dark-brown ink drawing: confident pen lines, contours, hatching and cross-hatching for shadows, a few construction strokes, on plain warm off-white paper color #EDE3CC. No watercolor, no color, no washes, no glow, no gradients. Same composition and framing as the color version.
```

### C1 · P08 — La tierra se quiebra en Eldervald
*Narrador: «A muchas millas de allí, en los bosques de Eldervald, la tierra se quiebra.»*
Movimiento sugerido: travelling rápido a ras de suelo hacia la grieta; temblor al final.

**FINAL**
```
A rural dirt road through a dark misty Nordic pine forest at night (Eldervald). Low camera, almost at
ground level. In the middle of the road the earth is cracking open, chunks of mud and stones lifting, and a
pale, gaunt, grey-skinned hand with long dark nails claws out of the crack, gripping the grass. Faint
ember-red #E0603C glow from deep inside the crack. A lone lantern on a post far down the road. Foreground:
wet grass blades and ferns at the bottom edge, very close to camera.
RUNIC DETAILS: A half-buried old waymarker runestone at the roadside has its carved rune cracked and nearly dark, with the last runic blue #73D5DB sparks rising from it and dying, contrasting with the ember red glow of the crack in the road.
```
**FONDO — capa lejana (4608 × 2160, opaca)**
```
SCENE CONTEXT (this describes the whole shot; paint ONLY the layer requested below):
A rural dirt road through a dark misty Nordic pine forest at night (Eldervald). Low camera, almost at
ground level. In the middle of the road the earth is cracking open, chunks of mud and stones lifting, and a
pale, gaunt, grey-skinned hand with long dark nails claws out of the crack, gripping the grass. Faint
ember-red #E0603C glow from deep inside the crack. A lone lantern on a post far down the road. Foreground:
wet grass blades and ferns at the bottom edge, very close to camera.
RUNIC DETAILS: A half-buried old waymarker runestone at the roadside has its carved rune cracked and nearly dark, with the last runic blue #73D5DB sparks rising from it and dying, contrasting with the ember red glow of the crack in the road.

PAINT ONLY THE FAR BACKGROUND LAYER: the misty forest, the distant road and the lantern. Everything that belongs to the midground subject and the foreground is NOT painted; where they would be, paint what lies behind them (continuous sky, terrain, walls), so the layer is complete with no holes. Wide panoramic canvas 4608x2160 (wider than 16:9): extend the scenery naturally to both sides, same horizon height and perspective as the shot. Opaque, full frame.
```
**MEDIO — capa del sujeto (3840 × 2160, sobre magenta)**
```
SCENE CONTEXT (this describes the whole shot; paint ONLY the layer requested below):
A rural dirt road through a dark misty Nordic pine forest at night (Eldervald). Low camera, almost at
ground level. In the middle of the road the earth is cracking open, chunks of mud and stones lifting, and a
pale, gaunt, grey-skinned hand with long dark nails claws out of the crack, gripping the grass. Faint
ember-red #E0603C glow from deep inside the crack. A lone lantern on a post far down the road. Foreground:
wet grass blades and ferns at the bottom edge, very close to camera.
RUNIC DETAILS: A half-buried old waymarker runestone at the roadside has its carved rune cracked and nearly dark, with the last runic blue #73D5DB sparks rising from it and dying, contrasting with the ember red glow of the crack in the road.

PAINT ONLY THE MIDGROUND LAYER: the cracking road section with the emerging hand and the mud chunks. Same placement, size and perspective as in the shot (16:9, 3840x2160). Everything else is a perfectly flat, solid pure magenta #FF00FF background: no sky, no extra ground, no cast shadows or glow spilling onto the magenta, clean crisp outer edges.
```
**FRENTE — capa cercana (3840 × 2160, sobre magenta)**
```
SCENE CONTEXT (this describes the whole shot; paint ONLY the layer requested below):
A rural dirt road through a dark misty Nordic pine forest at night (Eldervald). Low camera, almost at
ground level. In the middle of the road the earth is cracking open, chunks of mud and stones lifting, and a
pale, gaunt, grey-skinned hand with long dark nails claws out of the crack, gripping the grass. Faint
ember-red #E0603C glow from deep inside the crack. A lone lantern on a post far down the road. Foreground:
wet grass blades and ferns at the bottom edge, very close to camera.
RUNIC DETAILS: A half-buried old waymarker runestone at the roadside has its carved rune cracked and nearly dark, with the last runic blue #73D5DB sparks rising from it and dying, contrasting with the ember red glow of the crack in the road.

PAINT ONLY THE CLOSE FOREGROUND LAYER: the wet grass blades and ferns at the bottom edge. These elements are very close to the camera, partially cut by the frame edges, slightly larger and darker than the rest of the scene, as in the shot (16:9, 3840x2160). Everything else is a perfectly flat, solid pure magenta #FF00FF background with clean crisp edges.
```
**TINTA — versión solo línea (3840 × 2160, opcional, para que se dibuje)**
```
A rural dirt road through a dark misty Nordic pine forest at night (Eldervald). Low camera, almost at
ground level. In the middle of the road the earth is cracking open, chunks of mud and stones lifting, and a
pale, gaunt, grey-skinned hand with long dark nails claws out of the crack, gripping the grass. Faint
ember-red #E0603C glow from deep inside the crack. A lone lantern on a post far down the road. Foreground:
wet grass blades and ferns at the bottom edge, very close to camera.
RUNIC DETAILS: A half-buried old waymarker runestone at the roadside has its carved rune cracked and nearly dark, with the last runic blue #73D5DB sparks rising from it and dying, contrasting with the ember red glow of the crack in the road.

Render this exact shot ONLY as the finished black and dark-brown ink drawing: confident pen lines, contours, hatching and cross-hatching for shadows, a few construction strokes, on plain warm off-white paper color #EDE3CC. No watercolor, no color, no washes, no glow, no gradients. Same composition and framing as the color version.
```

### C1 · P09 — Los errantes de Helheim
*Narrador: «Los errantes de Helheim salen de la tierra y rondan las piedras apagadas.» · «Los asentamientos cierran sus puertas. Y lo que dormía bajo los caminos de los hombres… despierta.»*
Movimiento sugerido: acercamiento lento; los errantes avanzan; una ventana se cierra al fondo.

**FINAL**
```
Night in a small Eldervald settlement of timber houses with turf and shingle roofs, warm amber #E9B765 light
in a few windows, one villager in the background pulling a shutter closed in fear. In the muddy street, three
Wanderers of Helheim walk slowly toward the camera: narrow humanoid figures, tattered grey funerary cloth
wrappings, plates of dull matte iron on shoulders and chest, dry pale grey faces with hollow eyes, long
unkempt hair, broken marching gait. Beside the street a village runestone stands dark and dead. Mist on
the ground. Foreground: a broken wooden fence on the left and tall grass on the right.
RUNIC DETAILS: The village runestone's carved glyphs are visible but lifeless grey, with one last flicker of runic blue #73D5DB in a single groove; amber #E9B765 protection runes are painted on the house doors and shutters; the wanderers' iron plates are scratched with twisted, corrupted runes that do not glow.
```
**FONDO — capa lejana (4608 × 2160, opaca)**
```
SCENE CONTEXT (this describes the whole shot; paint ONLY the layer requested below):
Night in a small Eldervald settlement of timber houses with turf and shingle roofs, warm amber #E9B765 light
in a few windows, one villager in the background pulling a shutter closed in fear. In the muddy street, three
Wanderers of Helheim walk slowly toward the camera: narrow humanoid figures, tattered grey funerary cloth
wrappings, plates of dull matte iron on shoulders and chest, dry pale grey faces with hollow eyes, long
unkempt hair, broken marching gait. Beside the street a village runestone stands dark and dead. Mist on
the ground. Foreground: a broken wooden fence on the left and tall grass on the right.
RUNIC DETAILS: The village runestone's carved glyphs are visible but lifeless grey, with one last flicker of runic blue #73D5DB in a single groove; amber #E9B765 protection runes are painted on the house doors and shutters; the wanderers' iron plates are scratched with twisted, corrupted runes that do not glow.

PAINT ONLY THE FAR BACKGROUND LAYER: the houses, the background villager at the window, the trees and night sky. Everything that belongs to the midground subject and the foreground is NOT painted; where they would be, paint what lies behind them (continuous sky, terrain, walls), so the layer is complete with no holes. Wide panoramic canvas 4608x2160 (wider than 16:9): extend the scenery naturally to both sides, same horizon height and perspective as the shot. Opaque, full frame.
```
**MEDIO — capa del sujeto (3840 × 2160, sobre magenta)**
```
SCENE CONTEXT (this describes the whole shot; paint ONLY the layer requested below):
Night in a small Eldervald settlement of timber houses with turf and shingle roofs, warm amber #E9B765 light
in a few windows, one villager in the background pulling a shutter closed in fear. In the muddy street, three
Wanderers of Helheim walk slowly toward the camera: narrow humanoid figures, tattered grey funerary cloth
wrappings, plates of dull matte iron on shoulders and chest, dry pale grey faces with hollow eyes, long
unkempt hair, broken marching gait. Beside the street a village runestone stands dark and dead. Mist on
the ground. Foreground: a broken wooden fence on the left and tall grass on the right.
RUNIC DETAILS: The village runestone's carved glyphs are visible but lifeless grey, with one last flicker of runic blue #73D5DB in a single groove; amber #E9B765 protection runes are painted on the house doors and shutters; the wanderers' iron plates are scratched with twisted, corrupted runes that do not glow.

PAINT ONLY THE MIDGROUND LAYER: the three Wanderers, the dark runestone and the ground mist. Same placement, size and perspective as in the shot (16:9, 3840x2160). Everything else is a perfectly flat, solid pure magenta #FF00FF background: no sky, no extra ground, no cast shadows or glow spilling onto the magenta, clean crisp outer edges.
```
**FRENTE — capa cercana (3840 × 2160, sobre magenta)**
```
SCENE CONTEXT (this describes the whole shot; paint ONLY the layer requested below):
Night in a small Eldervald settlement of timber houses with turf and shingle roofs, warm amber #E9B765 light
in a few windows, one villager in the background pulling a shutter closed in fear. In the muddy street, three
Wanderers of Helheim walk slowly toward the camera: narrow humanoid figures, tattered grey funerary cloth
wrappings, plates of dull matte iron on shoulders and chest, dry pale grey faces with hollow eyes, long
unkempt hair, broken marching gait. Beside the street a village runestone stands dark and dead. Mist on
the ground. Foreground: a broken wooden fence on the left and tall grass on the right.
RUNIC DETAILS: The village runestone's carved glyphs are visible but lifeless grey, with one last flicker of runic blue #73D5DB in a single groove; amber #E9B765 protection runes are painted on the house doors and shutters; the wanderers' iron plates are scratched with twisted, corrupted runes that do not glow.

PAINT ONLY THE CLOSE FOREGROUND LAYER: the broken fence on the left and tall grass on the right. These elements are very close to the camera, partially cut by the frame edges, slightly larger and darker than the rest of the scene, as in the shot (16:9, 3840x2160). Everything else is a perfectly flat, solid pure magenta #FF00FF background with clean crisp edges.
```
**TINTA — versión solo línea (3840 × 2160, opcional, para que se dibuje)**
```
Night in a small Eldervald settlement of timber houses with turf and shingle roofs, warm amber #E9B765 light
in a few windows, one villager in the background pulling a shutter closed in fear. In the muddy street, three
Wanderers of Helheim walk slowly toward the camera: narrow humanoid figures, tattered grey funerary cloth
wrappings, plates of dull matte iron on shoulders and chest, dry pale grey faces with hollow eyes, long
unkempt hair, broken marching gait. Beside the street a village runestone stands dark and dead. Mist on
the ground. Foreground: a broken wooden fence on the left and tall grass on the right.
RUNIC DETAILS: The village runestone's carved glyphs are visible but lifeless grey, with one last flicker of runic blue #73D5DB in a single groove; amber #E9B765 protection runes are painted on the house doors and shutters; the wanderers' iron plates are scratched with twisted, corrupted runes that do not glow.

Render this exact shot ONLY as the finished black and dark-brown ink drawing: confident pen lines, contours, hatching and cross-hatching for shadows, a few construction strokes, on plain warm off-white paper color #EDE3CC. No watercolor, no color, no washes, no glow, no gradients. Same composition and framing as the color version.
```

### C1 · P10 — Lejos, en la fosa de la Arena
*Narrador: «Lejos de allí, en la fosa de la Arena, un guerrero sin memoria sigue peleando… sin saber que las runas lo llaman.»*
Movimiento sugerido: la cámara baja desde lo alto de las gradas hacia la fosa. Cierra a negro. Une con la cinemática 2.

**FINAL**
```
High angle view from the top of a vast circular stone arena at night, torches along the walls, the stands
dark and half empty. Far below in the sandy pit, small but unmistakable, EROMASH stands alone with his sword,
seen from behind and above, wearing his official red E helmet (three points up, whole). Under the sand around his
feet, the faint outline of an ancient buried runestone glows very weakly in runic blue #73D5DB, unnoticed.
Foreground: the iron railing and a torch at the top edge of the stands, close to camera.
RUNIC DETAILS: Under the sand of the pit, the buried runestone's glyph pattern glows faintly runic blue #73D5DB, with thin lines of light spreading through the sand toward Eromash's feet; a faint blue reflection on the top of his helmet; ancient dark runic carvings run along the base of the arena walls.
```
**FONDO — capa lejana (4608 × 2160, opaca)**
```
SCENE CONTEXT (this describes the whole shot; paint ONLY the layer requested below):
High angle view from the top of a vast circular stone arena at night, torches along the walls, the stands
dark and half empty. Far below in the sandy pit, small but unmistakable, EROMASH stands alone with his sword,
seen from behind and above, wearing his official red E helmet (three points up, whole). Under the sand around his
feet, the faint outline of an ancient buried runestone glows very weakly in runic blue #73D5DB, unnoticed.
Foreground: the iron railing and a torch at the top edge of the stands, close to camera.
RUNIC DETAILS: Under the sand of the pit, the buried runestone's glyph pattern glows faintly runic blue #73D5DB, with thin lines of light spreading through the sand toward Eromash's feet; a faint blue reflection on the top of his helmet; ancient dark runic carvings run along the base of the arena walls.

PAINT ONLY THE FAR BACKGROUND LAYER: the far side of the arena walls, the stands and the night sky with the citadel walls beyond. Everything that belongs to the midground subject and the foreground is NOT painted; where they would be, paint what lies behind them (continuous sky, terrain, walls), so the layer is complete with no holes. Wide panoramic canvas 4608x2160 (wider than 16:9): extend the scenery naturally to both sides, same horizon height and perspective as the shot. Opaque, full frame.
```
**MEDIO — capa del sujeto (3840 × 2160, sobre magenta)**
```
SCENE CONTEXT (this describes the whole shot; paint ONLY the layer requested below):
High angle view from the top of a vast circular stone arena at night, torches along the walls, the stands
dark and half empty. Far below in the sandy pit, small but unmistakable, EROMASH stands alone with his sword,
seen from behind and above, wearing his official red E helmet (three points up, whole). Under the sand around his
feet, the faint outline of an ancient buried runestone glows very weakly in runic blue #73D5DB, unnoticed.
Foreground: the iron railing and a torch at the top edge of the stands, close to camera.
RUNIC DETAILS: Under the sand of the pit, the buried runestone's glyph pattern glows faintly runic blue #73D5DB, with thin lines of light spreading through the sand toward Eromash's feet; a faint blue reflection on the top of his helmet; ancient dark runic carvings run along the base of the arena walls.

PAINT ONLY THE MIDGROUND LAYER: the sandy pit with Eromash and the faint buried runestone glow. Same placement, size and perspective as in the shot (16:9, 3840x2160). Everything else is a perfectly flat, solid pure magenta #FF00FF background: no sky, no extra ground, no cast shadows or glow spilling onto the magenta, clean crisp outer edges.
```
**FRENTE — capa cercana (3840 × 2160, sobre magenta)**
```
SCENE CONTEXT (this describes the whole shot; paint ONLY the layer requested below):
High angle view from the top of a vast circular stone arena at night, torches along the walls, the stands
dark and half empty. Far below in the sandy pit, small but unmistakable, EROMASH stands alone with his sword,
seen from behind and above, wearing his official red E helmet (three points up, whole). Under the sand around his
feet, the faint outline of an ancient buried runestone glows very weakly in runic blue #73D5DB, unnoticed.
Foreground: the iron railing and a torch at the top edge of the stands, close to camera.
RUNIC DETAILS: Under the sand of the pit, the buried runestone's glyph pattern glows faintly runic blue #73D5DB, with thin lines of light spreading through the sand toward Eromash's feet; a faint blue reflection on the top of his helmet; ancient dark runic carvings run along the base of the arena walls.

PAINT ONLY THE CLOSE FOREGROUND LAYER: the iron railing and the torch at the top edge. These elements are very close to the camera, partially cut by the frame edges, slightly larger and darker than the rest of the scene, as in the shot (16:9, 3840x2160). Everything else is a perfectly flat, solid pure magenta #FF00FF background with clean crisp edges.
```
**TINTA — versión solo línea (3840 × 2160, opcional, para que se dibuje)**
```
High angle view from the top of a vast circular stone arena at night, torches along the walls, the stands
dark and half empty. Far below in the sandy pit, small but unmistakable, EROMASH stands alone with his sword,
seen from behind and above, wearing his official red E helmet (three points up, whole). Under the sand around his
feet, the faint outline of an ancient buried runestone glows very weakly in runic blue #73D5DB, unnoticed.
Foreground: the iron railing and a torch at the top edge of the stands, close to camera.
RUNIC DETAILS: Under the sand of the pit, the buried runestone's glyph pattern glows faintly runic blue #73D5DB, with thin lines of light spreading through the sand toward Eromash's feet; a faint blue reflection on the top of his helmet; ancient dark runic carvings run along the base of the arena walls.

Render this exact shot ONLY as the finished black and dark-brown ink drawing: confident pen lines, contours, hatching and cross-hatching for shadows, a few construction strokes, on plain warm off-white paper color #EDE3CC. No watercolor, no color, no washes, no glow, no gradients. Same composition and framing as the color version.
```

---

## CINEMÁTICA 2 — El eco del yelmo y el trato (La Arena)

Se ve después del prólogo, al empezar una partida nueva. Sigue `output/Cinematica 2/plan.md`. **En 7 de los 8 planos aparece Eromash (o su reflejo): revisá el casco en cada imagen.**

### C2 · P01 — La fosa de la Arena
*Movimiento sugerido: plano picado que baja desde las gradas hasta Eromash. Tambores.*

**FINAL**
```
Daylight inside the Arena of a closed Norse citadel: a deep circular sand pit stained with blood, high
stone walls, stands packed with a roaring crowd (painted loosely as masses of figures and raised fists),
banners hanging. In the center of the pit, EROMASH stands over a fallen Helheim beast — a huge emaciated
creature with grey hide, bony spines and tattered iron plates fused to its body, lying defeated on the sand.
Eromash holds his sword low, breathing hard, official red E helmet (three points up, whole). Under their bodies
a cracked ancient runestone slab is uncovered in the sand, its runes starting to glow runic blue #73D5DB.
High angle. Foreground: iron bars of a gate at the bottom edge.
RUNIC DETAILS: The uncovered slab is a large circular rune carving glowing runic blue #73D5DB with an almost white core; lines of runic light crawl through the sand toward Eromash's boots and light his red E helmet and armor from below in blue.
```
**FONDO — capa lejana (4608 × 2160, opaca)**
```
SCENE CONTEXT (this describes the whole shot; paint ONLY the layer requested below):
Daylight inside the Arena of a closed Norse citadel: a deep circular sand pit stained with blood, high
stone walls, stands packed with a roaring crowd (painted loosely as masses of figures and raised fists),
banners hanging. In the center of the pit, EROMASH stands over a fallen Helheim beast — a huge emaciated
creature with grey hide, bony spines and tattered iron plates fused to its body, lying defeated on the sand.
Eromash holds his sword low, breathing hard, official red E helmet (three points up, whole). Under their bodies
a cracked ancient runestone slab is uncovered in the sand, its runes starting to glow runic blue #73D5DB.
High angle. Foreground: iron bars of a gate at the bottom edge.
RUNIC DETAILS: The uncovered slab is a large circular rune carving glowing runic blue #73D5DB with an almost white core; lines of runic light crawl through the sand toward Eromash's boots and light his red E helmet and armor from below in blue.

PAINT ONLY THE FAR BACKGROUND LAYER: the arena walls, the crowd in the stands, banners and sky. Everything that belongs to the midground subject and the foreground is NOT painted; where they would be, paint what lies behind them (continuous sky, terrain, walls), so the layer is complete with no holes. Wide panoramic canvas 4608x2160 (wider than 16:9): extend the scenery naturally to both sides, same horizon height and perspective as the shot. Opaque, full frame.
```
**MEDIO — capa del sujeto (3840 × 2160, sobre magenta)**
```
SCENE CONTEXT (this describes the whole shot; paint ONLY the layer requested below):
Daylight inside the Arena of a closed Norse citadel: a deep circular sand pit stained with blood, high
stone walls, stands packed with a roaring crowd (painted loosely as masses of figures and raised fists),
banners hanging. In the center of the pit, EROMASH stands over a fallen Helheim beast — a huge emaciated
creature with grey hide, bony spines and tattered iron plates fused to its body, lying defeated on the sand.
Eromash holds his sword low, breathing hard, official red E helmet (three points up, whole). Under their bodies
a cracked ancient runestone slab is uncovered in the sand, its runes starting to glow runic blue #73D5DB.
High angle. Foreground: iron bars of a gate at the bottom edge.
RUNIC DETAILS: The uncovered slab is a large circular rune carving glowing runic blue #73D5DB with an almost white core; lines of runic light crawl through the sand toward Eromash's boots and light his red E helmet and armor from below in blue.

PAINT ONLY THE MIDGROUND LAYER: Eromash, the fallen beast and the runestone slab with the sand around them. Same placement, size and perspective as in the shot (16:9, 3840x2160). Everything else is a perfectly flat, solid pure magenta #FF00FF background: no sky, no extra ground, no cast shadows or glow spilling onto the magenta, clean crisp outer edges.
```
**FRENTE — capa cercana (3840 × 2160, sobre magenta)**
```
SCENE CONTEXT (this describes the whole shot; paint ONLY the layer requested below):
Daylight inside the Arena of a closed Norse citadel: a deep circular sand pit stained with blood, high
stone walls, stands packed with a roaring crowd (painted loosely as masses of figures and raised fists),
banners hanging. In the center of the pit, EROMASH stands over a fallen Helheim beast — a huge emaciated
creature with grey hide, bony spines and tattered iron plates fused to its body, lying defeated on the sand.
Eromash holds his sword low, breathing hard, official red E helmet (three points up, whole). Under their bodies
a cracked ancient runestone slab is uncovered in the sand, its runes starting to glow runic blue #73D5DB.
High angle. Foreground: iron bars of a gate at the bottom edge.
RUNIC DETAILS: The uncovered slab is a large circular rune carving glowing runic blue #73D5DB with an almost white core; lines of runic light crawl through the sand toward Eromash's boots and light his red E helmet and armor from below in blue.

PAINT ONLY THE CLOSE FOREGROUND LAYER: the iron gate bars at the bottom edge. These elements are very close to the camera, partially cut by the frame edges, slightly larger and darker than the rest of the scene, as in the shot (16:9, 3840x2160). Everything else is a perfectly flat, solid pure magenta #FF00FF background with clean crisp edges.
```
**TINTA — versión solo línea (3840 × 2160, opcional, para que se dibuje)**
```
Daylight inside the Arena of a closed Norse citadel: a deep circular sand pit stained with blood, high
stone walls, stands packed with a roaring crowd (painted loosely as masses of figures and raised fists),
banners hanging. In the center of the pit, EROMASH stands over a fallen Helheim beast — a huge emaciated
creature with grey hide, bony spines and tattered iron plates fused to its body, lying defeated on the sand.
Eromash holds his sword low, breathing hard, official red E helmet (three points up, whole). Under their bodies
a cracked ancient runestone slab is uncovered in the sand, its runes starting to glow runic blue #73D5DB.
High angle. Foreground: iron bars of a gate at the bottom edge.
RUNIC DETAILS: The uncovered slab is a large circular rune carving glowing runic blue #73D5DB with an almost white core; lines of runic light crawl through the sand toward Eromash's boots and light his red E helmet and armor from below in blue.

Render this exact shot ONLY as the finished black and dark-brown ink drawing: confident pen lines, contours, hatching and cross-hatching for shadows, a few construction strokes, on plain warm off-white paper color #EDE3CC. No watercolor, no color, no washes, no glow, no gradients. Same composition and framing as the color version.
```

### C2 · P02 — Los ojos de la bestia
*Bestia: «Otra vez…» · Movimiento sugerido: acercamiento lento; al final, destello y la losa se quiebra.*

**FINAL**
```
Extreme close-up of the dying Helheim beast's eye, lying on the sand: a huge ancient weary eye, pale iris,
grey cracked skin around it. Reflected in the wet surface of the eye we see the small silhouette of Eromash
standing over it, his red E helmet (three points up) catching a faint runic blue glow #73D5DB. Sand grains and
blood on the creature's skin. Background: blurred sand and the glowing rune slab under the beast. The beast
looks at him with recognition, not hatred.
RUNIC DETAILS: The eye reflects the runic blue #73D5DB glow of the slab and of Eromash's helmet; tiny glyph shapes are visible in the reflection; thin blue light slits come from the slab beneath the beast.
```
**FONDO — capa lejana (4608 × 2160, opaca)**
```
SCENE CONTEXT (this describes the whole shot; paint ONLY the layer requested below):
Extreme close-up of the dying Helheim beast's eye, lying on the sand: a huge ancient weary eye, pale iris,
grey cracked skin around it. Reflected in the wet surface of the eye we see the small silhouette of Eromash
standing over it, his red E helmet (three points up) catching a faint runic blue glow #73D5DB. Sand grains and
blood on the creature's skin. Background: blurred sand and the glowing rune slab under the beast. The beast
looks at him with recognition, not hatred.
RUNIC DETAILS: The eye reflects the runic blue #73D5DB glow of the slab and of Eromash's helmet; tiny glyph shapes are visible in the reflection; thin blue light slits come from the slab beneath the beast.

PAINT ONLY THE FAR BACKGROUND LAYER: the blurred sand and the glowing rune slab. Everything that belongs to the midground subject and the foreground is NOT painted; where they would be, paint what lies behind them (continuous sky, terrain, walls), so the layer is complete with no holes. Wide panoramic canvas 4608x2160 (wider than 16:9): extend the scenery naturally to both sides, same horizon height and perspective as the shot. Opaque, full frame.
```
**MEDIO — capa del sujeto (3840 × 2160, sobre magenta)**
```
SCENE CONTEXT (this describes the whole shot; paint ONLY the layer requested below):
Extreme close-up of the dying Helheim beast's eye, lying on the sand: a huge ancient weary eye, pale iris,
grey cracked skin around it. Reflected in the wet surface of the eye we see the small silhouette of Eromash
standing over it, his red E helmet (three points up) catching a faint runic blue glow #73D5DB. Sand grains and
blood on the creature's skin. Background: blurred sand and the glowing rune slab under the beast. The beast
looks at him with recognition, not hatred.
RUNIC DETAILS: The eye reflects the runic blue #73D5DB glow of the slab and of Eromash's helmet; tiny glyph shapes are visible in the reflection; thin blue light slits come from the slab beneath the beast.

PAINT ONLY THE MIDGROUND LAYER: the beast's eye and the skin around it, with the reflection. Same placement, size and perspective as in the shot (16:9, 3840x2160). Everything else is a perfectly flat, solid pure magenta #FF00FF background: no sky, no extra ground, no cast shadows or glow spilling onto the magenta, clean crisp outer edges.
```
**FRENTE — capa cercana (3840 × 2160, sobre magenta)**
```
SCENE CONTEXT (this describes the whole shot; paint ONLY the layer requested below):
Extreme close-up of the dying Helheim beast's eye, lying on the sand: a huge ancient weary eye, pale iris,
grey cracked skin around it. Reflected in the wet surface of the eye we see the small silhouette of Eromash
standing over it, his red E helmet (three points up) catching a faint runic blue glow #73D5DB. Sand grains and
blood on the creature's skin. Background: blurred sand and the glowing rune slab under the beast. The beast
looks at him with recognition, not hatred.
RUNIC DETAILS: The eye reflects the runic blue #73D5DB glow of the slab and of Eromash's helmet; tiny glyph shapes are visible in the reflection; thin blue light slits come from the slab beneath the beast.

PAINT ONLY THE CLOSE FOREGROUND LAYER: floating sand grains and dust particles in the foreground. These elements are very close to the camera, partially cut by the frame edges, slightly larger and darker than the rest of the scene, as in the shot (16:9, 3840x2160). Everything else is a perfectly flat, solid pure magenta #FF00FF background with clean crisp edges.
```
**TINTA — versión solo línea (3840 × 2160, opcional, para que se dibuje)**
```
Extreme close-up of the dying Helheim beast's eye, lying on the sand: a huge ancient weary eye, pale iris,
grey cracked skin around it. Reflected in the wet surface of the eye we see the small silhouette of Eromash
standing over it, his red E helmet (three points up) catching a faint runic blue glow #73D5DB. Sand grains and
blood on the creature's skin. Background: blurred sand and the glowing rune slab under the beast. The beast
looks at him with recognition, not hatred.
RUNIC DETAILS: The eye reflects the runic blue #73D5DB glow of the slab and of Eromash's helmet; tiny glyph shapes are visible in the reflection; thin blue light slits come from the slab beneath the beast.

Render this exact shot ONLY as the finished black and dark-brown ink drawing: confident pen lines, contours, hatching and cross-hatching for shadows, a few construction strokes, on plain warm off-white paper color #EDE3CC. No watercolor, no color, no washes, no glow, no gradients. Same composition and framing as the color version.
```

### C2 · P03 — La losa se quiebra
*Movimiento sugerido: temblor; la luz rúnica estalla desde las grietas.*

**FINAL**
```
Mid shot in the arena pit: the ancient runestone slab under the sand cracks apart in a burst of runic blue
light #73D5DB with an almost white core, beams shooting up through the cracks and sand flying. The beast's
body slumps lifeless. EROMASH steps back, shielding himself with his arm, his red E helmet (three points up,
whole) lit blue from below. The crowd in the background is silent and frozen. Foreground: chunks of stone
and sand flying toward camera.
RUNIC DETAILS: Glyphs of pure light rise out of the cracks like floating runes, runic blue #73D5DB with white cores, scattering blue motes; the edges of Eromash's red E helmet and armor are rimmed with blue light.
```
**FONDO — capa lejana (4608 × 2160, opaca)**
```
SCENE CONTEXT (this describes the whole shot; paint ONLY the layer requested below):
Mid shot in the arena pit: the ancient runestone slab under the sand cracks apart in a burst of runic blue
light #73D5DB with an almost white core, beams shooting up through the cracks and sand flying. The beast's
body slumps lifeless. EROMASH steps back, shielding himself with his arm, his red E helmet (three points up,
whole) lit blue from below. The crowd in the background is silent and frozen. Foreground: chunks of stone
and sand flying toward camera.
RUNIC DETAILS: Glyphs of pure light rise out of the cracks like floating runes, runic blue #73D5DB with white cores, scattering blue motes; the edges of Eromash's red E helmet and armor are rimmed with blue light.

PAINT ONLY THE FAR BACKGROUND LAYER: the arena wall and the frozen crowd. Everything that belongs to the midground subject and the foreground is NOT painted; where they would be, paint what lies behind them (continuous sky, terrain, walls), so the layer is complete with no holes. Wide panoramic canvas 4608x2160 (wider than 16:9): extend the scenery naturally to both sides, same horizon height and perspective as the shot. Opaque, full frame.
```
**MEDIO — capa del sujeto (3840 × 2160, sobre magenta)**
```
SCENE CONTEXT (this describes the whole shot; paint ONLY the layer requested below):
Mid shot in the arena pit: the ancient runestone slab under the sand cracks apart in a burst of runic blue
light #73D5DB with an almost white core, beams shooting up through the cracks and sand flying. The beast's
body slumps lifeless. EROMASH steps back, shielding himself with his arm, his red E helmet (three points up,
whole) lit blue from below. The crowd in the background is silent and frozen. Foreground: chunks of stone
and sand flying toward camera.
RUNIC DETAILS: Glyphs of pure light rise out of the cracks like floating runes, runic blue #73D5DB with white cores, scattering blue motes; the edges of Eromash's red E helmet and armor are rimmed with blue light.

PAINT ONLY THE MIDGROUND LAYER: Eromash, the beast and the cracking slab with the light beams. Same placement, size and perspective as in the shot (16:9, 3840x2160). Everything else is a perfectly flat, solid pure magenta #FF00FF background: no sky, no extra ground, no cast shadows or glow spilling onto the magenta, clean crisp outer edges.
```
**FRENTE — capa cercana (3840 × 2160, sobre magenta)**
```
SCENE CONTEXT (this describes the whole shot; paint ONLY the layer requested below):
Mid shot in the arena pit: the ancient runestone slab under the sand cracks apart in a burst of runic blue
light #73D5DB with an almost white core, beams shooting up through the cracks and sand flying. The beast's
body slumps lifeless. EROMASH steps back, shielding himself with his arm, his red E helmet (three points up,
whole) lit blue from below. The crowd in the background is silent and frozen. Foreground: chunks of stone
and sand flying toward camera.
RUNIC DETAILS: Glyphs of pure light rise out of the cracks like floating runes, runic blue #73D5DB with white cores, scattering blue motes; the edges of Eromash's red E helmet and armor are rimmed with blue light.

PAINT ONLY THE CLOSE FOREGROUND LAYER: the flying stone chunks and sand. These elements are very close to the camera, partially cut by the frame edges, slightly larger and darker than the rest of the scene, as in the shot (16:9, 3840x2160). Everything else is a perfectly flat, solid pure magenta #FF00FF background with clean crisp edges.
```
**TINTA — versión solo línea (3840 × 2160, opcional, para que se dibuje)**
```
Mid shot in the arena pit: the ancient runestone slab under the sand cracks apart in a burst of runic blue
light #73D5DB with an almost white core, beams shooting up through the cracks and sand flying. The beast's
body slumps lifeless. EROMASH steps back, shielding himself with his arm, his red E helmet (three points up,
whole) lit blue from below. The crowd in the background is silent and frozen. Foreground: chunks of stone
and sand flying toward camera.
RUNIC DETAILS: Glyphs of pure light rise out of the cracks like floating runes, runic blue #73D5DB with white cores, scattering blue motes; the edges of Eromash's red E helmet and armor are rimmed with blue light.

Render this exact shot ONLY as the finished black and dark-brown ink drawing: confident pen lines, contours, hatching and cross-hatching for shadows, a few construction strokes, on plain warm off-white paper color #EDE3CC. No watercolor, no color, no washes, no glow, no gradients. Same composition and framing as the color version.
```

### C2 · P04 — La cámara del rey
*Rey: «La hoja entró en diagonal, rasgando la sien derecha.» · Movimiento sugerido: paneo lento lateral.*

**FINAL**
```
A private stone chamber high in the citadel tower at night, lit only by candles: heavy tapestries, a
carved wooden desk with maps and a goblet. The King of the Arena sits in shadow behind the desk, wrapped in
a wide-brimmed hood and a long grey cloak; his face is hidden in darkness except for ONE single eye that
catches the candlelight with a cold glint (the other side of the face is fully in shadow). Two ravens perched
on a beam in the dark (subtle). Mid shot, side angle. Foreground: the edge of a stone column and a candle
on the left.
RUNIC DETAILS: Subtle runic presence: a tapestry woven with ancient glyphs; on the desk map, the world tree is marked with a small glowing runic blue #73D5DB rune; the king's single eye has a cold blue glint; a rune-carved spear leans in the shadows.
```
**FONDO — capa lejana (4608 × 2160, opaca)**
```
SCENE CONTEXT (this describes the whole shot; paint ONLY the layer requested below):
A private stone chamber high in the citadel tower at night, lit only by candles: heavy tapestries, a
carved wooden desk with maps and a goblet. The King of the Arena sits in shadow behind the desk, wrapped in
a wide-brimmed hood and a long grey cloak; his face is hidden in darkness except for ONE single eye that
catches the candlelight with a cold glint (the other side of the face is fully in shadow). Two ravens perched
on a beam in the dark (subtle). Mid shot, side angle. Foreground: the edge of a stone column and a candle
on the left.
RUNIC DETAILS: Subtle runic presence: a tapestry woven with ancient glyphs; on the desk map, the world tree is marked with a small glowing runic blue #73D5DB rune; the king's single eye has a cold blue glint; a rune-carved spear leans in the shadows.

PAINT ONLY THE FAR BACKGROUND LAYER: the chamber walls, tapestries and the dark window. Everything that belongs to the midground subject and the foreground is NOT painted; where they would be, paint what lies behind them (continuous sky, terrain, walls), so the layer is complete with no holes. Wide panoramic canvas 4608x2160 (wider than 16:9): extend the scenery naturally to both sides, same horizon height and perspective as the shot. Opaque, full frame.
```
**MEDIO — capa del sujeto (3840 × 2160, sobre magenta)**
```
SCENE CONTEXT (this describes the whole shot; paint ONLY the layer requested below):
A private stone chamber high in the citadel tower at night, lit only by candles: heavy tapestries, a
carved wooden desk with maps and a goblet. The King of the Arena sits in shadow behind the desk, wrapped in
a wide-brimmed hood and a long grey cloak; his face is hidden in darkness except for ONE single eye that
catches the candlelight with a cold glint (the other side of the face is fully in shadow). Two ravens perched
on a beam in the dark (subtle). Mid shot, side angle. Foreground: the edge of a stone column and a candle
on the left.
RUNIC DETAILS: Subtle runic presence: a tapestry woven with ancient glyphs; on the desk map, the world tree is marked with a small glowing runic blue #73D5DB rune; the king's single eye has a cold blue glint; a rune-carved spear leans in the shadows.

PAINT ONLY THE MIDGROUND LAYER: the king, the desk and the ravens. Same placement, size and perspective as in the shot (16:9, 3840x2160). Everything else is a perfectly flat, solid pure magenta #FF00FF background: no sky, no extra ground, no cast shadows or glow spilling onto the magenta, clean crisp outer edges.
```
**FRENTE — capa cercana (3840 × 2160, sobre magenta)**
```
SCENE CONTEXT (this describes the whole shot; paint ONLY the layer requested below):
A private stone chamber high in the citadel tower at night, lit only by candles: heavy tapestries, a
carved wooden desk with maps and a goblet. The King of the Arena sits in shadow behind the desk, wrapped in
a wide-brimmed hood and a long grey cloak; his face is hidden in darkness except for ONE single eye that
catches the candlelight with a cold glint (the other side of the face is fully in shadow). Two ravens perched
on a beam in the dark (subtle). Mid shot, side angle. Foreground: the edge of a stone column and a candle
on the left.
RUNIC DETAILS: Subtle runic presence: a tapestry woven with ancient glyphs; on the desk map, the world tree is marked with a small glowing runic blue #73D5DB rune; the king's single eye has a cold blue glint; a rune-carved spear leans in the shadows.

PAINT ONLY THE CLOSE FOREGROUND LAYER: the stone column edge and the candle on the left. These elements are very close to the camera, partially cut by the frame edges, slightly larger and darker than the rest of the scene, as in the shot (16:9, 3840x2160). Everything else is a perfectly flat, solid pure magenta #FF00FF background with clean crisp edges.
```
**TINTA — versión solo línea (3840 × 2160, opcional, para que se dibuje)**
```
A private stone chamber high in the citadel tower at night, lit only by candles: heavy tapestries, a
carved wooden desk with maps and a goblet. The King of the Arena sits in shadow behind the desk, wrapped in
a wide-brimmed hood and a long grey cloak; his face is hidden in darkness except for ONE single eye that
catches the candlelight with a cold glint (the other side of the face is fully in shadow). Two ravens perched
on a beam in the dark (subtle). Mid shot, side angle. Foreground: the edge of a stone column and a candle
on the left.
RUNIC DETAILS: Subtle runic presence: a tapestry woven with ancient glyphs; on the desk map, the world tree is marked with a small glowing runic blue #73D5DB rune; the king's single eye has a cold blue glint; a rune-carved spear leans in the shadows.

Render this exact shot ONLY as the finished black and dark-brown ink drawing: confident pen lines, contours, hatching and cross-hatching for shadows, a few construction strokes, on plain warm off-white paper color #EDE3CC. No watercolor, no color, no washes, no glow, no gradients. Same composition and framing as the color version.
```

### C2 · P05 — El medallón
*Rey: «Yo estuve allí. Llegá al árbol y te devolveré tu nombre.» · Movimiento sugerido: acercamiento por encima del hombro.*

**FINAL**
```
Over-the-shoulder shot from behind EROMASH: in the foreground, out of focus, his shoulder armor and the back
of his official red E helmet (three points up, whole). On the wooden desk in front of him, a royal
medallion of old gold is spinning on its edge, catching candlelight, engraved with a stylized tree. Across
the desk, the hooded King leans forward, his single eye glinting in the shadow of the hood.
RUNIC DETAILS: The spinning medallion is engraved with a tree and a central rune that glows faint runic blue #73D5DB as it turns, leaving a thin blue light trail; on the map under it, a small blue rune marks the World Ash.
```
**FONDO — capa lejana (4608 × 2160, opaca)**
```
SCENE CONTEXT (this describes the whole shot; paint ONLY the layer requested below):
Over-the-shoulder shot from behind EROMASH: in the foreground, out of focus, his shoulder armor and the back
of his official red E helmet (three points up, whole). On the wooden desk in front of him, a royal
medallion of old gold is spinning on its edge, catching candlelight, engraved with a stylized tree. Across
the desk, the hooded King leans forward, his single eye glinting in the shadow of the hood.
RUNIC DETAILS: The spinning medallion is engraved with a tree and a central rune that glows faint runic blue #73D5DB as it turns, leaving a thin blue light trail; on the map under it, a small blue rune marks the World Ash.

PAINT ONLY THE FAR BACKGROUND LAYER: the dark chamber behind the king. Everything that belongs to the midground subject and the foreground is NOT painted; where they would be, paint what lies behind them (continuous sky, terrain, walls), so the layer is complete with no holes. Wide panoramic canvas 4608x2160 (wider than 16:9): extend the scenery naturally to both sides, same horizon height and perspective as the shot. Opaque, full frame.
```
**MEDIO — capa del sujeto (3840 × 2160, sobre magenta)**
```
SCENE CONTEXT (this describes the whole shot; paint ONLY the layer requested below):
Over-the-shoulder shot from behind EROMASH: in the foreground, out of focus, his shoulder armor and the back
of his official red E helmet (three points up, whole). On the wooden desk in front of him, a royal
medallion of old gold is spinning on its edge, catching candlelight, engraved with a stylized tree. Across
the desk, the hooded King leans forward, his single eye glinting in the shadow of the hood.
RUNIC DETAILS: The spinning medallion is engraved with a tree and a central rune that glows faint runic blue #73D5DB as it turns, leaving a thin blue light trail; on the map under it, a small blue rune marks the World Ash.

PAINT ONLY THE MIDGROUND LAYER: the desk, the spinning medallion and the king. Same placement, size and perspective as in the shot (16:9, 3840x2160). Everything else is a perfectly flat, solid pure magenta #FF00FF background: no sky, no extra ground, no cast shadows or glow spilling onto the magenta, clean crisp outer edges.
```
**FRENTE — capa cercana (3840 × 2160, sobre magenta)**
```
SCENE CONTEXT (this describes the whole shot; paint ONLY the layer requested below):
Over-the-shoulder shot from behind EROMASH: in the foreground, out of focus, his shoulder armor and the back
of his official red E helmet (three points up, whole). On the wooden desk in front of him, a royal
medallion of old gold is spinning on its edge, catching candlelight, engraved with a stylized tree. Across
the desk, the hooded King leans forward, his single eye glinting in the shadow of the hood.
RUNIC DETAILS: The spinning medallion is engraved with a tree and a central rune that glows faint runic blue #73D5DB as it turns, leaving a thin blue light trail; on the map under it, a small blue rune marks the World Ash.

PAINT ONLY THE CLOSE FOREGROUND LAYER: Eromash's shoulder and the back of his red E helmet, out of focus. These elements are very close to the camera, partially cut by the frame edges, slightly larger and darker than the rest of the scene, as in the shot (16:9, 3840x2160). Everything else is a perfectly flat, solid pure magenta #FF00FF background with clean crisp edges.
```
**TINTA — versión solo línea (3840 × 2160, opcional, para que se dibuje)**
```
Over-the-shoulder shot from behind EROMASH: in the foreground, out of focus, his shoulder armor and the back
of his official red E helmet (three points up, whole). On the wooden desk in front of him, a royal
medallion of old gold is spinning on its edge, catching candlelight, engraved with a stylized tree. Across
the desk, the hooded King leans forward, his single eye glinting in the shadow of the hood.
RUNIC DETAILS: The spinning medallion is engraved with a tree and a central rune that glows faint runic blue #73D5DB as it turns, leaving a thin blue light trail; on the map under it, a small blue rune marks the World Ash.

Render this exact shot ONLY as the finished black and dark-brown ink drawing: confident pen lines, contours, hatching and cross-hatching for shadows, a few construction strokes, on plain warm off-white paper color #EDE3CC. No watercolor, no color, no washes, no glow, no gradients. Same composition and framing as the color version.
```

### C2 · P06 — La forja de Bera
*Bera: «Esto no es metal quemado, Eromash. Es madera del lecho profundo.» · Movimiento sugerido: foco que pasa del casco a la astilla.*

**FINAL**
```
A Norse forge, glowing coals, anvil, hanging tools, warm orange firelight and smoke. Close shot: EROMASH
sits on a stool in profile, in full armor, WEARING his official red E helmet (three points up, whole, the E
intact) - he never removes it. Bera the blacksmith, a strong middle-aged woman with braided hair, leather
apron and soot on her forearms, leans over the side of his helmet with fine iron pliers and pulls a black
splinter out of a thin seam at the side of the helmet (the seam never crosses the E). The splinter looks
like petrified root and gives off a thin wisp of cold pale smoke. Foreground: a pair of tongs and sparks.
RUNIC DETAILS: The petrified splinter has tiny veins of runic blue #73D5DB light running through its grain; the thin seam in the side of the helmet glows faint blue where the splinter comes out; simple amber #E9B765 maker's runes are stamped on the forge tools.
```
**FONDO — capa lejana (4608 × 2160, opaca)**
```
SCENE CONTEXT (this describes the whole shot; paint ONLY the layer requested below):
A Norse forge, glowing coals, anvil, hanging tools, warm orange firelight and smoke. Close shot: EROMASH
sits on a stool in profile, in full armor, WEARING his official red E helmet (three points up, whole, the E
intact) - he never removes it. Bera the blacksmith, a strong middle-aged woman with braided hair, leather
apron and soot on her forearms, leans over the side of his helmet with fine iron pliers and pulls a black
splinter out of a thin seam at the side of the helmet (the seam never crosses the E). The splinter looks
like petrified root and gives off a thin wisp of cold pale smoke. Foreground: a pair of tongs and sparks.
RUNIC DETAILS: The petrified splinter has tiny veins of runic blue #73D5DB light running through its grain; the thin seam in the side of the helmet glows faint blue where the splinter comes out; simple amber #E9B765 maker's runes are stamped on the forge tools.

PAINT ONLY THE FAR BACKGROUND LAYER: the forge walls, coals, hanging tools and smoke. Everything that belongs to the midground subject and the foreground is NOT painted; where they would be, paint what lies behind them (continuous sky, terrain, walls), so the layer is complete with no holes. Wide panoramic canvas 4608x2160 (wider than 16:9): extend the scenery naturally to both sides, same horizon height and perspective as the shot. Opaque, full frame.
```
**MEDIO — capa del sujeto (3840 × 2160, sobre magenta)**
```
SCENE CONTEXT (this describes the whole shot; paint ONLY the layer requested below):
A Norse forge, glowing coals, anvil, hanging tools, warm orange firelight and smoke. Close shot: EROMASH
sits on a stool in profile, in full armor, WEARING his official red E helmet (three points up, whole, the E
intact) - he never removes it. Bera the blacksmith, a strong middle-aged woman with braided hair, leather
apron and soot on her forearms, leans over the side of his helmet with fine iron pliers and pulls a black
splinter out of a thin seam at the side of the helmet (the seam never crosses the E). The splinter looks
like petrified root and gives off a thin wisp of cold pale smoke. Foreground: a pair of tongs and sparks.
RUNIC DETAILS: The petrified splinter has tiny veins of runic blue #73D5DB light running through its grain; the thin seam in the side of the helmet glows faint blue where the splinter comes out; simple amber #E9B765 maker's runes are stamped on the forge tools.

PAINT ONLY THE MIDGROUND LAYER: Eromash seated with his red E helmet on, Bera leaning over him with the pliers and the smoking splinter. Same placement, size and perspective as in the shot (16:9, 3840x2160). Everything else is a perfectly flat, solid pure magenta #FF00FF background: no sky, no extra ground, no cast shadows or glow spilling onto the magenta, clean crisp outer edges.
```
**FRENTE — capa cercana (3840 × 2160, sobre magenta)**
```
SCENE CONTEXT (this describes the whole shot; paint ONLY the layer requested below):
A Norse forge, glowing coals, anvil, hanging tools, warm orange firelight and smoke. Close shot: EROMASH
sits on a stool in profile, in full armor, WEARING his official red E helmet (three points up, whole, the E
intact) - he never removes it. Bera the blacksmith, a strong middle-aged woman with braided hair, leather
apron and soot on her forearms, leans over the side of his helmet with fine iron pliers and pulls a black
splinter out of a thin seam at the side of the helmet (the seam never crosses the E). The splinter looks
like petrified root and gives off a thin wisp of cold pale smoke. Foreground: a pair of tongs and sparks.
RUNIC DETAILS: The petrified splinter has tiny veins of runic blue #73D5DB light running through its grain; the thin seam in the side of the helmet glows faint blue where the splinter comes out; simple amber #E9B765 maker's runes are stamped on the forge tools.

PAINT ONLY THE CLOSE FOREGROUND LAYER: the tongs and the flying sparks. These elements are very close to the camera, partially cut by the frame edges, slightly larger and darker than the rest of the scene, as in the shot (16:9, 3840x2160). Everything else is a perfectly flat, solid pure magenta #FF00FF background with clean crisp edges.
```
**TINTA — versión solo línea (3840 × 2160, opcional, para que se dibuje)**
```
A Norse forge, glowing coals, anvil, hanging tools, warm orange firelight and smoke. Close shot: EROMASH
sits on a stool in profile, in full armor, WEARING his official red E helmet (three points up, whole, the E
intact) - he never removes it. Bera the blacksmith, a strong middle-aged woman with braided hair, leather
apron and soot on her forearms, leans over the side of his helmet with fine iron pliers and pulls a black
splinter out of a thin seam at the side of the helmet (the seam never crosses the E). The splinter looks
like petrified root and gives off a thin wisp of cold pale smoke. Foreground: a pair of tongs and sparks.
RUNIC DETAILS: The petrified splinter has tiny veins of runic blue #73D5DB light running through its grain; the thin seam in the side of the helmet glows faint blue where the splinter comes out; simple amber #E9B765 maker's runes are stamped on the forge tools.

Render this exact shot ONLY as the finished black and dark-brown ink drawing: confident pen lines, contours, hatching and cross-hatching for shadows, a few construction strokes, on plain warm off-white paper color #EDE3CC. No watercolor, no color, no washes, no glow, no gradients. Same composition and framing as the color version.
```

> Respeta la regla: el casco queda puesto. Bera trabaja sobre la hendija lateral con Eromash sentado.

### C2 · P07 — Bera le da el rumbo
*Bera: «Buscá a Eydis, la guardabosques, en los bosques del oeste.» · Movimiento sugerido: paneo suave entre los dos.*

**FINAL**
```
In the same forge, wider shot: Bera, the blacksmith, places the black petrified splinter wrapped in a
leather cloth into Eromash's gloved hand. EROMASH stands tall in full armor (red tabard, steel pauldrons), official red E helmet
(three points up, whole), seen three-quarters from behind. Bera points toward an open window where the
western forests are visible far away under grey clouds. Firelight on their sides, cold daylight from the
window.
RUNIC DETAILS: The splinter glows faint runic blue #73D5DB through the leather cloth in Eromash's hand; rune marks are carved on the anvil; through the window, tiny blue points of light (distant runestones) dot the western forest.
```
**FONDO — capa lejana (4608 × 2160, opaca)**
```
SCENE CONTEXT (this describes the whole shot; paint ONLY the layer requested below):
In the same forge, wider shot: Bera, the blacksmith, places the black petrified splinter wrapped in a
leather cloth into Eromash's gloved hand. EROMASH stands tall in full armor (red tabard, steel pauldrons), official red E helmet
(three points up, whole), seen three-quarters from behind. Bera points toward an open window where the
western forests are visible far away under grey clouds. Firelight on their sides, cold daylight from the
window.
RUNIC DETAILS: The splinter glows faint runic blue #73D5DB through the leather cloth in Eromash's hand; rune marks are carved on the anvil; through the window, tiny blue points of light (distant runestones) dot the western forest.

PAINT ONLY THE FAR BACKGROUND LAYER: the forge interior and the window view of the distant western forests. Everything that belongs to the midground subject and the foreground is NOT painted; where they would be, paint what lies behind them (continuous sky, terrain, walls), so the layer is complete with no holes. Wide panoramic canvas 4608x2160 (wider than 16:9): extend the scenery naturally to both sides, same horizon height and perspective as the shot. Opaque, full frame.
```
**MEDIO — capa del sujeto (3840 × 2160, sobre magenta)**
```
SCENE CONTEXT (this describes the whole shot; paint ONLY the layer requested below):
In the same forge, wider shot: Bera, the blacksmith, places the black petrified splinter wrapped in a
leather cloth into Eromash's gloved hand. EROMASH stands tall in full armor (red tabard, steel pauldrons), official red E helmet
(three points up, whole), seen three-quarters from behind. Bera points toward an open window where the
western forests are visible far away under grey clouds. Firelight on their sides, cold daylight from the
window.
RUNIC DETAILS: The splinter glows faint runic blue #73D5DB through the leather cloth in Eromash's hand; rune marks are carved on the anvil; through the window, tiny blue points of light (distant runestones) dot the western forest.

PAINT ONLY THE MIDGROUND LAYER: Bera and Eromash with the splinter. Same placement, size and perspective as in the shot (16:9, 3840x2160). Everything else is a perfectly flat, solid pure magenta #FF00FF background: no sky, no extra ground, no cast shadows or glow spilling onto the magenta, clean crisp outer edges.
```
**FRENTE — capa cercana (3840 × 2160, sobre magenta)**
```
SCENE CONTEXT (this describes the whole shot; paint ONLY the layer requested below):
In the same forge, wider shot: Bera, the blacksmith, places the black petrified splinter wrapped in a
leather cloth into Eromash's gloved hand. EROMASH stands tall in full armor (red tabard, steel pauldrons), official red E helmet
(three points up, whole), seen three-quarters from behind. Bera points toward an open window where the
western forests are visible far away under grey clouds. Firelight on their sides, cold daylight from the
window.
RUNIC DETAILS: The splinter glows faint runic blue #73D5DB through the leather cloth in Eromash's hand; rune marks are carved on the anvil; through the window, tiny blue points of light (distant runestones) dot the western forest.

PAINT ONLY THE CLOSE FOREGROUND LAYER: some hanging chains and tools at the top edge. These elements are very close to the camera, partially cut by the frame edges, slightly larger and darker than the rest of the scene, as in the shot (16:9, 3840x2160). Everything else is a perfectly flat, solid pure magenta #FF00FF background with clean crisp edges.
```
**TINTA — versión solo línea (3840 × 2160, opcional, para que se dibuje)**
```
In the same forge, wider shot: Bera, the blacksmith, places the black petrified splinter wrapped in a
leather cloth into Eromash's gloved hand. EROMASH stands tall in full armor (red tabard, steel pauldrons), official red E helmet
(three points up, whole), seen three-quarters from behind. Bera points toward an open window where the
western forests are visible far away under grey clouds. Firelight on their sides, cold daylight from the
window.
RUNIC DETAILS: The splinter glows faint runic blue #73D5DB through the leather cloth in Eromash's hand; rune marks are carved on the anvil; through the window, tiny blue points of light (distant runestones) dot the western forest.

Render this exact shot ONLY as the finished black and dark-brown ink drawing: confident pen lines, contours, hatching and cross-hatching for shadows, a few construction strokes, on plain warm off-white paper color #EDE3CC. No watercolor, no color, no washes, no glow, no gradients. Same composition and framing as the color version.
```

### C2 · P08 — La puerta de hierro
*Narrador (opcional): «Con una astilla del lecho del mundo y un nombre por recuperar, Eromash dejó atrás la fosa.» · Movimiento sugerido: la puerta se abre y la cámara avanza hacia la luz. Paso al juego en el Puesto de Eydis.*

**FINAL**
```
The great iron gate of the citadel opening outward, morning light flooding in. EROMASH stands in the gateway
seen from behind, full body, cloak moving in the wind, official red E helmet (three points up, whole), sword at
his side. Beyond the gate, a road winds west across moors toward the dark distant forests of Eldervald under
a pale sky. Guards on the walls watch him go. Foreground: the massive iron gate leaves and chains, framing
the shot on both sides.
RUNIC DETAILS: Ancient runes are carved on the gate arch; along the road west, distant waystones glow as small runic blue #73D5DB points leading toward the forest; the splinter pouch at Eromash's belt glows faint blue.
```
**FONDO — capa lejana (4608 × 2160, opaca)**
```
SCENE CONTEXT (this describes the whole shot; paint ONLY the layer requested below):
The great iron gate of the citadel opening outward, morning light flooding in. EROMASH stands in the gateway
seen from behind, full body, cloak moving in the wind, official red E helmet (three points up, whole), sword at
his side. Beyond the gate, a road winds west across moors toward the dark distant forests of Eldervald under
a pale sky. Guards on the walls watch him go. Foreground: the massive iron gate leaves and chains, framing
the shot on both sides.
RUNIC DETAILS: Ancient runes are carved on the gate arch; along the road west, distant waystones glow as small runic blue #73D5DB points leading toward the forest; the splinter pouch at Eromash's belt glows faint blue.

PAINT ONLY THE FAR BACKGROUND LAYER: the landscape beyond the gate: the road, the moors, the distant Eldervald forests and the sky. Everything that belongs to the midground subject and the foreground is NOT painted; where they would be, paint what lies behind them (continuous sky, terrain, walls), so the layer is complete with no holes. Wide panoramic canvas 4608x2160 (wider than 16:9): extend the scenery naturally to both sides, same horizon height and perspective as the shot. Opaque, full frame.
```
**MEDIO — capa del sujeto (3840 × 2160, sobre magenta)**
```
SCENE CONTEXT (this describes the whole shot; paint ONLY the layer requested below):
The great iron gate of the citadel opening outward, morning light flooding in. EROMASH stands in the gateway
seen from behind, full body, cloak moving in the wind, official red E helmet (three points up, whole), sword at
his side. Beyond the gate, a road winds west across moors toward the dark distant forests of Eldervald under
a pale sky. Guards on the walls watch him go. Foreground: the massive iron gate leaves and chains, framing
the shot on both sides.
RUNIC DETAILS: Ancient runes are carved on the gate arch; along the road west, distant waystones glow as small runic blue #73D5DB points leading toward the forest; the splinter pouch at Eromash's belt glows faint blue.

PAINT ONLY THE MIDGROUND LAYER: Eromash in the gateway and the guards on the walls. Same placement, size and perspective as in the shot (16:9, 3840x2160). Everything else is a perfectly flat, solid pure magenta #FF00FF background: no sky, no extra ground, no cast shadows or glow spilling onto the magenta, clean crisp outer edges.
```
**FRENTE — capa cercana (3840 × 2160, sobre magenta)**
```
SCENE CONTEXT (this describes the whole shot; paint ONLY the layer requested below):
The great iron gate of the citadel opening outward, morning light flooding in. EROMASH stands in the gateway
seen from behind, full body, cloak moving in the wind, official red E helmet (three points up, whole), sword at
his side. Beyond the gate, a road winds west across moors toward the dark distant forests of Eldervald under
a pale sky. Guards on the walls watch him go. Foreground: the massive iron gate leaves and chains, framing
the shot on both sides.
RUNIC DETAILS: Ancient runes are carved on the gate arch; along the road west, distant waystones glow as small runic blue #73D5DB points leading toward the forest; the splinter pouch at Eromash's belt glows faint blue.

PAINT ONLY THE CLOSE FOREGROUND LAYER: the iron gate leaves and chains on both sides. These elements are very close to the camera, partially cut by the frame edges, slightly larger and darker than the rest of the scene, as in the shot (16:9, 3840x2160). Everything else is a perfectly flat, solid pure magenta #FF00FF background with clean crisp edges.
```
**TINTA — versión solo línea (3840 × 2160, opcional, para que se dibuje)**
```
The great iron gate of the citadel opening outward, morning light flooding in. EROMASH stands in the gateway
seen from behind, full body, cloak moving in the wind, official red E helmet (three points up, whole), sword at
his side. Beyond the gate, a road winds west across moors toward the dark distant forests of Eldervald under
a pale sky. Guards on the walls watch him go. Foreground: the massive iron gate leaves and chains, framing
the shot on both sides.
RUNIC DETAILS: Ancient runes are carved on the gate arch; along the road west, distant waystones glow as small runic blue #73D5DB points leading toward the forest; the splinter pouch at Eromash's belt glows faint blue.

Render this exact shot ONLY as the finished black and dark-brown ink drawing: confident pen lines, contours, hatching and cross-hatching for shadows, a few construction strokes, on plain warm off-white paper color #EDE3CC. No watercolor, no color, no washes, no glow, no gradients. Same composition and framing as the color version.
```

---

## Extra opcional: versión en tinta para que «se dibuje»

Para cualquier plano, si querés que la IA de video lo muestre dibujándose, generá además una versión en tinta a partir de la final, con la final subida como referencia:

```
Same image, same composition, same framing, pixel-aligned: only the black and dark-brown ink linework and
hatching on plain warm off-white paper color #EDE3CC, no watercolor, no color, no shading washes, as if the
illustrator had only finished the inking.
```

En la IA de video ponés **la versión en tinta como primer cuadro y la final como último**, con un prompt del tipo «the ink drawing gets painted with watercolor washes, color spreading in blooms from the main subject outward, camera slowly pushes in».

## Resumen de cantidades

| | Planos | Imágenes (×4) | Con Eromash |
|---|---|---|---|
| Cinemática 1 | 10 | 40 | 1 (P10) |
| Cinemática 2 | 8 | 32 | 7 (P01, P02 en reflejo, P03, P05, P06, P07, P08) |
| **Total** | **18** | **72** | revisar casco en todas |
