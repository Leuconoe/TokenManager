// Design Ref: §3.4, §7 (#5) — passphrase-based backup cipher.
// Argon2id KDF (64 MiB / 3 iter / 1 par) + AES-256-GCM.
// File format (§3.4): header(plaintext JSON) + '\n' + base64(ciphertext).
//
// This class is pure Dart (the `cryptography` package needs no native build),
// so it is unit-testable without Flutter platform plugins.

import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';

import 'package:cryptography/cryptography.dart';

/// Thrown when decryption fails authentication (wrong passphrase or tampering).
/// Maps to error code E-BAK-01.
class BackupAuthException implements Exception {
  final String message;
  BackupAuthException([this.message = '비밀번호가 올바르지 않거나 백업이 손상되었습니다']);
  @override
  String toString() => 'BackupAuthException: $message';
}

/// Thrown when the backup file header is malformed / unsupported (E-BAK-02).
class BackupFormatException implements Exception {
  final String message;
  BackupFormatException(this.message);
  @override
  String toString() => 'BackupFormatException: $message';
}

class BackupCipher {
  static const String _magic = 'TokenManagerBackup';
  static const int _version = 1;
  static const int _saltLen = 16;
  static const int _nonceLen = 12;
  static const int _memKiB = 65536; // 64 MiB
  static const int _iterations = 3;
  static const int _parallelism = 1;
  static const int _keyLen = 32; // 256-bit

  final AesGcm _aead = AesGcm.with256bits();

  Argon2id _kdf() => Argon2id(
        memory: _memKiB,
        iterations: _iterations,
        parallelism: _parallelism,
        hashLength: _keyLen,
      );

  /// Encrypts [plain] under [passphrase], returning the full backup blob.
  Future<Uint8List> encrypt(Uint8List plain, String passphrase) async {
    final salt = _randomBytes(_saltLen);
    final nonce = _randomBytes(_nonceLen);
    final secretKey = await _kdf().deriveKeyFromPassword(
      password: passphrase,
      nonce: salt,
    );
    final box = await _aead.encrypt(plain, secretKey: secretKey, nonce: nonce);

    final header = <String, dynamic>{
      'magic': _magic,
      'version': _version,
      'kdf': 'argon2id',
      'params': {'memKiB': _memKiB, 'iter': _iterations, 'par': _parallelism},
      'salt': base64.encode(salt),
      'nonce': base64.encode(nonce),
      'mac': base64.encode(box.mac.bytes),
    };
    final out = '${jsonEncode(header)}\n${base64.encode(box.cipherText)}';
    return Uint8List.fromList(utf8.encode(out));
  }

  /// Decrypts a backup blob produced by [encrypt]. Throws [BackupAuthException]
  /// on wrong passphrase, [BackupFormatException] on malformed input.
  Future<Uint8List> decrypt(Uint8List file, String passphrase) async {
    final text = utf8.decode(file, allowMalformed: true);
    final nl = text.indexOf('\n');
    if (nl < 0) throw BackupFormatException('헤더 구분자가 없습니다');

    final Map<String, dynamic> header;
    try {
      header = jsonDecode(text.substring(0, nl)) as Map<String, dynamic>;
    } catch (_) {
      throw BackupFormatException('헤더 JSON이 유효하지 않습니다');
    }
    if (header['magic'] != _magic) {
      throw BackupFormatException('TokenManager 백업 파일이 아닙니다');
    }
    if (header['version'] != _version) {
      throw BackupFormatException('지원하지 않는 백업 버전: ${header['version']}');
    }

    final salt = base64.decode(header['salt'] as String);
    final nonce = base64.decode(header['nonce'] as String);
    final mac = base64.decode(header['mac'] as String);
    final cipherText = base64.decode(text.substring(nl + 1).trim());

    final secretKey = await _kdf().deriveKeyFromPassword(
      password: passphrase,
      nonce: salt,
    );
    try {
      final clear = await _aead.decrypt(
        SecretBox(cipherText, nonce: nonce, mac: Mac(mac)),
        secretKey: secretKey,
      );
      return Uint8List.fromList(clear);
    } on SecretBoxAuthenticationError {
      throw BackupAuthException();
    }
  }

  static Uint8List _randomBytes(int n) {
    final r = Random.secure();
    return Uint8List.fromList(List<int>.generate(n, (_) => r.nextInt(256)));
  }
}
