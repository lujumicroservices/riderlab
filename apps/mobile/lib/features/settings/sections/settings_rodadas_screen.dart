import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../l10n/l10n_ext.dart';
import '../../../providers/rodada_share_prefs.dart';
import '../../../theme/app_theme.dart';
import '../../../theme/ride_viz_palette.dart';
import '../../ride_active/location_permission_gate.dart';
import '../../rodadas/rodada_providers.dart';
import '../../watch/family_circle_screen.dart';
import 'settings_section_common.dart';

/// Settings → Rodadas y privacidad: share switches + family link.
class SettingsRodadasScreen extends ConsumerWidget {
  const SettingsRodadasScreen({super.key});

  Future<void> _pushShareToRodadas(WidgetRef ref) async {
    await syncShareSettingsToOpenRodadas(
      repo: ref.read(rodadaRepositoryProvider),
      settings: ref.read(rodadaSharePrefsProvider),
    );
    ref.invalidate(myRodadasProvider);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final share = ref.watch(rodadaSharePrefsProvider);

    return SettingsSectionScaffold(
      title: l10n.settingsHubRodadas,
      help: l10n.settingsHubShareHelp,
      children: [
        SwitchListTile(
          contentPadding: EdgeInsets.zero,
          title: Text(l10n.autoArmOnRodadaStart, style: settingsTileTitle),
          subtitle: Text(l10n.autoArmOnRodadaStartHelp, style: settingsTileSub),
          value: share.autoArmOnStart,
          activeThumbColor: RideVizPalette.leanLeft,
          onChanged: (v) async {
            if (v) {
              final ok = await LocationPermissionGate.requestForRecording(
                context,
                offerBackground: true,
              );
              if (!ok || !context.mounted) return;
            }
            await ref
                .read(rodadaSharePrefsProvider.notifier)
                .setAutoArmOnStart(v);
            await _pushShareToRodadas(ref);
          },
        ),
        SwitchListTile(
          contentPadding: EdgeInsets.zero,
          title: Text(l10n.shareLocationOnRoute, style: settingsTileTitle),
          subtitle: Text(l10n.shareLocationEvery5Min, style: settingsTileSub),
          value: share.shareLive,
          activeThumbColor: RideVizPalette.leanLeft,
          onChanged: (v) async {
            if (v) {
              final ok = await LocationPermissionGate.requestForRodadaLive(
                context,
              );
              if (!ok || !context.mounted) return;
            }
            await ref.read(rodadaSharePrefsProvider.notifier).setShareLive(v);
            await _pushShareToRodadas(ref);
          },
        ),
        SwitchListTile(
          contentPadding: EdgeInsets.zero,
          title: Text(l10n.autoShareFamilyOnRodada, style: settingsTileTitle),
          subtitle: Text(
            l10n.autoShareFamilyOnRodadaHelp,
            style: settingsTileSub,
          ),
          value: share.autoShareFamily,
          activeThumbColor: RideVizPalette.leanLeft,
          onChanged: (v) async {
            if (v) {
              final ok = await LocationPermissionGate.requestForRodadaLive(
                context,
              );
              if (!ok || !context.mounted) return;
            }
            await ref
                .read(rodadaSharePrefsProvider.notifier)
                .setAutoShareFamily(v);
            await _pushShareToRodadas(ref);
          },
        ),
        SwitchListTile(
          contentPadding: EdgeInsets.zero,
          title: Text(l10n.shareTrackAfterRides, style: settingsTileTitle),
          value: share.shareTrack,
          activeThumbColor: RideVizPalette.leanLeft,
          onChanged: (v) async {
            await ref.read(rodadaSharePrefsProvider.notifier).setShareTrack(v);
            await _pushShareToRodadas(ref);
          },
        ),
        const SizedBox(height: 8),
        ListTile(
          contentPadding: EdgeInsets.zero,
          leading: const Icon(Icons.favorite, color: AppTheme.lineHot),
          title: Text(l10n.familyRodadaTipTitle, style: settingsTileTitle),
          subtitle: Text(
            l10n.settingsHubFamilyLinkBody,
            style: settingsTileSub,
          ),
          trailing: const Icon(Icons.chevron_right),
          onTap: () => pushSettingsPage(context, const FamilyCircleScreen()),
        ),
      ],
    );
  }
}
