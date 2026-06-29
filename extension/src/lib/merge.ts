// Sync merge — keyed by serviceName (title). Port of the app's sync_merge.dart.
// Resolution is a deterministic total order so every device converges to the
// same winner regardless of merge order: newest updatedAt wins; on a tie a
// tombstone wins (delete beats a concurrent edit); still tied, higher id wins.
// Tombstones (deletedAt != null) are normal entries, so a later deletion
// propagates and a later edit revives/overrides.

import type { TokenEntry } from './domain';

/** True if `cand` should replace `cur` as the winner for a title. */
function wins(cand: TokenEntry, cur: TokenEntry): boolean {
  if (cand.updatedAt !== cur.updatedAt) return cand.updatedAt > cur.updatedAt;
  const candTomb = cand.deletedAt != null;
  const curTomb = cur.deletedAt != null;
  if (candTomb !== curTomb) return candTomb; // tie -> deletion wins
  return cand.id > cur.id; // stable, order-independent final tiebreak
}

export function mergeByTitle(local: TokenEntry[], remote: TokenEntry[]): TokenEntry[] {
  const map = new Map<string, TokenEntry>();
  const consider = (e: TokenEntry) => {
    const cur = map.get(e.serviceName);
    if (!cur || wins(e, cur)) map.set(e.serviceName, e);
  };
  for (const e of local) consider(e);
  for (const e of remote) consider(e);
  return [...map.values()];
}
