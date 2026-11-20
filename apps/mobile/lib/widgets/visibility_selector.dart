import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/models/share_visibility.dart';
import '../../l10n/l10n_ext.dart';
import '../../l10n/share_visibility_l10n.dart';
import '../../theme/app_theme.dart';

/// Fast 3-way visibility control (Solo yo / Amigos / Todos).
class VisibilitySelector extends StatelessWidget {
  const VisibilitySelector({
    super.key,
    required this.value,
    required this.onChanged,
    this.dense = false,
  });

  final ShareVisibility value;
  final ValueChanged<ShareVisibility> onChanged;
  final bool dense;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SegmentedButton<ShareVisibility>(
          segments: [
            for (final v in ShareVisibility.values)
              ButtonSegment(
                value: v,
                label: Text(
                  l10n.visibilityOptionLabel(v),
                  style: GoogleFonts.exo2(fontSize: dense ? 11 : 12),
                ),
                tooltip: l10n.visibilityOptionHelp(v),
              ),
          ],
          selected: {value},
          onSelectionChanged: (set) {
            if (set.isEmpty) return;
            onChanged(set.first);
          },
          style: ButtonStyle(
            visualDensity: dense
                ? VisualDensity.compact
                : VisualDensity.standard,
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
        ),
        if (!dense) ...[
          const SizedBox(height: 6),
          Text(
            l10n.visibilityOptionHelp(value),
            style: GoogleFonts.rajdhani(color: AppTheme.steel, fontSize: 12),
          ),
        ],
      ],
    );
  }
}
