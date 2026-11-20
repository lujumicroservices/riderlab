"""Replay a real GPX ride into the Android emulator: GPS fixes + lean via gravity.

The emulator console takes `geo fix <lon> <lat> <alt> <sats> <knots>` and
`sensor set acceleration x:y:z`. The phone is assumed upright in a portrait
mount (gravity on +Y); leaning the bike rolls gravity into X by the
coordinated-turn angle atan(v^2 / (r g)).

Usage:
  python tool/demo/sim_ride.py TRACK.gpx --pick 150          # curviest 150 s
  python tool/demo/sim_ride.py TRACK.gpx --start 600 --seconds 120
  python tool/demo/sim_ride.py TRACK.gpx --park 30          # stand still at start
Writes a JSON line per second to stdout (t, speed, lean) for the demo map.
"""

from __future__ import annotations

import argparse
import json
import math
import os
import re
import subprocess
import sys
import time
from datetime import datetime

G = 9.81
ADB = os.environ.get(
    "ADB", os.path.expanduser("~/AppData/Local/Android/Sdk/platform-tools/adb.exe")
)


def adb_emu(*args: str) -> None:
    subprocess.run([ADB, "emu", *args], capture_output=True, timeout=10)


def load_gpx(path: str):
    text = open(path, encoding="utf-8").read()
    pts = []
    for m in re.finditer(r"<trkpt[^>]*?lat=\"([-\d.]+)\"[^>]*?lon=\"([-\d.]+)\"(.*?)</trkpt>", text, re.S):
        lat, lon, body = float(m.group(1)), float(m.group(2)), m.group(3)
        t = re.search(r"<time>([^<]+)</time>", body)
        e = re.search(r"<ele>([^<]+)</ele>", body)
        if not t:
            continue
        ts = datetime.fromisoformat(t.group(1).replace("Z", "+00:00")).timestamp()
        pts.append((ts, lat, lon, float(e.group(1)) if e else 1500.0))
    pts.sort()
    t0 = pts[0][0]
    return [(t - t0, la, lo, el) for t, la, lo, el in pts]


def dist_m(a, b):
    la1, lo1, la2, lo2 = map(math.radians, (a[1], a[2], b[1], b[2]))
    x = (lo2 - lo1) * math.cos((la1 + la2) / 2)
    return math.hypot(x, la2 - la1) * 6371000


def bearing(a, b):
    la1, lo1, la2, lo2 = map(math.radians, (a[1], a[2], b[1], b[2]))
    y = math.sin(lo2 - lo1) * math.cos(la2)
    x = math.cos(la1) * math.sin(la2) - math.sin(la1) * math.cos(la2) * math.cos(lo2 - lo1)
    return math.degrees(math.atan2(y, x))


def at(pts, t):
    """Linear interpolation of position at track time t."""
    lo, hi = 0, len(pts) - 1
    while hi - lo > 1:
        mid = (lo + hi) // 2
        if pts[mid][0] <= t:
            lo = mid
        else:
            hi = mid
    a, b = pts[lo], pts[hi]
    span = max(b[0] - a[0], 1e-6)
    f = min(max((t - a[0]) / span, 0), 1)
    return (t, a[1] + (b[1] - a[1]) * f, a[2] + (b[2] - a[2]) * f, a[3] + (b[3] - a[3]) * f)


def kinematics(pts, t, dt=2.0):
    p0, p1, p2 = at(pts, t - dt), at(pts, t), at(pts, t + dt)
    v = dist_m(p0, p2) / (2 * dt)
    turn = (bearing(p1, p2) - bearing(p0, p1) + 540) % 360 - 180  # deg over dt
    yaw_rate = math.radians(turn) / dt
    lean = math.degrees(math.atan2(v * yaw_rate, G))  # +right
    lean = max(-50.0, min(50.0, lean))
    return v, lean, p1


def pick_window(pts, seconds):
    best, best_t = -1.0, 0.0
    end = pts[-1][0] - seconds - 2
    t = 2.0
    while t < end:
        score, slow = 0.0, 0
        s = t
        while s < t + seconds:
            v, lean, _ = kinematics(pts, s)
            score += abs(lean)
            slow += v < 6
            s += 2
        if slow < seconds / 10 and score > best:
            best, best_t = score, t
        t += 10
    return best_t


def set_lean(lean_deg):
    r = math.radians(lean_deg)
    adb_emu("sensor", "set", "acceleration", f"{G * math.sin(r):.3f}:{G * math.cos(r):.3f}:0.2")


def fix(p, v):
    adb_emu("geo", "fix", f"{p[2]:.7f}", f"{p[1]:.7f}", f"{p[3]:.1f}", "12", f"{v * 1.943844:.2f}")


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("gpx")
    ap.add_argument("--pick", type=float, help="auto-pick the curviest window of N seconds")
    ap.add_argument("--start", type=float, default=None)
    ap.add_argument("--seconds", type=float, default=120)
    ap.add_argument("--park", type=float, default=0, help="stand still N s at the start")
    ap.add_argument("--hz", type=float, default=4)
    ap.add_argument("--slow-end", type=float, default=0, help="stand still N s at the end")
    a = ap.parse_args()

    pts = load_gpx(a.gpx)
    seconds = a.pick or a.seconds
    start = a.start if a.start is not None else (pick_window(pts, seconds) if a.pick else 2.0)
    print(json.dumps({"event": "window", "start": round(start, 1), "seconds": seconds}), flush=True)

    first = at(pts, start)
    set_lean(0)
    t_end_park = time.time() + a.park
    while time.time() < t_end_park:
        fix(first, 0)
        time.sleep(1)

    step = 1 / a.hz
    t0 = time.time()
    last_log = -1
    while True:
        el = time.time() - t0
        if el > seconds:
            break
        v, lean, p = kinematics(pts, start + el)
        fix(p, v)
        set_lean(lean)
        if int(el) != last_log:
            last_log = int(el)
            print(json.dumps({"t": last_log, "kmh": round(v * 3.6, 1), "lean": round(lean, 1),
                              "lat": round(p[1], 6), "lon": round(p[2], 6)}), flush=True)
        time.sleep(max(0, step - ((time.time() - t0) - el)))

    last = at(pts, start + seconds)
    set_lean(0)
    t_end = time.time() + a.slow_end
    while time.time() < t_end:
        fix(last, 0)
        time.sleep(1)
    print(json.dumps({"event": "done"}), flush=True)


if __name__ == "__main__":
    sys.exit(main())
