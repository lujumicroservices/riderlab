import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/app_build_info.dart';
import '../../core/app_mode.dart';
import '../../core/auth/impersonation_controller.dart';
import '../../core/distribution.dart';
import '../../l10n/l10n_ext.dart';
import '../../providers/alias_provider.dart';
import '../../providers/auth_providers.dart';
import '../../providers/locale_provider.dart';
import '../../providers/pro_entitlement_provider.dart';
import '../../providers/rodada_share_prefs.dart';
import '../../theme/app_theme.dart';
import '../../theme/ride_viz_palette.dart';
import '../../widgets/app_snack.dart';
import '../../widgets/pro_upsell.dart';
import 'sections/settings_accessories_screen.dart';
import 'sections/settings_account_screen.dart';
import 'sections/settings_data_screen.dart';
import 'sections/settings_lab_screen.dart';
import 'sections/settings_language_screen.dart';
import 'sections/settings_legal_screen.dart';
import 'sections/settings_pro_screen.dart';
import 'sections/settings_recording_screen.dart';
import 'sections/settings_rodadas_screen.dart';
import 'sections/settings_section_common.dart';
import 'sections/settings_staff_screen.dart';

/// Settings hub: profile card + one row per section (each opens its own
/// screen in `sections/`), so every option is at most two taps away.
class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final isPro = ref.watch(isProProvider);
    final pro = ref.watch(proEntitlementProvider);
    final locale = ref.watch(localeProvider);
    final share = ref.watch(rodadaSharePrefsProvider);
    final soundOn = ref.watch(modeSoundEnabledProvider);
    final imp = ref.watch(impersonationProvider);
    final lastSync = settingsLastSyncLabel(
      context,
      ref.watch(settingsLastSyncProvider),
    );
    final showLab = !AppDistribution.isStoreBuild || imp.staff;
    final showStaff = settingsStaffVisible(imp);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.settings)),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
        children: [
          const _ProfileCard(),
          const SizedBox(height: 12),
          SettingsNavRow(
            icon: Icons.workspace_premium_outlined,
            iconColor: RideVizPalette.leanLeft,
            title: l10n.proUnlock,
            subtitle: settingsProStatusLabel(context, l10n, pro, isPro),
            onTap: () => pushSettingsPage(context, const SettingsProScreen()),
          ),
          SettingsNavRow(
            icon: Icons.fiber_manual_record_outlined,
            title: l10n.settingsHubRecording,
            subtitle: soundOn
                ? l10n.settingsHubSoundOn
                : l10n.settingsHubSoundOff,
            onTap: () =>
                pushSettingsPage(context, const SettingsRecordingScreen()),
          ),
          SettingsNavRow(
            icon: Icons.groups_outlined,
            title: l10n.settingsHubRodadas,
            subtitle: share.shareLive
                ? l10n.settingsHubShareLiveOn
                : l10n.settingsHubShareLiveOff,
            onTap: () =>
                pushSettingsPage(context, const SettingsRodadasScreen()),
          ),
          SettingsNavRow(
            icon: Icons.cloud_sync_outlined,
            title: l10n.settingsHubData,
            subtitle: lastSync ?? l10n.settingsHubDataSub,
            onTap: () => pushSettingsPage(context, const SettingsDataScreen()),
          ),
          SettingsNavRow(
            icon: Icons.translate,
            title: l10n.language,
            subtitle: locale.languageCode == 'es' ? l10n.spanish : l10n.english,
            onTap: () =>
                pushSettingsPage(context, const SettingsLanguageScreen()),
          ),
          SettingsNavRow(
            icon: Icons.videocam_outlined,
            title: l10n.settingsHubAccessories,
            subtitle: AppDistribution.allowsMetricaLogger
                ? l10n.settingsHubAccessoriesSub
                : l10n.settingsHubAccessoriesSubCameraOnly,
            trailing: isPro ? null : const ProBadge(),
            onTap: () =>
                pushSettingsPage(context, const SettingsAccessoriesScreen()),
          ),
          SettingsNavRow(
            icon: Icons.gavel_outlined,
            title: l10n.settingsHubLegal,
            subtitle: l10n.settingsHubLegalSub,
            onTap: () => pushSettingsPage(context, const SettingsLegalScreen()),
          ),
          if (showLab)
            SettingsNavRow(
              icon: Icons.science_outlined,
              iconColor: AppTheme.lineHot,
              title: l10n.settingsHubLab,
              subtitle: l10n.settingsHubLabSub,
              onTap: () => pushSettingsPage(context, const SettingsLabScreen()),
            ),
          if (showStaff)
            SettingsNavRow(
              icon: Icons.admin_panel_settings_outlined,
              iconColor: AppTheme.signal,
              title: l10n.settingsHubStaff,
              subtitle: l10n.settingsHubStaffSub,
              onTap: () =>
                  pushSettingsPage(context, const SettingsStaffScreen()),
            ),
          const SizedBox(height: 24),
          const _VersionFooter(),
        ],
      ),
    );
  }
}

/// Alias, email and Free/Pro chip. Tapping opens Cuenta.
class _ProfileCard extends ConsumerWidget {
  const _ProfileCard();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final alias = ref.watch(riderAliasProvider).trim();
    final auth = ref.watch(authServiceProvider);
    final signedIn = ref.watch(hasPermanentIdentityProvider);
    final isPro = ref.watch(isProProvider);
    final authLabel = auth.displayLabel?.trim();
    final email = auth.currentUser?.email;

    final name = alias.isNotEmpty
        ? alias
        : (authLabel != null && authLabel.isNotEmpty
              ? authLabel
              : (signedIn
                    ? l10n.accountSignedIn
                    : l10n.settingsHubProfileGuest));
    final secondLine = !signedIn
        ? l10n.settingsHubProfileSignInHint
        : (email != null && email.isNotEmpty ? email : null);
    final initial = name.isNotEmpty
        ? String.fromCharCode(name.runes.first).toUpperCase()
        : '?';

    return Material(
      color: AppTheme.asphaltElevated,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: () => pushSettingsPage(context, const SettingsAccountScreen()),
        child: Container(
          constraints: const BoxConstraints(minHeight: 72),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: signedIn
                  ? AppTheme.line.withValues(alpha: 0.35)
                  : AppTheme.mist.withValues(alpha: 0.08),
            ),
          ),
          child: Row(
            children: [
              CircleAvatar(
                radius: 22,
                backgroundColor: AppTheme.asphalt,
                child: Text(
                  initial,
                  style: GoogleFonts.exo2(
                    fontWeight: FontWeight.w800,
                    fontSize: 18,
                    color: AppTheme.mist,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.exo2(
                        fontWeight: FontWeight.w700,
                        fontSize: 16,
                      ),
                    ),
                    if (secondLine != null)
                      Text(
                        secondLine,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.rajdhani(
                          color: AppTheme.steel,
                          fontSize: 13,
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              _PlanChip(isPro: isPro),
              const Icon(Icons.chevron_right),
            ],
          ),
        ),
      ),
    );
  }
}

class _PlanChip extends StatelessWidget {
  const _PlanChip({required this.isPro});

  final bool isPro;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final color = isPro ? RideVizPalette.leanLeft : AppTheme.steel;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.6)),
        color: color.withValues(alpha: 0.12),
      ),
      child: Text(
        isPro ? l10n.settingsHubChipPro : l10n.settingsHubChipFree,
        style: GoogleFonts.rajdhani(
          color: color,
          fontWeight: FontWeight.w700,
          fontSize: 13,
        ),
      ),
    );
  }
}

/// Small version line at the bottom of the hub; tap the icon to copy it.
class _VersionFooter extends ConsumerWidget {
  const _VersionFooter();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final info = ref.watch(appBuildInfoProvider).valueOrNull;
    final line = info?.fullLine;
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Flexible(
          child: Text(
            line == null
                ? l10n.appVersionTitle
                : '${l10n.appVersionTitle} $line',
            textAlign: TextAlign.center,
            style: GoogleFonts.rajdhani(color: AppTheme.steel, fontSize: 12),
          ),
        ),
        if (line != null)
          IconButton(
            tooltip: l10n.appVersionCopy,
            icon: const Icon(Icons.copy, size: 16, color: AppTheme.steel),
            onPressed: () async {
              await Clipboard.setData(ClipboardData(text: line));
              if (!context.mounted) return;
              showAppSnack(context, l10n.appVersionCopied);
            },
          ),
      ],
    );
  }
}
