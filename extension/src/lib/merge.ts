// Sync merge — keyed by serviceName (title), newest updatedAt wins. Port of the
// app's sync_merge.dart. Tombstones (deletedAt != null) are normal entries, so a
// later deletion propagates and a later edit revives/overrides.

import type { TokenEntry } from './domain';

export function mergeByTitle(local: TokenEntry[], remote: TokenEntry[]): TokenEntry[] {
  const map = new Map<string, TokenEntry>();
  const consider = (e: TokenEntry) => {
    const cur = map.get(e.serviceName);
    if (!cur || e.updatedAt > cur.updatedAt) map.set(e.serviceName, e);
  };
  for (const e of local) consider(e);
  for (const e of remote) consider(e);
  return [...map.values()];
}
