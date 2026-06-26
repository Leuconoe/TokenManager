// Design Ref: §5.4 BackupPage — passphrase export/import (SAF + share).

import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:share_plus/share_plus.dart';

import '../../core/crypto/passphrase_crypto.dart';
import '../../core/providers.dart';
import '../../l10n/app_localizations.dart';
import '../tokens/token_providers.dart';
import 'data/backup_repository.dart';

class BackupPage extends ConsumerStatefulWidget {
  const BackupPage({super.key});

  @override
  ConsumerState<BackupPage> createState() => _BackupPageState();
}

class _BackupPageState extends ConsumerState<BackupPage> {
  final _passCtrl = TextEditingController();
  ImportMode _mode = ImportMode.merge;
  bool _busy = false;

  @override
  void dispose() {
    _passCtrl.dispose();
    super.dispose();
  }

  String get _fileName {
    final d = DateTime.now();
    final ymd =
        '${d.year}${d.month.toString().padLeft(2, '0')}${d.day.toString().padLeft(2, '0')}';
    return 'tokenmanager-backup-$ymd.tmbk';
  }

  bool _validatePass() {
    if (_passCtrl.text.length < 8) {
      _snack(AppLocalizations.of(context).passphraseTooShort);
      return false;
    }
    return true;
  }

  Future<void> _export({required bool share}) async {
    if (!_validatePass()) return;
    final l = AppLocalizations.of(context);
    setState(() => _busy = true);
    try {
      final repo = ref.read(backupRepositoryProvider);
      if (share) {
        final bytes = await repo.exportBytes(_passCtrl.text);
        final tmp = File('${Directory.systemTemp.path}/$_fileName');
        await tmp.writeAsBytes(bytes, flush: true);
        await Share.shareXFiles([XFile(tmp.path)], text: l.shareWarn);
        _snack(l.shareOpened);
      } else {
        // SAF: user picks save location.
        final path = await FilePicker.saveFile(
          fileName: _fileName,
          bytes: await repo.exportBytes(_passCtrl.text),
        );
        if (path != null) _snack(l.exportSaved);
      }
    } catch (e) {
      _snack(l.exportFailed(e.toString()));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _import() async {
    if (!_validatePass()) return;
    final l = AppLocalizations.of(context);
    setState(() => _busy = true);
    try {
      final picked = await FilePicker.pickFiles();
      if (picked == null || picked.files.single.path == null) return;
      final file = File(picked.files.single.path!);
      final result = await ref.read(backupRepositoryProvider).import(
            file,
            _passCtrl.text,
            _mode,
            onConflict: (local, imported) async {
              if (!mounted) return true;
              final useImported = await showDialog<bool>(
                context: context,
                builder: (ctx) => AlertDialog(
                  title: Text(l.mergeConflictTitle(imported.serviceName)),
                  content: Text(l.mergeConflictBody),
                  actions: [
                    TextButton(
                        onPressed: () => Navigator.pop(ctx, false),
                        child: Text(l.mergeKeepLocal)),
                    FilledButton(
                        onPressed: () => Navigator.pop(ctx, true),
                        child: Text(l.mergeUseImported)),
                  ],
                ),
              );
              return useImported ?? false; // dismiss = keep local
            },
          );
      await ref.read(tokenListProvider.notifier).setFilter(null);
      _snack(l.restoreDone(result.count));
    } on BackupAuthException {
      _snack(l.restoreAuthError);
    } on BackupFormatException {
      _snack(l.restoreFormatError);
    } catch (e) {
      _snack(l.exportFailed(e.toString()));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  void _snack(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(msg)));
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(l.backupTitle)),
      body: AbsorbPointer(
        absorbing: _busy,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Text(l.backupInfo,
                style: const TextStyle(fontSize: 13, color: Colors.grey)),
            const SizedBox(height: 16),
            TextField(
              controller: _passCtrl,
              obscureText: true,
              decoration: InputDecoration(
                labelText: l.passphraseLabel,
                border: const OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 24),
            Text(l.exportSection,
                style: const TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Row(children: [
              Expanded(
                child: FilledButton.icon(
                  onPressed: () => _export(share: false),
                  icon: const Icon(Icons.save_alt),
                  label: Text(l.exportSave),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => _export(share: true),
                  icon: const Icon(Icons.share),
                  label: Text(l.exportShare),
                ),
              ),
            ]),
            const Divider(height: 40),
            Text(l.restoreSection,
                style: const TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            RadioGroup<ImportMode>(
              groupValue: _mode,
              onChanged: (v) => setState(() => _mode = v!),
              child: Column(
                children: [
                  RadioListTile<ImportMode>(
                    value: ImportMode.merge,
                    title: Text(l.modeMerge),
                    dense: true,
                  ),
                  RadioListTile<ImportMode>(
                    value: ImportMode.overwrite,
                    title: Text(l.modeOverwrite),
                    dense: true,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            FilledButton.tonalIcon(
              onPressed: _import,
              icon: const Icon(Icons.restore),
              label: Text(l.restoreButton),
            ),
            if (_busy) ...[
              const SizedBox(height: 24),
              const Center(child: CircularProgressIndicator()),
            ],
          ],
        ),
      ),
    );
  }
}
