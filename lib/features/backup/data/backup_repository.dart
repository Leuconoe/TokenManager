// Design Ref: §3.4, §F7 — passphrase backup export / import.

import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import '../../../core/domain/crypto_port.dart';
import '../../../core/domain/token_entry.dart';
import '../../tokens/data/token_repository.dart';

enum ImportMode { merge, overwrite }

class BackupResult {
  final int count;
  const BackupResult(this.count);
}

class BackupRepository {
  final TokenRepository _tokens;
  final CryptoPort _crypto;
  BackupRepository(this._tokens, this._crypto);

  /// Serializes all entries → encrypts with [passphrase] → returns blob bytes.
  /// Caller persists via SAF (file_picker.saveFile) or share sheet.
  Future<Uint8List> exportBytes(String passphrase) async {
    final all = await _tokens.list();
    final json = jsonEncode(all.map((e) => e.toJson()).toList());
    final plain = Uint8List.fromList(utf8.encode(json));
    return _crypto.encryptBackup(plain, passphrase);
  }

  /// Writes the encrypted blob to [path].
  Future<File> exportToFile(String path, String passphrase) async {
    final bytes = await exportBytes(passphrase);
    final file = File(path);
    await file.writeAsBytes(bytes, flush: true);
    return file;
  }

  /// Decrypts [file] with [passphrase] and applies entries.
  /// merge: upsert by id (keep others). overwrite: replace all.
  /// Throws BackupAuthException / BackupFormatException on failure.
  Future<BackupResult> import(
    File file,
    String passphrase,
    ImportMode mode,
  ) async {
    final cipher = await file.readAsBytes();
    final plain = await _crypto.decryptBackup(cipher, passphrase);
    final list = (jsonDecode(utf8.decode(plain)) as List)
        .map((e) => TokenEntry.fromJson(e as Map<String, dynamic>))
        .toList();

    if (mode == ImportMode.overwrite) {
      for (final existing in await _tokens.list()) {
        await _tokens.delete(existing.id);
      }
    }
    for (final e in list) {
      await _tokens.upsert(e);
    }
    return BackupResult(list.length);
  }
}
