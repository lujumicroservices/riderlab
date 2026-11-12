"""Draws leader-line labels on the Faceta renders and builds the assembly sheet.

~/.venvs/motoline-cad/bin/python annotate.py

Reads _views/<name>.png + <name>.json (label anchors in pixels, written from Blender)
and writes the final images next to this script.
"""
import json
from pathlib import Path

from PIL import Image, ImageDraw, ImageFont

HERE = Path(__file__).parent
V = HERE / "_views"
FONT = "/System/Library/Fonts/Supplemental/Arial.ttf"
FONT_B = "/System/Library/Fonts/Supplemental/Arial Bold.ttf"
INK = (30, 32, 36)
LINE = (70, 74, 80)
ACCENT = (230, 90, 10)


def spread(ys, lo, hi, gap):
    """Keep label rows at least `gap` apart, in order, inside [lo, hi]."""
    out = []
    for y in ys:
        y = max(y, lo, (out[-1] + gap) if out else lo)
        out.append(y)
    over = out[-1] - hi if out else 0
    if over > 0:
        out = [y - over for y in out]
        for i in range(len(out) - 2, -1, -1):
            out[i] = min(out[i], out[i + 1] - gap)
    return out


# Anchors that the automatic bounding-box centre gets wrong (part hidden in that view,
# or a ring whose centre is empty): drop the label or pin it to a pixel.
FIX = {
    "p2v2_rayosx": {"drop": ["Pantalla 2.0\" ST7789"]},
    "p2v2_distribucion": {"drop": ["Botones: tact + botador"],
                          "pin": {"Cordón de silicón": (1600, 640)}},
    "paso1": {"drop": ["Pad AMPS (insertos M4)"], "pin": {"Ranura + cordón de silicón": (318, 600)}},
    "paso4": {"drop": ["Placa AMPS + bola RAM 1\""], "pin": {"6 tornillos M3 por detrás": (330, 440)}},
}


def annotate(name, title, out_name, size=30, margin=0.17):
    meta = json.loads((V / f"{name}.json").read_text())
    fx = FIX.get(name, {})
    meta["labels"] = [l for l in meta["labels"] if l["text"] not in fx.get("drop", [])]
    for l in meta["labels"]:
        if l["text"] in fx.get("pin", {}):
            l["x"], l["y"] = fx["pin"][l["text"]]
    im = Image.open(V / f"{name}.png").convert("RGB")
    W, H = im.size
    d = ImageDraw.Draw(im)
    f = ImageFont.truetype(FONT, size)
    fb = ImageFont.truetype(FONT_B, int(size * 1.25))
    top = int(H * 0.11)
    for side in ("L", "R"):
        labs = sorted([l for l in meta["labels"] if l["side"] == side], key=lambda l: l["y"])
        if not labs:
            continue
        ys = spread([l["y"] for l in labs], top, H - size * 1.5, size * 1.55)
        widest = max(d.textlength(l["text"], font=f) for l in labs) + 40
        col = max(W * margin, widest) if side == "L" else min(W * (1 - margin), W - widest)
        for l, y in zip(labs, ys):
            ax, ay = l["x"], l["y"]
            d.line([(ax, ay), (col, y)], fill=LINE, width=max(2, size // 12))
            d.ellipse([ax - 5, ay - 5, ax + 5, ay + 5], fill=ACCENT)
            tw = d.textlength(l["text"], font=f)
            tx = col - tw - 10 if side == "L" else col + 10
            d.text((tx, y), l["text"], font=f, fill=INK, anchor="lm")
    if title:
        d.text((W * 0.03, H * 0.045), title, font=fb, fill=INK, anchor="lm")
    im.save(HERE / out_name)
    return im


def steps_sheet():
    caps = [
        ("1", "Base: insertos M4 (AMPS) y cordón de silicón en la ranura"),
        ("2", "Electrónica a la base: placas en separadores, LiPo con VHB"),
        ("3", "Tapa: PC pegado, membrana, pantalla, botones y pasamuros"),
        ("4", "Cerrar con 6 M3 por detrás y montar placa AMPS + bola RAM"),
    ]
    tiles = [annotate(f"paso{i}", None, f"_paso{i}.png", size=26, margin=0.2) for i in range(1, 5)]
    w, h = tiles[0].size
    pad, head, capt = 30, 110, 70
    sheet = Image.new("RGB", (2 * w + 3 * pad, head + 2 * (h + capt) + 3 * pad), (236, 236, 238))
    d = ImageDraw.Draw(sheet)
    d.text((pad, head / 2), "Métrica P2 \"Faceta\": ensamble en 4 pasos", font=ImageFont.truetype(FONT_B, 48), fill=INK, anchor="lm")
    fn = ImageFont.truetype(FONT_B, 40)
    fc = ImageFont.truetype(FONT, 30)
    for i, (tile, (num, cap)) in enumerate(zip(tiles, caps)):
        x = pad + (i % 2) * (w + pad)
        y = head + pad + (i // 2) * (h + capt + pad)
        sheet.paste(tile, (x, y + capt))
        d.ellipse([x, y + 8, x + 52, y + 60], fill=ACCENT)
        d.text((x + 26, y + 34), num, font=fn, fill=(255, 255, 255), anchor="mm")
        d.text((x + 70, y + 34), cap, font=fc, fill=INK, anchor="lm")
    sheet.save(HERE / "p2v2_faceta_05_ensamble.png")
    for i in range(1, 5):
        (HERE / f"_paso{i}.png").unlink()


if __name__ == "__main__":
    annotate("p2v2_rayosx", "Métrica P2 \"Faceta\": distribución interna (tapa translúcida)", "p2v2_faceta_03_rayosx.png")
    annotate("p2v2_distribucion", "Vista frontal sin tapa ni pantalla", "p2v2_faceta_04_distribucion.png", margin=0.2)
    steps_sheet()
    print("ok")
