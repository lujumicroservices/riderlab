import 'package:flutter/material.dart';

import '../../../l10n/l10n_ext.dart';
import '../../../widgets/account_auth_section.dart';
import '../../../widgets/rider_alias_chip.dart';
import 'settings_section_common.dart';

/// Settings → Cuenta: alias, session, sign out, delete account.
class SettingsAccountScreen extends StatelessWidget {
  const SettingsAccountScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return SettingsSectionScaffold(
      title: l10n.accountSection,
      children: const [
        Align(alignment: Alignment.centerLeft, child: RiderAliasChip()),
        SizedBox(height: 16),
        AccountAuthSection(),
      ],
    );
  }
}
