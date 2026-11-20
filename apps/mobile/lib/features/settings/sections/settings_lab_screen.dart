import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/auth/impersonation_controller.dart';
import '../../../core/distribution.dart';
import '../../../core/notifications/push_diagnostics.dart';
import '../../../l10n/l10n_ext.dart';
import '../../../theme/app_theme.dart';
import '../../../widgets/app_snack.dart';
import '../../experimental/circuit_8h/circuit_8h_hub_screen.dart';
import '../../home/home_nav_icons.dart';
import '../../lean_lab/lean_imu_lab_screen.dart';
import '../../lean_lab/lean_lab_screen.dart';
import 'settings_section_common.dart';

/// Settings → Laboratorio (sideload or staff only): Circuito 8h, Lean Lab,
/// Lean IMU Lab, push diagnostics.
class SettingsLabScreen extends ConsumerStatefulWidget {
  const SettingsLabScreen({super.key});

  @override
  ConsumerState<SettingsLabScreen> createState() => _SettingsLabScreenState();
}

class _SettingsLabScreenState extends ConsumerState<SettingsLabScreen> {
  @override
  void initState() {
    super.initState();
    PushDiagnostics.hydrate().then((_) {
      if (mounted) setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final staff = ref.watch(impersonationProvider).staff;
    return SettingsSectionScaffold(
      title: l10n.settingsHubLab,
      help: l10n.labsSectionHelp,
      children: [
        // Experimental GPS / Circuito 8h lab: sideload pilots only, never
        // in Play or App Store builds.
        if (!AppDistribution.isStoreBuild)
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const Icon(Icons.alt_route, color: AppTheme.lineHot),
            title: Text(l10n.gpsTrackPointsLabTile, style: settingsTileTitle),
            subtitle: Text(l10n.gpsTrackPointsLabHelp, style: settingsTileSub),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => pushSettingsPage(context, const Circuit8hHubScreen()),
          ),
        ListTile(
          contentPadding: EdgeInsets.zero,
          leading: const AppMotoIcon(size: 28, color: AppTheme.line),
          title: Text(l10n.leanLabSettingsTile, style: settingsTileTitle),
          subtitle: Text(l10n.leanLabSettingsHelp, style: settingsTileSub),
          trailing: const Icon(Icons.chevron_right),
          onTap: () => pushSettingsPage(context, const LeanLabScreen()),
        ),
        ListTile(
          contentPadding: EdgeInsets.zero,
          leading: const Icon(Icons.sensors, color: AppTheme.lineHot),
          title: Text(l10n.leanImuLabSettingsTile, style: settingsTileTitle),
          subtitle: Text(l10n.leanImuLabSettingsHelp, style: settingsTileSub),
          trailing: const Icon(Icons.chevron_right),
          onTap: () => pushSettingsPage(context, const LeanImuLabScreen()),
        ),
        if (!AppDistribution.isStoreBuild || staff)
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const Icon(
              Icons.notifications_outlined,
              color: AppTheme.mist,
            ),
            title: Text(l10n.pushDiagnosticsTitle, style: settingsTileTitle),
            subtitle: SelectableText(
              PushDiagnostics.history.isEmpty
                  ? l10n.pushDiagnosticsEmpty
                  : PushDiagnostics.history.reversed.take(5).join('\n'),
              style: settingsTileSub,
            ),
            trailing: PushDiagnostics.history.isEmpty
                ? null
                : IconButton(
                    tooltip: l10n.pushDiagnosticsTitle,
                    icon: const Icon(Icons.copy, size: 18),
                    onPressed: () async {
                      await Clipboard.setData(
                        ClipboardData(text: PushDiagnostics.history.join('\n')),
                      );
                      if (!context.mounted) return;
                      showAppSnack(context, l10n.pushDiagnosticsCopied);
                    },
                  ),
          ),
      ],
    );
  }
}
