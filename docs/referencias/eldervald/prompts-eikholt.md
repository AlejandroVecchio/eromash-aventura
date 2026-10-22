# Eikholt, la capital: instrucciones para generar imágenes

Versión 1 · 22/10/2026. Base: el documento «Eikholt, capital de Eldervald» y `docs/eldervald.md`.

## Cómo usar este archivo

- **Cada prompt se pega completo y sin cambios.** Ya trae el estilo, el plano de la ciudad y las reglas. No resumir ni sacar partes: la coherencia entre imágenes depende de que todos repitan el mismo plano.
- **Adjuntar en todas las imágenes:** `puesto-eydis-v2.png` (estilo y árboles) y `refugio-v1-encendido.png` (luz rúnica). Desde la segunda imagen, adjuntar también `eikholt-00-vista-general.png` para que la IA respete la disposición.
- **Medida:** 16:9, la mayor que permita la herramienta.
- **Orden:** generar primero la vista general (00). Si sale bien, todas las demás se apoyan en ella. Si algo del plano sale mal en la 00, corregirlo antes de seguir.
- **Prompt negativo:** si la herramienta tiene ese campo, pegar ahí el bloque «Prohibido» de cada prompt. Si no lo tiene, dejarlo dentro del prompt.
- **Sin Eromash.** Las imágenes son de la ciudad. El héroe se agrega en otra etapa con su hoja aprobada.

## El plano fijo de Eikholt

Lo que no puede cambiar entre imágenes (también va dentro de cada prompt, en inglés):

| Lugar | Dónde está | Qué lo identifica |
|---|---|---|
| El Roble | Centro exacto del claro | Tronco de unos 12 m de ancho, copa de 80 m que cubre la plaza, raíces enormes sobre el suelo, musgo, cintas atadas en las raíces bajas |
| Plaza del Roble | Anillo alrededor del tronco | Tierra apisonada y lajas, el pozo al este del tronco, la campana colgada de una rama baja al sudoeste, el tablón de avisos |
| Círculo del Ting | Lado norte del tronco, entre las raíces | Anillo de 12 piedras talladas para sentarse y, en el centro, una piedra negra sin luz con runas que no son del bosque |
| Mercado de los Toldos | Lado sur del tronco, bajo la copa | Toldos de lona teñida (ocre, verde apagado, azul humo, rojo óxido), puestos de madera |
| Puerta del Sur | Borde sur | Arco de troncos con faroles ámbar, casa de guardia, el gran tablero de tablillas. Llega el camino del Puesto y de Hrafngard |
| Puerta del Norte | Borde norte | Arco más sólido, reforzado con hierro; da al camino del Paso del Guardián |
| Puerta del Este | Borde este | Puente de madera sobre el brazo del río hacia el Aserradero y el Santuario |
| Puerta del Oeste | Borde oeste | Camino a Brunvik |
| Barrio de los Oficios | Oeste y sudoeste, segundo anillo | Herrería con humo oscuro, carpintería, cordelería |
| Casa de las Lindes | Borde oeste, pasando los oficios | Techo azul gris, piedra antigua abajo y madera arriba, patio con una losa rúnica azul |
| Casa de Sanación | Noroeste | Hierbas colgadas, jardín medicinal cercado |
| Guardia del Roble | Junto a la Puerta del Norte | Cuartel bajo, patio de práctica con muñecos de paja y estantes de lanzas |
| Hospedería del Hongo Dorado | Sudeste, mirando a la plaza | La casa más grande: dos pisos, cartel con un hongo dorado tallado, ventanas cálidas |
| Corral de caravanas | Nordeste, junto a la Puerta del Norte | Carretas varadas tapadas con lonas, bueyes, mercancía de otras regiones |
| Huertas de luz | Este, entre las casas y el río | Huertas en los claros con sol |
| Brazo del río | Bordea el este y el sur | Agua oscura y lenta, de este a sudoeste; muelle de balsas al sudeste |
| Mirador | Una rama alta del lado norte del Roble | Plataforma de madera con baranda y una escalera que sube por el tronco |
| Empalizada | Rodea toda la ciudad | Troncos afilados, baja (unos 3 m), con postes de runas ámbar cada tanto |

**Las luces y lo que significan.**
- **Ámbar** `#E9B765`: la gente. Faroles, ventanas, fogones y las runas talladas de protección doméstica en dinteles y postes.
- **Azul rúnico** `#73D5DB`: lo antiguo. Aparece en pocos lugares, y por eso se lee de lejos: la losa del patio de la Casa de las Lindes, dos piedras guardianas antiguas a los lados de la Puerta del Norte y vetas muy finas en las raíces más viejas del Roble.
- **Sin luz:** la piedra del Ting. Es lo desconocido.

---

## Bloques comunes

Estos tres bloques ya van dentro de cada prompt. Están acá para que se entienda qué hace cada parte.

**STYLE**
```
Painterly stylized 3D game concept art for a Norse dark-fantasy action RPG, in the visual language of the attached reference images: hand-painted textures, simplified readable volumes, strong silhouettes, soft wide shading bands, rich value contrast, no photorealism, no thick black outlines. Old-growth northern forest of colossal ancient conifers and oaks with wide moss-covered trunks, exposed roots, ferns, mossy boulders, wet earth. Overall mood: dim, cool, damp forest light (shadow #182C2B, foliage #30443B, moss #68704B, earth #4C3C32, path #78684E, stone #737C77) with warm amber human light (#E9B765) from lanterns, windows and hearths. Ancient rune light is cold cyan-blue #73D5DB with a near-white core #D8F6F7 and a deeper halo #2F8FA0; it EMANATES from carved grooves and spills onto nearby stone, moss, mist and people. Runes are Elder Futhark only. Camera: high three-quarter diagonal view as in an isometric-like action RPG (about 45 degrees down), unless stated otherwise.
```

**CITY LAYOUT**
```
Eikholt is the forest capital, a large timber town in a wide clearing roughly 300 meters across, ringed by a low palisade of sharpened logs with amber-carved rune posts. At the exact center stands the Eikholt Oak: a colossal ancient oak with a trunk about 12 meters wide, a canopy 80 meters across that roofs the central plaza, giant mossy roots rising from the ground, faint thin cyan rune veins in its oldest roots, and hundreds of small cloth ribbons with knots tied to its low roots. North of the trunk, among the roots: the Thing Circle, a ring of twelve carved seat-stones around one black unlit standing stone covered in strange runes unlike any other. South of the trunk, under the canopy: the Market of Awnings. East of the trunk: the stone well. A bronze bell hangs from a low branch to the southwest, beside a notice board. Second ring: crafts quarter to the west and southwest (smithy with dark smoke, carpentry, ropewalk); House of Healing to the northwest; Oak Guard barracks and training yard beside the North Gate; the Golden Mushroom inn, the largest two-story building, facing the plaza from the southeast; caravan yard to the northeast. Outer ring: homes, sunlit vegetable plots to the east. Four gates: South Gate (log arch with amber lanterns, guardhouse, a huge board of hanging wooden name-tablets), North Gate (heavier arch reinforced with iron, flanked by two ancient blue-glowing guardian stones, leads to the mountain pass), East Gate (wooden bridge over a slow dark river arm), West Gate (road to the fishing village). The river arm runs along the east and south edges, with a raft dock to the southeast. The House of the Borders stands at the west edge: blue-grey roof, ancient stone lower walls under a timber extension, a courtyard with an old flagstone that glows cyan. A lookout platform sits on a high north branch of the Oak, reached by a stair winding up the trunk.
```

**ARCHITECTURE AND PEOPLE**
```
Architecture: dark damp timber houses on stone plinths, steep shingle roofs with moss, deep eaves and covered porches, small warm windows, geometric carvings on important beams, amber protective runes carved over doors. Older houses nestle between the Oak's roots; nothing is built in the treetops except the lookout. Smoke from many chimneys. Signs of maintenance and repair everywhere, not ruins. People: Elderians, a human forest culture of varied ages, builds and skin tones; wool, coarse linen, waxed leather, tall boots, short cloaks in muted greens, ochres and smoke blue; braided or tied-back hair; working hands. Not everyone wears furs, helmets or weapons. Visitors from other northern realms stand out by their clothing and goods.
```

**PROHIBIDO** (va al final de cada prompt)
```
Do not include: any text, letters, captions or watermarks; the hero or any red-helmeted warrior; stone castles, cathedrals, city walls of masonry, medieval European city streets; elves, pointed ears, fairies; treehouse villages or houses built in the canopy; glowing mushrooms everywhere or a neon forest; magenta or purple light; cyan light on ordinary houses; modern objects; snow; palm trees; Celtic knots used as runes; floating islands.
```

---

## 00 · Vista general de Eikholt

Para qué: fija el plano. Todas las demás imágenes se apoyan en esta.

```
[STYLE] Painterly stylized 3D game concept art for a Norse dark-fantasy action RPG, in the visual language of the attached reference images: hand-painted textures, simplified readable volumes, strong silhouettes, soft wide shading bands, rich value contrast, no photorealism, no thick black outlines. Old-growth northern forest of colossal ancient conifers and oaks with wide moss-covered trunks, exposed roots, ferns, mossy boulders, wet earth. Overall mood: dim, cool, damp forest light (shadow #182C2B, foliage #30443B, moss #68704B, earth #4C3C32, path #78684E, stone #737C77) with warm amber human light (#E9B765) from lanterns, windows and hearths. Ancient rune light is cold cyan-blue #73D5DB with a near-white core #D8F6F7 and a deeper halo #2F8FA0; it EMANATES from carved grooves and spills onto nearby stone, moss, mist and people. Runes are Elder Futhark only.

[CITY LAYOUT] Eikholt is the forest capital, a large timber town in a wide clearing roughly 300 meters across, ringed by a low palisade of sharpened logs with amber-carved rune posts. At the exact center stands the Eikholt Oak: a colossal ancient oak with a trunk about 12 meters wide, a canopy 80 meters across that roofs the central plaza, giant mossy roots rising from the ground, faint thin cyan rune veins in its oldest roots, and hundreds of small cloth ribbons with knots tied to its low roots. North of the trunk, among the roots: the Thing Circle, a ring of twelve carved seat-stones around one black unlit standing stone covered in strange runes unlike any other. South of the trunk, under the canopy: the Market of Awnings. East of the trunk: the stone well. A bronze bell hangs from a low branch to the southwest, beside a notice board. Second ring: crafts quarter to the west and southwest (smithy with dark smoke, carpentry, ropewalk); House of Healing to the northwest; Oak Guard barracks and training yard beside the North Gate; the Golden Mushroom inn, the largest two-story building, facing the plaza from the southeast; caravan yard to the northeast. Outer ring: homes, sunlit vegetable plots to the east. Four gates: South Gate (log arch with amber lanterns, guardhouse, a huge board of hanging wooden name-tablets), North Gate (heavier arch reinforced with iron, flanked by two ancient blue-glowing guardian stones, leads to the mountain pass), East Gate (wooden bridge over a slow dark river arm), West Gate (road to the fishing village). The river arm runs along the east and south edges, with a raft dock to the southeast. The House of the Borders stands at the west edge: blue-grey roof, ancient stone lower walls under a timber extension, a courtyard with an old flagstone that glows cyan. A lookout platform sits on a high north branch of the Oak, reached by a stair winding up the trunk.

[ARCHITECTURE AND PEOPLE] Dark damp timber houses on stone plinths, steep shingle roofs with moss, deep eaves, small warm windows, amber protective runes carved over doors, smoke from many chimneys, signs of maintenance and repair. Tiny figures of townspeople in muted wool and leather.

[THIS IMAGE] High aerial establishing view from the south, looking north over the whole town, like a game world-map vignette rendered in 3D. The Oak dominates the center and is clearly the tallest and widest thing in the clearing; its canopy shades the plaza while the outer ring gets more sky. The surrounding forest is darker and colder than the town, so Eikholt reads as a warm amber island. In the far north, beyond the forest, a dark mountain range under low clouds. Late afternoon, overcast with one soft break of light over the clearing. All four gates, the river arm on the east and south, the raft dock, the caravan yard, the smithy smoke and the blue-roofed House of the Borders must be visible and in their stated positions. Blue rune light appears ONLY at the North Gate guardian stones, the House of the Borders courtyard flagstone and the thin veins in the Oak roots. 16:9.

Do not include: any text, letters, captions or watermarks; the hero or any red-helmeted warrior; stone castles, cathedrals, masonry city walls, medieval European city streets; elves, pointed ears, fairies; treehouse villages or houses in the canopy; glowing mushrooms everywhere or a neon forest; magenta or purple light; cyan light on ordinary houses; modern objects; snow; palm trees; Celtic knots used as runes; floating islands.
```

---

Desde acá, cada prompt empieza con los mismos bloques. Para no repetirlos en este archivo, aparecen como `[STYLE]`, `[CITY LAYOUT]`, `[ARCHITECTURE AND PEOPLE]` y `[DO NOT]`. **Al pegar en la IA, reemplazar cada marca por el texto completo del bloque.** La versión ya armada para pegar sin editar está en `prompts-eikholt-completos.md`.

## 01 · Puerta del Sur y el gran tablero de tablillas

Para qué: la llegada (EL-02). Es lo primero que ve el jugador de la ciudad.

```
[STYLE] [CITY LAYOUT] [ARCHITECTURE AND PEOPLE]

[THIS IMAGE] Game camera view of the South Gate seen from the road outside, looking north into town. A wide log arch with carved geometric beams and two amber lanterns on iron brackets; amber protective runes carved into the lintel (glowing softly warm, NOT blue). To the right of the arch, a small guardhouse with a porch; a middle-aged gatekeeper in a wool coat turns a wooden tablet on a huge board: a wall-sized frame under a shingle roof holding hundreds of small hanging wooden name-tablets, most turned to their pale side, a handful turned to their dark side. Through the arch: a glimpse of the market awnings and the vast trunk and roots of the Oak in the distance, its canopy filling the top of the frame. On the road in front: deep cart ruts, a merchant's ox cart waiting, two townspeople running out to help someone off-frame. The forest behind the viewer is cold and dark; the town ahead is warm. Late afternoon.

[DO NOT]
```

## 02 · Plaza del Roble y Mercado de los Toldos

Para qué: el corazón de la ciudad. Comercio y gente de otros reinos.

```
[STYLE] [CITY LAYOUT] [ARCHITECTURE AND PEOPLE]

[THIS IMAGE] Game camera view of the Market of Awnings on the south side of the Oak, the colossal trunk and roots filling the back of the frame, ribbons tied to the low roots. Stalls of wood and dyed canvas (ochre, muted green, smoke blue, rust red). Local goods: baskets of forest mushrooms, smoked fish on racks, furs, bundles of herbs, clay pots, carved bowls, coils of rope. Goods from other realms, clearly distinct: a stall of black obsidian amulets and grey ash-salts in small jars run by a talkative woman in a soot-stained shawl from a volcanic land; a stall of iron ingots, picks and heavy mountain tools beside a silent dusty miner; frost-pale fur and whalebone carvings from a snowy realm; sea salt, tarred ship rope and salted fish from the coast. Off to one side, a well-dressed emissary in a dark blue cloak with a silver raven brooch, holding a cup he does not drink, watching. To the east, the stone well with an old woman sitting on its rim. The bronze bell and the notice board covered in pinned wooden slips to the southwest. Mid-morning, busy, warm under the canopy with beams of light breaking through the leaves. Thin cyan veins glow faintly in the oldest root behind the stalls; nothing else is blue.

[DO NOT]
```

## 03 · El Círculo del Ting y la piedra dormida

Para qué: el poder político de la capital y el misterio que se quiere conocer.

```
[STYLE] [CITY LAYOUT] [ARCHITECTURE AND PEOPLE]

[THIS IMAGE] Game camera view of the Thing Circle on the north side of the Oak, nested among giant roots that form natural walls. Twelve carved seat-stones in a ring, each with a different craft symbol (axe, net, mushroom, leaf, scales, quill, hammer, oar, spear, needle, wheel, tree). An assembly in session: about fifteen Elderians standing and sitting, arguing; a grey-haired woman spokesperson holds a tall oak staff covered in notches; a gruff captain in a padded gambeson and a smith with burned forearms face each other; the raven-brooch emissary in dark blue stands at the edge. At the center: a tall black standing stone with NO light at all, carved with angular runes that clearly do not match the Elder Futhark runes used elsewhere, partly covered in moss and old offerings; it feels foreign and dormant. A cloaked island woman with constellation tattoos on her hands sits apart on a root, sketching the stone. Thin cyan veins in the surrounding roots, faint. Overcast afternoon, cool light through the canopy, amber lanterns hung on the roots.

[DO NOT]
```

## 04 · Barrio de los Oficios: herrería, armas y trabajo

Para qué: las armas, el equipo y el trabajo de la ciudad.

```
[STYLE] [CITY LAYOUT] [ARCHITECTURE AND PEOPLE]

[THIS IMAGE] Game camera view of the crafts quarter west of the plaza, the Oak's trunk visible at the right edge. In front: the smithy, an open-sided timber forge with a stone hearth glowing orange, dark smoke, an anvil, a muscular woman smith with scarred forearms hammering. Racks of finished weapons and armor under the eaves: spears, bearded axes, seaxes, round shields painted with simple forest symbols, mail shirts, padded gambesons, iron helmets with nasal guards; one special locked rack holds a sword with a faint cyan line along the fuller, the only rune-touched weapon, rare and expensive. Next door: a carpentry yard with planks drying, sawdust, a half-built cart; further on, a ropewalk where a man twists long ropes while talking; downstream to the south, tannery vats by the river. Iron is scarce: an almost empty ore bin. Morning, smoke and steam, warm forge light against cool damp air.

[DO NOT]
```

## 05 · Casa de las Lindes y su patio

Para qué: el saber y la magia rúnica estudiada. EL-03 y EL-07.

```
[STYLE] [CITY LAYOUT] [ARCHITECTURE AND PEOPLE]

[THIS IMAGE] Game camera view of the House of the Borders at the west edge of town. Older and different from every other house: lower walls of ancient fitted grey stone, a later timber extension above, a steep blue-grey roof. Maps on hide and paper drying under the eaves, a display cabinet of brass and wooden instruments visible through an open door, shelves of scrolls and tablets. In the walled courtyard: an old flagstone, older than the house, carved with Elder Futhark runes whose grooves glow cyan-blue and spill light onto the wet courtyard stones, the moss and the lower walls; slow motes rise from it. Beside it, an examination table with a fragment of antler. A tall elderly woman with silver hair, ink-stained fingers and spectacles on a cord stands with a thin, cold-looking scribe in snow-realm furs who argues over a scroll. Dusk: the courtyard's blue against the amber windows of the house.

[DO NOT]
```

## 06 · Casa de Sanación y jardín medicinal

```
[STYLE] [CITY LAYOUT] [ARCHITECTURE AND PEOPLE]

[THIS IMAGE] Game camera view of the House of Healing in the northwest quarter: a long low timber house with wide open shutters, bunches of drying herbs hanging from every beam, a fenced medicinal garden with labeled-by-shape beds (no text), a stone basin, steaming pots on an outdoor hearth. Inside through the open wall: cots with wool blankets; a bearded injured worker with a splinted leg propped up, joking; a woman sitting beside him mending a garment. The healer, an energetic middle-aged woman, smells a bundle of herbs. Amber protective runes carved on the door frame. Soft morning light, steam, calm and warm, the Oak's canopy edge visible above.

[DO NOT]
```

## 07 · La hospedería del Hongo Dorado (de noche)

Para qué: forasteros, rumores, música. Dos tomas: afuera e interior.

```
[STYLE] [CITY LAYOUT] [ARCHITECTURE AND PEOPLE]

[THIS IMAGE] Two views side by side. Left: exterior at night of the Golden Mushroom inn on the southeast side of the plaza, the largest building in town, two stories, a carved golden mushroom hanging sign (a carving, no letters), every window glowing amber, people on the porch, the Oak's roots and the dark plaza behind. Right: interior, a long hall with a big central hearth, low beams with carvings, long tables. A skald plays a lyre-like kantele for a small crowd; the innkeeper behind the counter; his barefoot daughter carrying mugs. Travelers from other realms at the tables: a broad, laughing shipwright with tar-stained hands and a sea-blue knit cap; a dusty silent miner; the soot-shawled amulet seller; the island woman with constellation tattoos drawing on a slate. Warm, crowded, alive.

[DO NOT]
```

## 08 · Puerta del Norte, la Guardia y el corral de caravanas

Para qué: la crisis del Paso cerrado y la gente varada.

```
[STYLE] [CITY LAYOUT] [ARCHITECTURE AND PEOPLE]

[THIS IMAGE] Game camera view of the north edge of town. The North Gate: a heavier log arch reinforced with iron bands, closed, with two guards. On either side stand two ancient guardian stones, older than the town, whose carved Elder Futhark runes glow cyan-blue and spill cold light onto the gate, the mud and the guards; slow motes rise. Beside the gate: the Oak Guard barracks and training yard, straw dummies, spear racks, round shields, young recruits drilling under a gruff captain. To the northeast: the caravan yard full of stranded wagons under tarps, oxen, crates and barrels marked with simple pictographs from other lands (a wave, a mountain, a snowflake, a flame), travelers waiting by a fire. Beyond the palisade to the north, a dark road climbing into the forest toward distant mountains. Grey afternoon, tense mood.

[DO NOT]
```

## 09 · El río, el muelle de balsas y las huertas

```
[STYLE] [CITY LAYOUT] [ARCHITECTURE AND PEOPLE]

[THIS IMAGE] Game camera view of the southeast edge of town where the slow dark river arm bends: a timber raft dock with log rafts, a raft jammed against floating logs, fishermen with nets, fish drying racks. North of the dock, sunlit vegetable plots in clearings between houses, and the East Gate with its wooden bridge over the river toward the forest. The water reflects amber lanterns. Morning mist on the river; the Oak's canopy visible behind the roofs.

[DO NOT]
```

## 10 · Desde el Mirador del Roble

Para qué: la vista que enseña el mapa de un vistazo.

```
[STYLE] [CITY LAYOUT] [ARCHITECTURE AND PEOPLE]

[THIS IMAGE] Over-the-shoulder view from the lookout platform on a high north branch of the Oak, wooden railing in the foreground, looking north. Below: the North Gate with its two blue guardian stones, the caravan yard, roofs and smoke. Beyond: the immense old forest stretching away; a river glinting; far to the north, a gorge where a broken bridge crosses (the Guardian's Pass), and behind it a dark mountain range under low cloud. Very far on the horizon, barely visible, an enormous tree silhouette rising above the mountains. Small cyan points of rune stones scattered through the forest like beacons. Late afternoon light breaking through clouds.

[DO NOT]
```

## 11 · La Noche de los Faroles

Para qué: la fiesta después de reabrir el Paso. La recompensa emocional.

```
[STYLE] [CITY LAYOUT] [ARCHITECTURE AND PEOPLE]

[THIS IMAGE] Game camera view of the plaza under the Oak at night during a festival. Hundreds of amber lanterns lit at once: hung from the roots, the low branches, the market awnings and every porch. Long tables carried into the plaza with food and drink; people dancing to a kantele and a fiddle; children racing. Five wooden name-tablets hang from a low root on their pale side, decorated with ribbons. The thin cyan veins of the oldest roots glow a little stronger than usual. The raven-brooch emissary raises a cup without drinking; an old woman sits silent on the well. The surrounding forest is pitch dark; the town is a warm island of light.

[DO NOT]
```

---

## Qué revisar en cada imagen antes de aprobarla

1. **El plano se respeta:** el Roble en el centro, el Ting al norte, el mercado al sur, el pozo al este, las cuatro puertas y el río al este y al sur.
2. **La regla de las luces:** azul solo en los tres lugares antiguos (piedras de la Puerta del Norte, losa de la Casa de las Lindes y vetas del Roble); ámbar en todo lo humano; la piedra del Ting sin luz.
3. **Las runas son del futhark**, sin espirales ni nudos.
4. **Los forasteros se distinguen** por ropa y mercancía, sin que haga falta texto.
5. **Sin Eromash, sin letras y sin castillos de piedra.**
