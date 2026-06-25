// Design Ref: §2.1, §4.1 — Crypto isolation port (Domain layer, no impl deps).
// The 2-key model lives behind this single interface:
//   - loadOrCreateDbKey(): device-bound at-rest key (Android Keystore)
//   - encrypt/decryptBackup(): portable passphrase-derived key (Argon2id)

import 'dart:typed_data';

abstract interface class CryptoPort {
  /// Returns the 256-bit DB key as 64-char lowercase hex.
  /// First call generates a random key and stores it in hardware-backed
  /// Keystore (never present in code/APK). Subsequent calls load it.
  Future<String> loadOrCreateDbKey();

  /// Encrypts [plain] into a self-describing backup blob using [passphrase].
  Future<Uint8List> encryptBackup(Uint8List plain, String passphrase);

  /// Decrypts a backup blob. Throws on wrong passphrase / tampered data.
  Future<Uint8List> decryptBackup(Uint8List cipher, String passphrase);
}
