import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:purchases_flutter/purchases_flutter.dart';

import '../core/distribution.dart';
import '../core/legal/legal_urls.dart';
import '../core/pro/store_l10n.dart';
import '../l10n/l10n_ext.dart';
import '../providers/pro_entitlement_provider.dart';
import '../theme/app_theme.dart';
import '../theme/ride_viz_palette.dart';
import 'partner_code_redeem.dart';
import 'app_snack.dart';

/// Runs [open] for Pro users; otherwise shows the Pro sheet.
/// Used for hardware features (Métrica logger, adventure camera).
void openIfPro(BuildContext context, WidgetRef ref, VoidCallback open) {
  if (ref.read(isProProvider)) {
    open();
  } else {
    showProUpsellSheet(context, ref);
  }
}

Future<void> showProUpsellSheet(BuildContext context, WidgetRef ref) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: AppTheme.asphaltElevated,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (ctx) => const _ProUpsellSheet(),
  );
}

class _ProUpsellSheet extends ConsumerStatefulWidget {
  const _ProUpsellSheet();

  @override
  ConsumerState<_ProUpsellSheet> createState() => _ProUpsellSheetState();
}

class _ProUpsellSheetState extends ConsumerState<_ProUpsellSheet> {
  Offering? _offering;
  Package? _selected;
  bool _loading = revenueCatConfigured;
  bool _busy = false;

  @override
  void initState() {
    super.initState();
    if (revenueCatConfigured) _loadOffering();
  }

  Future<void> _loadOffering() async {
    final offering =
        await ref.read(proEntitlementProvider.notifier).currentOffering();
    if (!mounted) return;
    setState(() {
      _offering = offering;
      // Yearly is the default choice (docs/FREE_VS_PRO.md).
      _selected = offering?.annual ??
          offering?.monthly ??
          offering?.availablePackages.firstOrNull;
      _loading = false;
    });
  }

  Future<void> _subscribe() async {
    final l10n = context.l10n;
    final notifier = ref.read(proEntitlementProvider.notifier);
    setState(() => _busy = true);
    final ok = _selected != null
        ? await notifier.purchasePackage(_selected!)
        : await notifier.purchasePro();
    if (!mounted) return;
    setState(() => _busy = false);
    if (ok) {
      Navigator.of(context).pop();
      showAppSnack(context, l10n.proUnlocked);
      return;
    }
    if (_offering == null) {
      showAppSnack(
        context,
        AppDistribution.allowsPartnerCodes
            ? l10n.proStoreNotReady
            : StoreL10n.of(context).storeNotReady,
      );
    }
  }

  Future<void> _restore() async {
    final s = StoreL10n.of(context);
    final l10n = context.l10n;
    setState(() => _busy = true);
    final ok = await ref.read(proEntitlementProvider.notifier).restorePurchases();
    if (!mounted) return;
    setState(() => _busy = false);
    showAppSnack(context, ok ? l10n.proUnlocked : s.restoredNone);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final s = StoreL10n.of(context);
    final status = ref.watch(proEntitlementProvider);
    final remaining = proRemainingLabel(l10n, status);
    final inset = MediaQuery.viewInsetsOf(context).bottom;
    final packages = <Package>[
      if (_offering?.annual != null) _offering!.annual!,
      if (_offering?.monthly != null) _offering!.monthly!,
    ];

    return SafeArea(
      child: Padding(
        padding: EdgeInsets.fromLTRB(24, 16, 24, 24 + inset),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppTheme.mist.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                l10n.proUnlock,
                style: GoogleFonts.barlowCondensed(
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                l10n.proUnlockBody,
                style: GoogleFonts.rajdhani(
                  color: AppTheme.steel,
                  fontSize: 15,
                  height: 1.4,
                ),
              ),
              if (remaining != null) ...[
                const SizedBox(height: 10),
                Text(
                  remaining,
                  style: GoogleFonts.rajdhani(
                    color: RideVizPalette.leanLeft,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
              if (status.expiredAfterGrant) ...[
                const SizedBox(height: 10),
                Text(
                  l10n.proExpiredKeepLab,
                  style: GoogleFonts.rajdhani(
                    color: AppTheme.signal,
                    fontSize: 14,
                    height: 1.35,
                  ),
                ),
              ],
              const SizedBox(height: 20),
              _FeatureRow(text: l10n.proFeatureSegment),
              const SizedBox(height: 10),
              _FeatureRow(text: l10n.proFeatureBrakes),
              const SizedBox(height: 10),
              _FeatureRow(text: l10n.proFeatureCurva),
              const SizedBox(height: 10),
              _FeatureRow(text: s.proHardwareBody),
              const SizedBox(height: 24),
              if (status.isPaid)
                Text(
                  l10n.proUnlocked,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.rajdhani(
                    color: RideVizPalette.leanLeft,
                    fontWeight: FontWeight.w700,
                  ),
                )
              else ...[
                if (_loading)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    child: Text(
                      s.loadingPlans,
                      textAlign: TextAlign.center,
                      style: GoogleFonts.rajdhani(color: AppTheme.steel),
                    ),
                  )
                else if (revenueCatConfigured && packages.isEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Text(
                      s.plansUnavailable,
                      textAlign: TextAlign.center,
                      style: GoogleFonts.rajdhani(color: AppTheme.signal),
                    ),
                  ),
                for (final p in packages) ...[
                  _PlanTile(
                    package: p,
                    selected: identical(p, _selected),
                    onTap: () => setState(() => _selected = p),
                  ),
                  const SizedBox(height: 10),
                ],
                const SizedBox(height: 6),
                FilledButton(
                  onPressed: _busy || _loading ? null : _subscribe,
                  child: Text(
                    packages.isNotEmpty ? s.subscribe : l10n.upgradeToPro,
                  ),
                ),
                if (revenueCatConfigured) ...[
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: TextButton(
                          onPressed: _busy ? null : _restore,
                          child: Text(s.restore),
                        ),
                      ),
                      if (AppDistribution.allowsOfferCodes)
                        Expanded(
                          child: TextButton(
                            onPressed: _busy
                                ? null
                                : () => ref
                                    .read(proEntitlementProvider.notifier)
                                    .presentOfferCodeRedemption(),
                            child: Text(s.redeemOfferCode),
                          ),
                        ),
                    ],
                  ),
                ],
                if (packages.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Text(
                    s.autoRenewDisclosure(ios: AppDistribution.isAppStore),
                    textAlign: TextAlign.center,
                    style: GoogleFonts.rajdhani(
                      color: AppTheme.steel,
                      fontSize: 11.5,
                      height: 1.35,
                    ),
                  ),
                ],
                if (AppDistribution.allowsPartnerCodes) ...[
                  const SizedBox(height: 16),
                  Text(
                    l10n.havePartnerCode,
                    style: GoogleFonts.rajdhani(fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 8),
                  const PartnerCodeRedeemField(compact: true),
                ],
                const SizedBox(height: 8),
                Text(
                  AppDistribution.allowsPartnerCodes
                      ? l10n.startTrialHelp
                      : s.trialHelpStore,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.rajdhani(
                    color: AppTheme.steel,
                    fontSize: 12,
                  ),
                ),
              ],
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  TextButton(
                    onPressed: () =>
                        openLegalUrlOrSnack(context, LegalUrls.terms),
                    child: Text(s.terms),
                  ),
                  Text('·', style: GoogleFonts.rajdhani(color: AppTheme.steel)),
                  TextButton(
                    onPressed: () =>
                        openLegalUrlOrSnack(context, LegalUrls.privacy),
                    child: Text(s.privacy),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PlanTile extends StatelessWidget {
  const _PlanTile({
    required this.package,
    required this.selected,
    required this.onTap,
  });

  final Package package;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final s = StoreL10n.of(context);
    final yearly = package.packageType == PackageType.annual;
    final price = package.storeProduct.priceString;
    final accent = RideVizPalette.leanLeft;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: selected ? accent : AppTheme.mist.withValues(alpha: 0.2),
            width: selected ? 2 : 1,
          ),
          color: selected ? accent.withValues(alpha: 0.08) : null,
        ),
        child: Row(
          children: [
            Icon(
              selected ? Icons.radio_button_checked : Icons.radio_button_off,
              color: selected ? accent : AppTheme.steel,
              size: 20,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    yearly ? s.yearly : s.monthly,
                    style: GoogleFonts.exo2(fontWeight: FontWeight.w700),
                  ),
                  Text(
                    yearly ? s.perYear(price) : s.perMonth(price),
                    style: GoogleFonts.rajdhani(
                      color: AppTheme.steel,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
            if (yearly)
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: accent.withValues(alpha: 0.18),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  s.bestValue,
                  style: GoogleFonts.rajdhani(
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    color: accent,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _FeatureRow extends StatelessWidget {
  const _FeatureRow({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(Icons.check_circle, size: 20, color: RideVizPalette.leanLeft),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            text,
            style: GoogleFonts.rajdhani(fontSize: 14, height: 1.35),
          ),
        ),
      ],
    );
  }
}

/// Compact lock chip used on gated sections.
class ProBadge extends StatelessWidget {
  const ProBadge({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: RideVizPalette.leanLeft.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(
          color: RideVizPalette.leanLeft.withValues(alpha: 0.4),
        ),
      ),
      child: Text(
        l10n.pro,
        style: GoogleFonts.rajdhani(
          fontSize: 10,
          fontWeight: FontWeight.w800,
          letterSpacing: 1.0,
          color: RideVizPalette.leanLeft,
        ),
      ),
    );
  }
}
