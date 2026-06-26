// MV3 service worker — periodic expiry reminder.
// Reads ONLY the plaintext schedule (dates/counts), never the encrypted vault
// (no passphrase here). Notifications are generic; details require unlocking
// the popup.

import type { Schedule } from './lib/vault';

const ALARM = 'tm-expiry-scan';
const SCHEDULE_KEY = 'tm_schedule_v1';
const DAY_MS = 86_400_000;

function ensureAlarm(): void {
  // Twice daily; first run shortly after install/startup.
  chrome.alarms.create(ALARM, { delayInMinutes: 1, periodInMinutes: 720 });
}

chrome.runtime.onInstalled.addListener(ensureAlarm);
chrome.runtime.onStartup.addListener(ensureAlarm);

chrome.alarms.onAlarm.addListener((alarm) => {
  if (alarm.name === ALARM) void scan();
});

async function scan(): Promise<void> {
  const r = await chrome.storage.local.get(SCHEDULE_KEY);
  const s = r[SCHEDULE_KEY] as Schedule | undefined;
  if (!s) return;

  const now = Date.now();
  const soonMs = (s.soonDays ?? 14) * DAY_MS;
  let expired = 0;
  let soon = 0;
  for (const t of s.expiries ?? []) {
    if (t <= now) expired++;
    else if (t - now <= soonMs) soon++;
  }
  if (expired === 0 && soon === 0) return;

  const parts: string[] = [];
  if (expired) parts.push(`만료 ${expired}`);
  if (soon) parts.push(`임박 ${soon}`);

  chrome.notifications.create('tm-expiry', {
    type: 'basic',
    iconUrl: 'icons/icon.png',
    title: 'TokenManager',
    message: `${parts.join(' · ')} — 토큰 보관함을 열어 확인하세요`,
    priority: 1,
  });
}
