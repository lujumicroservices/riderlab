import 'dart:async';
import 'dart:io' show Platform;

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/notifications/push_notification_service.dart';
import '../../core/services/arm_foreground_service.dart';
import '../../core/services/location_service.dart';
import '../../l10n/l10n_ext.dart';
import '../../theme/app_theme.dart';
import '../../widgets/app_snack.dart';

/// Result of [LocationPermissionGate.prepareForRide].
class RidePermissionOutcome {
  const RidePermissionOutcome.granted({this.backgroundLimited = false})
    : granted = true,
      cancelled = false,
      reason = null;

  const RidePermissionOutcome.failed(LocationPermissionDenyReason this.reason)
    : granted = false,
      cancelled = false,
      backgroundLimited = false;

  const RidePermissionOutcome.cancelled()
    : granted = false,
      cancelled = true,
      reason = null,
      backgroundLimited = false;

  final bool granted;

  /// The user backed out of our own explainer (not an error).
  final bool cancelled;

  /// Why recording cannot start (phone location off, denied, denied forever).
  final LocationPermissionDenyReason? reason;

  /// Android: foreground-only location. Recording works through the
  /// foreground service, but may pause with the screen off.
  final bool backgroundLimited;
}

/// Prominent disclosure + every system prompt a ride needs, before calibration.
///
/// One explainer lists only the steps still pending, then asks in order:
/// 1. Foreground location ("While using the app").
/// 2. Android: background location. Android 11+ sends the user to Settings,
///    so our own "One more step" dialog (Continue / Not now) comes first.
///    Declining is remembered: no nag on later starts, only a toast.
/// 3. Notifications (Android 13+ / iOS), so the recording notification shows.
/// 4. Android: battery-optimization exemption.
///
/// Calibration (and arming) run after this, so nothing pops once the phone is
/// on the mount. iOS "Always" is still offered later, in context
/// ([offerAlwaysIfUseful]).
class LocationPermissionGate {
  LocationPermissionGate._();

  static final _location = LocationService();

  static const _prefAlwaysNotNow = 'ios_location_always_not_now';
  static const _prefAlwaysAsked = 'ios_location_always_asked';
  static const _prefBgDeclined = 'ride_android_background_declined';
  static const _prefNotifAsked = 'ride_notifications_asked';
  static const _prefBatteryAsked = 'ride_battery_optimization_asked';

  static bool _warnedLimited = false;

  static bool get _isIos => !kIsWeb && Platform.isIOS;
  static bool get _isAndroid => !kIsWeb && Platform.isAndroid;

  /// Runs [prepareForRide]; true when recording may start.
  static Future<bool> requestForRecording(
    BuildContext context, {
    bool offerBackground = false,
  }) async {
    final outcome = await prepareForRide(
      context,
      offerBackground: offerBackground,
    );
    return outcome.granted;
  }

  /// [offerBackground]: iOS step 2 right after step 1 succeeds (Armar auto).
  static Future<RidePermissionOutcome> prepareForRide(
    BuildContext context, {
    bool offerBackground = false,
  }) async {
    if (!await Geolocator.isLocationServiceEnabled()) {
      if (context.mounted) await _showServicesOffDialog(context);
      return const RidePermissionOutcome.failed(
        LocationPermissionDenyReason.servicesOff,
      );
    }

    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.deniedForever) {
      if (context.mounted) await _showDeniedDialog(context);
      return const RidePermissionOutcome.failed(
        LocationPermissionDenyReason.deniedForever,
      );
    }

    final prefs = await SharedPreferences.getInstance();
    final needForeground =
        permission == LocationPermission.denied ||
        permission == LocationPermission.unableToDetermine;
    final needBackground =
        _isAndroid &&
        permission != LocationPermission.always &&
        !(prefs.getBool(_prefBgDeclined) ?? false);
    final needNotifications =
        !(prefs.getBool(_prefNotifAsked) ?? false) &&
        !await _notificationsGranted();
    final needBattery =
        _isAndroid &&
        !(prefs.getBool(_prefBatteryAsked) ?? false) &&
        !await ArmForegroundService.isIgnoringBatteryOptimizations();

    if (!context.mounted) return const RidePermissionOutcome.cancelled();
    if (needForeground || needBackground || needNotifications || needBattery) {
      final l10n = context.l10n;
      final steps = <String>[
        if (needForeground && !_isIos) l10n.ridePermsStepLocation,
        if (needBackground) l10n.ridePermsStepBackground,
        if (needNotifications) l10n.ridePermsStepNotifications,
        if (needBattery) l10n.ridePermsStepBattery,
      ];
      final intro = _isIos && needForeground
          ? l10n.locationDisclosureBodyIos
          : l10n.ridePermsIntro;
      final body = [
        intro,
        for (var i = 0; i < steps.length; i++) '${i + 1}. ${steps[i]}',
      ].join('\n');

      final accepted = await _showDisclosure(
        context,
        title: l10n.locationDisclosureTitle,
        body: body,
        cancelLabel: needForeground ? l10n.cancel : l10n.notNow,
      );
      if (!accepted) {
        if (needForeground) return const RidePermissionOutcome.cancelled();
        // Location already works: remember the optional steps as declined
        // so the explainer does not come back on every start.
        if (needBackground) await prefs.setBool(_prefBgDeclined, true);
        if (needNotifications) await prefs.setBool(_prefNotifAsked, true);
        if (needBattery) await prefs.setBool(_prefBatteryAsked, true);
        if (!context.mounted) return const RidePermissionOutcome.granted();
        return _granted(context, permission);
      }

      // 1. Foreground location.
      if (needForeground) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.deniedForever) {
          if (context.mounted) await _showDeniedDialog(context);
          return const RidePermissionOutcome.failed(
            LocationPermissionDenyReason.deniedForever,
          );
        }
        if (permission != LocationPermission.whileInUse &&
            permission != LocationPermission.always) {
          return const RidePermissionOutcome.failed(
            LocationPermissionDenyReason.denied,
          );
        }
      }

      // 2. Android background location (Settings page on Android 11+).
      if (needBackground &&
          permission != LocationPermission.always &&
          context.mounted) {
        final go = await _showDisclosure(
          context,
          title: context.l10n.ridePermsBackgroundTitle,
          body: context.l10n.ridePermsBackgroundBody,
          cancelLabel: context.l10n.notNow,
          icon: Icons.lock_clock,
        );
        var always = false;
        if (go) always = await _location.requestAlwaysUpgrade();
        if (always) {
          permission = LocationPermission.always;
        } else {
          await prefs.setBool(_prefBgDeclined, true);
        }
      }

      // 3. Notifications (recording notification + rodada pushes).
      if (needNotifications) {
        await prefs.setBool(_prefNotifAsked, true);
        final status = await Permission.notification.request();
        if (status.isGranted) {
          unawaited(
            PushNotificationService.instance.onNotificationPermissionGranted(),
          );
        }
      }

      // 4. Android battery optimization (system dialog).
      if (needBattery) {
        await prefs.setBool(_prefBatteryAsked, true);
        try {
          await ArmForegroundService.requestIgnoreBatteryOptimizationIfNeeded();
        } catch (_) {}
      }
    }

    if (offerBackground && context.mounted) {
      await offerAlwaysIfUseful(context);
    }
    if (!context.mounted) return const RidePermissionOutcome.granted();
    return _granted(context, permission);
  }

  static Future<bool> _notificationsGranted() async {
    try {
      return await Permission.notification.isGranted;
    } catch (_) {
      return true;
    }
  }

  /// Foreground-only on Android: still record, warn once per app session.
  static RidePermissionOutcome _granted(
    BuildContext context,
    LocationPermission permission,
  ) {
    final limited = _isAndroid && permission != LocationPermission.always;
    if (limited && !_warnedLimited) {
      _warnedLimited = true;
      final l10n = context.l10n;
      showAppSnack(
        context,
        l10n.ridePermsBackgroundLimited,
        tone: AppToastTone.warning,
        actionLabel: l10n.locationOpenSettings,
        onAction: () => unawaited(openAppSettings()),
      );
    }
    return RidePermissionOutcome.granted(backgroundLimited: limited);
  }

  /// iOS step 2: offer "Always" once, with an explanation screen first.
  ///
  /// No-op on Android, when already "Always", when the user chose "Not now",
  /// or when iOS already showed its one-time upgrade prompt.
  static Future<void> offerAlwaysIfUseful(BuildContext context) async {
    if (!_isIos) return;
    final permission = await Geolocator.checkPermission();
    if (permission != LocationPermission.whileInUse) return;
    final prefs = await SharedPreferences.getInstance();
    if (prefs.getBool(_prefAlwaysNotNow) ?? false) return;
    if (prefs.getBool(_prefAlwaysAsked) ?? false) return;
    if (!context.mounted) return;

    final l10n = context.l10n;
    final go = await _showDisclosure(
      context,
      title: l10n.locationAlwaysTitle,
      body: l10n.locationAlwaysBody,
      cancelLabel: l10n.notNow,
      icon: Icons.lock_clock,
    );
    if (!go) {
      await prefs.setBool(_prefAlwaysNotNow, true);
      return;
    }
    await prefs.setBool(_prefAlwaysAsked, true);
    final granted = await _location.requestAlwaysUpgrade();
    if (granted || !context.mounted) return;
    await _showSettingsDialog(
      context,
      title: l10n.locationAlwaysDeclinedTitle,
      body: l10n.locationAlwaysDeclinedBody,
    );
  }

  /// While-in-use location for rodada En vivo (map + optional pack sharing).
  static Future<bool> requestForRodadaLive(BuildContext context) async {
    if (await hasWhileInUsePermission()) return true;
    if (!context.mounted) return false;

    final accepted = await _showDisclosure(
      context,
      title: context.l10n.locationRodadaLiveDisclosureTitle,
      body: context.l10n.locationRodadaLiveDisclosureBody,
    );
    if (!accepted || !context.mounted) return false;

    final permission = await Geolocator.requestPermission();
    return permission == LocationPermission.whileInUse ||
        permission == LocationPermission.always;
  }

  static Future<bool> hasWhileInUsePermission() async {
    if (!await Geolocator.isLocationServiceEnabled()) return false;
    final permission = await Geolocator.checkPermission();
    return permission == LocationPermission.whileInUse ||
        permission == LocationPermission.always;
  }

  static Future<void> _showDeniedDialog(BuildContext context) {
    final l10n = context.l10n;
    return _showSettingsDialog(
      context,
      title: l10n.locationDeniedTitle,
      body: _isIos ? l10n.locationDeniedBody : l10n.ridePermsDeniedBodyAndroid,
    );
  }

  /// Phone-wide location switch is off: offer the system location page.
  static Future<void> _showServicesOffDialog(BuildContext context) async {
    final l10n = context.l10n;
    final open = await _showDisclosure(
      context,
      title: l10n.ridePermsLocationOffTitle,
      body: l10n.locationServicesOff,
      cancelLabel: l10n.notNow,
      confirmLabel: l10n.locationOpenSettings,
      icon: Icons.location_off,
    );
    if (open) await Geolocator.openLocationSettings();
  }

  static Future<void> _showSettingsDialog(
    BuildContext context, {
    required String title,
    required String body,
  }) async {
    final l10n = context.l10n;
    final open = await _showDisclosure(
      context,
      title: title,
      body: body,
      cancelLabel: l10n.notNow,
      confirmLabel: l10n.locationOpenSettings,
      icon: Icons.location_off,
    );
    if (open) await openAppSettings();
  }

  static Future<bool> _showDisclosure(
    BuildContext context, {
    required String title,
    required String body,
    String? cancelLabel,
    String? confirmLabel,
    IconData icon = Icons.location_on,
  }) async {
    final l10n = context.l10n;
    final accepted = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      useRootNavigator: true,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppTheme.asphaltElevated,
        title: Row(
          children: [
            Icon(icon, color: AppTheme.line, size: 26),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                title,
                style: GoogleFonts.exo2(fontWeight: FontWeight.w800),
              ),
            ),
          ],
        ),
        content: SingleChildScrollView(
          child: Text(
            body,
            style: GoogleFonts.rajdhani(
              fontSize: 15,
              height: 1.45,
              color: AppTheme.mist,
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(cancelLabel ?? l10n.cancel),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(confirmLabel ?? l10n.locationDisclosureContinue),
          ),
        ],
      ),
    );
    return accepted == true;
  }
}
