---
name: firmware-bench
description: Build, flash and bench-test the RiderLab/Métrica logger firmware (M5Stack Basic ESP32 + M135 GNSS, PlatformIO) in hardware/firmware. Use when the user mentions firmware, Métrica, M5, logger, flashear, PlatformIO, COM port, serial commands (GNSS, PINSCAN, ROLE, THEME, CIRCUIT…), the anchor station, or bench checklist.
---

# Firmware: build, flash, bench

Project: `hardware/firmware` — `platformio.ini` env `m5stack-basic` (espressif32@6.7.0, Arduino, 16 MB flash, `default_16MB.csv`).
Version string: `FIRMWARE_VERSION` in `include/HardwareConfig.h` (format `0.6.9j-asleep`: semver + letter + short tag). Bump it for every flash that changes behaviour, and add a one-line `// <version>: …` note in the header you touched (existing convention).

## Before flashing
- Read `hardware/STATUS.md` and the version table in `docs/CHANGELOG_CONTEXT.md` — which unit (e.g. 3876 on COM6), what is installed.
- For a risky change, back up flash first: `python ~/.platformio/packages/tool-esptoolpy/esptool.py --port COMx read_flash 0 0x1000000 backup_<unit>_<version>.bin` (esptool is not installed as a pip module; use PlatformIO's copy) (keep it outside git).
- NVS (Wi-Fi, pairing, role, REF, theme) survives because the partition table keeps NVS at the same offset — don't change partitions without saying so.

## Build / flash / monitor (from hardware/firmware)
```bash
python -m platformio run                      # build; report flash/RAM usage
python -m platformio run -t upload            # device on USB-C of the Basic
python -m platformio device monitor -b 115200
```
`upload_flags = --after no_reset`: after upload, press the reset button on the Basic (otherwise it may sit in DOWNLOAD_BOOT with a black screen). Find the port with `python -m platformio device list`.

## Bench test
Walk `hardware/firmware/BENCH_CHECKLIST.md` row by row and report pass/fail per row. Key serial commands: `HELP`, `STATUS`, `GNSS`, `GNSSCFG`, `PINSCAN`, `IMU`, `BARO`, `ROLE?`, `THEME?`, `CIRCUIT …`. Expect boot banner `RIDERLAB riderlab-logger <version> ROLE=…`.
Anchor role: also run the "Modo ancla" table and `ANCHOR.md`.
Pin facts: RXD→G16, TXD→G12, PPS→G34; never TXD→G0.

## Post-processing tools
`hardware/firmware/tools/` (anchor_correct.py + `python -m unittest tools/test_anchor_correct.py -v`) and `hardware/tools/` (maps, GNSS capture, session pull).

## Don'ts
- Don't provision real Wi-Fi passwords or device secrets (`WIFI`, `PAIR`) on the user's behalf from chat history — ask them to type them in the monitor.
- Don't flash a unit the user didn't name.
