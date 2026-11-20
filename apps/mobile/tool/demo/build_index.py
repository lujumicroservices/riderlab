"""Build index.html + INDEX.md for a demo run folder (tool/demo/out/<date>/).

  python tool/demo/build_index.py tool/demo/out/2026-11-20

Also writes <clip>.vtt next to each .srt so browsers show the captions.
The page is self-contained (relative links), so the whole folder can be
zipped or uploaded as is.
"""

from __future__ import annotations

import html
import json
import os
import sys


def srt_to_vtt(srt: str) -> str:
    out = ["WEBVTT", ""]
    for block in srt.strip().split("\n\n"):
        lines = block.splitlines()
        if len(lines) >= 3:
            out += [lines[1].replace(",", "."), *lines[2:], ""]
    return "\n".join(out)


def fmt(t: float) -> str:
    return f"{int(t // 60)}:{t % 60:04.1f}"


def main(run_dir: str):
    clips = []
    for name in sorted(os.listdir(run_dir)):
        mp = os.path.join(run_dir, name, f"{name}.map.json")
        if not os.path.exists(mp):
            continue
        data = json.load(open(mp, encoding="utf-8"))
        srt = os.path.join(run_dir, name, f"{name}.srt")
        if os.path.exists(srt):
            with open(os.path.join(run_dir, name, f"{name}.vtt"), "w", encoding="utf-8") as f:
                f.write(srt_to_vtt(open(srt, encoding="utf-8").read()))
        size = os.path.getsize(os.path.join(run_dir, name, data["video"])) if os.path.exists(
            os.path.join(run_dir, name, data["video"])) else 0
        clips.append((name, data, size))

    # ---- Markdown -------------------------------------------------------
    md = ["# RiderLab: demo por funcionalidad", "",
          f"Corrida: `{os.path.basename(os.path.abspath(run_dir))}`. Cada video tiene su mapa "
          "(`.map.json`), subtítulos editables (`.srt`/`.vtt`) y capturas por escena (`keyframes/`).", "",
          "| # | Funcionalidad | Qué se ve | Video | Duración | Mapa |", "|---|---|---|---|---|---|"]
    for i, (name, data, size) in enumerate(clips, 1):
        ok = "" if not data.get("error") else " ⚠️"
        md.append(f"| {i} | {data['title']}{ok} | {data['feature']} | [{name}.mp4]({name}/{data['video']}) "
                  f"| {fmt(data['duration_s'])} | [map]({name}/{name}.map.json) · [srt]({name}/{name}.srt) |")
    md += ["", "## Escenas", ""]
    for name, data, _ in clips:
        md.append(f"### {data['title']} — `{name}`")
        for s in data["scenes"]:
            md.append(f"- `{fmt(s['t'])}–{fmt(s['end'])}` **{s['text']}** — {s['caption']} "
                      f"([captura]({name}/{s['keyframe']}))")
        md.append("")
    open(os.path.join(run_dir, "INDEX.md"), "w", encoding="utf-8").write("\n".join(md))

    # ---- HTML -----------------------------------------------------------
    cards = []
    for i, (name, data, size) in enumerate(clips, 1):
        scenes = "".join(
            f'<li><button data-v="v{i}" data-t="{s["t"]}"><span class="ts">{fmt(s["t"])}</span>'
            f'{html.escape(s["text"])}</button><p>{html.escape(s["caption"])}</p></li>'
            for s in data["scenes"])
        actions = "".join(
            f'<li><span class="ts">{fmt(e["t"])}</span><span class="k">{e["type"]}</span>{html.escape(e["text"])}</li>'
            for e in data["events"] if e["type"] not in ("scene",))
        err = f'<p class="err">Error en la grabación: {html.escape(data["error"])}</p>' if data.get("error") else ""
        cards.append(f"""
<section class="clip" id="{name}">
  <header><span class="n">{i:02d}</span><div><h2>{html.escape(data['title'])}</h2>
  <p>{html.escape(data['feature'])}</p></div></header>{err}
  <div class="grid">
    <video id="v{i}" controls preload="metadata" src="{name}/{data['video']}">
      <track kind="subtitles" srclang="es" label="Español" src="{name}/{name}.vtt" default>
    </video>
    <div class="side">
      <h3>Escenas</h3><ol class="scenes">{scenes}</ol>
      <details><summary>Acciones ({sum(1 for e in data['events'] if e['type'] != 'scene')})</summary>
      <ol class="acts">{actions}</ol></details>
      <p class="files"><a href="{name}/{data['video']}">mp4</a> · <a href="{name}/{name}.map.json">map.json</a>
      · <a href="{name}/{name}.srt">srt</a> · {fmt(data['duration_s'])} · {size / 1e6:.1f} MB</p>
    </div>
  </div>
</section>""")
    toc = "".join(f'<li><a href="#{n}">{html.escape(d["title"])}</a></li>' for n, d, _ in clips)
    page = f"""<!doctype html><html lang="es"><head><meta charset="utf-8">
<meta name="viewport" content="width=device-width,initial-scale=1">
<title>RiderLab Demo</title>
<style>
:root{{--bg:#0f1115;--panel:#1b1e25;--ink:#eef1f5;--mute:#9aa3ad;--hot:#ff4122;--teal:#00c9a7;--line:#2a2f38}}
@media (prefers-color-scheme: light){{:root:not([data-theme=dark]){{--bg:#f6f7f9;--panel:#fff;--ink:#14171c;--mute:#5d6670;--line:#e3e6ea}}}}
*{{box-sizing:border-box}}body{{margin:0;background:var(--bg);color:var(--ink);font:15px/1.5 system-ui,sans-serif}}
main{{max-width:1100px;margin:0 auto;padding:24px 16px 64px}}
h1{{font-size:28px;margin:0 0 4px}}.lead{{color:var(--mute);margin:0 0 20px}}
nav ol{{display:flex;flex-wrap:wrap;gap:8px;padding:0;margin:0 0 28px;list-style:none}}
nav a{{display:block;padding:6px 12px;border:1px solid var(--line);border-radius:999px;color:var(--ink);text-decoration:none;font-size:13px}}
.clip{{background:var(--panel);border:1px solid var(--line);border-radius:16px;padding:18px;margin:0 0 20px}}
.clip header{{display:flex;gap:14px;align-items:center;margin-bottom:12px}}
.n{{font:700 22px/1 ui-monospace,monospace;color:var(--hot)}}h2{{margin:0;font-size:19px}}header p{{margin:2px 0 0;color:var(--mute)}}
.grid{{display:grid;grid-template-columns:minmax(0,300px) 1fr;gap:18px}}
video{{width:100%;border-radius:12px;background:#000;aspect-ratio:9/20}}
h3{{margin:0 0 6px;font-size:14px;color:var(--mute);text-transform:uppercase;letter-spacing:.06em}}
ol.scenes{{list-style:none;padding:0;margin:0 0 12px}}ol.scenes li{{margin:0 0 8px}}
ol.scenes button{{all:unset;cursor:pointer;font-weight:600}}ol.scenes button:hover{{color:var(--teal)}}
ol.scenes p{{margin:0 0 0 62px;color:var(--mute);font-size:13px}}
.ts{{display:inline-block;width:56px;font:12px ui-monospace,monospace;color:var(--teal)}}
.k{{display:inline-block;width:60px;font-size:12px;color:var(--mute)}}
ol.acts{{list-style:none;padding:0;font-size:13px}}.files{{font-size:13px;color:var(--mute)}}.files a{{color:var(--teal)}}
.err{{color:var(--hot)}}
@media (max-width:700px){{.grid{{grid-template-columns:1fr}}video{{max-width:320px}}}}
</style></head><body><main>
<h1>RiderLab: demo por funcionalidad</h1>
<p class="lead">Grabado en emulador con una rodada real reproducida por GPS. Toca una escena para saltar a ese momento.</p>
<nav><ol>{toc}</ol></nav>
{''.join(cards)}
</main>
<script>
document.querySelectorAll('ol.scenes button').forEach(b=>b.addEventListener('click',()=>{{
  const v=document.getElementById(b.dataset.v); v.currentTime=parseFloat(b.dataset.t); v.play();}}));
</script></body></html>"""
    open(os.path.join(run_dir, "index.html"), "w", encoding="utf-8").write(page)
    print(f"{len(clips)} clips -> {os.path.join(run_dir, 'index.html')}")


if __name__ == "__main__":
    main(sys.argv[1])
