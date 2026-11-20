---
name: riderlab-release
description: Prepare a RiderLab Android Play release — version bump in apps/mobile/pubspec.yaml, pre-flight checks, signed AAB via tool/release_play.ps1 (Windows) or release_play.sh (macOS/Linux), Play "what's new" notes, and the docs/ESTADO_SESION.md handoff. Use when the user says "release", "nueva versión", "build de Play", "AAB", "prepara la 104", "sube a prueba interna", or asks to bump the version.
---

# RiderLab Play release

Package `com.rawthrottle.riderlab`. Flavor `play`, `--dart-define=DISTRIBUTION=play`.
Version lives only in `apps/mobile/pubspec.yaml` as `version: X.Y.Z+CODE` (CODE = Play versionCode, must strictly increase for every upload).

## 0. Read current state first
- `docs/ESTADO_SESION.md` — which branch, which build is pending upload, what is already applied in production (e.g. migrations that must NOT be re-run).
- `git status` / current branch. Do not release from a dirty tree without asking.

## 1. Pre-flight (stop and report if anything fails)
Required local files (gitignored, restored from Nextcloud per `TRASLADO.md`):
- `apps/mobile/.env` containing `REVENUECAT_API_KEY_ANDROID=goog_...`
- `apps/mobile/android/upload-keystore.jks`, `apps/mobile/android/key.properties`

Never print, copy, commit or read aloud the contents of these files. Only check they exist / the key prefix is present.

Then:
1. Run the `mobile-release-check` skill (plugin) on `apps/mobile` — on Windows invoke its script with `python`, not `python3` (python3 is the Store stub).
2. `cd packages/ride_core && dart test`
3. From `apps/mobile`: `flutter pub get`, `flutter gen-l10n`, `flutter analyze --no-fatal-infos`, `flutter test`.
4. Optional before a big release: `/claude-security` scan.

## 2. Bump version
- Patch + code: `powershell -ExecutionPolicy Bypass -File tool/release_play.ps1 -BumpPatch` (bumps and builds in one go).
- Minor/major or code-only: edit the `version:` line by hand; always `+1` the build code.

## 3. Build
- Windows: `powershell -ExecutionPolicy Bypass -File apps/mobile/tool/release_play.ps1`
- macOS/Linux: `sh apps/mobile/tool/release_play.sh` (also runs the Pro entitlement analyze/test gate).
Output: `dist/RiderLab-X.Y.Z-CODE.aab` (dist/ is gitignored). Report its path and size.

## 4. Release notes
Update both `apps/mobile/play/whatsnew/whatsnew-es-419` and `whatsnew-en-US` (Play limit: 500 chars each). Spanish is the primary voice; keep them user-facing, no internal jargon.

## 5. Upload — only when the user explicitly asks
- Preferred: GitHub Action `play-release` (`workflow_dispatch`, `track` internal|alpha|beta, `status` draft|completed). Default to `internal` + `draft`.
- Or the user uploads the AAB by hand in Play Console.
Always internal testing first; promote the same AAB after a test purchase works (see ESTADO_SESION "Publicar").

## 6. Handoff
Update `docs/ESTADO_SESION.md`: date (absolute), branch, version+code, where the AAB lives, what is uploaded vs pending. Commit only if the user asks.

## iOS
Separate flow — see `docs/APP_STORE_RELEASE.md` and `.github/workflows/ios-testflight.yml`. Build numbers are independent of Android's.
