import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/auth/impersonation_controller.dart';
import '../../../l10n/l10n_ext.dart';
import '../../../providers/pro_entitlement_provider.dart';
import '../../../theme/app_theme.dart';
import '../../../widgets/app_snack.dart';
import '../../moderation/staff_reports_screen.dart';
import '../impersonate_screen.dart';
import 'settings_section_common.dart';

/// Same gate the staff tiles used in the old single-scroll Settings.
bool settingsStaffVisible(ImpersonationState s) => s.staff && !s.active;

/// Settings → Staff: impersonate, UGC report queue, partner codes.
class SettingsStaffScreen extends ConsumerWidget {
  const SettingsStaffScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final visible = settingsStaffVisible(ref.watch(impersonationProvider));
    return SettingsSectionScaffold(
      title: l10n.settingsHubStaff,
      children: [
        if (visible) ...[
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const Icon(Icons.visibility, color: AppTheme.signal),
            title: Text(l10n.impersonateTile, style: settingsTileTitle),
            subtitle: Text(l10n.impersonateHelp, style: settingsTileSub),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => pushSettingsPage(context, const ImpersonateScreen()),
          ),
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const Icon(Icons.flag_outlined, color: AppTheme.signal),
            title: Text(l10n.ugcStaffQueueTitle, style: settingsTileTitle),
            subtitle: Text(l10n.ugcStaffQueueHelp, style: settingsTileSub),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => pushSettingsPage(context, const StaffReportsScreen()),
          ),
          const SizedBox(height: 16),
          const _StaffPartnerCodeTile(),
        ],
      ],
    );
  }
}

class _StaffPartnerCodeTile extends ConsumerStatefulWidget {
  const _StaffPartnerCodeTile();
  @override
  ConsumerState<_StaffPartnerCodeTile> createState() =>
      _StaffPartnerCodeTileState();
}

class _StaffPartnerCodeTileState extends ConsumerState<_StaffPartnerCodeTile> {
  final _label = TextEditingController();
  bool _busy = false;
  String? _lastCode;

  @override
  void dispose() {
    _label.dispose();
    super.dispose();
  }

  Future<void> _create() async {
    final l10n = context.l10n;
    setState(() => _busy = true);
    final result = await ref
        .read(proEntitlementProvider.notifier)
        .staffCreatePartnerCode(label: _label.text);
    if (!mounted) return;
    setState(() => _busy = false);
    if (!result.ok || result.code == null) {
      showAppSnackError(context, l10n.partnerCodeInvalid);
      return;
    }
    setState(() => _lastCode = result.code);
    await Clipboard.setData(ClipboardData(text: result.code!));
    if (!mounted) return;
    showAppSnack(context, l10n.partnerCodeCopied(result.code!));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          l10n.createPartnerCode,
          style: GoogleFonts.rajdhani(fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 4),
        Text(
          l10n.createPartnerCodeHelp,
          style: GoogleFonts.rajdhani(
            color: AppTheme.steel,
            fontSize: 12,
            height: 1.35,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: _label,
          decoration: InputDecoration(
            hintText: l10n.partnerLabelHint,
            isDense: true,
          ),
        ),
        const SizedBox(height: 8),
        OutlinedButton(
          style: OutlinedButton.styleFrom(minimumSize: const Size(0, 48)),
          onPressed: _busy ? null : _create,
          child: Text(l10n.createPartnerCode),
        ),
        if (_lastCode != null) ...[
          const SizedBox(height: 8),
          SelectableText(
            _lastCode!,
            style: GoogleFonts.exo2(fontWeight: FontWeight.w700),
          ),
        ],
      ],
    );
  }
}
