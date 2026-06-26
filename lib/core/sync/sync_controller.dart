// Wires settings → FolderSyncStorage → SyncService. Reads the sync config
// (enabled / folder / passphrase) each run so changes take effect immediately.

import '../domain/crypto_port.dart';
import '../../features/settings/settings_repository.dart';
import '../../features/tokens/data/token_repository.dart';
import 'folder_sync_storage.dart';
import 'sync_service.dart';

class SyncController {
  final TokenRepository repo;
  final CryptoPort crypto;
  final SettingsRepository settings;

  SyncController(this.repo, this.crypto, this.settings);

  /// Runs a sync cycle if enabled & configured. Returns merged count, or null
  /// if sync is off / not configured. Throws on wrong passphrase.
  Future<int?> syncNow() async {
    if (!await settings.getSyncEnabled()) return null;
    final folder = await settings.getSyncFolder();
    final pass = await settings.getSyncPassphrase();
    if (folder == null || pass == null || pass.isEmpty) return null;

    final svc = SyncService(repo, crypto, FolderSyncStorage(folder));
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
