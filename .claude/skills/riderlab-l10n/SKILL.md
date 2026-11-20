---
name: riderlab-l10n
description: Add, change or audit user-facing strings in the RiderLab Flutter app (Spanish template + English). Use whenever a change adds or edits UI text in apps/mobile, when the user mentions "traducción", "strings", "l10n", "arb", "texto en inglés/español", or when a hardcoded string shows up in a widget.
---

# RiderLab localization

Config: `apps/mobile/l10n.yaml`
- Template: `lib/l10n/app_es.arb` (Spanish is the source of truth), plus `lib/l10n/app_en.arb`.
- Generated: `lib/l10n/app_localizations*.dart` — never edit by hand.
- `nullable-getter: false`, preferred locale `es`.

## Adding / changing a string
1. Add the key to **both** `app_es.arb` and `app_en.arb`, same key, camelCase, prefixed by feature (`gps…`, `ride…`, `pro…`, `friends…`). Look at neighbouring keys and reuse an existing one if the meaning is identical.
2. Placeholders: declare them in `@key` metadata in `app_es.arb` (`"placeholders": {"meters": {"type": "String"}}`). Plurals use ICU `{count, plural, =1{…} other{…}}` in both files.
3. Spanish: Mexican Spanish, "tú", short — these are rider-facing screens often read at a glance. English: natural, not literal.
4. Run `flutter gen-l10n` from `apps/mobile`.
5. Use via `context.l10n` / `AppLocalizations.of(context)` (see `lib/l10n/l10n_ext.dart`). For enum → text mappings, follow the extension pattern in `lib/l10n/gps_warmup_l10n.dart` and `skill_tip_l10n.dart`. User-facing errors go through `lib/l10n/user_facing_error.dart`.

## Audit (run before a release or after a big UI change)
```bash
cd apps/mobile
python -c "import json;l=lambda p:{k for k in json.load(open(p,encoding='utf-8')) if not k.startswith('@')};e,s=l('lib/l10n/app_en.arb'),l('lib/l10n/app_es.arb');print('missing en:',sorted(s-e));print('missing es:',sorted(e-s))"
```
Then search `lib/` for hardcoded UI text, e.g. Grep `Text\('[A-ZÁÉÍÓÚ¿¡]` and `label: '` in `lib/features`. Report findings; don't mass-migrate without asking.

Store listing text (Play/App Store) is not in ARB files — see `docs/store/` and `apps/mobile/play/whatsnew/`.
