// L1 unit tests — Design §8.2 (#1-2): backup cipher roundtrip + auth failure.

import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:token_manager/core/crypto/passphrase_crypto.dart';

void main() {
  final cipher = BackupCipher();
  final plain = Uint8List.fromList(
    utf8.encode('[{"id":"1","serviceName":"GitHub PAT"}]'),
  );

  group('BackupCipher', () {
    test('roundtrip with correct passphrase returns original', () async {
      final enc = await cipher.encrypt(plain, 'correct horse battery staple');
      final dec = await cipher.decrypt(enc, 'correct horse battery staple');
      expect(dec, equals(plain));
    }, timeout: const Timeout(Duration(minutes: 2)));

    test('wrong passphrase throws BackupAuthException', () async {
      final enc = await cipher.encrypt(plain, 'right-passphrase');
      await expectLater(
        cipher.decrypt(enc, 'wrong-passphrase'),
        throwsA(isA<BackupAuthException>()),
      );
    }, timeout: const Timeout(Duration(minutes: 2)));

    test('non-backup data throws BackupFormatException', () async {
      final garbage = Uint8List.fromList(utf8.encode('not a backup file'));
      await expectLater(
        cipher.decrypt(garbage, 'whatever'),
        throwsA(isA<BackupFormatException>()),
      );
    });

    test('header advertises argon2id + version 1', () async {
      final enc = await cipher.encrypt(plain, 'pw');
      final text = utf8.decode(enc);
      final header =
          jsonDecode(text.substring(0, text.indexOf('\n'))) as Map<String, dynamic>;
      expect(header['kdf'], 'argon2id');
      expect(header['version'], 1);
      expect(header['magic'], 'TokenManagerBackup');
    }, timeout: const Timeout(Duration(minutes: 2)));
  });
}
