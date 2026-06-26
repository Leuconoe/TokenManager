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
  /// Throws BackupAuthException on wrong passphrase / corrupt remote.
  Future<SyncResult> syncNow(String passphrase) async {
    final localAll = await repo.listAll();

    final remoteBytes = await storage.read();
    if (remoteBytes == null) {
      // First sync from this folder: seed it with the local snapshot.
      await storage.write(await _encode(passphrase, localAll));
      return const SyncResult(0, true);
    }

    final remoteAll = await _decode(passphrase, remoteBytes);
    final merged = mergeByTitle(localAll, remoteAll);

    // Apply merged locally (id-keyed upsert; tombstones included).
    for (final e in merged) {
      await repo.upsert(e);
    }
    // Push the merged snapshot back.
    await storage.write(await _encode(passphrase, merged));
    return SyncResult(merged.length, true);
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
