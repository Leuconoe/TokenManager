// Reads the active tab (activeTab permission) to pre-fill the add form.

export interface TabHint {
  url: string;
  serviceName: string;
}

/** Returns the active tab's URL + a guessed service name, or null. */
export async function activeTabHint(): Promise<TabHint | null> {
  if (typeof chrome === 'undefined' || !chrome.tabs?.query) return null;
  try {
    const [tab] = await chrome.tabs.query({ active: true, currentWindow: true });
    const raw = tab?.url ?? '';
    if (!/^https?:\/\//i.test(raw)) return null; // skip chrome://, about:, etc.
    const u = new URL(raw);
    return { url: raw, serviceName: guessName(u.hostname) };
  } catch {
    return null;
  }
}

/** github.com -> "Github", console.aws.amazon.com -> "Amazon". Rough; user edits. */
function guessName(hostname: string): string {
  const host = hostname.replace(/^www\./, '');
  const parts = host.split('.');
  const core = parts.length >= 2 ? parts[parts.length - 2] : parts[0];
  return core ? core.charAt(0).toUpperCase() + core.slice(1) : host;
}
