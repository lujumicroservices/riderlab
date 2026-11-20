#!/bin/sh
# macOS/Linux twin of release_play.ps1: signed Play AAB (playRelease).
# Does not upload. From the repo root or anywhere:
#   sh apps/mobile/tool/release_play.sh
set -eu
cd "$(dirname "$0")/.."

for f in android/upload-keystore.jks android/key.properties .env; do
  [ -f "$f" ] || { echo "Missing $f" >&2; exit 1; }
done
grep -q '^REVENUECAT_API_KEY_ANDROID=goog_' .env || {
  echo "Missing REVENUECAT_API_KEY_ANDROID=goog_... in .env" >&2; exit 1; }

line=$(sed -n 's/^version:[[:space:]]*\([^[:space:]]*\).*/\1/p' pubspec.yaml)
echo "Building Play AAB for $line ..."

flutter pub get
flutter gen-l10n
flutter analyze --no-fatal-infos lib/providers/pro_entitlement_provider.dart lib/features/pro lib/widgets lib/core/pro
flutter test test/pro_entitlement_test.dart
flutter build appbundle --flavor play --release --dart-define=DISTRIBUTION=play

aab=build/app/outputs/bundle/playRelease/app-play-release.aab
[ -f "$aab" ] || { echo "AAB not found: $aab" >&2; exit 1; }
mkdir -p ../../dist
copy="../../dist/RiderLab-$(echo "$line" | tr '+' '-').aab"
cp -f "$aab" "$copy"
echo ""
echo "AAB ready:"
echo "  $(pwd)/$aab"
echo "  $(cd ../../dist && pwd)/$(basename "$copy")"
