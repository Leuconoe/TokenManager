// Design Ref: §2.3, §9.4 — dependency injection wiring (Riverpod).

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'crypto/keystore_crypto.dart';
import 'db/app_database.dart';
import 'domain/crypto_port.dart';
import 'notification/scheduler.dart';
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

/// Whether the vault is currently unlocked (gated by biometric auth).
final appUnlockedProvider = StateProvider<bool>((ref) => false);
