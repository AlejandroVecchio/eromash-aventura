# Banco de animaciones (Universal Animation Library)

**Antes de pedir, descargar o hacer una animación humana, mirá acá.** El proyecto tiene un banco de 44 clips de calidad, gratis y ya conectado al juego: la *Universal Animation Library [Standard]* de Quaternius (CC0, uso comercial libre, sin atribución obligatoria).

- Archivo: `assets/modelos/animaciones/ual/UAL1_Standard.glb` (sin movimiento de raíz: los clips se quedan en el lugar).
- Original: `C:/eromash-juego/aventura/fuentes/Universal Animation Library[Standard]/` (trae también la versión `_RM` con movimiento de raíz, tres guías de importación y la licencia).
- Visor de Quaternius con todos los clips: https://quaternius.com/animviewer.html
- Licencia y créditos: `assets/modelos/animaciones/ual/CREDITOS.md`.

## Cómo está conectado

Los clips del pack están en **T** y el esqueleto del pack está girado 90° (sobre el eje vertical) respecto al de Eromash y los NPC de Tripo, que tienen los brazos caídos. Un clip del pack aplicado tal cual deja los brazos estirados hacia adelante. Por eso **no se usan directo**: `scripts/personajes/retarget.gd` (clase `Retarget`) los pasa al esqueleto de cada modelo:

1. Mide el giro entre los dos esqueletos con la dirección de los pies y lo aplica a las rotaciones y a la cadera.
2. Para brazos y piernas calcula la rotación más corta que lleva su dirección de reposo a la del pack y mueve el clip sobre eso (`orientación_destino = delta · corrección · reposo_destino`). Tronco y cabeza no se corrigen.
3. Muestrea a 30 Hz y deja el resultado como un clip normal del reproductor del personaje.

Funciona igual para Eromash, Eydis, Orm, Svanhild, los trabajadores y el Errante (cada uno con su propia pose de reposo). Cada clip pasado cuesta unos 7 ms al cargar, así que **cada personaje pide solo los suyos**.

### Cómo usarlo desde el código

```gdscript
# al armar el personaje (Eromash ya lo hace en Animaciones.preparar_heroe)
Animaciones.dar_animaciones(anim, modelo)                         # NPC: clips de Animaciones.UAL_NPC
Animaciones.dar_animaciones(anim, modelo, ["Idle", "Sitting_Idle"])  # los que pidas
anim.play("ual/Idle")                                             # se piden como "ual/<Nombre>"
```

- Los clips con `_Loop` en el pack ya vienen en bucle. Los demás se reproducen una vez.
- Pasos (caminar, correr): `Animaciones.velocidad_ual("Walk", altura)` da los m/s que avanza el clip en un personaje de esa altura; la velocidad de reproducción es `velocidad_real / ese valor`. Valores medidos (maniquí de 1,83 m): Walk y Walk_Formal 0,97 m/s, Jog_Fwd 5,36, Sprint 8,25, Crouch_Fwd 0,75, Swim_Fwd 2,18.
- **Para sumar un clip nuevo**: agregar su nombre a `UAL_NPC` o `UAL_HEROE` en `animaciones.gd` (o pasarlo en la llamada).
- Clips *propios del héroe* (los de Mixamo) en otro esqueleto: `Animaciones.agregar_heroe(anim, modelo, ["mecanismo"])` los pasa por el mismo `Retarget` y quedan como `heroe/mecanismo`. Sin esto rotan los brazos del NPC desde la pose de reposo del héroe.
- Si hace falta ver un clip: `herramientas/ver_animaciones.gd` saca una tira de cuadros (de frente y de costado) de cualquier clip sobre cualquier modelo. Uso en el encabezado del archivo.

## Qué se usa hoy

| Quién | Qué | Clip |
|---|---|---|
| Eromash sin armas | caminar, reposo | **`meshy/Caminar`** (Meshy, 1,04 s, ~1,6 m/s naturales: se reproduce a ~1,5×), reposo: sus `descanso`/`descanso2` de siempre (el `ual/Idle` queda solo para NPC). **Trote** (ritmo por defecto): su `correr` propio de siempre. **Sprint**: `ual/Sprint` (0,67 s, 8,25 m/s naturales en 1,83 m). Controles y velocidades: `docs/personaje-heroe.md` |
| Eromash | salto completo | `Jump_Start` (despegue y ascenso) → `Jump` (en el aire, también al caer de un borde) → `Jump_Land` (aterrizaje, 0,45 s) |
| Eromash | combo | sigue siendo el de dos golpes de siempre (`ataque`, `ataque2`); se probó una estocada (`Sword_Attack`) y una patada y se descartaron |
| NPC | reposo, caminar, hablar | `Idle`, `Walk` a 1,6 m/s, `Idle_Talking` mientras dicen su línea del diálogo (señal `Juego.hablante`) |
| Trabajadores | cuatro puestos distintos | `Idle`, `Idle_Talking`, `mecanismo` y `levantar` (propios del héroe, pasados a su esqueleto) |
| Errante | reposo, caminar, golpe recibido, muerte | `Idle`, `Walk` (al ritmo de su velocidad), `Hit_Chest`/`Hit_Head`, `Death01`; el golpe sigue siendo el `ataque` del héroe pasado a su esqueleto (cae justo al terminar el aviso en el piso) |

## Todos los clips (44)

Duración en segundos. **B** = bucle. Los marcados con ✔ ya se usan.

| Clip | s | | Idea de uso |
|---|---|---|---|
| `Idle` | 2,5 | B ✔ | reposo de cualquier humano |
| `Idle_Talking` | 2,93 | B ✔ | conversar, dar indicaciones |
| `Idle_Torch` | 1,27 | B | sostener una antorcha (vigías, cuevas, mazmorras) |
| `Sword_Idle` | 1,67 | B | guardia con espada de guardias del reino, caballeros, duelistas |
| `Walk` | 1,33 | B ✔ | caminar |
| `Walk_Formal` | 1,33 | B | caminar erguido: nobles, sacerdotes, procesiones, el rey |
| `Jog_Fwd` | 0,93 | B ✔ | correr |
| `Sprint` | 0,67 | B | carrera a fondo, persecuciones, enemigos rápidos |
| `Crouch_Idle`, `Crouch_Fwd` | 2,93 / 2,0 | B | sigilo, pasar bajo algo, mazmorras |
| `Jump_Start`, `Jump`, `Jump_Land` | 1,33 / 2,5 / 1,27 | B (`Jump`) ✔ | salto |
| `Roll` | 1,47 | | esquiva rodando hacia adelante; con avance de 5 m en la versión `_RM` |
| `Sword_Attack` | 1,53 | | estocada rápida (probada como tercer golpe del combo y descartada; el golpe cae a los 0,26 del clip) |
| `Punch_Cross`, `Punch_Jab` | 1,0 / 0,87 | | pelea sin armas, brutos, borrachos de taberna |
| `Hit_Chest`, `Hit_Head` | 0,33 / 0,43 | ✔ | reacción corta a un golpe |
| `Death01` | 2,4 | ✔ | caer y quedar tendido |
| `Interact` | 2,0 | | señalar un camino, hacer un gesto (Eydis mostrando el sendero) |
| `PickUp_Table` | 0,83 | | agarrar un objeto de una mesa o un cofre bajo |
| `Push` | 2,67 | B | empujar un carro, una puerta pesada, un bloque |
| `Fixing_Kneeling` | 5,2 | | arreglar algo en el suelo (arranca de pie: recortarlo para un bucle) |
| `Sitting_Enter`, `Sitting_Idle`, `Sitting_Talking`, `Sitting_Exit` | 1,3 / 1,67 / 2,93 / 1,03 | B (Idle, Talking) | taberna, fogata, consejo, escritorio: necesita un banco o silla a unos 0,45 m |
| `Driving` | 1,67 | B | llevar un carro o carreta (con el modelo del carro) |
| `Swim_Fwd`, `Swim_Idle` | 1,33 / 3,33 | B | nadar |
| `Spell_Simple_Enter`, `_Idle`, `_Shoot`, `_Exit` | 0,53 / 2,1 / 0,5 / 0,43 | B (Idle) | conjuros de runas: Svanhild, magos, una Lente del Eco nueva |
| `Dance` | 1,0 | B | fiestas, celebraciones |
| `Pistol_*` (7) | | | no encajan con el juego: sirven de referencia para apuntar con un arco o ballesta |
| `A_TPose` | 2,5 | | referencia; no se usa |

## Cosas para tener en cuenta

- **Postura del `Walk` del pack**: va con el torso caído y los codos muy doblados (se lee enojado o triste), y casi no mueve cadera ni hombros. Se probaron ajustes de postura, balanceo de brazos y torsión del tronco (están en `Retarget.convertir(clip, ajustes)`, documentados en `retarget.gd`, y `Animaciones.UAL_VARIANTES` es donde se darían de alta), pero Alejandro eligió reemplazar la caminata por la de Meshy, que ya trae todo eso hecho. Hoy no se usa ninguna variante.
- **Caminar es un paseo lento** (0,97 m/s) y el juego camina a 2,4 m/s: se reproduce a unas 2,3× y los pasos se ven cortos y rápidos. Si molesta, la salida es bajar `VEL` en `heroe.gd` (a ~1,8 m/s) o combinar con `Jog_Fwd`; el clip `Walk_Formal` tiene la misma velocidad.
- **Ropa y armas** no siguen los huesos: el faldón, la capa y las armas guardadas se animan con el cuerpo del modelo, no con el clip. Si una animación mete la mano dentro de la espada guardada, mirar `_arreglar_vaina` en `heroe.gd`.
- **Armado**: mientras el héroe tiene espada y escudo en la mano usa sus propios clips de guardia (`guardia`, `caminar_armado`, `correr_armado`, `bloqueo`); los del pack están pensados para manos libres o con espada sola.
- Los NPC iguales comparten biblioteca (clave: ruta del modelo). Si dos modelos distintos usan el mismo esqueleto, igual se calculan por separado.
- El pack **Pro** o más grandes de Quaternius (si Alejandro los consigue) se importan igual: `assets/modelos/animaciones/<pack>/`, con el mismo `mapa-ual.tres` (`herramientas/crear_mapa_ual.gd` lo genera) y el mismo `Retarget`.

## Caminata de Meshy

Meshy (Animate) genera animaciones para un modelo que se le sube y devuelve el modelo con su rig. Para Eromash se subió `docs/referencias/meshy/eromash-para-meshy-sin-armas.glb` (una sola malla, 1,85 m, sin rig ni animaciones, mirando al frente) y se descargó la caminata *Walking* como FBX *con piel*.

- Archivo: `assets/modelos/animaciones/meshy/caminar-meshy.fbx` (créditos y licencia pendiente en el `CREDITOS.md` de esa carpeta).
- Su rig usa los **nombres de hueso de Mixamo** (`mixamorig_*`), los mismos que el héroe, así que se importa con el mismo `assets/modelos/mapa-humano.tres` (ver el `.fbx.import`). `Animaciones.biblioteca_meshy()` lo pasa al esqueleto del héroe con `Retarget` y queda como **`meshy/Caminar`**.
- **Velocidad natural 1,6 m/s** (`Animaciones.MESHY_VELOCIDAD_CAMINAR`), medida con `herramientas/medir_paso.gd` (zancada de 0,83 m por paso, calibrado contra el `Walk` del pack: 0,97 m/s).
- Coordinación medida: manos en contrafase (−1,0), cada mano opuesta al pie de su lado (−0,92 a −0,95), cadera 5,2° en fase con las piernas (+0,97), hombros 12,8° en contrafase (−0,99).
- **Para sumar otro clip de Meshy** (idle, correr, etc.): descargarlo igual (FBX con piel o sin piel, 30 fps), copiarlo a esa carpeta, darle el mismo `.fbx.import` (mapa humano, ruta `PATH:target_character/Skeleton3D`) y agregarlo en `biblioteca_meshy()`.
- Meshy exporta el clip con piel y pesa unos 11 MB; el clip en sí es liviano.
