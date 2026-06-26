// Design Ref: §4.1 — TokenRepository contract + Drift implementation.

import 'package:drift/drift.dart';

import '../../../core/db/app_database.dart';
import '../../../core/domain/token_entry.dart';
import '../../../core/domain/token_status.dart';

enum TokenSort { expirySoonest, serviceName, recentlyUpdated }

abstract interface class TokenRepository {
  /// Active (non-deleted) entries.
  Future<List<TokenEntry>> list({TokenSort sort});

  /// ALL rows including tombstones (deletedAt != null) — for sync/backup.
  Future<List<TokenEntry>> listAll();

  Future<TokenEntry?> getById(String id);
  Future<void> upsert(TokenEntry entry);

  /// Soft delete (tombstone) so the deletion can be synced.
  Future<void> delete(String id);

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
  Future<List<TokenEntry>> list({TokenSort sort = TokenSort.expirySoonest}) async {
    final rows = await (_db.select(_db.tokenEntries)
          ..where((t) => t.deletedAt.isNull()))
        .get();
    final entries = rows.map(_toEntry).toList();
    _applySort(entries, sort);
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
    final now = DateTime.now().millisecondsSinceEpoch;
    await (_db.update(_db.tokenEntries)..where((t) => t.id.equals(id))).write(
      TokenEntriesCompanion(
        deletedAt: Value(now),
        updatedAt: Value(now),
      ),
    );
  }

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

  void _applySort(List<TokenEntry> list, TokenSort sort) {
    switch (sort) {
      case TokenSort.expirySoonest:
        // soonest expiry first; no-expiry entries sink to the bottom.
        list.sort((a, b) {
          if (a.expiresAt == null && b.expiresAt == null) {
            return a.serviceName.toLowerCase().compareTo(b.serviceName.toLowerCase());
          }
          if (a.expiresAt == null) return 1;
          if (b.expiresAt == null) return -1;
          return a.expiresAt!.compareTo(b.expiresAt!);
        });
      case TokenSort.serviceName:
        list.sort((a, b) =>
            a.serviceName.toLowerCase().compareTo(b.serviceName.toLowerCase()));
      case TokenSort.recentlyUpdated:
        list.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
    }
  }
}
