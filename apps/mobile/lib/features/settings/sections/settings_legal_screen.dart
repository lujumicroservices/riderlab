import 'package:flutter/material.dart';

import '../../../core/legal/legal_urls.dart';
import '../../../l10n/l10n_ext.dart';
import '../../../theme/app_theme.dart';
import '../../moderation/content_guidelines.dart';
import '../widgets/app_version_tile.dart';
import 'settings_section_common.dart';

/// Settings → Legal y ayuda: terms, privacy, community guidelines, version.
class SettingsLegalScreen extends StatelessWidget {
  const SettingsLegalScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return SettingsSectionScaffold(
      title: l10n.settingsHubLegal,
      children: [
        ListTile(
          contentPadding: EdgeInsets.zero,
          leading: const Icon(Icons.description_outlined, color: AppTheme.line),
          title: Text(l10n.termsTitle, style: settingsTileTitle),
          subtitle: Text(l10n.legalOpenInBrowser, style: settingsTileSub),
          trailing: const Icon(Icons.chevron_right),
          onTap: () => openLegalUrlOrSnack(context, LegalUrls.terms),
        ),
        ListTile(
          contentPadding: EdgeInsets.zero,
          leading: const Icon(Icons.privacy_tip_outlined, color: AppTheme.line),
          title: Text(l10n.privacyTitle, style: settingsTileTitle),
          subtitle: Text(l10n.legalOpenInBrowser, style: settingsTileSub),
          trailing: const Icon(Icons.chevron_right),
          onTap: () => openLegalUrlOrSnack(context, LegalUrls.privacy),
        ),
        ListTile(
          contentPadding: EdgeInsets.zero,
          leading: const Icon(Icons.gavel_outlined, color: AppTheme.line),
          title: Text(l10n.ugcGuidelinesTitle, style: settingsTileTitle),
          subtitle: Text(l10n.ugcGuidelinesBanner, style: settingsTileSub),
          trailing: const Icon(Icons.chevron_right),
          onTap: () => showUgcGuidelinesDialog(context),
        ),
        const AppVersionTile(),
      ],
    );
  }
}
