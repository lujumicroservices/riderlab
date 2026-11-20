import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../l10n/l10n_ext.dart';
import '../../../providers/locale_provider.dart';
import '../../../theme/ride_viz_palette.dart';
import 'settings_section_common.dart';

/// Settings → Idioma: Español / English.
class SettingsLanguageScreen extends ConsumerWidget {
  const SettingsLanguageScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final current = ref.watch(localeProvider).languageCode;
    final options = <(String, String)>[
      ('es', l10n.spanish),
      ('en', l10n.english),
    ];
    return SettingsSectionScaffold(
      title: l10n.language,
      children: [
        RadioGroup<String>(
          groupValue: current,
          onChanged: (code) {
            if (code == null) return;
            ref.read(localeProvider.notifier).setLocale(Locale(code));
          },
          child: Column(
            children: [
              for (final (code, label) in options)
                RadioListTile<String>(
                  contentPadding: EdgeInsets.zero,
                  value: code,
                  activeColor: RideVizPalette.leanLeft,
                  title: Text(label, style: settingsTileTitle),
                ),
            ],
          ),
        ),
      ],
    );
  }
}
