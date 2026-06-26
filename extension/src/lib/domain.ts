// Mirrors the app's TokenEntry/TokenStatus. Token VALUES are never stored.

export type TokenStatus = 'valid' | 'expiringSoon' | 'expired' | 'noExpiry';

export interface TokenEntry {
  id: string;
  serviceName: string;
  url: string;
  issuedAt: number | null; // epoch ms
  expiresAt: number | null; // epoch ms, null = no expiry
  note: string;
  createdAt: number;
  updatedAt: number;
  deletedAt?: number | null; // epoch ms tombstone; null/absent = live (sync)
}

export const SOON_DAYS = 14;

/** Live (non-tombstoned) entries — what the UI and schedule should see. */
export function activeEntries(entries: TokenEntry[]): TokenEntry[] {
  return entries.filter((e) => e.deletedAt == null);
}

export function statusOf(
  e: TokenEntry,
  now: number = Date.now(),
  soonDays: number = SOON_DAYS,
): TokenStatus {
  if (e.expiresAt == null) return 'noExpiry';
  if (e.expiresAt <= now) return 'expired';
  if (e.expiresAt - now <= soonDays * 86_400_000) return 'expiringSoon';
  return 'valid';
}

export function uuid(): string {
  return crypto.randomUUID();
}
