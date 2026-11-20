import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../l10n/l10n_ext.dart';
import '../../providers/pro_entitlement_provider.dart';
import '../../theme/app_theme.dart';
import '../../theme/ride_viz_palette.dart';
import '../../widgets/pro_upsell.dart';

/// Commercial / Pro upsell banner shown over locked curva detail, etc.
class ProUpsellBanner extends ConsumerWidget {
  const ProUpsellBanner({
    super.key,
    required this.title,
    required this.body,
    this.compact = false,
  });

  final String title;
  final String body;
  final bool compact;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    return Material(
      color: Colors.transparent,
      elevation: 8,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.fromLTRB(
          16,
          compact ? 12 : 18,
          16,
          compact ? 12 : 18,
        ),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppTheme.asphaltElevated,
              RideVizPalette.leanLeft.withValues(alpha: 0.22),
              RideVizPalette.leanRight.withValues(alpha: 0.14),
            ],
          ),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: RideVizPalette.leanLeft.withValues(alpha: 0.5),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: RideVizPalette.leanRight.withValues(alpha: 0.95),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    l10n.pro,
                    style: GoogleFonts.exo2(
                      fontWeight: FontWeight.w800,
                      fontSize: 11,
                      color: AppTheme.asphalt,
                      letterSpacing: 0.8,
                    ),
                  ),
                ),
                const Spacer(),
                Icon(
                  Icons.lock_outline,
                  size: 18,
                  color: AppTheme.mist.withValues(alpha: 0.8),
                ),
              ],
            ),
            SizedBox(height: compact ? 8 : 12),
            Text(
              title,
              style: GoogleFonts.exo2(
                fontWeight: FontWeight.w700,
                fontSize: compact ? 16 : 18,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              body,
              style: GoogleFonts.rajdhani(
                color: AppTheme.steel,
                fontSize: 13,
                height: 1.35,
              ),
            ),
            SizedBox(height: compact ? 10 : 14),
            FilledButton(
              // The sheet shows price, plan and terms before any purchase.
              onPressed: () => showProUpsellSheet(context, ref),
              style: FilledButton.styleFrom(
                backgroundColor: RideVizPalette.leanLeft,
                foregroundColor: AppTheme.asphalt,
                minimumSize: Size.fromHeight(compact ? 44 : 48),
              ),
              child: Text(
                l10n.upgradeToPro,
                style: GoogleFonts.exo2(fontWeight: FontWeight.w700),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Free: a static, blurred and dimmed preview of [child] with a lock and the
/// Pro banner on top, from the first frame (no reveal-then-blur).
/// Pro: content stays fully open.
class ProTeaserGate extends ConsumerWidget {
  const ProTeaserGate({
    super.key,
    required this.child,
    required this.bannerTitle,
    required this.bannerBody,
    this.teaserMs = 0,
  });

  final Widget child;
  final String bannerTitle;
  final String bannerBody;

  /// Ignored: kept so existing callers compile. The lock shows immediately.
  final int teaserMs;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (ref.watch(isProProvider)) return child;

    return Stack(
      fit: StackFit.expand,
      children: [
        // Preview only: blurred, dimmed and not interactive.
        IgnorePointer(
          child: ExcludeSemantics(
            child: ImageFiltered(
              imageFilter: ImageFilter.blur(sigmaX: 6, sigmaY: 6),
              child: child,
            ),
          ),
        ),
        Positioned.fill(
          child: IgnorePointer(
            child: ColoredBox(color: AppTheme.asphalt.withValues(alpha: 0.55)),
          ),
        ),
        Positioned(
          left: 16,
          right: 16,
          top: 12,
          child: ProUpsellBanner(
            title: bannerTitle,
            body: bannerBody,
            compact: true,
          ),
        ),
      ],
    );
  }
}
