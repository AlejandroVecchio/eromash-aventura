# Eromash modular — maestro y base reconstruida

Estado: 16/10/2026. **La base anterior de rellenos/parches quedó descartada.**
La base activa usa una malla anatómica continua de MakeHuman (CC0), adaptada
al esqueleto existente. Las piezas de armadura originales se conservan.
Todavía no se exportó/integró esta versión con el inventario de Godot.

## Archivos que usar

- Maestro activo: `docs/fuentes/personaje/Eromash-partes.blend`.
- Copia de revisión de la reconstrucción:
  `docs/fuentes/personaje/Eromash-base-nueva-revision.blend`.
- Fuente original previa a toda separación:
  `docs/fuentes/personaje/eromash_original_respaldo.blend`.
- Capturas vigentes: `docs/referencias/personaje_modular/base_nueva/`.
  Las imágenes de la carpeta superior corresponden a etapas anteriores.
- Validación actual: `docs/fuentes/personaje/verificacion_base_nueva.json`.
- Créditos y licencia de la nueva base:
  `docs/fuentes/personaje/manos_makehuman/CREDITOS.md`.

El archivo que Alejandro había abierto en Downloads se conservó. La versión
trabajada está dentro de este proyecto, en las rutas anteriores.

## Organización de Blender

- `01_Cuerpo_base_nuevo`: `cuerpo_base_liso`, casco fijo y
  `botas_simples_referencia`.
- `02_Equipo_intercambiable`: pechera, cinturón, tabardo trasero, hombros,
  brazales, guantes, piernas, botas exteriores, espada y escudo.
- `03_Revision`: cámara/luces para revisar. No exportar.
- `90_Original_conservado`: originales y referencias ocultos. No exportar.
- `01_Cuerpo_base`: prototipo anterior, desactivado como colección tanto en
  vista como en render. **No volver a activarlo:** se superpondría a la base nueva.

`cuerpo_base_liso` es una sola superficie para torso, brazos, manos y piernas.
Camisa y pantalón se distinguen por material, sin una abertura de cintura.
La piel de las manos está modelada con palma, pulgar, nudillos y dedos de la
base anatómica; no está construida con cápsulas de los huesos. Se conservaron
los bucles de polígonos y se adaptaron los pesos de la fuente al rig Mixamo.
Hay un nivel de subdivisión para suavizar la superficie.

Los extremos abiertos del cuerpo se limitan a cuello y tobillos, cubiertos por
el casco/cuello original y las botas. No se incluyen pies anatómicos: el
calzado de base recupera la forma y los pesos de las botas propias existentes,
con material de cuero sencillo. No se usa la bota tubular del prototipo.

## Controles de equipo

Seleccionar `Armature_nuevo` → Propiedades del objeto → Propiedades personalizadas.
Cada valor `equipo_*` usa **0 para quitar / 1 para poner**.

- Individuales: `equipo_pechera`, `equipo_cinturon`, `equipo_hombros`,
  `equipo_brazales`, `equipo_guantes`, `equipo_piernas`, `equipo_botas`.
- `equipo_brazos`: habilita el conjunto hombros/brazales/guantes; en 0 lo oculta.
- `equipo_piernas_completo`: habilita grebas y botas; en 0 oculta el conjunto.
- Para restaurar todo, poner los controles conjuntos e individuales en 1.
- El casco E sigue fijo, con su geometría original.
- El paño trasero es `tabardo_trasero` y sigue `equipo_cinturon`, igual que el
  faldón delantero. No es una capa de hombros independiente.

Los guantes usan el patrón de las manos nuevas y un pequeño solape de puño.
Al equiparlos se oculta la piel cubierta mediante el modificador
`Piel_cubierta_por_guantes` de la base; al quitarlos vuelve la mano continua.
**Probar con estos controles**, no ocultando solamente el objeto guantes en
el Outliner: la máscara y el guante deben cambiar juntos.

El maestro se deja con la base visible y el rig en REST para revisar. Para
reproducir clips, activar POSE y elegir una de las 34 acciones existentes.
Las curvas, nombres de huesos y posiciones de reposo del esqueleto original
no se modificaron. Algunos clips acumulan avance y requieren reencuadrar.

## Revisión realizada y límites

- El cuerpo nuevo forma **un componente conectado**.
- No tiene bordes abiertos en axilas, brazos, muñecas ni cintura. Los bordes
  autorizados son los de cuello/tobillos, cubiertos por equipo permanente/base.
- No tiene aristas interiores no manifold ni vértices sin pesos de huesos.
- Se muestrearon cinco cuadros de las 34 acciones (170 poses), verificando
  coordenadas válidas. Esto comprueba integridad, no sustituye una revisión visual.
- Se revisaron capturas de reposo, ataque, bloqueo y carrera, acercamientos de
  bíceps, manos por ambas caras, gemelos y calzado, y el conjunto equipado.
- La armadura original mantiene su separación por ranuras. Los guantes y la
  base ya no deben compararse vértice a vértice con el modelo Tripo: se reconstruyeron.

La comprobación de runtime, rendimiento y cambios visuales desde el inventario
de Godot sigue pendiente de la exportación/integración. Los drivers y la máscara
de Blender no se convierten automáticamente en lógica glTF.

## Futuras piezas

Modelar sobre esta base y su pose de reposo, con los mismos ejes/origen y el
esqueleto Mixamo de 65 huesos. No escalar piezas independientemente: Godot
ajusta la altura final a 1,85 m a partir de los huesos. Adaptar una pieza nueva
de Tripo una vez en Blender, transferir/corregir pesos y probar su articulación.

Asignar `ranura` a cada pieza y declarar qué zona de la base oculta, como en
guantes. Conservar solape en puños, cintura y tobillos. Exportar únicamente
rig, base y piezas necesarias; excluir referencias, prototipos, cámaras y luces.
Espada/escudo mantienen su lógica actual de mano y guardado.

## Herramientas de la reconstrucción actual

Ejecutar dentro de Blender sobre la escena de trabajo, en este orden:

1. `herramientas/adaptar_cuerpo_makehuman_blender.py`.
2. `herramientas/pulir_base_lisa_blender.py`.
3. `herramientas/finalizar_base_lisa_blender.py`.
4. `herramientas/guantes_sobre_base_lisa_blender.py`.
5. `herramientas/verificar_base_lisa_blender.py`.
6. `herramientas/capturar_base_lisa_blender.py`.

Son herramientas específicas de esta fuente/rig. Los scripts anteriores de
rellenos, unión de cintura, muñecas por cápsulas o calcetines corresponden a
**prototipos descartados** y no deben ejecutarse sobre este maestro.
