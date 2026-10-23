// Diseña una voz nueva con ElevenLabs (Voice Design) a partir de una descripción.
// La clave se lee igual que en generar.mjs (herramientas/voces/.env).
//
//   node disenar.mjs                 genera muestras en output/Cinematica 1/voces/diseno/
//   node disenar.mjs --guardar=N     guarda la muestra N (1, 2, 3) como voz de la cuenta
//   node disenar.mjs --comparar      misma frase con las voces premade más graves (plan gratuito)
//
// Diseñar y guardar voces por API requiere plan pago (con el gratuito responde 403).
//
// Las muestras valen un rato (el generated_voice_id vence); se anotan en diseno/muestras.json.

import { ElevenLabsClient } from "@elevenlabs/elevenlabs-js";
import { mkdir, readFile, writeFile } from "node:fs/promises";
import { dirname, join } from "node:path";
import { fileURLToPath } from "node:url";

const AQUI = dirname(fileURLToPath(import.meta.url));
const RAIZ = join(AQUI, "..", "..");
const SALIDA = join(RAIZ, "output", "Cinematica 1", "voces", "diseno");

const NOMBRE = "Eromash - Narrador épico";
const DESCRIPCION =
	"Epic Nordic saga narrator. An old man in his sixties with a very deep, resonant, gravelly bass voice. " +
	"Slow, deliberate, solemn pacing with weight and gravitas, like an ancient legend told beside the fire " +
	"in a great mead hall. Majestic and ominous, never theatrical. Close microphone, clean studio recording.";
const TEXTO =
	"Desde antes de la memoria, Yggdrasil sostiene los nueve mundos. Su copa sigue verde. " +
	"Nadie mira lo que pasa en sus raíces. Al pie del Fresno, las runas que guardaban los caminos " +
	"parpadean... y se apagan. Y lo que dormía bajo los caminos de los hombres... despierta.";

async function leerClave() {
	const deEntorno = process.env.ELEVENLABS_API_KEY?.trim();
	if (deEntorno) return deEntorno;
	const texto = await readFile(join(AQUI, ".env"), "utf8");
	const m = texto.match(/^\s*ELEVENLABS_API_KEY\s*=\s*["']?(.*?)["']?\s*$/m);
	if (!m || !m[1]) throw new Error("Falta ELEVENLABS_API_KEY en herramientas/voces/.env");
	return m[1];
}

const elevenlabs = new ElevenLabsClient({ apiKey: await leerClave() });
await mkdir(SALIDA, { recursive: true });

// --comparar: con el plan gratuito no se puede diseñar ni guardar voces por API (403).
// Mientras tanto, la misma frase con las voces premade más graves de la cuenta, para elegir.
const CANDIDATAS = {
	brian: "nPczCjzI2devNBz1zQrb", // grave, resonante (la que usa hoy el narrador)
	george: "JBFqnCBsd6RMkjVDRZzb", // narrador británico de cuentos, cálido
	callum: "N2lVS1w4EtoT3dr4eOWO", // áspero, con filo inquietante
	bill: "pqHfZKP75CvOlQylNhV4", // anciano, sabio (la del guardián)
	daniel: "onwK4e9ZLuTAKqWW03F9", // firme, de locutor
};
if (process.argv.includes("--comparar")) {
	const frase = "Desde antes de la memoria, Yggdrasil sostiene los nueve mundos. Y lo que dormía bajo los caminos de los hombres... despierta.";
	for (const [nombre, id] of Object.entries(CANDIDATAS)) {
		const audio = await elevenlabs.textToSpeech.convert(id, {
			text: frase,
			modelId: "eleven_v4",
			languageCode: "es",
			outputFormat: "mp3_44100_128",
			voiceSettings: { stability: 0.65, similarityBoost: 0.75, style: 0.25, speed: 0.85 },
		});
		const partes = [];
		for await (const parte of audio) partes.push(Buffer.from(parte));
		const archivo = join(SALIDA, `comparar_${nombre}.mp3`);
		await writeFile(archivo, Buffer.concat(partes));
		console.log("listo", archivo);
	}
	process.exit(0);
}

const guardar = process.argv.find((a) => a.startsWith("--guardar="));
if (guardar) {
	const n = Number(guardar.split("=")[1]);
	const muestras = JSON.parse(await readFile(join(SALIDA, "muestras.json"), "utf8"));
	const voz = await elevenlabs.textToVoice.create({
		voiceName: NOMBRE,
		voiceDescription: DESCRIPCION,
		generatedVoiceId: muestras[n - 1],
	});
	console.log("voz guardada", voz.voiceId);
	process.exit(0);
}

const r = await elevenlabs.textToVoice.design({
	voiceDescription: DESCRIPCION,
	modelId: "eleven_ttv_v3",
	text: TEXTO,
	guidanceScale: 5,
	loudness: 0.4,
	outputFormat: "mp3_44100_128",
});
const ids = [];
for (const [i, p] of r.previews.entries()) {
	const archivo = join(SALIDA, `narrador_muestra_${i + 1}.mp3`);
	await writeFile(archivo, Buffer.from(p.audioBase64, "base64"));
	ids.push(p.generatedVoiceId);
	console.log("muestra", i + 1, archivo, `${p.durationSecs?.toFixed?.(1) ?? "?"} s`);
}
await writeFile(join(SALIDA, "muestras.json"), JSON.stringify(ids, null, "\t"));
