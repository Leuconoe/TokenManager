// Encrypted vault persisted in chrome.storage.local, unlocked per session
// with a passphrase (Argon2id-derived key). Token metadata only.

import { SOON_DAYS, type TokenEntry } from './domain';
import { decryptVault, encryptVault, type VaultBlob } from './crypto';

const KEY = 'tm_vault_v1';
const SCHEDULE_KEY = 'tm_schedule_v1';

/** Plaintext expiry schedule for the background worker — DATES/COUNTS ONLY,
 * no service names/URLs/notes (the worker has no passphrase to decrypt). */
export interface Schedule {
  soonDays: number;
  expiries: number[]; // epoch ms of entries that have an expiry
  noExpiry: number; // count of entries without expiry
}

async function loadBlob(): Promise<VaultBlob | null> {
  const r = await chrome.storage.local.get(KEY);
  return (r[KEY] as VaultBlob | undefined) ?? null;
}

/** True if a vault already exists (passphrase was set before). */
export async function vaultExists(): Promise<boolean> {
  return (await loadBlob()) !== null;
}

/** Unlock with passphrase → entries. Throws on wrong passphrase. */
export async function unlock(passphrase: string): Promise<TokenEntry[]> {
  const blob = await loadBlob();
  if (!blob) return []; // first run: empty until first save sets passphrase
  const json = await decryptVault(passphrase, blob);
  return JSON.parse(json) as TokenEntry[];
}

/** Encrypt + persist the full entry set under the session passphrase, and
 * refresh the plaintext expiry schedule the background worker reads. */
export async function save(passphrase: string, entries: TokenEntry[]): Promise<void> {
  const blob = await encryptVault(passphrase, JSON.stringify(entries));
  const schedule: Schedule = {
    soonDays: SOON_DAYS,
    expiries: entries.filter((e) => e.expiresAt != null).map((e) => e.expiresAt!),
    noExpiry: entries.filter((e) => e.expiresAt == null).length,
  };
  await chrome.storage.local.set({ [KEY]: blob, [SCHEDULE_KEY]: schedule });
}
