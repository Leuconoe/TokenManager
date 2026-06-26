// win-3 — shared expiry scan + notify, used by both the Android background
// isolate (workmanager) and the desktop tray scheduler. No BuildContext: l10n
// is loaded via the delegate from the device locale.

import 'dart:io' show Platform;
import 'dart:ui' show Locale;

import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../../features/settings/settings_repository.dart';
import '../../features/tokens/data/token_repository.dart';
import '../../l10n/app_localizations.dart';
import '../domain/token_entry.dart';
import '../domain/token_status.dart';
import '../notification/scheduler.dart';

const _kLastNoExpiryWarn = 'tm_last_noexpiry_warn_v1';

class ScanService {
  final TokenRepository repo;
  final SettingsRepository settings;
  final NotificationScheduler notifier;

  ScanService(this.repo, this.settings, this.notifier);

  static const _storage = FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
  );

  /// Scans token statuses and emits notifications (Android). Returns the
  /// grouped scan so desktop callers can update the tray tooltip.
  /// Idempotent per cadence for the no-expiry warning.
  Future<Map<TokenStatus, List<TokenEntry>>> run() async {
    final lead = await settings.getExpiryLead();
    final scan = await repo.scanStatus(soonDays: lead.days);
    final warn = await _shouldWarnNoExpiry();
    final l10n = await AppLocalizations.delegate.load(_deviceLocale());
    await notifier.notifyFromScan(scan, warnNoExpiry: warn, l10n: l10n);
    if (warn) await _stampNoExpiryWarn();
    return scan;
  }

  Future<bool> _shouldWarnNoExpiry() async {
    final interval = await settings.getNoExpiryInterval();
    if (interval == NoExpiryWarnInterval.off) return false;
    final last = await _storage.read(key: _kLastNoExpiryWarn);
    final lastMs = last == null ? null : int.tryParse(last);
    if (lastMs == null) return true;
    final elapsed =
        DateTime.now().difference(DateTime.fromMillisecondsSinceEpoch(lastMs));
    return elapsed.inDays >= interval.days;
  }

  Future<void> _stampNoExpiryWarn() => _storage.write(
        key: _kLastNoExpiryWarn,
        value: DateTime.now().millisecondsSinceEpoch.toString(),
      );

  /// Device locale mapped to a supported one (English fallback).
  static Locale _deviceLocale() {
    final code = Platform.localeName.split(RegExp(r'[_-]')).first.toLowerCase();
    final supported =
        AppLocalizations.supportedLocales.map((l) => l.languageCode).toSet();
    return supported.contains(code) ? Locale(code) : const Locale('en');
  }
}
