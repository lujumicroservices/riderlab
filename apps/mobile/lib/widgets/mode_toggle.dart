import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../core/app_mode.dart';
import '../l10n/l10n_ext.dart';
import '../providers/ride_providers.dart';
import '../theme/app_theme.dart';
import '../theme/offroad_theme.dart';
import 'app_snack.dart';

/// Street / Track pill shown in the header of both home screens.
///
/// Locked while a ride is recording or the session is armed: switching mode
/// mid-session would swap the home underneath the live recorder.
class ModeToggle extends ConsumerWidget {
  const ModeToggle({super.key});

  /// Minimum touch height (glove-friendly).
  static const double minTouchHeight = 48;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final mode = ref.watch(appModeProvider);
    final armed = ref.watch(armedStateProvider);
    final recording = ref.watch(rideRecorderProvider).isRecording;
    final locked = armed || recording;
    final off = mode == AppMode.off;
    final accent = off ? OffroadTheme.track : AppTheme.signal;
    final current = off ? l10n.homeModeTrack : l10n.homeModeStreet;

    final pill = Container(
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: off ? OffroadTheme.panel : AppTheme.asphaltElevated,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: accent.withValues(alpha: 0.6)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _Segment(
            label: l10n.homeModeStreet,
            selected: !off,
            color: AppTheme.signal,
          ),
          _Segment(
            label: l10n.homeModeTrack,
            selected: off,
            color: OffroadTheme.track,
          ),
        ],
      ),
    );

    return Semantics(
      button: true,
      enabled: !locked,
      label: l10n.homeModeSemantics(current),
      hint: locked ? l10n.homeModeLockedHint : null,
      excludeSemantics: true,
      child: Tooltip(
        message: locked ? l10n.homeModeLockedHint : l10n.modeToggleSemantics,
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () {
            if (locked) {
              showAppSnack(context, l10n.homeModeLockedHint);
              return;
            }
            ref.read(appModeProvider.notifier).toggle();
          },
          child: ConstrainedBox(
            constraints: const BoxConstraints(minHeight: minTouchHeight),
            child: Center(
              widthFactor: 1,
              child: Opacity(opacity: locked ? 0.45 : 1, child: pill),
            ),
          ),
        ),
      ),
    );
  }
}

class _Segment extends StatelessWidget {
  const _Segment({
    required this.label,
    required this.selected,
    required this.color,
  });

  final String label;
  final bool selected;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 220),
      curve: Curves.easeOut,
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: selected ? color : Colors.transparent,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(
        label,
        style: GoogleFonts.rajdhani(
          fontSize: 14,
          fontWeight: FontWeight.w800,
          letterSpacing: 0.6,
          color: selected ? Colors.black : AppTheme.steel,
        ),
      ),
    );
  }
}
