// Plaintext preferences readable by the background worker (not sensitive).

// Two DISTINCT timings:
//  - ExpiryLead: how many days BEFORE expiry to warn (tokens WITH expiry).
//  - NoExpiryInterval: cadence of the warning for tokens WITHOUT expiry.
export type ExpiryLead = '7' | '14' | '30';
export type NoExpiryInterval = 'off' | '15' | '30';

export const EXPIRY_LEAD_KEY = 'tm_expiry_lead_v1';
export const NOEXPIRY_INTERVAL_KEY = 'tm_noexpiry_interval_v1';
export const NOEXPIRY_LAST_KEY = 'tm_noexpiry_last_v1';
// Drive sync passphrase (must match the app's sync passphrase + other devices).
// Stored in chrome.storage.local so the background worker can sync; this is a
// deliberate tradeoff (storage.local is not encrypted at rest) — it only
// unlocks the synced .tmbk, never the local vault (whose passphrase is never
// persisted). Leave it unset to sync only manually from the popup.
export const SYNC_PASS_KEY = 'tm_sync_pass_v1';
export const SYNC_LAST_KEY = 'tm_sync_last_v1';

export async function getExpiryLead(): Promise<ExpiryLead> {
  const r = await chrome.storage.local.get(EXPIRY_LEAD_KEY);
  const v = r[EXPIRY_LEAD_KEY];
  return v === '7' || v === '14' || v === '30' ? v : '14'; // default 14 days
}

export async function setExpiryLead(v: ExpiryLead): Promise<void> {
  await chrome.storage.local.set({ [EXPIRY_LEAD_KEY]: v });
}

export async function getNoExpiryInterval(): Promise<NoExpiryInterval> {
  const r = await chrome.storage.local.get(NOEXPIRY_INTERVAL_KEY);
  const v = r[NOEXPIRY_INTERVAL_KEY];
  return v === 'off' || v === '15' || v === '30' ? v : '30'; // default 30 days
}

export async function setNoExpiryInterval(v: NoExpiryInterval): Promise<void> {
  await chrome.storage.local.set({ [NOEXPIRY_INTERVAL_KEY]: v });
  // Reset the warning clock so a new cadence takes effect predictably.
  await chrome.storage.local.remove(NOEXPIRY_LAST_KEY);
}

export async function getSyncPassphrase(): Promise<string | null> {
  const r = await chrome.storage.local.get(SYNC_PASS_KEY);
  return (r[SYNC_PASS_KEY] as string | undefined) ?? null;
}

export async function setSyncPassphrase(p: string | null): Promise<void> {
  if (p == null || p === '') await chrome.storage.local.remove(SYNC_PASS_KEY);
  else await chrome.storage.local.set({ [SYNC_PASS_KEY]: p });
}

export async function getSyncLast(): Promise<number | null> {
  const r = await chrome.storage.local.get(SYNC_LAST_KEY);
  return (r[SYNC_LAST_KEY] as number | undefined) ?? null;
}

export async function setSyncLast(ms: number): Promise<void> {
  await chrome.storage.local.set({ [SYNC_LAST_KEY]: ms });
}
