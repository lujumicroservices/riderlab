import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/app_mode.dart';
import '../../../core/auth/impersonation_controller.dart';
import '../../../core/distribution.dart';
import '../../../l10n/l10n_ext.dart';
import '../../../providers/force_start_prefs.dart';
import '../../../theme/app_theme.dart';
import '../../../theme/ride_viz_palette.dart';
import 'settings_section_common.dart';

/// Settings → Grabación: mode sound and (field tool) force-start toggle.
class SettingsRecordingScreen extends ConsumerWidget {
  const SettingsRecordingScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final showForceStart =
        !AppDistribution.isStoreBuild || ref.watch(impersonationProvider).staff;

    return SettingsSectionScaffold(
      title: l10n.settingsHubRecording,
      children: [
        SwitchListTile(
          contentPadding: EdgeInsets.zero,
          secondary: const Icon(Icons.volume_up_rounded, color: AppTheme.mist),
          title: Text(l10n.settingsModeSound, style: settingsTileTitle),
          subtitle: Text(l10n.settingsModeSoundHelp, style: settingsTileSub),
          value: ref.watch(modeSoundEnabledProvider),
          activeThumbColor: RideVizPalette.leanLeft,
          onChanged: (v) => ref.read(modeSoundEnabledProvider.notifier).set(v),
        ),
        if (showForceStart)
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            secondary: const Icon(
              Icons.play_circle_outline,
              color: AppTheme.mist,
            ),
            title: Text(l10n.showForceStartArmed, style: settingsTileTitle),
            subtitle: Text(
              l10n.showForceStartArmedHelp,
              style: settingsTileSub,
            ),
            value: ref.watch(forceStartArmedVisibleProvider),
            activeThumbColor: RideVizPalette.leanLeft,
            onChanged: (v) =>
                ref.read(forceStartArmedVisibleProvider.notifier).setVisible(v),
          ),
      ],
    );
  }
}
