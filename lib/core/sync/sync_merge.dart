// Sync merge — keyed by serviceName (title). Resolution is a deterministic
// total order so every device converges to the same winner regardless of merge
// order: newest updatedAt wins; on a tie a tombstone wins (a delete beats a
// concurrent edit); still tied, higher id wins. Tombstones (deletedAt != null)
// are normal entries here, so a later deletion propagates and a later edit
// revives/overrides. Pure & unit-tested.

import '../domain/token_entry.dart';

/// True if [cand] should replace [cur] as the winner for a title.
bool _wins(TokenEntry cand, TokenEntry cur) {
  if (cand.updatedAt != cur.updatedAt) return cand.updatedAt.isAfter(cur.updatedAt);
  final candTomb = cand.deletedAt != null;
  final curTomb = cur.deletedAt != null;
  if (candTomb != curTomb) return candTomb; // tie -> deletion wins
  return cand.id.compareTo(cur.id) > 0; // stable, order-independent tiebreak
}

List<TokenEntry> mergeByTitle(List<TokenEntry> local, List<TokenEntry> remote) {
  final map = <String, TokenEntry>{};
  void consider(TokenEntry e) {
    final cur = map[e.serviceName];
    if (cur == null || _wins(e, cur)) {
      map[e.serviceName] = e;
    }
  }

  for (final e in local) {
    consider(e);
  }
  for (final e in remote) {
    consider(e);
  }
  return map.values.toList();
}
