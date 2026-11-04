import 'dart:io' show Platform;

import 'package:flutter/foundation.dart' show kIsWeb;

/// Build-time distribution channel.
///
/// Play Store AAB:
///   flutter build appbundle --flavor play --dart-define=DISTRIBUTION=play
///
/// App Store / TestFlight IPA:
///   flutter build ipa --release --dart-define=DISTRIBUTION=appstore
///
/// GitHub sideload APK (friend builds):
///   flutter build apk --flavor sideload --dart-define=DISTRIBUTION=sideload
class AppDistribution {
  AppDistribution._();

  static const channel = String.fromEnvironment(
    'DISTRIBUTION',
    defaultValue: 'sideload',
  );

  static bool get _isIOS => !kIsWeb && Platform.isIOS;

  /// True when built for Google Play (no sideload APK installer).
  static bool get isPlayStore => channel == 'play';

  /// True for App Store / TestFlight builds. Any iOS build counts: iOS can
  /// never sideload, so it must always follow App Store rules.
  static bool get isAppStore => channel == 'appstore' || _isIOS;

  /// Any build distributed through an official store (Play or App Store).
  static bool get isStoreBuild => isPlayStore || isAppStore;

  /// GitHub Release APK install path (REQUEST_INSTALL_PACKAGES).
  static bool get allowsSideloadUpdates => !isStoreBuild;

  /// Our own 90-day partner codes. Apple guideline 3.1.1 does not allow
  /// unlocking digital features with app-specific codes, so iOS uses
  /// App Store offer codes instead (see presentOfferCodeRedemption).
  static bool get allowsPartnerCodes => !isAppStore;

  /// iOS: App Store offer codes (redeemed through Apple's own sheet).
  static bool get allowsOfferCodes => isAppStore;

  /// Métrica logger (BLE pairing / SD import). Out of iOS 1.0: App Review
  /// cannot test it without the hardware, so it ships in 1.1 together with a
  /// pairing video on a real iPhone. Flip this to `true` for that release
  /// (and restore the Métrica wording in the iOS Bluetooth usage strings).
  static bool get allowsMetricaLogger => !isAppStore;
}
