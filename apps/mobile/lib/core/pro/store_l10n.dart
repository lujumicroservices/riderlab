import 'package:flutter/widgets.dart';

/// Strings for the store paywall (App Store / Play subscriptions).
///
/// Kept outside the ARB files so they do not need `flutter gen-l10n`.
/// Move them into app_es.arb / app_en.arb on the next l10n pass.
class StoreL10n {
  const StoreL10n._(this._es);

  final bool _es;

  static StoreL10n of(BuildContext context) {
    final code = Localizations.maybeLocaleOf(context)?.languageCode ?? 'es';
    return StoreL10n._(code != 'en');
  }

  String get monthly => _es ? 'Mensual' : 'Monthly';
  String get yearly => _es ? 'Anual' : 'Yearly';
  String get bestValue => _es ? 'Mejor precio' : 'Best value';
  String perMonth(String price) => _es ? '$price / mes' : '$price / month';
  String perYear(String price) => _es ? '$price / año' : '$price / year';
  String get subscribe => _es ? 'Suscribirme a Pro' : 'Subscribe to Pro';
  String get loadingPlans =>
      _es ? 'Cargando planes…' : 'Loading plans…';
  String get plansUnavailable => _es
      ? 'No pudimos cargar los planes. Revisa tu conexión e intenta de nuevo.'
      : 'Could not load plans. Check your connection and try again.';
  String get redeemOfferCode =>
      _es ? 'Canjear código de oferta' : 'Redeem offer code';
  String get restore => _es ? 'Restaurar compras' : 'Restore purchases';
  String get restoredNone => _es
      ? 'No encontramos compras para restaurar.'
      : 'No purchases to restore.';
  String get terms => _es ? 'Términos de uso' : 'Terms of Use';
  String get privacy => _es ? 'Privacidad' : 'Privacy Policy';

  /// Required auto-renew disclosure (App Store guideline 3.1.2).
  String autoRenewDisclosure({required bool ios}) {
    final store = ios ? 'Apple ID' : 'Google Play';
    final manage = ios
        ? (_es
            ? 'Ajustes > tu nombre > Suscripciones'
            : 'Settings > your name > Subscriptions')
        : (_es ? 'Google Play > Pagos y suscripciones' : 'Google Play > Payments & subscriptions');
    return _es
        ? 'El pago se carga a tu cuenta de $store al confirmar. La suscripción '
            'se renueva automáticamente al mismo precio salvo que la canceles al '
            'menos 24 horas antes del fin del periodo. Adminístrala o cancélala en '
            '$manage.'
        : 'Payment is charged to your $store account at confirmation. The '
            'subscription renews automatically at the same price unless you '
            'cancel at least 24 hours before the end of the period. Manage or '
            'cancel it in $manage.';
  }

  /// Trial help without partner-code wording (iOS).
  String get trialHelpStore => _es
      ? 'Toda cuenta con sesión recibe 30 días de Pro gratis, sin tarjeta. '
          'Después, el detalle de Ride Lab es de pago.'
      : 'Every signed-in account gets 30 days of Pro free, no card needed. '
          'After that, Ride Lab depth is paid.';

  String get storeNotReady => _es
      ? 'La suscripción aún no está disponible. Entra con tu cuenta para '
          '30 días de Pro gratis.'
      : 'The subscription is not available yet. Sign in for a free 30-day '
          'Pro trial.';

  /// Store builds have no ads SDK: the Free strip promotes Pro, not ad removal.
  String get freeStripLabel => 'PRO';
  String get freeStripBody => _es
      ? 'Zoom de tramo, todas las frenadas y detalle de curva'
      : 'Stretch zoom, every brake event and corner detail';

  String get proHardwareTitle =>
      _es ? 'Hardware es Pro' : 'Hardware is Pro';
  String get proHardwareBody => _es
      ? 'El logger Métrica y el control de cámara (GoPro) son parte de Pro.'
      : 'The Métrica logger and camera (GoPro) control are part of Pro.';
}
