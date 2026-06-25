// Design Ref: §F5/§F6, §2.2 — background scan isolate.
// Runs in a separate isolate; constructs its own DI (Keystore key is reachable
// in background, DB file decrypts the same way). No network used.

import 'dart:io' show Platform;
import 'dart:ui' show Locale;

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:workmanager/workmanager.dart';

import '../../features/settings/settings_repository.dart';
import '../../features/tokens/data/token_repository.dart';
import '../../l10n/app_localizations.dart';
import '../crypto/keystore_crypto.dart';
import '../db/app_database.dart';
import 'scheduler.dart';

const String _kLastNoExpiryWarn = 'tm_last_noexpiry_warn_v1';

@pragma('vm:entry-point')
void callbackDispatcher() {
  Workmanager().executeTask((task, _) async {
    if (task != kScanTaskName) return true;
    try {
      final crypto = AppCryptoPort();
      final db = AppDatabase(crypto);
      try {
        final repo = DriftTokenRepository(db);
        final scan = await repo.scanStatus();

        final warnNoExpiry = await _shouldWarnNoExpiry();
        final l10n = await AppLocalizations.delegate.load(_deviceLocale());
        await NotificationScheduler().notifyFromScan(scan,
            warnNoExpiry: warnNoExpiry, l10n: l10n);
        if (warnNoExpiry) await _stampNoExpiryWarn();
      } finally {
        await db.close();
      }
      return true;
    } catch (_) {
      // Swallow — background task must not crash loop; will retry next cycle.
      return true;
    }
  });
}

/// Best-effort device locale for background notifications. Falls back to a
/// supported locale; AppLocalizations.delegate.load requires a supported one.
Locale _deviceLocale() {
  final code = Platform.localeName.split(RegExp(r'[_-]')).first.toLowerCase();
  final supported =
      AppLocalizations.supportedLocales.map((l) => l.languageCode).toSet();
  return supported.contains(code) ? Locale(code) : const Locale('en');
}

/// True if the configured no-expiry interval has elapsed since last warning.
Future<bool> _shouldWarnNoExpiry() async {
  final interval = await SettingsRepository().getNoExpiryInterval();
  if (interval == NoExpiryWarnInterval.off) return false;

  const storage = FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
  );
  final last = await storage.read(key: _kLastNoExpiryWarn);
  if (last == null) return true;
  final lastMs = int.tryParse(last);
  if (lastMs == null) return true;
  final elapsed =
      DateTime.now().difference(DateTime.fromMillisecondsSinceEpoch(lastMs));
  return elapsed.inDays >= interval.days;
}

Future<void> _stampNoExpiryWarn() async {
  const storage = FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
  );
  await storage.write(
    key: _kLastNoExpiryWarn,
    value: DateTime.now().millisecondsSinceEpoch.toString(),
  );
}
