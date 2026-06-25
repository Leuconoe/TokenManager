// Design Ref: §2.1, §7 — CryptoPort implementation.
// SECURITY: the DB key is randomly generated on first launch and stored in
// flutter_secure_storage, which on Android is backed by the hardware Keystore
// (TEE/StrongBox). No key/seed material exists in the source or APK, so a
// decompiled binary reveals nothing and the key cannot be copied to another
// device. (Plan §1: device-bound encryption, no hardcoded seed.)

import 'dart:math';
import 'dart:typed_data';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../domain/crypto_port.dart';
import 'passphrase_crypto.dart';

class AppCryptoPort implements CryptoPort {
  static const String _dbKeyName = 'tm_db_key_hex_v1';

  final FlutterSecureStorage _storage;
  final BackupCipher _backup;

  AppCryptoPort({FlutterSecureStorage? storage, BackupCipher? backup})
      : _storage = storage ??
            const FlutterSecureStorage(
              aOptions: AndroidOptions(encryptedSharedPreferences: true),
            ),
        _backup = backup ?? BackupCipher();

  @override
  Future<String> loadOrCreateDbKey() async {
    final existing = await _storage.read(key: _dbKeyName);
    if (existing != null && _isHex64(existing)) return existing;

    // Generate a fresh 256-bit key. Random.secure() is a CSPRNG.
    final keyHex = _randomHex(32);
    await _storage.write(key: _dbKeyName, value: keyHex);
    return keyHex;
  }

  @override
  Future<Uint8List> encryptBackup(Uint8List plain, String passphrase) =>
      _backup.encrypt(plain, passphrase);

  @override
  Future<Uint8List> decryptBackup(Uint8List cipher, String passphrase) =>
      _backup.decrypt(cipher, passphrase);

  static bool _isHex64(String s) =>
      s.length == 64 && RegExp(r'^[0-9a-f]{64}$').hasMatch(s);

  static String _randomHex(int bytes) {
    final r = Random.secure();
    final sb = StringBuffer();
    for (var i = 0; i < bytes; i++) {
      sb.write(r.nextInt(256).toRadixString(16).padLeft(2, '0'));
    }
    return sb.toString();
  }
}
