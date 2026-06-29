// Drive sync orchestration — mirrors the app's sync_service.dart:
// pull remote → merge (title + newest updatedAt, tombstone aware) → re-check
// remote right before writing (lost-update guard) → push. The cloud only ever
// holds the passphrase-encrypted .tmbk blob.
//
// Runs only while the vault is UNLOCKED (popup), because merging requires the
// session vault passphrase to read/rewrite local entries — which is never
// persisted. So there is no background auto-sync; the popup syncs on unlock and
// on demand ("Sync now").

import { exportTmbk, importTmbk } from './crypto';
import { dlog } from './debuglog';
import type { TokenEntry } from './domain';
import * as drive from './drive';
import { mergeByTitle } from './merge';

function bytesEqual(a: Uint8Array, b: Uint8Array): boolean {
  if (a.length !== b.length) return false;
  for (let i = 0; i < a.length; i++) if (a[i] !== b[i]) return false;
  return true;
}

async function encode(syncPass: string, entries: TokenEntry[]): Promise<Uint8Array> {
  return exportTmbk(syncPass, JSON.stringify(entries));
}

async function decode(syncPass: string, bytes: Uint8Array): Promise<TokenEntry[]> {
  return JSON.parse(await importTmbk(syncPass, bytes)) as TokenEntry[];
}

/** One full sync cycle. Returns the merged entry set (tombstones included) for
 *  the caller to persist into the local vault. Throws BackupAuthError on a
 *  wrong sync passphrase / corrupt remote, DriveAuthError/DriveConfigError on
 *  transport/config problems. */
export async function syncNow(
  syncPass: string,
  localAll: TokenEntry[],
  interactive: boolean,
): Promise<TokenEntry[]> {
  dlog(`syncNow: start interactive=${interactive} local=${localAll.length}`);
  const remoteBytes = await drive.download(interactive);
  if (remoteBytes == null) {
    // First sync: seed the folder with the local snapshot.
    dlog('syncNow: remote empty — seeding');
    await drive.upload(interactive, await encode(syncPass, localAll));
    return localAll;
  }
  const remote = await decode(syncPass, remoteBytes);
  const tomb = (a: TokenEntry[]) => a.filter((e) => e.deletedAt != null).length;
  dlog(`syncNow: remote ${remoteBytes.length}B entries=${remote.length} (tomb local=${tomb(localAll)} remote=${tomb(remote)}) — merging`);

  let merged = mergeByTitle(localAll, remote);

  // Lost-update guard: re-read just before writing; fold in any change made
  // while we were merging/encrypting.
  const beforeWrite = await drive.download(interactive);
  if (beforeWrite != null && !bytesEqual(beforeWrite, remoteBytes)) {
    merged = mergeByTitle(merged, await decode(syncPass, beforeWrite));
  }

  // Diagnostic: detect deletions undone by the merge (local tombstone -> live).
  const locTomb = new Map(
    localAll.filter((e) => e.deletedAt != null).map((e) => [e.id, e]),
  );
  for (const m of merged) {
    if (m.deletedAt == null && locTomb.has(m.id)) {
      const lt = locTomb.get(m.id)!;
      dlog(`RESURRECTED "${m.serviceName}" localTombUpdatedAt=${lt.updatedAt} < remoteLiveUpdatedAt=${m.updatedAt} (Δ=${m.updatedAt - lt.updatedAt}ms)`);
    }
  }

  await drive.upload(interactive, await encode(syncPass, merged));
  dlog(`syncNow: pushed merged=${merged.length} tomb=${tomb(merged)}`);
  return merged;
}
