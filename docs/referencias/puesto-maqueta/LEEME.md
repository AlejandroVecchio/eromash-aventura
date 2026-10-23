# Puesto de Eydis — maqueta de estudio

Abrir `puesto-eydis.html` con Chrome o Edge. El archivo es autocontenido y funciona sin servidor ni conexión a Internet. Requiere WebGL.

- **Girar maqueta:** arrastrar para rotar; rueda o pellizco para acercar; botón derecho y arrastrar para desplazar el centro.
- **Caminar:** pulsar sobre la escena y usar WASD o flechas; arrastrar para mirar. Shift acelera. También hay botones de movimiento en pantalla.
- El selector lleva al portón, porche, huerta, atalaya, piedra y vista superior.
- Se pueden ocultar nombres y bosque, cambiar la luz y restablecer la cámara.

Maqueta de volúmenes basada en el concepto generado el 22/10/2026: recinto de 45 × 35 m, siete figuras humanas, perra y caballo, cinco tablillas oscuras. El cobertizo está dentro de la palisada. Las figuras son marcadores de escala, no diseños finales de personajes. El bosque frontal se abre para ver el recinto. La navegación tiene límites y colisiones básicas; no reproduce la jugabilidad ni el relieve completo de Eldervald. El acceso rápido a la atalaya permite mirarla sin simular subir la escalera.

No se modificó ni se integró esta propuesta en el mundo del juego.

`visor-base.html` contiene la escena editable. `construir.cjs` genera el HTML autocontenido reutilizando Three.js r160 del prototipo existente. `verificar.cjs` comprueba renderizado, cinco tablillas oscuras, navegación y controles con un navegador aislado; guarda las capturas `vista-general.png` y `vista-porche.png`. Ver créditos en `CREDITOS.md`.
