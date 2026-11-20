import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../l10n/l10n_ext.dart';
import '../../../theme/app_theme.dart';
import '../../../theme/ride_viz_palette.dart';

/// Compact one-line legend for the speed color scale: `0 ▬▬▬ 250 km/h`.
class SpeedColorLegend extends StatelessWidget {
  const SpeedColorLegend({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final style = GoogleFonts.rajdhani(
      fontSize: 11,
      height: 1,
      color: AppTheme.steel,
      fontWeight: FontWeight.w600,
    );
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text('0', style: style),
        const SizedBox(width: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(3),
          child: SizedBox(
            width: 96,
            height: 6,
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    for (final stop in RideVizPalette.speedStops) stop.$2,
                  ],
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: 6),
        Text(
          '${RideVizPalette.speedCapKmh.toStringAsFixed(0)} ${l10n.kmh}',
          style: style.copyWith(color: AppTheme.mist),
        ),
      ],
    );
  }
}
