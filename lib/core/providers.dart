// Design Ref: §2.3, §9.4 — dependency injection wiring (Riverpod).

import 'dart:io' show Platform;

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'crypto/keystore_crypto.dart';
import 'db/app_database.dart';
import 'domain/crypto_port.dart';
import 'notification/scheduler.dart';
import 'scan/android_scheduler.dart';
import 'scan/autostart_service.dart';
import 'scan/desktop_scheduler.dart';
import 'scan/scan_scheduler.dart';
import 'scan/scan_service.dart';
import 'sync/drive_auth_service.dart';
import 'sync/sync_controller.dart';
import 'update/update_service.dart';
import '../features/backup/data/backup_repository.dart';
import '../features/lock/biometric_service.dart';
import '../features/settings/settings_repository.dart';
import '../features/tokens/data/token_repository.dart';

/// CryptoPort — Keystore-backed key + passphrase backup cipher.
final cryptoPortProvider = Provider<CryptoPort>((ref) => AppCryptoPort());

/// Encrypted Drift database (SQLCipher).
final appDatabaseProvider = Provider<AppDatabase>((ref) {
  final db = AppDatabase(ref.watch(cryptoPortProvider));
  ref.onDispose(db.close);
  return db;
});

final tokenRepositoryProvider = Provider<TokenRepository>(
  (ref) => DriftTokenRepository(ref.watch(appDatabaseProvider)),
);

final biometricServiceProvider = Provider<BiometricService>(
  (ref) => BiometricService(),
);

final settingsRepositoryProvider = Provider<SettingsRepository>(
  (ref) => SettingsRepository(),
);

final backupRepositoryProvider = Provider<BackupRepository>(
  (ref) => BackupRepository(
    ref.watch(tokenRepositoryProvider),
    ref.watch(cryptoPortProvider),
  ),
);

final notificationSchedulerProvider = Provider<NotificationScheduler>(
  (ref) => NotificationScheduler(),
);

final scanServiceProvider = Provider<ScanService>(
  (ref) => ScanService(
    ref.watch(tokenRepositoryProvider),
    ref.watch(settingsRepositoryProvider),
    ref.watch(notificationSchedulerProvider),
  ),
);

final autoStartServiceProvider = Provider<AutoStartService>(
  (ref) => AutoStartService(),
);

/// Platform-branched scan scheduler: Android=WorkManager, Desktop=tray+startup.
final scanSchedulerProvider = Provider<ScanScheduler>((ref) {
  if (Platform.isAndroid) {
    return AndroidWorkmanagerScheduler(
      ref.watch(scanServiceProvider),
      ref.watch(notificationSchedulerProvider),
    );
  }
  return DesktopTrayScheduler(
    ref.watch(scanServiceProvider),
    ref.watch(settingsRepositoryProvider),
    ref.watch(autoStartServiceProvider),
  );
});

final updateServiceProvider = Provider<UpdateService>((ref) => UpdateService());

final driveAuthServiceProvider =
    Provider<DriveAuthService>((ref) => DriveAuthService());

final syncControllerProvider = Provider<SyncController>(
  (ref) => SyncController(
    ref.watch(tokenRepositoryProvider),
    ref.watch(cryptoPortProvider),
    ref.watch(settingsRepositoryProvider),
    ref.watch(driveAuthServiceProvider),
  ),
);

/// Whether the vault is currently unlocked (gated by biometric auth).
final appUnlockedProvider = StateProvider<bool>((ref) => false);
