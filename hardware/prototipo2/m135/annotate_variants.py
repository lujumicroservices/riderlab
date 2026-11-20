"""Labels each variant's renders and builds the side-by-side comparison sheet.

~/.venvs/motoline-cad/bin/python annotate_variants.py

Per variant: <v>/01_frente.png, 02_perfil.png, 03_distribucion.png, 04_sin_tapa.png
Here:        comparativa.png
"""
import json
from pathlib import Path

from PIL import Image, ImageDraw, ImageFont

HERE = Path(__file__).parent
FONT = "/System/Library/Fonts/Supplemental/Arial.ttf"
FONT_B = "/System/Library/Fonts/Supplemental/Arial Bold.ttf"
INK, LINE, ACCENT, RED, GREEN = (30, 32, 36), (70, 74, 80), (230, 90, 10), (200, 20, 20), (20, 140, 60)
VARIANTS = ("A_ancha", "B_profunda", "C_feather")


def spread(ys, lo, hi, gap):
    out = []
    for y in ys:
        out.append(max(y, lo, (out[-1] + gap) if out else lo))
    over = (out[-1] - hi) if out else 0
    if over > 0:
        out = [y - over for y in out]
        for i in range(len(out) - 2, -1, -1):
            out[i] = min(out[i], out[i + 1] - gap)
    return out


def labelled(img_path, json_path, size=28):
    meta = json.loads(Path(json_path).read_text())
    im = Image.open(img_path).convert("RGB")
    W, H = im.size
    d = ImageDraw.Draw(im)
    f = ImageFont.truetype(FONT, size)
    seen, labs_all = set(), []
    for l in meta["labels"]:
        if l["text"] not in seen:
            seen.add(l["text"])
            labs_all.append(l)
    for side in ("L", "R"):
        labs = sorted([l for l in labs_all if l["side"] == side], key=lambda l: l["y"])
        if not labs:
            continue
        ys = spread([l["y"] for l in labs], int(H * 0.12), H - size * 1.5, size * 1.5)
        widest = max(d.textlength(l["text"], font=f) for l in labs) + 30
        col = widest if side == "L" else W - widest
        for l, y in zip(labs, ys):
            d.line([(l["x"], l["y"]), (col, y)], fill=LINE, width=2)
            d.ellipse([l["x"] - 5, l["y"] - 5, l["x"] + 5, l["y"] + 5], fill=ACCENT)
            tx = col - d.textlength(l["text"], font=f) - 8 if side == "L" else col + 8
            d.text((tx, y), l["text"], font=f, fill=INK, anchor="lm")
    return im


def header(im, title, sub, ok):
    d = ImageDraw.Draw(im)
    dark = sum(im.crop((0, 0, 600, 140)).convert("L").getdata()) / (600 * 140) < 110
    d.text((40, 50), title, font=ImageFont.truetype(FONT_B, 44), fill=(240, 240, 240) if dark else INK, anchor="lm")
    d.text((40, 100), sub, font=ImageFont.truetype(FONT_B, 32), fill=GREEN if ok else RED, anchor="lm")
    return im


rows = []
for v in VARIANTS:
    vd = HERE / v
    cfg = json.loads((vd / "variant.json").read_text())
    rep = (vd / "colisiones.txt").read_text().splitlines()
    n = int(rep[1].split(",")[1].split()[0])
    ok = n == 0
    status = "Cabe: 0 colisiones" if ok else f"No cabe: {n} colisiones (piezas en rojo)"
    V = vd / "_views"
    out = {
        "01_frente.png": header(Image.open(V / "frente.png").convert("RGB"), cfg["title"], status, ok),
        "02_perfil.png": header(Image.open(V / "perfil.png").convert("RGB"), cfg["title"] + " · perfil", status, ok),
        "03_distribucion.png": header(labelled(V / "distribucion.png", V / "distribucion.json"),
                                      cfg["title"] + " · sin tapa ni pantalla", status, ok),
        "04_sin_tapa.png": header(labelled(V / "rayosx.png", V / "rayosx.json"), cfg["title"] + " · sin tapa", status, ok),
    }
    for name, im in out.items():
        im.save(vd / name)
    rows.append((cfg, status, ok, [out["01_frente.png"], out["02_perfil.png"], out["03_distribucion.png"]]))

# comparison sheet: one row per variant (front, profile, layout)
tw, th = 960, 600
pad, head = 24, 130
sheet = Image.new("RGB", (3 * tw + 4 * pad, head + len(rows) * (th + pad) + pad), (236, 236, 238))
d = ImageDraw.Draw(sheet)
d.text((pad, 60), "Métrica P2 Faceta con M135: 3 variantes", font=ImageFont.truetype(FONT_B, 54), fill=INK, anchor="lm")
for r, (cfg, status, ok, ims) in enumerate(rows):
    y = head + r * (th + pad)
    for c, im in enumerate(ims):
        sheet.paste(im.resize((tw, th)), (pad + c * (tw + pad), y))
sheet.save(HERE / "comparativa.png")
print("ok")
