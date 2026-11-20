import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../theme/app_theme.dart';

/// Shared look for Settings sub-screens.
TextStyle get settingsTileTitle =>
    GoogleFonts.rajdhani(fontWeight: FontWeight.w600);

TextStyle get settingsTileSub =>
    GoogleFonts.rajdhani(color: AppTheme.steel, fontSize: 12);

void pushSettingsPage(BuildContext context, Widget page) {
  Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => page));
}

/// Scaffold + padded list used by every Settings sub-screen.
class SettingsSectionScaffold extends StatelessWidget {
  const SettingsSectionScaffold({
    super.key,
    required this.title,
    required this.children,
    this.help,
  });

  final String title;
  final String? help;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(24, 12, 24, 32),
        children: [
          if (help != null && help!.trim().isNotEmpty) ...[
            Text(
              help!,
              style: GoogleFonts.rajdhani(
                color: AppTheme.steel,
                fontSize: 13,
                height: 1.35,
              ),
            ),
            const SizedBox(height: 8),
          ],
          ...children,
        ],
      ),
    );
  }
}

/// Hub row: icon, title, current-state subtitle, chevron (or custom trailing).
class SettingsNavRow extends StatelessWidget {
  const SettingsNavRow({
    super.key,
    required this.icon,
    required this.title,
    this.subtitle,
    this.trailing,
    required this.onTap,
    this.iconColor = AppTheme.line,
  });

  final IconData icon;
  final Color iconColor;
  final String title;
  final String? subtitle;
  final Widget? trailing;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      minVerticalPadding: 10,
      minTileHeight: 56,
      leading: Icon(icon, color: iconColor),
      title: Text(title, style: settingsTileTitle.copyWith(fontSize: 16)),
      subtitle: subtitle == null
          ? null
          : Text(
              subtitle!,
              style: settingsTileSub.copyWith(fontSize: 13),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
      trailing: trailing == null
          ? const Icon(Icons.chevron_right)
          : Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                trailing!,
                const SizedBox(width: 4),
                const Icon(Icons.chevron_right),
              ],
            ),
      onTap: onTap,
    );
  }
}
