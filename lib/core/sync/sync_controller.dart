// Wires settings → FolderSyncStorage → SyncService. Reads the sync config
// (enabled / folder / passphrase) each run so changes take effect immediately.

import 'dart:io' show Platform;

import '../domain/crypto_port.dart';
import '../../features/settings/settings_repository.dart';
import '../../features/tokens/data/token_repository.dart';
import 'drive_auth_service.dart';
import 'drive_sync_storage.dart';
import 'folder_sync_storage.dart';
import 'saf_sync_storage.dart';
import 'sync_service.dart';
import 'sync_storage.dart';

class SyncController {
  final TokenRepository repo;
  final CryptoPort crypto;
  final SettingsRepository settings;
  final DriveAuthService driveAuth;

  SyncController(this.repo, this.crypto, this.settings, this.driveAuth);

  /// Runs a sync cycle if enabled & configured. Returns merged count, or null
  /// if sync is off / not configured. Throws on wrong passphrase.
  Future<int?> syncNow() async {
    if (!await settings.getSyncEnabled()) return null;
    final pass = await settings.getSyncPassphrase();
    if (pass == null || pass.isEmpty) return null;

    final SyncStorage storage;
    if (Platform.isAndroid && await settings.getSyncProvider() == 'drive') {
      final api = await driveAuth.driveApi();
      if (api == null) throw StateError('drive-not-connected');
      storage = DriveSyncStorage(api);
    } else {
      final folder = await settings.getSyncFolder();
      if (folder == null) return null;
      // Android stores a SAF tree URI; desktop stores a filesystem path.
      storage =
          Platform.isAndroid ? SafSyncStorage(folder) : FolderSyncStorage(folder);
    }

    final svc = SyncService(repo, crypto, storage);
    final r = await svc.syncNow(pass);
    await settings.setSyncLast(DateTime.now());
    return r.merged;
  }

  /// Best-effort background push (after a local change) — never throws.
  Future<void> syncQuietly() async {
    try {
      await syncNow();
    } catch (_) {/* ignore — manual sync surfaces errors */}
  }
}
