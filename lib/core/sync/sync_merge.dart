// Sync merge — keyed by serviceName (title), newest updatedAt wins.
// Tombstones (deletedAt != null) are normal entries here, so a later deletion
// propagates and a later edit revives/overrides. Pure & unit-tested.

import '../domain/token_entry.dart';

List<TokenEntry> mergeByTitle(List<TokenEntry> local, List<TokenEntry> remote) {
  final map = <String, TokenEntry>{};
  void consider(TokenEntry e) {
    final cur = map[e.serviceName];
    if (cur == null || e.updatedAt.isAfter(cur.updatedAt)) {
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
