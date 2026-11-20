import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/distribution.dart';
import '../../../core/pro/pro_entitlement.dart';
import '../../../core/pro/store_l10n.dart';
import '../../../l10n/l10n_ext.dart';
import '../../../providers/pro_entitlement_provider.dart';
import '../../../theme/app_theme.dart';
import '../../../theme/ride_viz_palette.dart';
import '../../../widgets/partner_code_redeem.dart';
import '../../../widgets/pro_upsell.dart';
import 'settings_section_common.dart';

/// Hub subtitle for the Pro row: "Plan gratis", partner days left, or
/// "Activo hasta …".
String settingsProStatusLabel(
  BuildContext context,
  AppLocalizations l10n,
  ProEntitlementStatus pro,
  bool isPro,
) {
  if (!isPro) return l10n.settingsHubProFree;
  final remaining = proRemainingLabel(l10n, pro);
  if (remaining != null) return remaining;
  final ends = pro.endsAt;
  if (ends != null) {
    final date = MaterialLocalizations.of(
      context,
    ).formatMediumDate(ends.toLocal());
    return l10n.settingsHubProActiveUntil(date);
  }
  return l10n.settingsHubProActive;
}

/// Settings → RiderLab Pro: status, partner/offer codes, restore, upgrade.
class SettingsProScreen extends ConsumerWidget {
  const SettingsProScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final isPro = ref.watch(isProProvider);
    final pro = ref.watch(proEntitlementProvider);
    final remaining = proRemainingLabel(l10n, pro);
    // Store builds always offer Restore; without RevenueCat it explains why.
    final showRestore = revenueCatConfigured || AppDistribution.isStoreBuild;

    return SettingsSectionScaffold(
      title: l10n.proUnlock,
      children: [
        Text(
          l10n.proUnlockBody,
          style: GoogleFonts.rajdhani(
            color: AppTheme.steel,
            fontSize: 14,
            height: 1.4,
          ),
        ),
        if (remaining != null) ...[
          const SizedBox(height: 8),
          Text(
            remaining,
            style: GoogleFonts.rajdhani(
              color: RideVizPalette.leanLeft,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
        if (pro.expiredAfterGrant) ...[
          const SizedBox(height: 8),
          Text(
            l10n.proExpiredKeepLab,
            style: GoogleFonts.rajdhani(
              color: AppTheme.signal,
              fontSize: 13,
              height: 1.35,
            ),
          ),
        ],
        const SizedBox(height: 16),
        if (!isPro)
          FilledButton(
            style: FilledButton.styleFrom(minimumSize: const Size(0, 48)),
            onPressed: () => showProUpsellSheet(context, ref),
            child: Text(l10n.upgradeToPro),
          )
        else
          Row(
            children: [
              Icon(Icons.verified, color: RideVizPalette.leanLeft, size: 18),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  settingsProStatusLabel(context, l10n, pro, isPro),
                  style: GoogleFonts.rajdhani(
                    color: RideVizPalette.leanLeft,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        const SizedBox(height: 12),
        if (allowLocalProToggle)
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: Text(l10n.proToggleDev, style: settingsTileTitle),
            subtitle: Text(l10n.proToggleHelp, style: settingsTileSub),
            value: isPro,
            activeThumbColor: RideVizPalette.leanLeft,
            onChanged: (v) =>
                ref.read(proEntitlementProvider.notifier).setPro(v),
          ),
        if (showRestore)
          OutlinedButton(
            style: OutlinedButton.styleFrom(minimumSize: const Size(0, 48)),
            onPressed: () => restoreProPurchases(context, ref),
            child: Text(l10n.restorePurchases),
          ),
        if (revenueCatConfigured && AppDistribution.allowsOfferCodes)
          TextButton(
            style: TextButton.styleFrom(minimumSize: const Size(0, 48)),
            onPressed: () => ref
                .read(proEntitlementProvider.notifier)
                .presentOfferCodeRedemption(),
            child: Text(StoreL10n.of(context).redeemOfferCode),
          ),
        if (AppDistribution.allowsPartnerCodes) ...[
          const SizedBox(height: 8),
          const PartnerCodeRedeemField(),
        ],
      ],
    );
  }
}
