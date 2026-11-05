#!/bin/sh
# Xcode Cloud: runs after the repo is cloned, before xcodebuild.
# Installs Flutter, writes the gitignored config files from workflow secrets,
# and generates ios/Flutter/ephemeral (FlutterGeneratedPluginSwiftPackage),
# Generated.xcconfig and Pods, which the archive step needs.
#
# Xcode Cloud workflow → Environment → secret variables (base64):
#   MOBILE_ENV_IOS_B64             apps/mobile/.env for iOS
#   GOOGLE_SERVICE_INFO_PLIST_B64  Firebase GoogleService-Info.plist
# base64 -i apps/mobile/.env | pbcopy
# base64 -i apps/mobile/ios/Runner/GoogleService-Info.plist | pbcopy
set -eu

FLUTTER_VERSION=3.47.1
# App Store Connect needs a new build number per upload. Local / GitHub
# builds used 101; Xcode Cloud builds are CI_BUILD_NUMBER + 200.
BUILD_NUMBER=$((CI_BUILD_NUMBER + 200))

MOBILE="$CI_PRIMARY_REPOSITORY_PATH/apps/mobile"

if [ -z "${MOBILE_ENV_IOS_B64:-}" ] || [ -z "${GOOGLE_SERVICE_INFO_PLIST_B64:-}" ]; then
  echo "error: set MOBILE_ENV_IOS_B64 and GOOGLE_SERVICE_INFO_PLIST_B64 as secret environment variables in the Xcode Cloud workflow" >&2
  exit 1
fi
echo "$MOBILE_ENV_IOS_B64" | base64 --decode > "$MOBILE/.env"
echo "$GOOGLE_SERVICE_INFO_PLIST_B64" | base64 --decode > "$MOBILE/ios/Runner/GoogleService-Info.plist"
if ! /usr/libexec/PlistBuddy -c "Print :BUNDLE_ID" "$MOBILE/ios/Runner/GoogleService-Info.plist" | grep -qx com.rawthrottle.riderlab; then
  echo "error: GoogleService-Info.plist BUNDLE_ID is not com.rawthrottle.riderlab" >&2
  exit 1
fi

git clone https://github.com/flutter/flutter.git --depth 1 -b "$FLUTTER_VERSION" "$HOME/flutter"
export PATH="$PATH:$HOME/flutter/bin"
flutter --disable-analytics
flutter precache --ios

cd "$MOBILE"
flutter pub get
flutter build ios --config-only --release \
  --build-number="$BUILD_NUMBER" \
  --dart-define=DISTRIBUTION=appstore

HOMEBREW_NO_AUTO_UPDATE=1 brew install cocoapods
cd ios && pod install

echo "Xcode Cloud: Flutter $FLUTTER_VERSION ready, build number $BUILD_NUMBER"
