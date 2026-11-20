"""Drive RiderLab on an Android emulator over adb, record the screen, and write
a timeline ("map") of everything that happened in each clip.

Each clip produces, under OUT/<clip_id>/:
  <clip_id>.mp4        screen recording
  <clip_id>.map.json   timeline: scenes, actions (with tap coordinates and the
                       on-screen element), captions, keyframes, GPS samples
  <clip_id>.srt        caption skeleton from the scene/caption text (edit later)
  keyframes/NN.png     a screenshot at the start of every scene

Times in the map are seconds from the first frame of the video (measured from
when screenrecord started; adb latency makes them ~0.3 s approximate).
"""

from __future__ import annotations

import json
import os
import re
import subprocess
import time
import xml.etree.ElementTree as ET
from dataclasses import dataclass, field

ADB = os.environ.get(
    "ADB", os.path.expanduser("~/AppData/Local/Android/Sdk/platform-tools/adb.exe")
)
PACKAGE = "com.rawthrottle.riderlab"


def adb(*args: str, timeout: float = 30, check: bool = False) -> str:
    r = subprocess.run([ADB, *args], capture_output=True, timeout=timeout)
    if check and r.returncode != 0:
        raise RuntimeError(f"adb {' '.join(args)} failed: {r.stderr.decode(errors='replace')}")
    return r.stdout.decode("utf-8", errors="replace")


@dataclass
class Node:
    text: str
    bounds: tuple[int, int, int, int]

    @property
    def center(self) -> tuple[int, int]:
        x1, y1, x2, y2 = self.bounds
        return (x1 + x2) // 2, (y1 + y2) // 2


def dump() -> list[Node]:
    adb("shell", "uiautomator", "dump", "/sdcard/rl_ui.xml")
    raw = adb("exec-out", "cat", "/sdcard/rl_ui.xml")
    raw = raw[raw.find("<?xml"):] if "<?xml" in raw else raw
    nodes = []
    try:
        root = ET.fromstring(raw)
    except ET.ParseError:
        return nodes
    for n in root.iter("node"):
        label = (n.get("text") or "") or (n.get("content-desc") or "")
        rid = n.get("resource-id") or ""
        m = re.findall(r"\d+", n.get("bounds") or "")
        if len(m) != 4:
            continue
        b = tuple(int(v) for v in m)
        if label or rid:
            nodes.append(Node(label if label else rid, b))  # type: ignore[arg-type]
            if rid and label:
                nodes.append(Node(rid, b))  # type: ignore[arg-type]
    return nodes


def find(pattern: str, timeout: float = 8.0) -> Node | None:
    rx = re.compile(pattern, re.I | re.S)
    end = time.time() + timeout
    while True:
        for n in dump():
            if rx.search(n.text):
                return n
        if time.time() > end:
            return None
        time.sleep(0.6)


@dataclass
class Clip:
    clip_id: str
    title: str
    feature: str
    out_dir: str
    events: list[dict] = field(default_factory=list)
    gps: list[dict] = field(default_factory=list)
    t0: float = 0.0
    duration: float = 0.0
    _proc: subprocess.Popen | None = None
    _scene_n: int = 0

    # ---- recording ------------------------------------------------------
    def __enter__(self):
        os.makedirs(os.path.join(self.out_dir, "keyframes"), exist_ok=True)
        adb("shell", "rm", "-f", f"/sdcard/{self.clip_id}.mp4")
        self._proc = subprocess.Popen(
            [ADB, "shell", "screenrecord", "--bit-rate", "8000000",
             "--time-limit", "180", f"/sdcard/{self.clip_id}.mp4"],
            stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL,
        )
        time.sleep(0.8)  # screenrecord warm-up; first frame lands about here
        self.t0 = time.time() - 0.3
        return self

    def __exit__(self, *exc):
        time.sleep(1.0)
        adb("shell", "pkill", "-INT", "screenrecord")
        try:
            self._proc.wait(timeout=15)  # type: ignore[union-attr]
        except subprocess.TimeoutExpired:
            self._proc.kill()  # type: ignore[union-attr]
        time.sleep(1.5)
        duration = round(self.now(), 2)
        self.duration = duration
        mp4 = os.path.join(self.out_dir, f"{self.clip_id}.mp4")
        adb("pull", f"/sdcard/{self.clip_id}.mp4", mp4, timeout=120)
        self._write(duration, error=repr(exc[1]) if exc[1] else None)
        return False

    def now(self) -> float:
        return time.time() - self.t0

    # ---- timeline -------------------------------------------------------
    def _event(self, kind: str, text: str, **extra):
        ev = {"t": round(self.now(), 2), "type": kind, "text": text, **extra}
        self.events.append(ev)
        print(f"  [{ev['t']:6.2f}] {kind:8s} {text}", flush=True)
        return ev

    def scene(self, title: str, caption: str = ""):
        """A new section of the video. Takes a keyframe for later editing."""
        self._scene_n += 1
        key = f"keyframes/{self._scene_n:02d}.png"
        with open(os.path.join(self.out_dir, key), "wb") as f:
            f.write(subprocess.run([ADB, "exec-out", "screencap", "-p"],
                                   capture_output=True).stdout)
        return self._event("scene", title, caption=caption or title, keyframe=key)

    def caption(self, text: str, seconds: float = 3.0):
        return self._event("caption", text, duration=seconds)

    def wait(self, seconds: float):
        time.sleep(seconds)

    # ---- actions --------------------------------------------------------
    def tap(self, pattern: str, label: str | None = None, timeout: float = 8.0,
            optional: bool = False) -> bool:
        node = find(pattern, timeout)
        if node is None:
            if optional:
                self._event("skip", f"not on screen: {label or pattern}")
                return False
            raise RuntimeError(f"Element not found: {pattern}")
        x, y = node.center
        adb("shell", "input", "tap", str(x), str(y))
        self._event("tap", label or node.text, x=x, y=y, bounds=node.bounds)
        return True

    def tap_xy(self, x: int, y: int, label: str):
        adb("shell", "input", "tap", str(x), str(y))
        self._event("tap", label, x=x, y=y)

    def hold(self, pattern: str, ms: int, label: str | None = None, timeout: float = 8.0):
        node = find(pattern, timeout)
        if node is None:
            raise RuntimeError(f"Element not found: {pattern}")
        x, y = node.center
        self._event("hold", label or node.text, x=x, y=y, ms=ms, bounds=node.bounds)
        adb("shell", "input", "motionevent", "DOWN", str(x), str(y))
        time.sleep(ms / 1000)
        adb("shell", "input", "motionevent", "UP", str(x), str(y))

    def hold_xy(self, x: int, y: int, ms: int, label: str):
        # DOWN / UP as separate events: `input swipe` can block for many
        # seconds while a live screen keeps redrawing under screenrecord.
        self._event("hold", label, x=x, y=y, ms=ms)
        adb("shell", "input", "motionevent", "DOWN", str(x), str(y))
        time.sleep(ms / 1000)
        adb("shell", "input", "motionevent", "UP", str(x), str(y))

    def swipe(self, x1, y1, x2, y2, ms=400, label="scroll"):
        self._event("swipe", label, frm=[x1, y1], to=[x2, y2], ms=ms)
        adb("shell", "input", "swipe", str(x1), str(y1), str(x2), str(y2), str(ms))

    def back(self):
        self._event("key", "Atrás")
        adb("shell", "input", "keyevent", "BACK")

    def wait_for(self, pattern: str, timeout: float = 30.0, label: str | None = None) -> bool:
        node = find(pattern, timeout)
        self._event("seen" if node else "timeout", label or pattern)
        return node is not None

    def gps_sample(self, sample: dict):
        self.gps.append({"t": round(self.now(), 2), **sample})

    # ---- output ---------------------------------------------------------
    def _write(self, duration: float, error: str | None):
        scenes = [e for e in self.events if e["type"] == "scene"]
        for i, s in enumerate(scenes):
            s["end"] = scenes[i + 1]["t"] if i + 1 < len(scenes) else duration
        data = {
            "clip": self.clip_id,
            "title": self.title,
            "feature": self.feature,
            "video": f"{self.clip_id}.mp4",
            "duration_s": duration,
            "resolution": adb("shell", "wm", "size").strip().split()[-1],
            "time_base": "seconds from first video frame (±0.3 s)",
            "error": error,
            "scenes": scenes,
            "events": self.events,
            "gps": self.gps,
            "overlay_slots": [
                {"t": s["t"], "end": s["end"], "subtitle": s["caption"],
                 "voiceover": "", "animation": ""} for s in scenes
            ],
        }
        with open(os.path.join(self.out_dir, f"{self.clip_id}.map.json"), "w", encoding="utf-8") as f:
            json.dump(data, f, ensure_ascii=False, indent=2)
        with open(os.path.join(self.out_dir, f"{self.clip_id}.srt"), "w", encoding="utf-8") as f:
            cues = [(s["t"], s["end"], s["caption"]) for s in scenes]
            cues += [(c["t"], c["t"] + c["duration"], c["text"])
                     for c in self.events if c["type"] == "caption"]
            for i, (a, b, text) in enumerate(sorted(cues), 1):
                f.write(f"{i}\n{_srt(a)} --> {_srt(b)}\n{text}\n\n")


def _srt(t: float) -> str:
    ms = int(round(t * 1000))
    h, ms = divmod(ms, 3_600_000)
    m, ms = divmod(ms, 60_000)
    s, ms = divmod(ms, 1000)
    return f"{h:02d}:{m:02d}:{s:02d},{ms:03d}"


def launch(fresh: bool = True):
    if fresh:
        adb("shell", "am", "force-stop", PACKAGE)
    adb("shell", "monkey", "-p", PACKAGE, "-c", "android.intent.category.LAUNCHER", "1")
