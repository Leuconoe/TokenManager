// Design Ref: §5.3 SettingsPage — no-expiry warning cadence + security info.

import 'dart:io' show Platform;

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:saf_util/saf_util.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/crypto/passphrase_crypto.dart' show BackupAuthException;
import '../../core/debug/debug_log.dart';
import '../../core/platform/secure_screen.dart';
import '../../core/providers.dart';
import '../../core/update/windows_updater.dart';
import '../../l10n/app_localizations.dart';
import '../tokens/token_providers.dart';
import '../tokens/trash_page.dart';
import 'locale_controller.dart';
import 'settings_repository.dart';

final _syncEnabledProvider = FutureProvider<bool>(
    (ref) => ref.watch(settingsRepositoryProvider).getSyncEnabled());
final _syncFolderProvider = FutureProvider<String?>(
    (ref) => ref.watch(settingsRepositoryProvider).getSyncFolder());
final _syncPassSetProvider = FutureProvider<bool>((ref) async =>
    ((await ref.watch(settingsRepositoryProvider).getSyncPassphrase()) ?? '')
        .isNotEmpty);
final _syncProviderProvider = FutureProvider<String>(
    (ref) => ref.watch(settingsRepositoryProvider).getSyncProvider());
// autoDispose: re-checks the connection each time Settings opens, so a sync
// failure that disconnected Drive is reflected without an app restart.
final _driveEmailProvider = FutureProvider.autoDispose<String?>(
    (ref) => ref.watch(driveAuthServiceProvider).currentEmail());

final _versionProvider = FutureProvider<String>((ref) async =>
    (await PackageInfo.fromPlatform()).version);

final _intervalProvider = FutureProvider<NoExpiryWarnInterval>((ref) =>
    ref.watch(settingsRepositoryProvider).getNoExpiryInterval());

final _expiryLeadProvider = FutureProvider<ExpiryLeadInterval>((ref) =>
    ref.watch(settingsRepositoryProvider).getExpiryLead());

final _autoStartProvider = FutureProvider<bool>(
    (ref) => ref.watch(settingsRepositoryProvider).getAutoStart());
final _captureProvider = FutureProvider<bool>(
    (ref) => ref.watch(settingsRepositoryProvider).getCaptureProtection());
final _syncIntervalProvider = FutureProvider<SyncInterval>(
    (ref) => ref.watch(settingsRepositoryProvider).getSyncInterval());

bool get _isDesktop =>
    Platform.isWindows || Platform.isLinux || Platform.isMacOS;

// Folder sync supported on desktop (filesystem) and Android (SAF tree).
bool get _syncSupported => _isDesktop || Platform.isAndroid;

class SettingsPage extends ConsumerWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final async = ref.watch(_intervalProvider);
    return Scaffold(
      appBar: AppBar(title: Text(l.settingsTitle)),
      body: async.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('$e')),
        data: (current) => ListView(
          children: [
            ListTile(
              leading: const Icon(Icons.language),
              title: Text(l.settingsLanguage),
              subtitle: Text(_localeLabel(l, ref.watch(localeControllerProvider))),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => _pickLanguage(context, ref, l),
            ),
            if (_isDesktop)
              SwitchListTile(
                secondary: const Icon(Icons.power_settings_new),
                title: Text(l.settingsAutoStart),
                subtitle: Text(l.settingsAutoStartSubtitle),
                value: ref.watch(_autoStartProvider).valueOrNull ?? true,
                onChanged: (v) async {
                  await ref.read(settingsRepositoryProvider).setAutoStart(v);
                  final svc = ref.read(autoStartServiceProvider);
                  v ? await svc.enable() : await svc.disable();
                  ref.invalidate(_autoStartProvider);
                },
              ),
            const Divider(),
            ListTile(
              title: Text(l.expiryLeadTitle),
              subtitle: Text(l.expiryLeadSubtitle),
            ),
            RadioGroup<ExpiryLeadInterval>(
              groupValue: ref.watch(_expiryLeadProvider).valueOrNull ??
                  ExpiryLeadInterval.days14,
              onChanged: (v) async {
                await ref.read(settingsRepositoryProvider).setExpiryLead(v!);
                ref.invalidate(_expiryLeadProvider);
                ref.invalidate(tokenListProvider); // badges reflect new window
              },
              child: Column(
                children: ExpiryLeadInterval.values
                    .map((lead) => RadioListTile<ExpiryLeadInterval>(
                          value: lead,
                          title: Text(_leadLabel(l, lead)),
                        ))
                    .toList(),
              ),
            ),
            const Divider(),
            ListTile(
              title: Text(l.noExpiryWarnTitle),
              subtitle: Text(l.noExpiryWarnSubtitle),
            ),
            RadioGroup<NoExpiryWarnInterval>(
              groupValue: current,
              onChanged: (v) async {
                await ref
                    .read(settingsRepositoryProvider)
                    .setNoExpiryInterval(v!);
                ref.invalidate(_intervalProvider);
              },
              child: Column(
                children: NoExpiryWarnInterval.values
                    .map((iv) => RadioListTile<NoExpiryWarnInterval>(
                          value: iv,
                          title: Text(_label(l, iv)),
                        ))
                    .toList(),
              ),
            ),
            if (_syncSupported) ...[
              const Divider(),
              ListTile(
                leading: const Icon(Icons.sync),
                title: Text(l.syncSectionTitle),
                subtitle: Text(l.syncEnableSubtitle),
                isThreeLine: true,
                trailing: Switch(
                  value: ref.watch(_syncEnabledProvider).valueOrNull ?? false,
                  onChanged: (v) async {
                    await ref.read(settingsRepositoryProvider).setSyncEnabled(v);
                    ref.invalidate(_syncEnabledProvider);
                  },
                ),
              ),
              RadioGroup<String>(
                groupValue: ref.watch(_syncProviderProvider).valueOrNull ?? 'folder',
                onChanged: (v) async {
                  await ref.read(settingsRepositoryProvider).setSyncProvider(v!);
                  ref.invalidate(_syncProviderProvider);
                },
                child: Column(children: [
                  RadioListTile<String>(
                      value: 'folder', dense: true, title: Text(l.syncProviderFolder)),
                  RadioListTile<String>(
                      value: 'drive', dense: true, title: Text(l.syncProviderDrive)),
                ]),
              ),
              if ((ref.watch(_syncProviderProvider).valueOrNull ?? 'folder') == 'drive')
                ListTile(
                  leading: const Icon(Icons.account_circle_outlined),
                  title: Text(l.syncDriveConnect),
                  subtitle: Text(ref.watch(_driveEmailProvider).valueOrNull ??
                      l.syncDriveNotConnected),
                  onTap: () async {
                    final m = ScaffoldMessenger.of(context);
                    try {
                      final email =
                          await ref.read(driveAuthServiceProvider).signIn();
                      ref.invalidate(_driveEmailProvider);
                      if (email == null) return; // user cancelled
                    } catch (_) {
                      m.showSnackBar(
                          SnackBar(content: Text(l.syncDriveSignInFailed)));
                    }
                  },
                ),
              if ((ref.watch(_syncProviderProvider).valueOrNull ?? 'folder') == 'folder')
                ListTile(
                  title: Text(l.syncFolderTitle),
                subtitle: Text(ref.watch(_syncFolderProvider).valueOrNull ??
                    l.syncValueNotSet),
                trailing: const Icon(Icons.folder_open),
                onTap: () async {
                  // Android: SAF document tree (persisted). Desktop: a path.
                  final String? loc;
                  if (Platform.isAndroid) {
                    final d = await SafUtil().pickDirectory(
                        writePermission: true, persistablePermission: true);
                    loc = d?.uri;
                  } else {
                    loc = await FilePicker.getDirectoryPath();
                  }
                  if (loc != null) {
                    await ref.read(settingsRepositoryProvider).setSyncFolder(loc);
                    ref.invalidate(_syncFolderProvider);
                  }
                },
              ),
              ListTile(
                title: Text(l.syncPassphraseTitle),
                subtitle: Text(
                    (ref.watch(_syncPassSetProvider).valueOrNull ?? false)
                        ? l.syncValueSet
                        : l.syncValueNotSet),
                trailing: const Icon(Icons.key_outlined),
                onTap: () => _setSyncPass(context, ref, l),
              ),
              ListTile(
                leading: const Icon(Icons.sync_alt),
                title: Text(l.syncNowAction),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => _runSync(context, ref, l),
              ),
              ListTile(
                leading: const Icon(Icons.schedule),
                title: Text(l.syncIntervalTitle),
                subtitle: Text(l.syncIntervalSubtitle),
                isThreeLine: true,
              ),
              RadioGroup<SyncInterval>(
                groupValue:
                    ref.watch(_syncIntervalProvider).valueOrNull ?? SyncInterval.off,
                onChanged: (v) async {
                  await ref.read(settingsRepositoryProvider).setSyncInterval(v!);
                  ref.invalidate(_syncIntervalProvider);
                },
                child: Column(children: [
                  RadioListTile<SyncInterval>(
                      value: SyncInterval.off, dense: true, title: Text(l.intervalOff)),
                  RadioListTile<SyncInterval>(
                      value: SyncInterval.min5, dense: true, title: Text(l.syncInterval5m)),
                  RadioListTile<SyncInterval>(
                      value: SyncInterval.hour1, dense: true, title: Text(l.syncInterval1h)),
                ]),
              ),
            ],
            const Divider(),
            ListTile(
              leading: const Icon(Icons.system_update_outlined),
              title: Text(l.settingsCheckUpdate),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => _checkUpdate(context, ref, l),
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.shield_outlined),
              title: Text(l.securitySectionTitle),
              subtitle: Text(l.securityInfo),
              isThreeLine: true,
            ),
            if (Platform.isAndroid)
              SwitchListTile(
                secondary: const Icon(Icons.screenshot_monitor_outlined),
                title: Text(l.captureProtectionTitle),
                subtitle: Text(l.captureProtectionSubtitle),
                value: ref.watch(_captureProvider).valueOrNull ?? true,
                onChanged: (v) async {
                  await ref.read(settingsRepositoryProvider)
                      .setCaptureProtection(v);
                  await SecureScreen.apply(v);
                  ref.invalidate(_captureProvider);
                },
              ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.delete_outline),
              title: Text(l.trashTitle),
              subtitle: Text(l.trashSubtitle),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const TrashPage())),
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.bug_report_outlined),
              title: Text(l.debugLogTitle),
              trailing: TextButton(
                onPressed: () => DebugLog.instance.clear(),
                child: Text(l.debugLogClear),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Container(
                height: 200,
                width: double.infinity,
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: ValueListenableBuilder<List<String>>(
                  valueListenable: DebugLog.instance.entries,
                  builder: (context, lines, _) => SingleChildScrollView(
                    reverse: true,
                    child: SelectableText(
                      lines.isEmpty ? '—' : lines.join('\n'),
                      style: const TextStyle(
                          fontFamily: 'monospace', fontSize: 11),
                    ),
                  ),
                ),
              ),
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.info_outline),
              title: Text(l.versionTitle),
              subtitle: Text(ref.watch(_versionProvider).valueOrNull ?? '—'),
            ),
          ],
        ),
      ),
    );
  }

  String _label(AppLocalizations l, NoExpiryWarnInterval iv) => switch (iv) {
        NoExpiryWarnInterval.off => l.intervalOff,
        NoExpiryWarnInterval.days15 => l.interval15Days,
        NoExpiryWarnInterval.days30 => l.interval30Days,
      };

  String _leadLabel(AppLocalizations l, ExpiryLeadInterval lead) => switch (lead) {
        ExpiryLeadInterval.days7 => l.lead7Days,
        ExpiryLeadInterval.days14 => l.lead14Days,
        ExpiryLeadInterval.days30 => l.lead30Days,
      };

  Future<void> _setSyncPass(
      BuildContext context, WidgetRef ref, AppLocalizations l) async {
    final ctrl = TextEditingController();
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l.syncPassphraseTitle),
        content: TextField(
          controller: ctrl,
          obscureText: true,
          autofocus: true,
          decoration: InputDecoration(
            labelText: l.syncPassphraseTitle,
            helperText: l.passphraseMin8,
            border: const OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: Text(l.actionCancel)),
          FilledButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: Text(l.actionSave)),
        ],
      ),
    );
    if (ok == true && ctrl.text.length >= 8) {
      await ref.read(settingsRepositoryProvider).setSyncPassphrase(ctrl.text);
      ref.invalidate(_syncPassSetProvider);
    }
  }

  Future<void> _runSync(
      BuildContext context, WidgetRef ref, AppLocalizations l) async {
    final m = ScaffoldMessenger.of(context);
    m.showSnackBar(SnackBar(
        content: Text(l.syncInProgress), duration: const Duration(seconds: 30)));
    try {
      final n = await ref.read(syncControllerProvider).syncNow();
      if (!context.mounted) return;
      m.hideCurrentSnackBar();
      if (n == null) {
        m.showSnackBar(SnackBar(content: Text(l.syncNeedSetup)));
        return;
      }
      ref.invalidate(tokenListProvider); // reflect merged result
      m.showSnackBar(SnackBar(content: Text(l.syncResultDone(n))));
    } on BackupAuthException {
      // Distinct handling: the sync passphrase doesn't match the remote file.
      if (!context.mounted) return;
      m.hideCurrentSnackBar();
      final reenter = await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: Text(l.syncPassMismatchTitle),
          content: Text(l.syncPassMismatchBody),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(ctx, false),
                child: Text(l.actionCancel)),
            FilledButton(
                onPressed: () => Navigator.pop(ctx, true),
                child: Text(l.syncPassReenter)),
          ],
        ),
      );
      if (reenter == true && context.mounted) {
        await _setSyncPass(context, ref, l);
      }
    } catch (_) {
      if (!context.mounted) return;
      m.hideCurrentSnackBar();
      // The controller drops the Drive connection on a non-passphrase failure;
      // refresh the connect tile so it shows "not connected" → reconnect.
      ref.invalidate(_driveEmailProvider);
      m.showSnackBar(SnackBar(content: Text(l.syncResultFailed)));
    }
  }

  Future<void> _checkUpdate(
      BuildContext context, WidgetRef ref, AppLocalizations l) async {
    final messenger = ScaffoldMessenger.of(context);
    messenger.showSnackBar(SnackBar(content: Text(l.updateChecking)));
    try {
      final info = await ref.read(updateServiceProvider).check();
      if (!context.mounted) return;
      messenger.hideCurrentSnackBar();
      if (!info.hasUpdate) {
        messenger.showSnackBar(
            SnackBar(content: Text(l.updateUpToDate(info.current))));
        return;
      }
      final canAuto = Platform.isWindows && info.windowsAssetUrl.isNotEmpty;
      final action = await showDialog<String>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: Text(l.updateAvailableTitle),
          content: Text(l.updateAvailableBody(info.latest, info.current)),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(ctx, 'cancel'),
                child: Text(l.actionCancel)),
            TextButton(
                onPressed: () => Navigator.pop(ctx, 'open'),
                child: Text(l.updateOpen)),
            if (canAuto)
              FilledButton(
                  onPressed: () => Navigator.pop(ctx, 'auto'),
                  child: Text(l.updateAutoInstall)),
          ],
        ),
      );
      if (action == 'open' && info.url.isNotEmpty) {
        await launchUrl(Uri.parse(info.url),
            mode: LaunchMode.externalApplication);
      } else if (action == 'auto') {
        messenger.showSnackBar(SnackBar(content: Text(l.updateInstalling)));
        // Launches the detached helper and exits the app; the helper swaps the
        // files and relaunches.
        await WindowsUpdater.downloadInstallAndRestart(info.windowsAssetUrl);
      }
    } catch (_) {
      if (!context.mounted) return;
      messenger.hideCurrentSnackBar();
      messenger.showSnackBar(SnackBar(content: Text(l.updateFailed)));
    }
  }

  String _localeLabel(AppLocalizations l, Locale? current) {
    if (current == null) return l.languageSystemDefault;
    for (final e in kSelectableLocales) {
      if (e.locale == current) return e.label;
    }
    return current.toLanguageTag();
  }

  Future<void> _pickLanguage(
      BuildContext context, WidgetRef ref, AppLocalizations l) async {
    final current = ref.read(localeControllerProvider);
    final picked = await showDialog<({Locale? locale})>(
      context: context,
      builder: (ctx) => SimpleDialog(
        title: Text(l.settingsLanguage),
        children: kSelectableLocales
            .map((e) => ListTile(
                  title: Text(
                      e.locale == null ? l.languageSystemDefault : e.label),
                  trailing: _key(e.locale) == _key(current)
                      ? const Icon(Icons.check, color: Colors.indigo)
                      : null,
                  onTap: () => Navigator.pop(ctx, (locale: e.locale)),
                ))
            .toList(),
      ),
    );
    if (picked != null) {
      await ref.read(localeControllerProvider.notifier).setLocale(picked.locale);
    }
  }

  static String _key(Locale? l) => l == null ? 'system' : l.toLanguageTag();
}
