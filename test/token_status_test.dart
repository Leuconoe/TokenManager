// L1 unit tests — Design §8.2 (#3-5): TokenStatus derivation.

import 'package:flutter_test/flutter_test.dart';
import 'package:token_manager/core/domain/token_status.dart';

void main() {
  final now = DateTime(2026, 6, 12, 12, 0, 0);

  group('TokenStatus.compute', () {
    test('null expiry -> noExpiry', () {
      expect(TokenStatus.compute(null, now), TokenStatus.noExpiry);
    });

    test('expiry in the past -> expired', () {
      expect(
        TokenStatus.compute(now.subtract(const Duration(days: 1)), now),
        TokenStatus.expired,
      );
    });

    test('expiry exactly now -> expired', () {
      expect(TokenStatus.compute(now, now), TokenStatus.expired);
    });

    test('expiry in 10 days -> expiringSoon', () {
      expect(
        TokenStatus.compute(now.add(const Duration(days: 10)), now),
        TokenStatus.expiringSoon,
      );
    });

    test('expiry exactly at 14-day boundary -> expiringSoon', () {
      expect(
        TokenStatus.compute(now.add(const Duration(days: 14)), now),
        TokenStatus.expiringSoon,
      );
    });

    test('expiry in 30 days -> valid', () {
      expect(
        TokenStatus.compute(now.add(const Duration(days: 30)), now),
        TokenStatus.valid,
      );
    });

    test('custom soonDays window respected', () {
      expect(
        TokenStatus.compute(now.add(const Duration(days: 20)), now,
            soonDays: 30),
        TokenStatus.expiringSoon,
      );
    });
  });
}
