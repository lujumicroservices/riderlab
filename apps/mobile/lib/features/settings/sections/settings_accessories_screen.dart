import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/distribution.dart';
import '../../../core/pro/store_l10n.dart';
import '../../../l10n/l10n_ext.dart';
import '../../../providers/pro_entitlement_provider.dart';
import '../../../theme/app_theme.dart';
import '../../../widgets/pro_upsell.dart';
import '../../adventure_camera/widgets/adventure_camera_settings_section.dart';
import '../logger_hardware_screen.dart';
import 'settings_section_common.dart';

/// Settings → Accesorios: M5 Logger and adventure camera (GoPro).
class SettingsAccessoriesScreen extends ConsumerWidget {
  const SettingsAccessoriesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final isPro = ref.watch(isProProvider);
    return SettingsSectionScaffold(
      title: l10n.settingsHubAccessories,
      children: [
        if (AppDistribution.allowsMetricaLogger)
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const Icon(Icons.memory, color: AppTheme.lineHot),
            // Product name, not translated.
            title: Text('M5 Logger', style: settingsTileTitle),
            subtitle: Text(l10n.settingsHubM5LoggerSub, style: settingsTileSub),
            trailing: isPro
                ? const Icon(Icons.chevron_right)
                : const ProBadge(),
            onTap: () => openIfPro(
              context,
              ref,
              () => pushSettingsPage(context, const LoggerHardwareScreen()),
            ),
          ),
        if (isPro)
          const AdventureCameraSettingsSection()
        else
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const Icon(Icons.videocam_outlined),
            title: Text(
              StoreL10n.of(context).proHardwareTitle,
              style: settingsTileTitle,
            ),
            subtitle: Text(
              StoreL10n.of(context).proHardwareBody,
              style: settingsTileSub,
            ),
            trailing: const ProBadge(),
            onTap: () => showProUpsellSheet(context, ref),
          ),
      ],
    );
  }
}
