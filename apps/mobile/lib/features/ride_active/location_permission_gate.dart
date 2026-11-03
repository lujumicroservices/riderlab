import 'dart:io' show Platform;

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:permission_handler/permission_handler.dart' show openAppSettings;
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/services/location_service.dart';
import '../../l10n/l10n_ext.dart';
import '../../theme/app_theme.dart';

/// Prominent disclosure before Android/iOS location permission prompts.
///
/// Same entry points on both platforms (Grabar, Armar auto, rodada, settings):
/// 1. Own disclosure → system prompt for foreground location.
///    Android: fine/coarse → notifications → background ("all the time").
///    iOS: "While Using" only.
/// 2. iOS only: "Always" is offered later, in context ([offerAlwaysIfUseful]):
///    when Armar auto is enabled or after a ride ends. Own explanation screen
///    first; "Not now" is remembered and never asked again automatically.
class LocationPermissionGate {
  LocationPermissionGate._();

  static final _location = LocationService();

  static const _prefAlwaysNotNow = 'ios_location_always_not_now';
  static const _prefAlwaysAsked = 'ios_location_always_asked';

  static bool get _isIos => !kIsWeb && Platform.isIOS;

  /// Shows disclosure (when needed) then requests location permissions for rides.
  ///
  /// [offerBackground]: iOS step 2 right after step 1 succeeds (Armar auto).
  static Future<bool> requestForRecording(
    BuildContext context, {
    bool offerBackground = false,
  }) async {
    if (await _location.hasRecordingPermission()) {
      if (offerBackground && context.mounted) {
        await offerAlwaysIfUseful(context);
      }
      return true;
    }
    if (!context.mounted) return false;

    if (_isIos &&
        await Geolocator.checkPermission() == LocationPermission.deniedForever) {
      // iOS will not show the system prompt again: explain and offer Settings.
      if (context.mounted) await _showDeniedDialog(context);
      return false;
    }
    if (!context.mounted) return false;

    final accepted = await _showDisclosure(
      context,
      title: context.l10n.locationDisclosureTitle,
      body: _isIos
          ? context.l10n.locationDisclosureBodyIos
          : context.l10n.locationDisclosureBody,
    );
    if (!accepted || !context.mounted) return false;

    final result = await _location.ensurePermission();
    if (!result.granted) return false;
    if (offerBackground && context.mounted) {
      await offerAlwaysIfUseful(context);
    }
    return true;
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
      body: l10n.locationDeniedBody,
    );
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
