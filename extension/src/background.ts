// MV3 service worker — periodic expiry + no-expiry reminders.
// Reads ONLY plaintext schedule/settings (dates, counts, cadence), never the
// encrypted vault (no passphrase here). Notifications are generic; details
// require unlocking the popup.

import type { Schedule } from './lib/vault';
import { NOEXPIRY_INTERVAL_KEY, NOEXPIRY_LAST_KEY } from './lib/settings';

const ALARM = 'tm-expiry-scan';
const SCHEDULE_KEY = 'tm_schedule_v1';
const DAY_MS = 86_400_000;

function ensureAlarm(): void {
  chrome.alarms.create(ALARM, { delayInMinutes: 1, periodInMinutes: 720 }); // 12h
}

chrome.runtime.onInstalled.addListener(ensureAlarm);
chrome.runtime.onStartup.addListener(ensureAlarm);

chrome.alarms.onAlarm.addListener((alarm) => {
  if (alarm.name === ALARM) void scan();
});

async function scan(): Promise<void> {
  const r = await chrome.storage.local.get([
    SCHEDULE_KEY,
    NOEXPIRY_INTERVAL_KEY,
    NOEXPIRY_LAST_KEY,
  ]);
  const s = r[SCHEDULE_KEY] as Schedule | undefined;
  if (!s) return;

  const now = Date.now();

  // --- Expiry / expiring-soon ---
  const soonMs = (s.soonDays ?? 14) * DAY_MS;
  let expired = 0;
  let soon = 0;
  for (const t of s.expiries ?? []) {
    if (t <= now) expired++;
    else if (t - now <= soonMs) soon++;
  }
  if (expired || soon) {
    const parts: string[] = [];
    if (expired) parts.push(`만료 ${expired}`);
    if (soon) parts.push(`임박 ${soon}`);
    notify('tm-expiry', `${parts.join(' · ')} — 토큰 보관함을 열어 확인하세요`);
  }

  // --- No-expiry periodic warning (off / 15 / 30 days) ---
  const interval = r[NOEXPIRY_INTERVAL_KEY] as string | undefined;
  const noExpiry = s.noExpiry ?? 0;
  if ((interval === '15' || interval === '30') && noExpiry > 0) {
    const days = parseInt(interval, 10);
    const last = r[NOEXPIRY_LAST_KEY] as number | undefined;
    if (last == null || now - last >= days * DAY_MS) {
      notify('tm-noexpiry', `만료일 없는 토큰 ${noExpiry}개 — 회전 정책 확인을 권장합니다`);
      await chrome.storage.local.set({ [NOEXPIRY_LAST_KEY]: now });
    }
  }
}

function notify(id: string, message: string): void {
  chrome.notifications.create(id, {
    type: 'basic',
    iconUrl: 'icons/icon.png',
    title: 'TokenManager',
    message,
    priority: 1,
  });
}
