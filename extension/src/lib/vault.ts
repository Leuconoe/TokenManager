// Encrypted vault persisted in chrome.storage.local, unlocked per session
// with a passphrase (Argon2id-derived key). Token metadata only.

import type { TokenEntry } from './domain';
import { decryptVault, encryptVault, type VaultBlob } from './crypto';

const KEY = 'tm_vault_v1';

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

/** Encrypt + persist the full entry set under the session passphrase. */
export async function save(passphrase: string, entries: TokenEntry[]): Promise<void> {
  const blob = await encryptVault(passphrase, JSON.stringify(entries));
  await chrome.storage.local.set({ [KEY]: blob });
}
