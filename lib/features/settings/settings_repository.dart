// Design Ref: §확정 #1 — no-expiry warning interval persistence.

import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Cadence for the "no expiry" security-warning notification.
enum NoExpiryWarnInterval {
  off(0),
  weekly(7),
  biweekly(14),
  monthly(30);

  final int days;
  const NoExpiryWarnInterval(this.days);
}

class SettingsRepository {
  static const _kInterval = 'tm_noexpiry_interval_v1';
  static const _kLocale = 'tm_locale_tag_v1'; // BCP47 tag, or absent = system
  static const _kAutoStart = 'tm_autostart_v1'; // desktop launch-at-login
  final FlutterSecureStorage _storage;

  SettingsRepository([FlutterSecureStorage? storage])
      : _storage = storage ??
            const FlutterSecureStorage(
              aOptions: AndroidOptions(encryptedSharedPreferences: true),
            );

  Future<NoExpiryWarnInterval> getNoExpiryInterval() async {
    final v = await _storage.read(key: _kInterval);
    return NoExpiryWarnInterval.values.firstWhere(
      (e) => e.name == v,
      orElse: () => NoExpiryWarnInterval.weekly, // default
    );
  }

  Future<void> setNoExpiryInterval(NoExpiryWarnInterval interval) =>
      _storage.write(key: _kInterval, value: interval.name);

  /// Returns the saved locale tag (e.g. "en", "zh_Hant"), or null for
  /// "follow system" (the default).
  Future<String?> getLocaleTag() => _storage.read(key: _kLocale);

  /// Persists the locale tag, or clears it (null = follow system).
  Future<void> setLocaleTag(String? tag) async {
    if (tag == null) {
      await _storage.delete(key: _kLocale);
    } else {
      await _storage.write(key: _kLocale, value: tag);
    }
  }

  /// Desktop launch-at-login preference (default: enabled).
  Future<bool> getAutoStart() async =>
      (await _storage.read(key: _kAutoStart)) != 'false';

  Future<void> setAutoStart(bool enabled) =>
      _storage.write(key: _kAutoStart, value: enabled ? 'true' : 'false');
}
