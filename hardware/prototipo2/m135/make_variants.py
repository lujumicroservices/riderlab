"""Writes variant.json for the three M135 layouts of the Faceta case.

python3 make_variants.py

Each variant.json has:
  cad     -> parameter overrides for ../cad/metrica_p2_v2_faceta.py
  geom    -> front-face depths (must match cad) for the Blender build
  display / buttons / connectors / parts -> internal layout (CAD mm, z = above the base)
Board sizes: DevKitC-VE 54.4x27.9, Feather V2 52.3x22.8, Adafruit 4682 microSD 25.4x22.8,
Adafruit 4410 charger ~26x17, Pololu S7V8F3 11.4x16.5, #2808 15.2x17.8, D24V10F5 12.7x17.8,
LiPo 51x30x8, M135 54x54x13.2.
"""
import json
from pathlib import Path

HERE = Path(__file__).parent
LIPO = {"type": "block", "name": "lipo", "size": [30, 51, 8], "mat": "lipo_foil", "bevel": 1.5, "sticker": True,
        "label": "LiPo 1S 1500 mAh"}


def carrier_stack(cx, cy, esp_y, lower_y):
    """Perfboard carrier with the small modules; the DevKitC rides on headers above them."""
    zc, zm, ze = 3.8, 7.0, 13.9          # carrier PCB, modules on carrier, ESP32 on 8.5 mm headers
    on = {"so_from": zc + 0.8}
    return [
        {"type": "board", "name": "carrier", "w": 56, "h": 48, "x": cx, "y": cy, "z": zc, "mat": "perfboard",
         "label": "Placa portadora (perfboard)"},
        {"type": "board", "name": "microsd", "w": 25.4, "h": 22.8, "x": cx - 14, "y": esp_y, "z": zm, "mat": "pcb_purple",
         "chips": [{"name": "slot", "size": [14, 15, 1.8]}], "label": "microSD (bajo la ESP32)", **on},
        {"type": "board", "name": "charger", "w": 26, "h": 17, "x": cx + 14, "y": esp_y - 2.5, "z": zm, "mat": "pcb_purple",
         "chips": [{"name": "usb", "size": [9, 7, 3], "dx": -9}], "label": "Cargador USB-C 4410 (bajo la ESP32)", **on},
        {"type": "board", "name": "pwrswitch", "w": 17.8, "h": 15.2, "x": cx - 18, "y": lower_y, "z": zm, "mat": "pcb_blue",
         "label": "Pololu power switch #2808", **on},
        {"type": "board", "name": "buckboost", "w": 11.4, "h": 16.5, "x": cx - 1, "y": lower_y, "z": zm, "mat": "pcb_blue",
         "chips": [{"name": "ic", "size": [4, 4, 1.2], "mat": "tact_black"}], "label": "Buck-boost 3.3 V S7V8F3", **on},
        {"type": "board", "name": "d24", "w": 12.7, "h": 17.8, "x": cx + 15, "y": lower_y, "z": zm, "mat": "pcb_blue",
         "chips": [{"name": "coil", "size": [5, 5, 3], "mat": "tact_black"}], "label": "Buck 12→5 V D24V10F5 (opcional)", **on},
        {"type": "board", "name": "esp32", "w": 54.4, "h": 27.9, "x": cx, "y": esp_y, "z": ze, "mat": "pcb_black",
         "headers": True, "so_from": zc + 0.8,
         "chips": [{"name": "mod", "size": [18, 25.5, 3.2], "dx": 13.5}, {"name": "usb", "size": [9, 7.5, 3.0], "dx": -24}],
         "label": "ESP32 DevKitC-VE (sobre la portadora)"},
    ]


CARRIER_STACKS = [["vx_carrier", n] for n in ("vx_microsd", "vx_charger", "vx_pwrswitch", "vx_buckboost", "vx_d24", "vx_esp32")]
SMA_LINK = [["vx_m135", "vx_sma_in"]]   # the module SMA meets the bulkhead

VARIANTS = {
    "A_ancha": {
        "title": "A · Ancha 172 mm: todo lado a lado",
        "cad": {"W": 172.0, "W_FRONT": 150.0, "WIN_X": -44.0, "BTN_X": -1.0, "CHEV_X": 47.0, "LOGO_X": 47.0,
                "PASS": {"usb": [-60, 16], "pg7": [-40, 12.5], "power": [-20, 12], "vent_m12": [10, 12.2], "sma": [58, 6.6]},
                "BOSS_PTS": [[-78, 23], [-78, -23], [80, 12], [80, -12], [0, 31], [0, -29]]},
        "geom": {"D_B": 22.0, "D_T": 32.0, "PZ": 11.0},
        "display": {"x": -44.0, "y": -1.0}, "buttons": {"x": -1.0},
        "connectors": [{"kind": "usb", "x": -60}, {"kind": "pg7", "x": -40}, {"kind": "power", "x": -20},
                       {"kind": "vent", "x": 10}, {"kind": "sma", "x": 58}],
        "parts": carrier_stack(-44, 6, 14.5, -9) + [
            {**LIPO, "x": 0, "y": 1.5, "z": 0.5},
            {"type": "m135", "x": 43, "y": 2, "z": 4, "sma_dx": 15}],
        "stacks": CARRIER_STACKS + SMA_LINK,
    },
    "B_profunda": {
        "title": "B · 150 mm, más profunda: LiPo debajo del M135",
        "cad": {"D_BOTTOM": 32.0, "D_TOP": 42.0, "Z_LOFT": 52.0, "W_FRONT": 122.8, "CH_FRONT": 17.4,
                "WIN_X": -33.0, "BTN_X": 15.0,
                "PASS": {"usb": [-50, 16], "pg7": [-28, 12.5], "power": [-9, 12], "vent_m12": [12, 12.2], "sma": [50, 6.6]}},
        "geom": {"D_B": 32.0, "D_T": 42.0, "PZ": 11.0},
        "display": {"x": -33.0, "y": -1.0}, "buttons": {"x": 15.0},
        "connectors": [{"kind": "usb", "x": -50}, {"kind": "pg7", "x": -28}, {"kind": "power", "x": -9},
                       {"kind": "vent", "x": 12}, {"kind": "sma", "x": 50}],
        "parts": carrier_stack(-34, 5.5, 13, -10) + [
            {**LIPO, "x": 30, "y": 4.5, "z": 0.5},
            {"type": "m135", "x": 30, "y": 2, "z": 10, "sma_dx": 20}],
        "stacks": CARRIER_STACKS + SMA_LINK,
    },
    "C_feather": {
        "title": "C · 150 mm con ESP32 Feather V2 (cargador integrado)",
        "cad": {"PASS": {"usb": [-46, 16], "pg7": [-18, 12.5], "vent_m12": [12, 12.2], "power": [30, 12], "sma": [56, 6.6]}},
        "geom": {"D_B": 22.0, "D_T": 32.0, "PZ": 11.0},
        "display": {"x": -36.0, "y": -1.0}, "buttons": {"x": 14.0},
        "connectors": [{"kind": "usb", "x": -46}, {"kind": "pg7", "x": -18}, {"kind": "vent", "x": 12},
                       {"kind": "power", "x": 30}, {"kind": "sma", "x": 56}],
        "parts": [
            {"type": "board", "name": "feather", "w": 52.3, "h": 22.8, "x": -35, "y": 16, "z": 6.0, "mat": "pcb_black",
             "chips": [{"name": "pico", "size": [10, 15, 2.4], "dx": 8}, {"name": "usb", "size": [9, 7.5, 3], "dx": -22}],
             "label": "ESP32 Feather V2 (con cargador)"},
            {"type": "board", "name": "microsd", "w": 25.4, "h": 22.8, "x": -47, "y": -8, "z": 6.0, "mat": "pcb_purple",
             "chips": [{"name": "slot", "size": [14, 15, 1.8]}], "label": "microSD"},
            {"type": "board", "name": "pwrswitch", "w": 17.8, "h": 15.2, "x": -24, "y": -8, "z": 6.0, "mat": "pcb_blue",
             "label": "Pololu power switch #2808"},
            {**LIPO, "x": 6, "y": 2.5, "z": 0.5},
            {"type": "m135", "x": 49, "y": 2, "z": 4, "sma_dx": 7}],
        "stacks": SMA_LINK,
    },
}

for name, v in VARIANTS.items():
    d = HERE / name
    d.mkdir(exist_ok=True)
    (d / "variant.json").write_text(json.dumps({"name": name, **v}, ensure_ascii=False, indent=1))
    print("wrote", d / "variant.json")
