# Prueba de equipo

Abrir `escenas/prueba_equipo.tscn` en Godot y pulsar F6, o ejecutar `probar_equipo.cmd` desde la raíz del proyecto.

Mapa aislado de 30 × 30 m. Panel con pechera, cinturón/tabardo, hombreras, brazales, guantes, piernas, botas, capa, espada y escudo. Equipar/quitar todo y contraste opcional. Casco fijo. WASD mueve, Shift corre, espacio salta, X guarda armas, clic ataca, Ctrl bloquea, Q/E y arrastre derecho giran la cámara, rueda acerca/aleja. Los controles del mando siguen las acciones existentes.

El controlador hereda `Heroe` sin modificar el héroe de la aventura. Se usa su esqueleto original y sus animaciones. Las mallas del paquete modular se vinculan a ese único Skeleton3D; se añaden 13 huesos auxiliares de la capa. El esqueleto auxiliar del archivo importado se elimina de la instancia. El panel cambia solo visibilidad, sin modificar el inventario ni guardar equipo.

El cuerpo Tripo conserva sus proporciones anteriores al ajuste de volumen; se mantiene la corrección suave de dedos. Se repartió en zonas compartiendo cortes y pesos. Los pesos son una transferencia inicial desde el personaje original, no una validación final de todas las animaciones. Al quitar pechera aparecen torso y ropa; brazos, manos, piernas y botas alternan sus zonas. Hombreras y cinturón son aditivos. Las mezclas pueden revelar uniones que requieren ajuste; este es el banco para localizarlas.

Capa correcta: `C:/eromash-juego/output/blender/capa-arena-v1/eromash-capa-arena-v4.blend`, objetos Capa_Eromash_Continua, tiras y Broche_E. Se copiaron sin escribir en la fuente. Sigue el torso con sus huesos auxiliares en reposo; no hay simulación de tela ni colisiones de la capa en esta entrega. Las otras capas probadas no se usan.

Fuente editable: `docs/fuentes/personaje/Eromash-prueba-equipo.blend`. Paquete: `assets/modelos/personaje/prueba_equipo/eromash_modular.glb`.

Validación: importación de Godot, alternancia base/equipo, resolución de todos los bindings de piel, un único Skeleton3D y desplazamiento real usando InputMap. Capturas en `docs/referencias/prueba_equipo/`. El proceso de captura reporta al cerrar avisos de recursos retenidos de las bibliotecas de animaciones; no confundirlos con validación visual final.
