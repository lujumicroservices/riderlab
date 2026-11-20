import 'package:flutter_test/flutter_test.dart';
import 'package:motoline/features/rodadas/invite_push_feedback.dart';
import 'package:motoline/features/rodadas/rodada_repository.dart';
import 'package:motoline/l10n/app_localizations_es.dart';

void main() {
  final l10n = AppLocalizationsEs();

  test('raw edge-function codes become rider-facing reasons', () {
    expect(
      inviteFailureReason(l10n, 'unauthorized'),
      l10n.invitePushReasonSession,
    );
    expect(inviteFailureReason(l10n, 'http 403'), l10n.invitePushReasonSession);
    expect(
      inviteFailureReason(l10n, 'upstream_failed (fcm 500)'),
      l10n.invitePushReasonService,
    );
    expect(inviteFailureReason(l10n, 'http 502'), l10n.invitePushReasonService);
    expect(inviteFailureReason(l10n, null), l10n.invitePushReasonUnknown);
    expect(inviteFailureReason(l10n, 'weird'), l10n.invitePushReasonUnknown);
  });

  test('messages never show the raw code', () {
    final single = messageForInviteResult(
      l10n,
      const RodadaInviteResult(error: 'upstream_failed (fcm 500)'),
    );
    expect(single, isNot(contains('upstream_failed')));
    expect(single, contains(l10n.invitePushReasonService));

    final batch = messageForInviteBatch(l10n, const [
      RodadaInviteResult(sent: 1),
      RodadaInviteResult(error: 'unauthorized'),
    ]);
    expect(batch, isNot(contains('unauthorized')));
    expect(batch, contains(l10n.invitePushReasonSession));
  });

  test('no_tokens keeps its dedicated message', () {
    expect(
      messageForInviteResult(
        l10n,
        const RodadaInviteResult(skipped: 'no_tokens'),
      ),
      l10n.inviteSentNoToken,
    );
  });
}
