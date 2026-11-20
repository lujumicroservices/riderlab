import '../../l10n/app_localizations.dart';
import 'rodada_repository.dart';

String messageForInviteResult(AppLocalizations l10n, RodadaInviteResult r) {
  if (r.alreadyMember) return l10n.inviteAlreadyMember;
  if (r.pushDelivered) return l10n.inviteSent;
  if (r.skipped == 'no_tokens') return l10n.inviteSentNoToken;
  return l10n.inviteSentPushFailed(
    inviteFailureReason(l10n, r.error ?? r.skipped),
  );
}

String? messageForInviteBatch(
  AppLocalizations l10n,
  List<RodadaInviteResult> results,
) {
  if (results.isEmpty) return null;
  var sent = 0;
  var failed = 0;
  String? lastReason;
  for (final r in results) {
    if (r.alreadyMember) continue;
    if (r.pushDelivered) {
      sent++;
      continue;
    }
    failed++;
    lastReason = r.error ?? r.skipped;
  }
  if (failed == 0) {
    return sent == 0 ? null : l10n.invitePushAllOk(sent);
  }
  return l10n.invitePushSummary(
    sent,
    failed,
    inviteFailureReason(l10n, lastReason),
  );
}

/// Turns a raw edge-function / transport code into text a rider understands.
String inviteFailureReason(AppLocalizations l10n, String? code) {
  final c = (code ?? '').toLowerCase();
  if (c.startsWith('unauthorized') ||
      c.startsWith('forbidden') ||
      c == 'http 401' ||
      c == 'http 403') {
    return l10n.invitePushReasonSession;
  }
  if (c.startsWith('upstream_failed') ||
      c.startsWith('misconfigured') ||
      c.startsWith('bad_response') ||
      c.startsWith('http 5') ||
      c.contains('socket') ||
      c.contains('timeout') ||
      c.contains('clientexception')) {
    return l10n.invitePushReasonService;
  }
  return l10n.invitePushReasonUnknown;
}
