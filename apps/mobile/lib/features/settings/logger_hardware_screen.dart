import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/services/logger_pairing_service.dart';
import '../../core/services/logger_session_importer.dart';
import '../../l10n/l10n_ext.dart';
import 'metrica_ble_pair_section.dart';
import '../../providers/ride_providers.dart';
import '../../theme/app_theme.dart';
import '../../widgets/app_snack.dart';
import '../settings/settings_group.dart';

/// Pair M5 logger + import session folder from SD / file share.
class LoggerHardwareScreen extends ConsumerStatefulWidget {
  const LoggerHardwareScreen({super.key});

  @override
  ConsumerState<LoggerHardwareScreen> createState() =>
      _LoggerHardwareScreenState();
}

class _LoggerHardwareScreenState extends ConsumerState<LoggerHardwareScreen> {
  final _pair = LoggerPairingService();
  String? _code;
  String? _serialCmd;
  bool _busy = false;

  Future<void> _mint() async {
    setState(() => _busy = true);
    try {
      final code = await _pair.mintPairCode();
      if (!mounted) return;
      setState(() {
        _code = code;
        _serialCmd = null;
      });
      showAppSnack(context, context.l10n.copyLoggerCodeMinted(code));
    } catch (e) {
      debugPrint('LoggerHardware mint failed: $e');
      if (mounted) showAppSnackError(context, context.l10n.userFacingError(e));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _claim() async {
    final l10n = context.l10n;
    final ctrl = TextEditingController(text: _code ?? '');
    final code = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.copyLoggerClaimTitle),
        content: TextField(
          controller: ctrl,
          decoration: InputDecoration(
            labelText: l10n.copyLoggerCodeLabel,
            hintText: l10n.copyLoggerCodeHint,
          ),
          textCapitalization: TextCapitalization.characters,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(l10n.cancel),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, ctrl.text.trim()),
            child: Text(l10n.copyLoggerClaim),
          ),
        ],
      ),
    );
    if (code == null || code.isEmpty || !mounted) return;
    setState(() => _busy = true);
    try {
      final res = await _pair.claimCode(code);
      if (!mounted) return;
      setState(() => _serialCmd = res.serialPairCommand);
      await Clipboard.setData(ClipboardData(text: res.serialPairCommand));
      if (!mounted) return;
      showAppSnack(context, context.l10n.copyLoggerPairCopied);
    } catch (e) {
      debugPrint('LoggerHardware claim failed: $e');
      if (mounted) showAppSnackError(context, context.l10n.userFacingError(e));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _importSession() async {
    final picked = await FilePicker.getDirectoryPath(
      dialogTitle: context.l10n.copyLoggerPickFolderTitle,
    );
    if (picked == null) return;
    setState(() => _busy = true);
    try {
      final sync = ref.read(rideSyncServiceProvider);
      final importer = LoggerSessionImporter(sync: sync);
      final ride = await importer.importDirectory(Directory(picked));
      if (!mounted) return;
      showAppSnack(
        context,
        context.l10n.copyLoggerImported(ride.pointCount, ride.displayTitle()),
      );
      ref.invalidate(ridesListProvider);
    } catch (e) {
      debugPrint('LoggerHardware import failed: $e');
      if (mounted) {
        showAppSnackError(context, context.l10n.copyLoggerImportFailed);
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Scaffold(
      // Product name, not translated.
      appBar: AppBar(title: const Text('M5 Logger')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(
            l10n.copyLoggerIntro,
            style: GoogleFonts.rajdhani(color: AppTheme.steel, fontSize: 15),
          ),
          const SizedBox(height: 16),
          SettingsGroup(
            title: l10n.copyLoggerPairSection,
            children: [
              const MetricaBlePairSection(),
              const SizedBox(height: 16),
              FilledButton.icon(
                onPressed: _busy ? null : _mint,
                icon: const Icon(Icons.qr_code_2),
                label: Text(_busy ? '…' : l10n.copyLoggerGenerateCode),
              ),
              if (_code != null) ...[
                const SizedBox(height: 8),
                SelectableText(
                  _code!,
                  style: GoogleFonts.exo2(
                    fontSize: 28,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 4,
                  ),
                ),
              ],
              const SizedBox(height: 8),
              OutlinedButton.icon(
                onPressed: _busy ? null : _claim,
                icon: const Icon(Icons.link),
                label: Text(l10n.copyLoggerClaimButton),
              ),
              if (_serialCmd != null) ...[
                const SizedBox(height: 8),
                SelectableText(
                  _serialCmd!,
                  style: GoogleFonts.robotoMono(fontSize: 12),
                ),
              ],
            ],
          ),
          SettingsGroup(
            title: l10n.copyLoggerImportSection,
            help: l10n.copyLoggerImportHelp,
            children: [
              FilledButton.icon(
                onPressed: _busy ? null : _importSession,
                icon: const Icon(Icons.folder_open),
                label: Text(l10n.copyLoggerPickFolder),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
