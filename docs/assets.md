# Assets del MVP de Eldervald

Lista de todo lo que usa el mundo hoy, por tipo, con dónde está y para qué se usa. Las rutas son desde `assets/`.

## Cómo sumar algo nuevo

1. **Elegí la pieza.** Los packs completos de Quaternius (Fantasy Props, Medieval Village, Stylized Nature) están en `C:/eromash-juego/aventura/fuentes/`. Del zip se copia solo la pieza que se va a usar, en glTF (`.gltf` + `.bin`), a la carpeta de su tipo dentro de `modelos/kit/`. Las texturas van al lado y se comparten entre piezas del mismo pack.
2. **Modelos propios** (Tripo o Blender) en `.glb`. Los originales de Tripo están en `C:/eromash-juego/output/` (Objetos, Enemigos, Personajes, Texturas); se copian al repo con nombre en español, en la carpeta que corresponda: `modelos/escenario/`, `modelos/objetos/`, `modelos/npc/`, `modelos/enemigos/` o `modelos/armas/`. Nombre en español, en minúsculas y con guiones (`cofre-runico.glb`).
3. **Créditos.** Cada pieza de terceros suma su línea en el `CREDITOS.md` de su carpeta, en el mismo commit.
4. **Ponerla en el mapa.** Hoy cada cosa se ubica por código en `scripts/mundo/escenario.gd` (pedímelo con el lugar). Cuando esté la escena editable con marcadores, se va a poder soltar en el editor.

## Naturaleza (Quaternius, Stylized Nature MegaKit · `modelos/kit/naturaleza/`)

Se siembran solos en `scripts/mundo/vegetacion.gd` (semilla fija, siempre en el mismo lugar), salvo donde se indica.

| Pieza | Para qué |
|---|---|
| `TwistedTree_1`, `_3`, `_5` | Árbol principal del bosque (las hojas se recolorean en el sombreador) |
| `Pine_1`, `_3`, `_5` | Pinos |
| `CommonTree_1`, `_3` | Árbol común |
| `DeadTree_1`, `_3` | Árboles secos cerca del Claro (enfermedad) y en el escenario |
| `Bush_Common` | Arbustos; también el follaje del Roble de Eikholt |
| `Fern_1` | Helechos |
| `Grass_Wispy_Tall`, `Grass_Common_Short` | Pasto |
| `Plant_1_Big` | Plantas grandes |
| `Mushroom_Common` | Hongos de rocío (brillan azul cerca de los caminos) |
| `Mushroom_Laetiporus` | Hongos de repisa |
| `Rock_Medium_1`, `_2`, `_3` | Rocas sólidas del bosque y del escenario (mojones del Refugio, bases) |
| `Pebble_Round_1` | Piedritas sueltas |
| `RockPath_Round_Wide` | Copiada, sin usar todavía |

## Aldea (Quaternius, Medieval Village MegaKit · `modelos/kit/aldea/`)

Las casas se arman con módulos en `casa()` de `escenario.gd`: paredes de 2 m, esquinas, techo y puerta.

| Pieza | Para qué |
|---|---|
| `Wall_Plaster_Straight` | Pared de revoque |
| `Wall_Plaster_Window_Wide_Round` | Pared con ventana |
| `Wall_Plaster_WoodGrid` | Pared con entramado de madera |
| `Wall_Plaster_Door_Round` | Pared con puerta |
| `Wall_UnevenBrick_Straight` | Pared de ladrillo (casas de piedra) |
| `Corner_Exterior_Wood` | Esquinas de las casas |
| `Roof_RoundTiles_4x6`, `Roof_RoundTiles_6x6` | Techos de tejas |
| `Door_1_Round` | Puerta |
| `Prop_Chimney` | Chimenea |
| `Prop_WoodenFence_Single` | Vallas y palisadas |
| `Prop_Wagon` | Carros (aserradero, caravana de Skeld) |
| `T_WoodTrim_BaseColor.png` | Textura de madera para tablas, andamios y pilas de troncos hechas por código |
| `Floor_WoodDark`, `Prop_Crate`, `Prop_WoodenFence_Extension1` | Copiadas, sin usar todavía |

## Objetos (Quaternius, Fantasy Props MegaKit · `modelos/kit/objetos/`)

| Pieza | Para qué |
|---|---|
| `Crate_Wooden` | Cajones (Puesto, carro, Refugio, Paso) |
| `Barrel` | Barriles; también reemplaza a la bolsa (`Bag` no se copió) |
| `Workbench` | Mesas de trabajo |
| `Bench` | Banco |
| `Bookcase_2` | Estantería (Casa de las Lindes) |
| `Bucket_Wooden_1` | Balde |
| `Rope_1` | Soga |
| `Lantern_Wall` | Farol del carrero tirado junto al carro |
| `Chest_Wood` | Copiado, sin usar todavía (sirve para los cofres) |

## Escenario propio (Tripo · `modelos/escenario/`)

| Archivo | Para qué |
|---|---|
| `roble-eikholt.glb` | El Roble de Eikholt |
| `piedra-runica.glb` | Piedras rúnicas (faros azules y la piedra caída del Refugio) |
| `cobertizo-refugio.glb` | Cobertizos (Puesto y Refugio) |
| `losa-patio.glb` | Losa del patio de la Casa de las Lindes |
| `pedestal-paso.glb` | Pedestal del Núcleo en el Paso |
| `soporte-petreo.glb`, `soporte-petreo-roto.glb` | Soportes del Claro, enteros y rotos |
| `tronco-hongos.glb` | Troncos caídos con hongos (sólidos) |
| `santuario-entrada.glb` | Entrada del Santuario de las Raíces |

## Objetos propios (Tripo · `modelos/objetos/`)

| Archivo | Para qué |
|---|---|
| `carro-volcado.glb` | El carro de EL-01 (y otro en el Refugio) |
| `farol-camino.glb` | Faroles de los caminos |
| `mesa-examen.glb` | Mesa de Svanhild |
| `fragmento-asta.glb` | Fragmento de asta (EL-02/03) |
| `nucleo-linde.glb` | Núcleo de la Linde (EL-05/06) |

## Personajes, enemigos y armas (Tripo)

| Archivo | Para qué |
|---|---|
| `personaje/eromash-completo.glb` | Eromash con todas sus animaciones |
| `npc/eydis.glb`, `orm.glb`, `svanhild.glb`, `trabajador.glb` | NPC (Orm y el trabajador, reexportados en Blender) |
| `enemigos/lobo-zarzal.glb` | Lobos de Zarzal (pesos rehechos en Blender) |
| `enemigos/errante-helheim.glb` | Errantes de Helheim |
| `enemigos/custodio-corteza.glb` | Custodio de corteza |
| `enemigos/ciervo-hueco.glb` | El Ciervo Hueco |
| `armas/lanza-eydis.glb`, `armas/hacha-orm.glb` | Armas de Eydis y Orm |

## Suelo (`texturas/suelo/`)

| Textura | Dónde va |
|---|---|
| `suelo-base.png` | Tierra del bosque |
| `musgo.png` | Musgo |
| `camino.png` | Caminos |
| `ribera.png` | Orillas de ríos y bordes de la quebrada |
| `lecho-rio.png` | Fondo de los ríos |
| `losas-ruina.png` | Patios y el Claro |
| `zona-enferma.png` | Tierra enferma cerca del Claro |

La piedra de las pendientes usa la textura de rocas del kit (`kit/naturaleza/Rocks_Diffuse.png`).

## Interfaz, marca y sonido

| Archivo | Para qué |
|---|---|
| `interfaz/mapa-eldervald.png` | Diario y minimapa |
| `interfaz/puntero/` | Puntero del mouse: `normal`, `interactuable` (azul, sobre algo usable) y `enemigo` (círculo). PNG de 128 px recortados de los originales de Alejandro (`eromash-juego/output/UI/puntero-runico-*-v1.png`, los mismos del prototipo); `scripts/autoload/puntero.gd` |
| `marca/logotipo.png` | Pantalla de título |
| `marca/fuentes/` | Eromash Display y Eromash Text |
| `audio/sfx/` | Efectos CC0 (golpes, runas, campanas, gong, ambiente); créditos en `audio/CREDITOS.md` |

## Hecho por código (sin archivo)

Agua de los ríos, zarzas violetas del Santuario, ataduras del Ciervo, avisos del piso, marcas de la Lente, rueda del aserradero y Lente del Eco en la mano.

## Animaciones (Quaternius, Universal Animation Library · `modelos/animaciones/ual/`)

| Archivo | Para qué |
|---|---|
| `UAL1_Standard.glb` | Banco de 44 animaciones humanas (CC0). Se pasan al esqueleto de cada personaje con `Retarget`; caminar/correr/descansar sin armas, salto, estocada del combo, hablar y reposo de los NPC, golpes y muerte del Errante |
| `mapa-ual.tres` | Mapa de huesos del pack al perfil humanoide (lo genera `herramientas/crear_mapa_ual.gd`) |

Qué trae cada clip y cómo usarlo: `docs/banco-animaciones.md`. Créditos: `modelos/animaciones/ual/CREDITOS.md`.

## Interfaz de aventura (16/10/2026)

assets/interfaz/equipo/ contiene miniaturas renderizadas de los seis modelos propios ya existentes (pechera, brazo, botas, capa, espada y escudo). Las genera herramientas/capturar_catalogo_interfaz.gd; no son modelos nuevos ni assets de terceros. assets/interfaz/vegvisir.svg es la reinterpretación vectorial propia de la maqueta, con su investigación en docs/referencias/interfaz-runica.html. docs/interfaz-aventura.md describe los usos y limitaciones.

## Maestro modular del personaje (16/10/2026, todavía sin integrar)

`docs/fuentes/personaje/Eromash-partes.blend` conserva el esqueleto y las 34
acciones, separa la armadura por ranuras y añade ropa interior de base. Incluye
controles para quitar/poner piezas en Blender y un respaldo del original.
Guía, validaciones y contrato para futuras piezas: `docs/personaje-modular.md`.
Capturas en `docs/referencias/personaje_modular/`. El juego sigue usando su GLB
actual; aún falta exportar e integrar los cambios visuales con el inventario.
La base anterior de rellenos fue sustituida por una base continua derivada de
MakeHuman (CC0), con datos y créditos en
`docs/fuentes/personaje/manos_makehuman/CREDITOS.md`. Armadura, casco y botas
siguen derivando de los modelos propios existentes. Capturas vigentes de la
reconstrucción en `docs/referencias/personaje_modular/base_nueva/`.

## Ilustraciones del prólogo (18/10/2026, sin integrar)

`assets/cinematicas/prologo_v1/` contiene seis diapositivas de «El susurro
de las raíces», con tres PNG por diapositiva: `imagenN_fondo.png`,
`imagenN_medio.png`, `imagenN_frente.png` (N = 1–6). Fondos opacos;
medios y frentes con alfa real. Generadas con image_gen a partir del guion
y la dirección artística. Guardián encapuchado, rostro en sombra y ojos
destacados por pedido de Alejandro. Prompts completos en `prompts.json`;
montaje de revisión en `vista_previa.html`, indicaciones en `MONTAJE.txt`.
Todavía no conectadas al reproductor del juego.
Corrección del plano 1: Yggdrasil es colosal y se contempla a extrema distancia,
detrás de varias cordilleras; queda en fondo, con ladera boscosa en medio.
Prompts vigentes para esas dos capas en `prompts_escala_yggdrasil.json`.

## Banco de equipo con base Tripo (16/10/2026)

`escenas/prueba_equipo.tscn` usa `assets/modelos/personaje/prueba_equipo/eromash_modular.glb`:
equipo original separado, cuerpo Tripo aportado por Alejandro y la capa de
`C:/eromash-juego/output/blender/capa-arena-v1/eromash-capa-arena-v4.blend`.
Este banco sustituye los experimentos de relleno/MakeHuman para esta prueba;
la aventura principal conserva su modelo actual. Fuente editable:
`docs/fuentes/personaje/Eromash-prueba-equipo.blend`. Procedencia en
`assets/modelos/personaje/prueba_equipo/CREDITOS.md` y límites en `docs/prueba-equipo.md`.
