# Dibuja las opciones de puntero de docs/referencias/punteros/ (48 px, normal y "activa").
# Uso: python3 herramientas/dibujar_punteros.py carpeta_de_salida
# Opciones de puntero para Eromash: se dibujan a 8x y se reducen a 48 px (más una variante "activa").
import math, sys
from PIL import Image, ImageDraw, ImageFilter
OUT = sys.argv[1]
S = 8; N = 48; G = N * S
AZUL = (115, 213, 219); AZUL_V = (170, 240, 245)
METAL = (38, 44, 46); METAL_L = (92, 104, 106); BORDE = (8, 10, 11)
AMBAR = (232, 184, 102)

def lienzo(): return Image.new("RGBA", (G, G), (0, 0, 0, 0))
def P(pts): return [(x * S, y * S) for x, y in pts]

def brillo(forma_fn, color, radio, fuerza):
    capa = lienzo(); forma_fn(ImageDraw.Draw(capa), color)
    b = capa.filter(ImageFilter.GaussianBlur(radio * S))
    a = b.split()[3].point(lambda v: min(255, int(v * fuerza)))
    b.putalpha(a); return b

def terminar(img, nombre):
    img.resize((N, N), Image.LANCZOS).save(f"{OUT}/{nombre}.png")

def flecha(activo):
    pts = [(3, 3), (3, 34), (11, 26), (17, 40), (23, 37), (17, 24), (29, 24)]
    img = lienzo()
    col = AMBAR if activo else AZUL
    img.alpha_composite(brillo(lambda d, c: d.polygon(P(pts), outline=c, width=3 * S), col, 1.6, 1.6 if activo else 1.1))
    d = ImageDraw.Draw(img)
    d.polygon(P(pts), fill=(58, 66, 68), outline=BORDE, width=int(1.6 * S))
    # filo de luz rúnica sobre el borde largo
    d.line(P([(5.5, 8), (5.5, 29)]), fill=AZUL_V if not activo else (255, 225, 160), width=int(1.4 * S))
    d.line(P([(6.5, 7.5), (24, 23)]), fill=col, width=int(1.1 * S))
    terminar(img, "1-flecha-runica" + ("-activa" if activo else ""))

def lanza(activo):
    # punta de lanza en hoja, apuntando arriba a la izquierda (45°)
    hoja = [(0, -20), (6, -6), (4, 6), (2, 9), (-2, 9), (-4, 6), (-6, -6)]
    cubo = [(-2.2, 9), (2.2, 9), (1.8, 16), (-1.8, 16)]
    a = math.radians(-45)
    def rot(pts): return [(23 + x * math.cos(a) - y * math.sin(a), 23 + x * math.sin(a) + y * math.cos(a)) for x, y in pts]
    img = lienzo(); col = AMBAR if activo else AZUL
    img.alpha_composite(brillo(lambda d, c: d.polygon(P(rot(hoja)), outline=c, width=3 * S), col, 1.6, 1.6 if activo else 1.1))
    d = ImageDraw.Draw(img)
    d.polygon(P(rot(cubo)), fill=(70, 52, 38), outline=BORDE, width=int(1.4 * S))
    d.polygon(P(rot(hoja)), fill=METAL_L, outline=BORDE, width=int(1.6 * S))
    d.polygon(P(rot([(0, -18), (2.5, -6), (0, 5), (-2.5, -6)])), fill=METAL)
    d.line(P(rot([(0, -15), (0, 4)])), fill=col, width=int(1.3 * S))   # nervio rúnico
    terminar(img, "2-punta-de-lanza" + ("-activa" if activo else ""))

def tiwaz(activo):
    # la runa Tiwaz (ᛏ), que ya es una flecha, inclinada y encendida
    a = math.radians(-45)
    def rot(pts): return [(22 + x * math.cos(a) - y * math.sin(a), 22 + x * math.sin(a) + y * math.cos(a)) for x, y in pts]
    trazos = [[(0, -19), (0, 19)], [(0, -19), (-10, -8)], [(0, -19), (10, -8)]]
    col = AMBAR if activo else AZUL
    img = lienzo()
    def dib(d, c, w):
        for t in trazos: d.line(P(rot(t)), fill=c, width=int(w * S), joint="curve")
    img.alpha_composite(brillo(lambda d, c: dib(d, c, 6), col, 2.0, 1.8 if activo else 1.3))
    d = ImageDraw.Draw(img)
    dib(d, BORDE, 6.5); dib(d, METAL, 4.6); dib(d, AZUL_V if not activo else (255, 225, 160), 2.0)
    terminar(img, "3-runa-tiwaz" + ("-activa" if activo else ""))

def mira(activo):
    # anillo con cuatro marcas rúnicas y punto central (punta en el centro)
    c = 24; col = AMBAR if activo else AZUL
    img = lienzo()
    def dib(d, color, w):
        d.ellipse([(c - 13) * S, (c - 13) * S, (c + 13) * S, (c + 13) * S], outline=color, width=int(w * S))
        for ang in range(4):
            t = math.radians(ang * 90 + 45)
            x1, y1 = c + math.cos(t) * 9, c + math.sin(t) * 9
            x2, y2 = c + math.cos(t) * 18, c + math.sin(t) * 18
            d.line([(x1 * S, y1 * S), (x2 * S, y2 * S)], fill=color, width=int(w * S))
    img.alpha_composite(brillo(lambda d, cc: dib(d, cc, 4), col, 1.8, 1.5 if activo else 1.1))
    d = ImageDraw.Draw(img)
    dib(d, BORDE, 4.2); dib(d, col, 2.2)
    d.ellipse([(c - 2) * S, (c - 2) * S, (c + 2) * S, (c + 2) * S], fill=AZUL_V if not activo else (255, 225, 160), outline=BORDE, width=S)
    terminar(img, "4-mira-runica" + ("-activa" if activo else ""))

for f in (flecha, lanza, tiwaz, mira):
    f(False); f(True)
print("ok")
