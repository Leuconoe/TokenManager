// Wires settings → FolderSyncStorage → SyncService. Reads the sync config
// (enabled / folder / passphrase) each run so changes take effect immediately.

import 'dart:io' show Platform;

import '../crypto/passphrase_crypto.dart' show BackupAuthException;
import '../debug/debug_log.dart';
import '../domain/crypto_port.dart';
import '../../features/settings/settings_repository.dart';
import '../../features/tokens/data/token_repository.dart';
import 'drive_auth.dart';
import 'drive_sync_storage.dart';
import 'folder_sync_storage.dart';
import 'saf_sync_storage.dart';
import 'sync_service.dart';
import 'sync_storage.dart';

class SyncController {
  final TokenRepository repo;
  final CryptoPort crypto;
  final SettingsRepository settings;
  final DriveAuth driveAuth;

  SyncController(this.repo, this.crypto, this.settings, this.driveAuth);

  /// Runs a sync cycle if enabled & configured. Returns merged count, or null
  /// if sync is off / not configured. Throws on wrong passphrase.
  Future<int?> syncNow() async {
    if (!await settings.getSyncEnabled()) {
      dlog('sync: disabled');
      return null;
    }
    final pass = await settings.getSyncPassphrase();
    if (pass == null || pass.isEmpty) {
      dlog('sync: no passphrase');
      return null;
    }

    final provider = await settings.getSyncProvider();
    dlog('sync: start provider=$provider platform=${Platform.operatingSystem}');
    final SyncStorage storage;
    if (provider == 'drive') {
      // Drive API on all platforms — shared visible "TokenManager" folder.
      final api = await driveAuth.driveApi();
      dlog('sync: driveApi=${api == null ? "null (not connected)" : "ok"}');
      if (api == null) throw StateError('drive-not-connected');
      storage = DriveSyncStorage(api);
    } else {
      final folder = await settings.getSyncFolder();
      if (folder == null) {
        dlog('sync: no folder configured');
        return null;
      }
      // Android stores a SAF tree URI; desktop stores a filesystem path.
      storage =
          Platform.isAndroid ? SafSyncStorage(folder) : FolderSyncStorage(folder);
    }

    try {
      final svc = SyncService(repo, crypto, storage);
      final r = await svc.syncNow(pass);
      await settings.setSyncLast(DateTime.now());
      dlog('sync: done merged=${r.merged}');
      return r.merged;
    } on BackupAuthException {
      // Wrong passphrase — keep the Drive connection; only the passphrase is off.
      dlog('sync: ERROR passphrase mismatch');
      rethrow;
    } catch (e) {
      // Any other failure on the Drive provider (auth/refresh/transport) drops
      // the connection so the user must reconnect (fresh consent) — a broken
      // refresh token can't recover on its own.
      dlog('sync: ERROR $e');
      if (provider == 'drive') {
        dlog('sync: disconnecting Drive after failure');
        try {
          await driveAuth.signOut();
        } catch (_) {/* ignore */}
      }
      rethrow;
    }
  }

  /// Best-effort background push (after a local change) — never throws.
  Future<void> syncQuietly() async {
    try {
      await syncNow();
    } catch (_) {/* ignore — manual sync surfaces errors */}
  }

  /// Strip purged tombstones from the remote file so an "empty trash" sticks
  /// (otherwise the next merge re-adds them). Best-effort; never throws.
  /// [ids] null = all tombstones; otherwise only those ids.
  Future<void> purgeRemoteTombstones({Set<String>? ids}) async {
    try {
      if (!await settings.getSyncEnabled()) return;
      final pass = await settings.getSyncPassphrase();
      if (pass == null || pass.isEmpty) return;
      final provider = await settings.getSyncProvider();
      final SyncStorage storage;
      if (provider == 'drive') {
        final api = await driveAuth.driveApi();
        if (api == null) return;
        storage = DriveSyncStorage(api);
      } else {
        final folder = await settings.getSyncFolder();
        if (folder == null) return;
        storage =
            Platform.isAndroid ? SafSyncStorage(folder) : FolderSyncStorage(folder);
      }
      await SyncService(repo, crypto, storage).purgeTombstones(pass, ids: ids);
      dlog('purge: stripped remote tombstones (${ids == null ? "all" : ids.length})');
    } catch (e) {
      dlog('purge: remote strip failed $e');
    }
  }
}
