// Lightweight persistent debug log (capped ring buffer in chrome.storage.local)
// so events survive the popup closing during the OAuth round-trip. Surfaced in
// Settings → Debug log.

const KEY = 'tm_debug_log_v1';
const CAP = 200;

export interface LogEntry {
  t: number; // epoch ms
  m: string;
}

/** Append a line. Fire-and-forget; never throws into callers. */
export function dlog(msg: string): void {
  void (async () => {
    try {
      const r = await chrome.storage.local.get(KEY);
      const list = ((r[KEY] as LogEntry[] | undefined) ?? []).slice(-CAP + 1);
      list.push({ t: Date.now(), m: msg });
      await chrome.storage.local.set({ [KEY]: list });
    } catch {
      /* ignore */
    }
  })();
}

export async function getLog(): Promise<LogEntry[]> {
  const r = await chrome.storage.local.get(KEY);
  return (r[KEY] as LogEntry[] | undefined) ?? [];
}

export async function clearLog(): Promise<void> {
  await chrome.storage.local.remove(KEY);
}
