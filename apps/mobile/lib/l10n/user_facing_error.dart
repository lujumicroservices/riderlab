import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:supabase_flutter/supabase_flutter.dart';

import '../core/services/location_service.dart';
import 'app_localizations.dart';
import 'gps_warmup_l10n.dart';

/// Turns any thrown error into a short, localized message for snackbars,
/// dialogs and error states. The raw error always goes to [debugPrint] so
/// nothing is lost for debugging; the UI never shows `Exception: …` text.
extension UserFacingErrorL10n on AppLocalizations {
  String userFacingError(Object error) {
    // Plain strings are messages we already chose (e.g. AuthException.message
    // stored in a provider); only translate the ones that look technical.
    if (error is String) return _fromText(error, passThrough: true);
    debugPrint('[userFacingError] ${error.runtimeType}: $error');

    if (error is LocationDeniedException) {
      return locationDeniedText(error.reason);
    }
    if (error is TimeoutException) return errTimeout;
    if (error is SocketException ||
        error is HandshakeException ||
        error is HttpException ||
        error is http.ClientException ||
        error is AuthRetryableFetchException) {
      return errNoConnection;
    }
    if (error is PlatformException) {
      final code = error.code.toLowerCase();
      if (code.contains('permission') || code.contains('denied')) {
        return errPermissionDenied;
      }
    }
    if (error is PostgrestException) {
      final code = error.code ?? '';
      if (code == 'PGRST116') return errNotFound;
      if (code == '42501' || code == 'PGRST301') return errNotAllowed;
      if (code == 'PGRST303') return errSessionExpired;
    }
    if (error is FunctionException) {
      final status = error.status;
      if (status == 401) return errSignInRequired;
      if (status == 403) return errNotAllowed;
      if (status == 404) return errNotFound;
      if (status >= 500) return errServer;
    }
    if (error is StorageException) {
      final status = error.statusCode ?? '';
      if (status == '401') return errSignInRequired;
      if (status == '403') return errNotAllowed;
      if (status == '404') return errNotFound;
    }
    if (error is AuthException) {
      return _fromText(error.message, passThrough: true);
    }
    return _fromText('$error', passThrough: false);
  }

  String _fromText(String raw, {required bool passThrough}) {
    final text = raw.trim();
    final lower = text.toLowerCase();
    if (text.contains('Rolling to next lap')) return gpsRollingNextLap;
    if (lower.contains('socketexception') ||
        lower.contains('failed host lookup') ||
        lower.contains('network is unreachable') ||
        lower.contains('connection refused') ||
        lower.contains('connection reset') ||
        lower.contains('connection closed') ||
        lower.contains('clientexception') ||
        lower.contains('handshakeexception')) {
      return errNoConnection;
    }
    if (lower.contains('timeoutexception') || lower.contains('timed out')) {
      return errTimeout;
    }
    if (lower.contains('jwt expired') || lower.contains('session expired')) {
      return errSessionExpired;
    }
    if (lower.contains('not signed in') || lower.contains('missing staff')) {
      return errSignInRequired;
    }
    if (lower.contains('supabase not ready') ||
        lower.contains('cloud is not configured')) {
      return cloudUnavailable;
    }
    if (lower.contains('a ride is already recording')) {
      return errRideAlreadyRecording;
    }
    if (lower.contains('could not start background gps')) {
      return errArmBackgroundGps;
    }
    if (lower.contains('a ride is already starting')) {
      return errRideAlreadyRecording;
    }
    if (lower.contains('viewing as another rider')) {
      return errRecordingWhileImpersonating;
    }
    if (lower.contains('row-level security') ||
        lower.contains('permission denied for')) {
      return errNotAllowed;
    }
    if (lower.contains('permission')) return errPermissionDenied;
    if (lower.contains('not found')) return errNotFound;
    if (passThrough && text.isNotEmpty && !_looksTechnical(text)) return text;
    return errGeneric;
  }

  static final _technical = RegExp(
    r'^(\w+(Exception|Error)\b|Bad state:|Invalid argument|Null check|'
    r'type .* is not a subtype|http \d{3})',
  );

  bool _looksTechnical(String text) => _technical.hasMatch(text);
}
