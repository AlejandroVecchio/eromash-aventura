// El casco de Eromash: la E oficial (mismo trazado que juego/js/motor/juego.js), rotada 90° como en el juego y con volumen.
// Regla del proyecto: la E nunca se pierde ni se deforma. Este archivo es la única fuente del casco en la aventura.
import * as THREE from "three";
import { SVGLoader } from "three/addons/loaders/SVGLoader.js";
import { toon, contorno, PALETA } from "../motor/render.js";

export const E_PATH =
  "m88,0c94.67.33,189.33.67,284,1l-55,60h-159l-3,84h161l-61,59h-97l-1,94h197l-58,56H33l56-57v-90l-63,1,62-62,3-86-65,1L88,0Z";

// Geometría de la E: ancho en metros (lado largo), grosor del relieve.
export function geometriaE(ancho = 0.62, grosor = 0.09) {
  const datos = new SVGLoader().parse(`<svg xmlns="http://www.w3.org/2000/svg"><path d="${E_PATH}"/></svg>`);
  const formas = datos.paths.flatMap((p) => SVGLoader.createShapes(p));
  const geo = new THREE.ExtrudeGeometry(formas, {
    depth: grosor / (ancho / 382),
    bevelEnabled: true,
    bevelThickness: 6,
    bevelSize: 4,
    bevelSegments: 1,
    curveSegments: 4,
  });
  // SVG (x a la derecha, y hacia abajo) rotado 90° como en el juego → X = -y, Y = -x.
  const m = new THREE.Matrix4().set(0, -1, 0, 0, -1, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 1);
  geo.applyMatrix4(m);
  invertirCaras(geo); // la matriz espeja, así que hay que dar vuelta los triángulos
  geo.computeBoundingBox();
  const c = new THREE.Vector3();
  geo.boundingBox.getCenter(c);
  geo.translate(-c.x, -c.y, -geo.boundingBox.max.z);
  geo.scale(ancho / 382, ancho / 382, ancho / 382);
  geo.computeVertexNormals();
  return geo;
}

function invertirCaras(geo) {
  for (const nombre of Object.keys(geo.attributes)) {
    const a = geo.attributes[nombre];
    for (let i = 0; i < a.count; i += 3) {
      for (let k = 0; k < a.itemSize; k++) {
        const v1 = a.array[(i + 1) * a.itemSize + k];
        a.array[(i + 1) * a.itemSize + k] = a.array[(i + 2) * a.itemSize + k];
        a.array[(i + 2) * a.itemSize + k] = v1;
      }
    }
    a.needsUpdate = true;
  }
}

// Cabeza completa provisoria: cúpula, cara oscura, ojos, barba y la E al frente.
// Se usa mientras no haya modelo; con el modelo, solo se usa geometriaE() para revisar que el casco respete la E.
export function crearCabeza() {
  const cabeza = new THREE.Group();
  cabeza.name = "cabeza";

  const cupula = new THREE.Mesh(new THREE.SphereGeometry(0.3, 12, 8, 0, Math.PI * 2, 0, Math.PI / 2), toon(PALETA.bordo, { flatShading: true }));
  cupula.scale.set(1, 1.05, 1);
  cupula.position.set(0, 0.02, -0.03);
  cupula.castShadow = true;
  contorno(cupula, 0.05);
  cabeza.add(cupula);

  const cara = new THREE.Mesh(new THREE.BoxGeometry(0.46, 0.4, 0.4), toon(0x0a0707));
  cara.position.set(0, -0.15, -0.02);
  cabeza.add(cara);

  const ojoMat = new THREE.MeshBasicMaterial({ color: PALETA.blanco });
  [-1, 1].forEach((lado) => {
    const ojo = new THREE.Mesh(new THREE.BoxGeometry(0.1, 0.032, 0.02), ojoMat);
    ojo.position.set(lado * 0.105, -0.12, 0.19);
    ojo.rotation.z = lado * -0.12;
    cabeza.add(ojo);
  });

  const barba = new THREE.Mesh(new THREE.ConeGeometry(0.2, 0.3, 6), toon(PALETA.bordo, { flatShading: true }));
  barba.rotation.x = Math.PI;
  barba.position.set(0, -0.38, 0.09);
  barba.castShadow = true;
  contorno(barba, 0.06);
  cabeza.add(barba);

  const e = new THREE.Mesh(geometriaE(), [toon(PALETA.rojo), toon(PALETA.oscuro)]);
  e.position.set(0, -0.05, 0.27);
  e.castShadow = true;
  e.name = "casco-E";
  contorno(e, 0.03);
  cabeza.add(e);

  return cabeza;
}
