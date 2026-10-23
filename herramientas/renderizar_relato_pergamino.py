"""Render reproducible de un relato de 10 s: tinta, acuarela y planos 2.5D."""
from pathlib import Path
import sys, subprocess, json
import numpy as np
from PIL import Image, ImageFilter, ImageDraw

ROOT = Path(__file__).resolve().parents[1]
sys.path.insert(0, str(ROOT / 'output/video-deps'))
import imageio_ffmpeg

OUT = ROOT / 'output/cinematica-pergamino'
OUT.mkdir(parents=True, exist_ok=True)
SRC = ROOT / 'docs/referencias/storyboard/yggdrasil'
W, H, FPS = 1920, 1080, 30
SIZE = (W, H)
def read(name):
    return Image.open(SRC / name).convert('RGB').resize(SIZE, Image.Resampling.LANCZOS)
base = read('paisaje-acuarela-aguada.png')
hero = read('paisaje-acuarela-con-eromash.png')
y, x = np.mgrid[0:H, 0:W].astype(np.float32)
u, v = x/W, y/H
rng = np.random.default_rng(48)
grain = rng.normal(0, .65, (H,W)).astype(np.float32)
fiber = .45*np.sin(y*2.7) + .6*np.sin(x*.012+y*.006)
paper = np.stack([238+grain+fiber,211+grain+fiber,165+grain+fiber],axis=2)
paper = np.clip(paper,0,255).astype(np.uint8)

def smooth(a):
    a=np.clip(a,0,1); return a*a*(3-2*a)
def polygon(points, feather=1):
    im=Image.new('L', SIZE); d=ImageDraw.Draw(im)
    d.polygon([(int(a/1672*W),int(b/941*H)) for a,b in points],fill=255)
    return np.asarray(im.filter(ImageFilter.GaussianBlur(feather)),dtype=np.float32)/255

# El suelo y el héroe forman un recorte unido, sin bordes rectangulares.
front=polygon([(0,752),(64,768),(152,787),(230,794),(290,794),
 (298,775),(307,734),(314,705),(304,687),(308,669),(290,665),
 (286,650),(291,613),(298,580),(307,553),(320,526),(333,519),
 (354,514),(352,505),(348,472),(354,466),(365,476),(371,463),
 (379,475),(392,467),(397,477),(394,509),(387,513),(406,520),
 (421,521),(433,548),(441,579),(448,611),(455,644),(454,664),
 (446,669),(436,656),(428,630),(418,623),(422,676),(429,699),
 (417,716),(419,751),(416,775),(425,801),(438,817),(437,831),
 (470,840),(514,854),(551,873),(571,900),(600,921),(730,941),(0,941)], .7)
# Se conserva la roca derecha como otro primer plano.
right=polygon([(1060,941),(1123,894),(1210,879),(1327,862),(1376,818),
 (1412,802),(1480,802),(1590,810),(1672,829),(1672,941)],1)
front=np.maximum(front,right)
middle=smooth((v-.48)/.19)*(1-front)
far=1-middle

def edges(img):
    arr=np.asarray(img,dtype=np.float32)
    low=np.asarray(img.filter(ImageFilter.MinFilter(3)),dtype=np.float32)
    high=np.asarray(img.filter(ImageFilter.MaxFilter(3)),dtype=np.float32)
    contrast=np.max(high-low,axis=2)
    dark=np.clip((170-arr.mean(axis=2))/100,0,1)
    return np.clip((contrast-14)/65,0,.65)*(.3+.7*dark)

brush=.025*np.sin(u*69+v*17)+.014*np.sin(v*125-u*23)+.008*np.sin(u*219+v*111)
arrival=.47*u+.53*(1-v)+brush
def make_layer(img, mask):
    arr=np.asarray(img,dtype=np.float32)
    return arr,mask,edges(img)
layers=[make_layer(base,np.ones((H,W),np.float32)),make_layer(base,middle),make_layer(hero,front)]

def warp(arr,scale,dx,dy):
    im=Image.fromarray(arr,'RGBA')
    # Transformación inversa, mismo pivote para mantener la cámara coherente.
    cx,cy=W*.55,H*.45
    return np.asarray(im.transform(SIZE,Image.Transform.AFFINE,
      (1/scale,0,cx-cx/scale-dx/scale,0,1/scale,cy-cy/scale-dy/scale),
      resample=Image.Resampling.BICUBIC))

def frame(t):
    canvas=paper.astype(np.float32).copy()
    travel=float(smooth((t-.5)/9))
    for n,(color,mask,edge) in enumerate(layers):
        delay=[.15,.65,3.7][n]
        draw=smooth(((t-delay)/[2.5,2.4,1.7][n]-arrival)/.10)
        paint=smooth(((t-delay-1.0)/[3.4,3.1,2.0][n]-arrival)/.20)
        ink=edge*draw*.78
        rgba=np.empty((H,W,4),dtype=np.uint8)
        # La tinta precede a la mancha de pigmento, no un fundido único.
        linecolor=np.array([99,53,32],dtype=np.float32)
        sketch=paper*(1-ink[...,None])+linecolor*ink[...,None]
        rgb=sketch*(1-paint[...,None])+color*paint[...,None]
        visibility=np.maximum(draw*.88,paint)*mask
        rgba[:,:,:3]=np.clip(rgb,0,255).astype(np.uint8)
        rgba[:,:,3]=(visibility*255).astype(np.uint8)
        scale=1+[.040,.065,.115][n]*travel
        dx=[-9,-20,-52][n]*travel
        dy=[2,6,16][n]*travel
        moved=warp(rgba,scale,dx,dy)
        alpha=moved[:,:,3:4].astype(np.float32)/255
        canvas=canvas*(1-alpha)+moved[:,:,:3]*alpha
    # El papel permanece quieto; al final la imagen se sostiene, sin corte negro.
    return np.clip(canvas,0,255).astype(np.uint8)

exe=imageio_ffmpeg.get_ffmpeg_exe()
video=OUT/'eromash-relato-pergamino-10s.mp4'
cmd=[exe,'-y','-f','rawvideo','-vcodec','rawvideo','-pix_fmt','rgb24',
 '-s',f'{W}x{H}','-r',str(FPS),'-i','-','-an','-c:v','libx264',
 '-preset','fast','-crf','18','-pix_fmt','yuv420p','-movflags','+faststart',str(video)]
proc=subprocess.Popen(cmd,stdin=subprocess.PIPE,stderr=(OUT/'codificacion.log').open('wb'))
for i in range(10*FPS):
    f=frame(i/FPS)
    proc.stdin.write(f.tobytes())
    if i in [0,45,90,150,225,299]: Image.fromarray(f).save(OUT/f'cuadro-{i:03d}.jpg',quality=92)
    if i%30==0: print(f'{i//30}/10 segundos renderizados',flush=True)
proc.stdin.close()
if proc.wait()!=0: raise RuntimeError('Falló FFmpeg; ver codificacion.log')
sheet=Image.new('RGB',(960*3,540*2))
for j,i in enumerate([0,45,90,150,225,299]):
    sheet.paste(Image.open(OUT/f'cuadro-{i:03d}.jpg').resize((960,540)),((j%3)*960,(j//3)*540))
sheet.save(OUT/'secuencia.jpg',quality=92)
(OUT/'datos.json').write_text(json.dumps({'duration_seconds':10,'fps':FPS,'frames':300,
 'resolution':[W,H],'audio':False,'reference':'https://www.youtube.com/watch?v=yJwmZgE9hrs',
 'technique':'Planos de imagen, recorte de personaje y rocas, cámara con parallax, máscaras temporales separadas para tinta y pigmento.'},indent=2),encoding='utf8')
print(video,flush=True)
