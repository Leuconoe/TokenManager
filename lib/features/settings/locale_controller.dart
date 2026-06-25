// win-1 — in-app language selection. null state = follow system locale.
// Persisted as a BCP47 tag in SettingsRepository.

import 'dart:ui' show Locale;

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/providers.dart';

/// Holds the user-selected [Locale], or null to follow the system locale.
class LocaleController extends Notifier<Locale?> {
  @override
  Locale? build() => null; // default before load() = system (English fallback)

  /// Loads the persisted locale tag at startup.
  Future<void> load() async {
    final tag = await ref.read(settingsRepositoryProvider).getLocaleTag();
    state = _parse(tag);
  }

  /// Sets and persists the locale (null = follow system).
  Future<void> setLocale(Locale? locale) async {
    state = locale;
    await ref
        .read(settingsRepositoryProvider)
        .setLocaleTag(locale == null ? null : _tag(locale));
  }

  static String _tag(Locale l) =>
      l.scriptCode != null ? '${l.languageCode}_${l.scriptCode}' : l.languageCode;

  static Locale? _parse(String? tag) {
    if (tag == null || tag.isEmpty) return null;
    final parts = tag.split('_');
    if (parts.length == 2) {
      // e.g. zh_Hant — second part is a script code (4 letters) here.
      return Locale.fromSubtags(
          languageCode: parts[0], scriptCode: parts[1]);
    }
    return Locale(parts[0]);
  }
}

final localeControllerProvider =
    NotifierProvider<LocaleController, Locale?>(LocaleController.new);

/// Selectable languages shown in Settings (null = system default).
/// Endonyms so each is readable in its own language.
const List<({Locale? locale, String label})> kSelectableLocales = [
  (locale: null, label: 'System'),
  (locale: Locale('ko'), label: '한국어'),
  (locale: Locale('en'), label: 'English'),
  (locale: Locale('ja'), label: '日本語'),
  (locale: Locale('zh'), label: '中文'),
  (locale: Locale.fromSubtags(languageCode: 'zh', scriptCode: 'Hant'),
      label: '中文 (繁體)'),
  (locale: Locale('es'), label: 'Español'),
  (locale: Locale('fr'), label: 'Français'),
];
