import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/auth/impersonation_controller.dart';
import '../../../core/lean_lab/lean_lab_service.dart';
import '../../../core/services/ride_sync_service.dart';
import '../../../l10n/l10n_ext.dart';
import '../../../providers/ride_providers.dart';
import '../../../widgets/app_snack.dart';
import 'settings_section_common.dart';

/// Last successful manual sync from Settings during this app session.
/// In-memory only (no persistence): cheap hint for the hub subtitle.
final settingsLastSyncProvider = StateProvider<DateTime?>((ref) => null);

String? settingsLastSyncLabel(BuildContext context, DateTime? at) {
  if (at == null) return null;
  final time = MaterialLocalizations.of(
    context,
  ).formatTimeOfDay(TimeOfDay.fromDateTime(at));
  return context.l10n.settingsHubLastSync(time);
}

/// Settings → Datos y sincronización.
class SettingsDataScreen extends ConsumerStatefulWidget {
  const SettingsDataScreen({super.key});

  @override
  ConsumerState<SettingsDataScreen> createState() => _SettingsDataScreenState();
}

class _SettingsDataScreenState extends ConsumerState<SettingsDataScreen> {
  bool _syncing = false;

  Future<void> _syncCloud() async {
    final l10n = context.l10n;
    if (ref.read(impersonationProvider).active) {
      showAppSnack(context, l10n.impersonateNoSync);
      return;
    }
    setState(() => _syncing = true);
    try {
      final sync = ref.read(rideSyncServiceProvider);
      final outbox = ref.read(syncOutboxServiceProvider);
      final drained = await outbox.drain(limit: 40);
      final result = await sync.syncAllCompletedRides();
      final combinedOk = drained.ok + result.ok;
      final combinedFail = drained.fail + result.fail;
      final pulled = await sync.pullMyCloudRides(
        policy: TrackPullPolicy.preferRicher,
      );
      final leanPulled = await LeanLabService.instance.pullMyCloudSessions();
      if (!mounted) return;
      final err = sync.lastSyncError ?? sync.lastPullError;
      if (err == null) {
        ref.read(settingsLastSyncProvider.notifier).state = DateTime.now();
      }
      final detail = err == null ? '' : '\n${l10n.userFacingError(err)}';
      showAppSnack(
        context,
        '${l10n.syncCloudRidesDone(combinedOk, combinedFail)} · '
        '${l10n.syncCloudRidesPulled(pulled, leanPulled)}'
        '$detail',
        duration: Duration(seconds: err == null ? 4 : 10),
      );
      ref.invalidate(ridesListProvider);
    } finally {
      if (mounted) setState(() => _syncing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final lastSync = settingsLastSyncLabel(
      context,
      ref.watch(settingsLastSyncProvider),
    );
    return SettingsSectionScaffold(
      title: l10n.settingsHubData,
      help: l10n.syncCloudRidesHelp,
      children: [
        const SizedBox(height: 8),
        FilledButton.icon(
          style: FilledButton.styleFrom(minimumSize: const Size(0, 48)),
          onPressed: _syncing || ref.watch(impersonationProvider).active
              ? null
              : _syncCloud,
          icon: _syncing
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Icon(Icons.cloud_upload_outlined),
          label: Text(_syncing ? '…' : l10n.syncCloudRides),
        ),
        if (lastSync != null) ...[
          const SizedBox(height: 10),
          Text(lastSync, style: settingsTileSub),
        ],
      ],
    );
  }
}
