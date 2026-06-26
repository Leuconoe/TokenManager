// Design Ref: §확정 #1 — no-expiry warning interval persistence.

import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// How many days BEFORE expiry to start warning (tokens that HAVE an expiry).
enum ExpiryLeadInterval {
  days7(7),
  days14(14),
  days30(30);

  final int days;
  const ExpiryLeadInterval(this.days);
}

/// Cadence for the "no expiry" security-warning notification.
enum NoExpiryWarnInterval {
  off(0),
  days15(15),
  days30(30);

  final int days;
  const NoExpiryWarnInterval(this.days);
}

/// Auto-sync cadence while sync is enabled (0 = manual only).
enum SyncInterval {
  off(0),
  min5(5),
  hour1(60);

  final int minutes;
  const SyncInterval(this.minutes);
}

class SettingsRepository {
  static const _kInterval = 'tm_noexpiry_interval_v1';
  static const _kExpiryLead = 'tm_expiry_lead_v1'; // days before expiry to warn
  static const _kLocale = 'tm_locale_tag_v1'; // BCP47 tag, or absent = system
  static const _kAutoStart = 'tm_autostart_v1'; // desktop launch-at-login
  static const _kSyncEnabled = 'tm_sync_enabled_v1';
  static const _kSyncFolder = 'tm_sync_folder_v1';
  static const _kSyncProvider = 'tm_sync_provider_v1'; // 'folder' | 'drive'
  static const _kSyncPass = 'tm_sync_pass_v1';
  static const _kSyncLast = 'tm_sync_last_v1';
  static const _kSyncInterval = 'tm_sync_interval_v1'; // auto-sync cadence
  static const _kCapture = 'tm_capture_protect_v1'; // Android FLAG_SECURE
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
      orElse: () => NoExpiryWarnInterval.days30, // default
    );
  }

  Future<void> setNoExpiryInterval(NoExpiryWarnInterval interval) =>
      _storage.write(key: _kInterval, value: interval.name);

  Future<ExpiryLeadInterval> getExpiryLead() async {
    final v = await _storage.read(key: _kExpiryLead);
    return ExpiryLeadInterval.values.firstWhere(
      (e) => e.name == v,
      orElse: () => ExpiryLeadInterval.days14, // default
    );
  }

  Future<void> setExpiryLead(ExpiryLeadInterval lead) =>
      _storage.write(key: _kExpiryLead, value: lead.name);

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

  // --- Folder sync ---
  Future<bool> getSyncEnabled() async =>
      (await _storage.read(key: _kSyncEnabled)) == 'true';
  Future<void> setSyncEnabled(bool v) =>
      _storage.write(key: _kSyncEnabled, value: v ? 'true' : 'false');

  Future<String?> getSyncFolder() => _storage.read(key: _kSyncFolder);
  Future<void> setSyncFolder(String? path) async {
    if (path == null) {
      await _storage.delete(key: _kSyncFolder);
    } else {
      await _storage.write(key: _kSyncFolder, value: path);
    }
  }

  /// 'folder' (SAF/desktop path) or 'drive' (Google Drive API, Android).
  Future<String> getSyncProvider() async =>
      (await _storage.read(key: _kSyncProvider)) == 'drive' ? 'drive' : 'folder';
  Future<void> setSyncProvider(String v) =>
      _storage.write(key: _kSyncProvider, value: v);

  Future<String?> getSyncPassphrase() => _storage.read(key: _kSyncPass);
  Future<void> setSyncPassphrase(String? p) async {
    if (p == null) {
      await _storage.delete(key: _kSyncPass);
    } else {
      await _storage.write(key: _kSyncPass, value: p);
    }
  }

  Future<DateTime?> getSyncLast() async {
    final v = await _storage.read(key: _kSyncLast);
    final ms = v == null ? null : int.tryParse(v);
    return ms == null ? null : DateTime.fromMillisecondsSinceEpoch(ms);
  }

  Future<void> setSyncLast(DateTime t) =>
      _storage.write(key: _kSyncLast, value: t.millisecondsSinceEpoch.toString());

  Future<SyncInterval> getSyncInterval() async {
    final v = await _storage.read(key: _kSyncInterval);
    return SyncInterval.values.firstWhere((e) => e.name == v,
        orElse: () => SyncInterval.off);
  }

  Future<void> setSyncInterval(SyncInterval i) =>
      _storage.write(key: _kSyncInterval, value: i.name);

  /// Android screenshot/recents block (FLAG_SECURE). Default: enabled.
  Future<bool> getCaptureProtection() async =>
      (await _storage.read(key: _kCapture)) != 'false';

  Future<void> setCaptureProtection(bool enabled) =>
      _storage.write(key: _kCapture, value: enabled ? 'true' : 'false');
}
