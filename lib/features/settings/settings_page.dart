// Design Ref: §5.3 SettingsPage — no-expiry warning cadence + security info.

import 'dart:io' show Platform;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/providers.dart';
import '../../l10n/app_localizations.dart';
import '../tokens/token_providers.dart';
import 'locale_controller.dart';
import 'settings_repository.dart';

final _intervalProvider = FutureProvider<NoExpiryWarnInterval>((ref) =>
    ref.watch(settingsRepositoryProvider).getNoExpiryInterval());

final _expiryLeadProvider = FutureProvider<ExpiryLeadInterval>((ref) =>
    ref.watch(settingsRepositoryProvider).getExpiryLead());

final _autoStartProvider = FutureProvider<bool>(
    (ref) => ref.watch(settingsRepositoryProvider).getAutoStart());

bool get _isDesktop =>
    Platform.isWindows || Platform.isLinux || Platform.isMacOS;

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
            const Divider(),
            ListTile(
              leading: const Icon(Icons.shield_outlined),
              title: Text(l.securitySectionTitle),
              subtitle: Text(l.securityInfo),
              isThreeLine: true,
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
