// Manual update check against the GitHub releases API (host_permissions).

const API = 'https://api.github.com/repos/Leuconoe/TokenManager/releases/latest';

export interface UpdateInfo {
  hasUpdate: boolean;
  current: string;
  latest: string;
  url: string;
}

export async function checkUpdate(): Promise<UpdateInfo> {
  const current = chrome.runtime.getManifest().version;
  const r = await fetch(API, { headers: { Accept: 'application/vnd.github+json' } });
  if (!r.ok) return { hasUpdate: false, current, latest: '', url: '' };
  const j = await r.json();
  const name = `${j.name ?? ''} ${j.tag_name ?? ''}`;
  const latest = (name.match(/(\d+)\.(\d+)\.(\d+)/) ?? [''])[0];
  const url = (j.html_url ?? '') as string;
  return { hasUpdate: !!latest && isNewer(latest, current), current, latest, url };
}

function isNewer(a: string, b: string): boolean {
  const pa = a.split('.').map((x) => parseInt(x, 10) || 0);
  const pb = b.split('.').map((x) => parseInt(x, 10) || 0);
  for (let i = 0; i < 3; i++) {
    const x = pa[i] ?? 0;
    const y = pb[i] ?? 0;
    if (x !== y) return x > y;
  }
  return false;
}
