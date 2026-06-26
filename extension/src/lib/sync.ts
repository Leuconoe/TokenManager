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
  dlog(`syncNow: remote ${remoteBytes.length}B — merging`);

  let merged = mergeByTitle(localAll, await decode(syncPass, remoteBytes));

  // Lost-update guard: re-read just before writing; fold in any change made
  // while we were merging/encrypting.
  const beforeWrite = await drive.download(interactive);
  if (beforeWrite != null && !bytesEqual(beforeWrite, remoteBytes)) {
    merged = mergeByTitle(merged, await decode(syncPass, beforeWrite));
  }

  await drive.upload(interactive, await encode(syncPass, merged));
  dlog(`syncNow: pushed merged=${merged.length}`);
  return merged;
}
