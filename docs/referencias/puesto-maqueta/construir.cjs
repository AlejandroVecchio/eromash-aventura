const fs=require('fs'),path=require('path');
const source=fs.readFileSync('C:/eromash-juego/aventura/lib/three/three.module.min.js','utf8');
const exp=source.match(/export\s*\{([^}]+)\};?\s*$/);
if(!exp)throw Error('No se encontró la tabla de exportación de Three.js');
const names=exp[1].split(',').map(x=>{const p=x.trim().split(/\s+as\s+/);return p.length===2?`${p[1]}:${p[0]}`:p[0]}).join(',');
const bundle='const THREE=(()=>{'+source.slice(0,exp.index)+';return {'+names+'};})();';
const html=fs.readFileSync(path.join(__dirname,'visor-base.html'),'utf8').replace('/* THREE_BUNDLED */',()=>bundle);
fs.writeFileSync(path.join(__dirname,'puesto-eydis.html'),html);
console.log('Visor autocontenido generado: '+html.length+' caracteres');
