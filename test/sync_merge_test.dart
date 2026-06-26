// L1 unit tests — sync merge: title key, newest updatedAt wins, tombstone-aware.

import 'package:flutter_test/flutter_test.dart';
import 'package:token_manager/core/domain/token_entry.dart';
import 'package:token_manager/core/sync/sync_merge.dart';

TokenEntry e(
  String title, {
  required int updated,
  bool deleted = false,
  String note = '',
}) {
  final ms = DateTime(2026).add(Duration(minutes: updated));
  return TokenEntry(
    id: title, // stable id by title for the test
    serviceName: title,
    note: note,
    createdAt: DateTime(2026),
    updatedAt: ms,
    deletedAt: deleted ? ms : null,
  );
}

void main() {
  group('mergeByTitle', () {
    test('newer updatedAt wins for same title', () {
      final local = [e('GitHub', updated: 1, note: 'old')];
      final remote = [e('GitHub', updated: 5, note: 'new')];
      final m = mergeByTitle(local, remote);
      expect(m.length, 1);
      expect(m.single.note, 'new');
    });

    test('later deletion propagates (tombstone wins)', () {
      final local = [e('AWS', updated: 2)]; // active, edited at t2
      final remote = [e('AWS', updated: 9, deleted: true)]; // deleted at t9
      final m = mergeByTitle(local, remote);
      expect(m.single.isDeleted, isTrue);
    });

    test('later edit overrides an older tombstone', () {
      final local = [e('Slack', updated: 9, deleted: true)];
      final remote = [e('Slack', updated: 3)];
      final m = mergeByTitle(local, remote);
      expect(m.single.isDeleted, isTrue); // local tombstone is newer
    });

    test('distinct titles are unioned', () {
      final m = mergeByTitle([e('A', updated: 1)], [e('B', updated: 1)]);
      expect(m.map((x) => x.serviceName).toSet(), {'A', 'B'});
    });
  });
}
