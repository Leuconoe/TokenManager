// Design Ref: §4.1 — TokenRepository contract + Drift implementation.

import 'package:drift/drift.dart';

import '../../../core/db/app_database.dart';
import '../../../core/domain/token_entry.dart';
import '../../../core/domain/token_status.dart';

enum TokenSort { expiry, created, name, site }

abstract interface class TokenRepository {
  /// Active (non-deleted) entries.
  Future<List<TokenEntry>> list({TokenSort sort, bool ascending});

  /// ALL rows including tombstones (deletedAt != null) — for sync/backup.
  Future<List<TokenEntry>> listAll();

  Future<TokenEntry?> getById(String id);
  Future<void> upsert(TokenEntry entry);

  /// Soft delete (tombstone) so the deletion can be synced.
  Future<void> delete(String id);

  /// Tombstoned entries (deletedAt != null), newest deletion first.
  Future<List<TokenEntry>> listDeleted();

  /// Un-delete a tombstone (revives + bumps updatedAt so the revive syncs).
  Future<void> restore(String id);

  /// Hard-delete a single row (permanent purge — local only).
  Future<void> purge(String id);

  /// Hard-delete all tombstones (permanent purge — local only).
  Future<int> purgeAllDeleted();

  /// Auto-purge tombstones whose deletion is older than [cutoff] (housekeeping,
  /// assumes all devices have synced the deletion by then).
  Future<int> purgeDeletedBefore(DateTime cutoff);

  /// Hard-wipe every row (used by overwrite-restore). Bypasses tombstones.
  Future<void> clearAll();

  /// Groups active entries by derived status (for notifications).
  Future<Map<TokenStatus, List<TokenEntry>>> scanStatus({
    DateTime? now,
    int soonDays,
  });
}

class DriftTokenRepository implements TokenRepository {
  final AppDatabase _db;
  DriftTokenRepository(this._db);

  @override
  Future<List<TokenEntry>> list(
      {TokenSort sort = TokenSort.expiry, bool ascending = true}) async {
    final rows = await (_db.select(_db.tokenEntries)
          ..where((t) => t.deletedAt.isNull()))
        .get();
    final entries = rows.map(_toEntry).toList();
    _applySort(entries, sort, ascending);
    return entries;
  }

  @override
  Future<List<TokenEntry>> listAll() async {
    final rows = await _db.select(_db.tokenEntries).get();
    return rows.map(_toEntry).toList();
  }

  @override
  Future<TokenEntry?> getById(String id) async {
    final row = await (_db.select(_db.tokenEntries)
          ..where((t) => t.id.equals(id)))
        .getSingleOrNull();
    return row == null ? null : _toEntry(row);
  }

  @override
  Future<void> upsert(TokenEntry entry) =>
      _db.into(_db.tokenEntries).insertOnConflictUpdate(_toCompanion(entry));

  @override
  Future<void> delete(String id) async {
    // Soft delete: mark tombstone so the deletion propagates via sync.
    // updatedAt is bumped past the row's own value so the tombstone always
    // supersedes the copy it was applied to — even if that copy carries a
    // future timestamp from a clock-skewed device (otherwise it resurrects).
    final now = DateTime.now().millisecondsSinceEpoch;
    final existing = await getById(id);
    final bumped = (existing != null && existing.updatedAt.millisecondsSinceEpoch >= now)
        ? existing.updatedAt.millisecondsSinceEpoch + 1
        : now;
    await (_db.update(_db.tokenEntries)..where((t) => t.id.equals(id))).write(
      TokenEntriesCompanion(
        deletedAt: Value(now),
        updatedAt: Value(bumped),
      ),
    );
  }

  @override
  Future<List<TokenEntry>> listDeleted() async {
    final rows = await (_db.select(_db.tokenEntries)
          ..where((t) => t.deletedAt.isNotNull()))
        .get();
    final entries = rows.map(_toEntry).toList();
    entries.sort((a, b) => (b.deletedAt ?? b.updatedAt)
        .compareTo(a.deletedAt ?? a.updatedAt)); // newest deletion first
    return entries;
  }

  @override
  Future<void> restore(String id) async {
    final now = DateTime.now().millisecondsSinceEpoch;
    final existing = await getById(id);
    final bumped = (existing != null && existing.updatedAt.millisecondsSinceEpoch >= now)
        ? existing.updatedAt.millisecondsSinceEpoch + 1
        : now;
    await (_db.update(_db.tokenEntries)..where((t) => t.id.equals(id))).write(
      TokenEntriesCompanion(
        deletedAt: const Value(null),
        updatedAt: Value(bumped),
      ),
    );
  }

  @override
  Future<void> purge(String id) async {
    await (_db.delete(_db.tokenEntries)..where((t) => t.id.equals(id))).go();
  }

  @override
  Future<int> purgeAllDeleted() =>
      (_db.delete(_db.tokenEntries)..where((t) => t.deletedAt.isNotNull())).go();

  @override
  Future<int> purgeDeletedBefore(DateTime cutoff) =>
      (_db.delete(_db.tokenEntries)
            ..where((t) => t.deletedAt.isSmallerThanValue(cutoff.millisecondsSinceEpoch)))
          .go();

  @override
  Future<void> clearAll() => _db.delete(_db.tokenEntries).go();

  @override
  Future<Map<TokenStatus, List<TokenEntry>>> scanStatus({
    DateTime? now,
    int soonDays = TokenStatus.defaultSoonDays,
  }) async {
    final ref = now ?? DateTime.now();
    final all = await list();
    final map = {for (final s in TokenStatus.values) s: <TokenEntry>[]};
    for (final e in all) {
      map[e.statusAt(ref, soonDays: soonDays)]!.add(e);
    }
    return map;
  }

  // --- mapping helpers ---

  TokenEntry _toEntry(TokenEntryRow r) => TokenEntry(
        id: r.id,
        serviceName: r.serviceName,
        url: r.url,
        issuedAt: _ms(r.issuedAt),
        expiresAt: _ms(r.expiresAt),
        note: r.note,
        createdAt: _ms(r.createdAt)!,
        updatedAt: _ms(r.updatedAt)!,
        deletedAt: _ms(r.deletedAt),
      );

  TokenEntriesCompanion _toCompanion(TokenEntry e) => TokenEntriesCompanion(
        id: Value(e.id),
        serviceName: Value(e.serviceName),
        url: Value(e.url),
        issuedAt: Value(e.issuedAt?.millisecondsSinceEpoch),
        expiresAt: Value(e.expiresAt?.millisecondsSinceEpoch),
        note: Value(e.note),
        createdAt: Value(e.createdAt.millisecondsSinceEpoch),
        updatedAt: Value(e.updatedAt.millisecondsSinceEpoch),
        deletedAt: Value(e.deletedAt?.millisecondsSinceEpoch),
      );

  static DateTime? _ms(int? v) =>
      v == null ? null : DateTime.fromMillisecondsSinceEpoch(v);

  void _applySort(List<TokenEntry> list, TokenSort sort, bool ascending) {
    final dir = ascending ? 1 : -1;
    switch (sort) {
      case TokenSort.expiry:
        // no-expiry entries always sink to the bottom (both directions).
        list.sort((a, b) {
          if (a.expiresAt == null && b.expiresAt == null) {
            return a.serviceName.toLowerCase().compareTo(b.serviceName.toLowerCase());
          }
          if (a.expiresAt == null) return 1;
          if (b.expiresAt == null) return -1;
          return dir * a.expiresAt!.compareTo(b.expiresAt!);
        });
      case TokenSort.created:
        list.sort((a, b) => dir * a.createdAt.compareTo(b.createdAt));
      case TokenSort.name:
        list.sort((a, b) =>
            dir * a.serviceName.toLowerCase().compareTo(b.serviceName.toLowerCase()));
      case TokenSort.site:
        list.sort((a, b) => dir * a.url.toLowerCase().compareTo(b.url.toLowerCase()));
    }
  }
}
