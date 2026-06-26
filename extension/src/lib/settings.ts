// Plaintext preferences readable by the background worker (not sensitive).

// Two DISTINCT timings:
//  - ExpiryLead: how many days BEFORE expiry to warn (tokens WITH expiry).
//  - NoExpiryInterval: cadence of the warning for tokens WITHOUT expiry.
export type ExpiryLead = '7' | '14' | '30';
export type NoExpiryInterval = 'off' | '15' | '30';

export const EXPIRY_LEAD_KEY = 'tm_expiry_lead_v1';
export const NOEXPIRY_INTERVAL_KEY = 'tm_noexpiry_interval_v1';
export const NOEXPIRY_LAST_KEY = 'tm_noexpiry_last_v1';

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
