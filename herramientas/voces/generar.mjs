// Voces del narrador con ElevenLabs.
// La clave va en herramientas/voces/.env (ELEVENLABS_API_KEY=...) o en esa variable de entorno.
//
//   cd herramientas/voces
//   npm install
//   node generar.mjs --probar
//   node generar.mjs
//
// --probar solo confirma la cuenta (no gasta caracteres de voz).
// Sin argumentos genera «La fogata en las ruinas» en output/Cinematica 1/voces/.
// node generar.mjs --prologo genera las voces de los subtítulos de la Cinemática 1 (ver más abajo).

import { ElevenLabsClient } from "@elevenlabs/elevenlabs-js";
import { mkdir, readFile, stat, unlink, writeFile } from "node:fs/promises";
import { dirname, join } from "node:path";
import { fileURLToPath } from "node:url";

const AQUI = dirname(fileURLToPath(import.meta.url));
const RAIZ = join(AQUI, "..", "..");
const VOZ = "Nh2zY9kknu6z4pZy6FhD";
const MODELO = "eleven_v4";
const SALIDA = join(RAIZ, "output", "Cinematica 1", "voces");

const LINEAS = [
	["1-ruinas", "Hay lugares que el olvido no abandona.", "There are places oblivion never leaves."],
	["2-fogata", "El fuego seguía encendido... Alguien lo había dejado así.", "The fire was still burning... Someone had left it that way."],
	["3-ojos", "No estaba solo.", "He was not alone."],
	["4-lobos", "Los lobos de Eldervald no cazan por hambre.", "The wolves of Eldervald do not hunt for hunger."],
	["5-cae", "Porque en estas ruinas... ellos no son los cazadores.", "Because in these ruins... they are not the hunters."],
	["6-mira", "Y lo que caza a los lobos... ahora lo miraba a él.", "And the thing that hunts the wolves... was now looking at him."],
];

async function leerClave() {
	const deEntorno = process.env.ELEVENLABS_API_KEY?.trim();
	if (deEntorno && deEntorno !== "tu_clave") return deEntorno;
	try {
		const texto = await readFile(join(AQUI, ".env"), "utf8");
		for (const linea of texto.split(/\r?\n/)) {
			const coincidencia = linea.match(/^\s*ELEVENLABS_API_KEY\s*=\s*(.*?)\s*$/);
			if (!coincidencia) continue;
			let valor = coincidencia[1];
			if (
				(valor.startsWith('"') && valor.endsWith('"')) ||
				(valor.startsWith("'") && valor.endsWith("'"))
			) {
				valor = valor.slice(1, -1);
			}
			valor = valor.trim();
			if (valor && valor !== "tu_clave") return valor;
		}
	} catch {
		// No hay .env todavía.
	}
	console.error(
		"Falta la clave. Copiá herramientas/voces/.env.example a herramientas/voces/.env y pegá la clave de ElevenLabs (Developers → API keys). Ese archivo no se sube a git."
	);
	process.exit(1);
}

const elevenlabs = new ElevenLabsClient({ apiKey: await leerClave() });

async function sintetizar(text, idioma, archivo, voz = VOZ, ajustes = undefined) {
	const audio = await elevenlabs.textToSpeech.convert(voz, {
		text,
		modelId: MODELO,
		languageCode: idioma,
		outputFormat: "mp3_44100_128",
		...(ajustes ? { voiceSettings: ajustes } : {}),
	});
	const partes = [];
	for await (const parte of audio) partes.push(Buffer.from(parte));
	await writeFile(archivo, Buffer.concat(partes));
}

if (process.argv.includes("--probar")) {
	try {
		const usuario = await elevenlabs.user.get();
		const suscripcion = usuario.subscription;
		console.log("conectado");
		console.log("plan", suscripcion.tier);
		console.log("caracteres", `${suscripcion.characterCount} / ${suscripcion.characterLimit}`);
	} catch (error) {
		const mensaje = error?.body?.detail?.message ?? error?.message ?? String(error);
		if (!String(mensaje).includes("user_read")) {
			console.error(mensaje);
			process.exit(1);
		}
		console.log("clave aceptada");
		console.log("sin permiso para leer la cuenta; se prueba texto a voz");
	}
	await mkdir(SALIDA, { recursive: true });
	const prueba = join(SALIDA, "_prueba.mp3");
	await sintetizar("Prueba.", "es", prueba);
	const peso = (await stat(prueba)).size;
	await unlink(prueba);
	console.log("texto a voz", peso, "bytes");
	process.exit(0);
}

// --prologo: las líneas de la Cinemática 1 (tabla «Líneas» de output/Cinematica 1/subtitulos.md),
// un mp3 por clave e idioma: cine_prologo_01-es.mp3, cine_prologo_01-en.mp3...
// Voces premade de la cuenta (la de biblioteca de arriba responde 402 en el plan gratuito):
//   Narrador → Brian (nPczCjzI2devNBz1zQrb): grave, resonante; más lento, para leyenda.
//   Guardián → Bill (pqHfZKP75CvOlQylNhV4): anciano; más lento y suave, casi un susurro.
const VOCES_PROLOGO = {
	Narrador: { voz: "nPczCjzI2devNBz1zQrb", ajustes: { stability: 0.6, similarityBoost: 0.75, style: 0.2, speed: 0.88 } },
	Guardián: { voz: "pqHfZKP75CvOlQylNhV4", ajustes: { stability: 0.4, similarityBoost: 0.7, style: 0.45, speed: 0.82 } },
};

if (process.argv.includes("--prologo")) {
	const tabla = await readFile(join(RAIZ, "output", "Cinematica 1", "subtitulos.md"), "utf8");
	const lineas = [];
	for (const fila of tabla.split(/\r?\n/)) {
		const celdas = fila.split("|").map((c) => c.trim());
		// | Plano | Imagen | Quién | Clave | Español | English | Entra | Dura |
		const clave = celdas[4]?.match(/^`(cine_prologo_\d+)`$/)?.[1];
		if (clave) lineas.push({ clave, quien: celdas[3], es: celdas[5], en: celdas[6] });
	}
	await mkdir(SALIDA, { recursive: true });
	// --solo=cine_prologo_10 regenera solo esa línea
	const solo = process.argv.find((a) => a.startsWith("--solo="))?.split("=")[1];
	for (const { clave, quien, es, en } of lineas) {
		if (solo && clave !== solo) continue;
		const voz = VOCES_PROLOGO[quien];
		if (!voz) throw new Error(`Sin voz para «${quien}» (${clave})`);
		for (const [idioma, text] of [
			["es", es],
			["en", en],
		]) {
			const archivo = join(SALIDA, `${clave}-${idioma}.mp3`);
			await sintetizar(text, idioma, archivo, voz.voz, voz.ajustes);
			console.log("listo", archivo);
		}
	}
	process.exit(0);
}

await mkdir(SALIDA, { recursive: true });

for (const [escena, es, en] of LINEAS) {
	for (const [idioma, text] of [
		["es", es],
		["en", en],
	]) {
		const archivo = join(SALIDA, `${escena}-${idioma}.mp3`);
		await sintetizar(text, idioma, archivo);
		console.log("listo", archivo);
	}
}
