// Sync orchestration: pull remote → merge (title + newest updatedAt, tombstone
// aware) → persist locally → push merged. The synced file is a passphrase
// encrypted blob (same crypto as .tmbk); the cloud only ever holds ciphertext.

import 'dart:convert';
import 'dart:typed_data';

import '../domain/crypto_port.dart';
import '../domain/token_entry.dart';
import '../../features/tokens/data/token_repository.dart';
import 'sync_merge.dart';
import 'sync_storage.dart';

class SyncResult {
  final int merged;
  final bool pushed;
  const SyncResult(this.merged, this.pushed);
}

class SyncService {
  final TokenRepository repo;
  final CryptoPort crypto;
  final SyncStorage storage;

  SyncService(this.repo, this.crypto, this.storage);

  /// Runs one full sync cycle with [passphrase] (same as the backup passphrase).
  /// Never blindly overwrites: reads the remote, merges, and re-checks the
  /// remote one more time right before writing so a concurrent change made
  /// while we were working is merged in (not lost).
  /// Throws BackupAuthException on wrong passphrase / corrupt remote.
  Future<SyncResult> syncNow(String passphrase) async {
    final localAll = await repo.listAll();

    final remoteBytes = await storage.read();
    if (remoteBytes == null) {
      // First sync from this folder: seed it with the local snapshot.
      await storage.write(await _encode(passphrase, localAll));
      return const SyncResult(0, true);
    }

    var merged = mergeByTitle(localAll, await _decode(passphrase, remoteBytes));

    // Safety: re-read the remote just before writing. If it changed while we
    // were merging/encrypting, fold that newer copy in instead of clobbering.
    final beforeWrite = await storage.read();
    if (beforeWrite != null && !_bytesEqual(beforeWrite, remoteBytes)) {
      merged = mergeByTitle(merged, await _decode(passphrase, beforeWrite));
    }

    for (final e in merged) {
      await repo.upsert(e); // apply merged locally (tombstones included)
    }
    await storage.write(await _encode(passphrase, merged));
    return SyncResult(merged.length, true);
  }

  static bool _bytesEqual(Uint8List a, Uint8List b) {
    if (a.length != b.length) return false;
    for (var i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }

  /// Permanently remove tombstones from the remote file so an "empty trash"
  /// (or per-item purge) sticks instead of being re-added by the next merge.
  /// [ids] null = strip all tombstones; otherwise only those ids. Best-effort.
  Future<void> purgeTombstones(String passphrase, {Set<String>? ids}) async {
    final bytes = await storage.read();
    if (bytes == null) return;
    final entries = await _decode(passphrase, bytes);
    final kept = entries
        .where((e) =>
            e.deletedAt == null || (ids != null && !ids.contains(e.id)))
        .toList();
    if (kept.length != entries.length) {
      await storage.write(await _encode(passphrase, kept));
    }
  }

  Future<Uint8List> _encode(String passphrase, List<TokenEntry> entries) {
    final json = jsonEncode(entries.map((e) => e.toJson()).toList());
    return crypto.encryptBackup(Uint8List.fromList(utf8.encode(json)), passphrase);
  }

  Future<List<TokenEntry>> _decode(String passphrase, Uint8List bytes) async {
    final plain = await crypto.decryptBackup(bytes, passphrase);
    return (jsonDecode(utf8.decode(plain)) as List)
        .map((e) => TokenEntry.fromJson(e as Map<String, dynamic>))
        .toList();
  }
}
