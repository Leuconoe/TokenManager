// Google Drive sync transport for the extension. OAuth via
// chrome.identity.launchWebAuthFlow (implicit grant — no client secret), scoped
// to drive.file (non-sensitive: per-file access to files this project creates).
// The sync file lives in a VISIBLE "TokenManager" folder in My Drive so that all
// three clients (Android, Windows, extension) — sharing one Cloud project —
// read/write the same file, and the user can see it (and Google Drive for
// Desktop can mirror it).

import { GOOGLE_OAUTH_CLIENT_ID } from './oauth.config';
import { dlog } from './debuglog';

export const SYNC_FILE = 'tokenmanager-sync.tmbk';
export const SYNC_FOLDER = 'TokenManager';
const FOLDER_MIME = 'application/vnd.google-apps.folder';
const SCOPE = 'https://www.googleapis.com/auth/drive.file';
const API = 'https://www.googleapis.com/drive/v3';
const UPLOAD = 'https://www.googleapis.com/upload/drive/v3';
const TOKEN_KEY = 'tm_drive_token_v1'; // { accessToken, expiresAt }
const CONNECTED_KEY = 'tm_drive_connected_v1';

export class DriveAuthError extends Error {}
export class DriveConfigError extends Error {}

interface CachedToken {
  accessToken: string;
  expiresAt: number; // epoch ms
  scope?: string; // the scope this token was issued for (invalidate on change)
}

export function redirectUri(): string {
  return chrome.identity.getRedirectURL();
}

export async function isConnected(): Promise<boolean> {
  const r = await chrome.storage.local.get(CONNECTED_KEY);
  return r[CONNECTED_KEY] === true;
}

export async function disconnect(): Promise<void> {
  await chrome.storage.local.remove([TOKEN_KEY, CONNECTED_KEY]);
}

function parseFragmentToken(redirect: string): CachedToken | null {
  const hash = redirect.split('#')[1];
  if (!hash) return null;
  const p = new URLSearchParams(hash);
  const accessToken = p.get('access_token');
  const expiresIn = parseInt(p.get('expires_in') ?? '0', 10);
  if (!accessToken) return null;
  return { accessToken, expiresAt: Date.now() + (expiresIn - 60) * 1000, scope: SCOPE };
}

/** Obtain an access token. interactive=true may show the consent window;
 *  interactive=false refreshes silently (works while the Google session +
 *  prior consent are valid). */
export async function getToken(interactive: boolean): Promise<string> {
  if (!GOOGLE_OAUTH_CLIENT_ID) {
    throw new DriveConfigError('OAuth client ID not configured');
  }
  const cached = (await chrome.storage.local.get(TOKEN_KEY))[TOKEN_KEY] as
    | CachedToken
    | undefined;
  if (cached && cached.expiresAt > Date.now() && cached.scope === SCOPE) {
    dlog('getToken: using cached token');
    return cached.accessToken;
  }
  if (cached && cached.scope !== SCOPE) {
    dlog(`getToken: cached token scope mismatch (${cached.scope}) — re-consenting`);
  }

  dlog(`getToken: launchWebAuthFlow interactive=${interactive} redirect=${redirectUri()}`);
  const url =
    'https://accounts.google.com/o/oauth2/v2/auth' +
    `?client_id=${encodeURIComponent(GOOGLE_OAUTH_CLIENT_ID)}` +
    '&response_type=token' +
    `&redirect_uri=${encodeURIComponent(redirectUri())}` +
    `&scope=${encodeURIComponent(SCOPE)}` +
    (interactive ? '&prompt=consent' : '&prompt=none');

  let redirect: string | undefined;
  try {
    redirect = await chrome.identity.launchWebAuthFlow({ url, interactive });
  } catch (e) {
    dlog(`getToken: launchWebAuthFlow threw: ${(e as Error)?.message ?? e}`);
    throw new DriveAuthError((e as Error)?.message ?? 'auth flow failed');
  }
  // Google may return an error in the fragment or query (e.g. access_denied,
  // redirect_uri_mismatch) — surface it instead of a generic "no token".
  if (redirect) {
    const errMatch = redirect.match(/[#&?]error=([^&]+)/);
    if (errMatch) {
      const g = decodeURIComponent(errMatch[1]);
      dlog(`getToken: google error=${g}`);
      throw new DriveAuthError(`google: ${g}`);
    }
  }
  const tok = redirect ? parseFragmentToken(redirect) : null;
  if (!tok) {
    dlog('getToken: no access_token in redirect');
    throw new DriveAuthError('no access token returned');
  }
  dlog('getToken: got access token');
  await chrome.storage.local.set({ [TOKEN_KEY]: tok, [CONNECTED_KEY]: true });
  return tok.accessToken;
}

async function authedFetch(
  interactive: boolean,
  path: string,
  init: RequestInit = {},
): Promise<Response> {
  const doFetch = async (token: string) =>
    fetch(path, {
      ...init,
      headers: { ...(init.headers ?? {}), Authorization: `Bearer ${token}` },
    });
  let res = await doFetch(await getToken(interactive));
  if (res.status === 401) {
    dlog('authedFetch: 401 — refreshing token');
    await chrome.storage.local.remove(TOKEN_KEY);
    res = await doFetch(await getToken(interactive));
  }
  const m = (init.method ?? 'GET').toUpperCase();
  dlog(`${m} ${path.replace(/^https:\/\/www\.googleapis\.com/, '')} -> ${res.status}`);
  return res;
}

/** Find (or create) the visible "TokenManager" folder; returns its id. */
async function ensureFolderId(interactive: boolean): Promise<string> {
  const q = encodeURIComponent(
    `name='${SYNC_FOLDER}' and mimeType='${FOLDER_MIME}' and trashed=false`,
  );
  const res = await authedFetch(interactive, `${API}/files?fields=files(id)&q=${q}`);
  if (!res.ok) throw new DriveAuthError(`folder lookup failed (${res.status})`);
  const data = (await res.json()) as { files?: Array<{ id: string }> };
  if (data.files?.[0]?.id) return data.files[0].id;

  const create = await authedFetch(interactive, `${API}/files?fields=id`, {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify({ name: SYNC_FOLDER, mimeType: FOLDER_MIME }),
  });
  if (!create.ok) throw new DriveAuthError(`folder create failed (${create.status})`);
  return ((await create.json()) as { id: string }).id;
}

/** Drive file id of the sync file inside the TokenManager folder, or null. */
async function findFileId(interactive: boolean, folderId: string): Promise<string | null> {
  const q = encodeURIComponent(
    `name='${SYNC_FILE}' and '${folderId}' in parents and trashed=false`,
  );
  const res = await authedFetch(interactive, `${API}/files?fields=files(id)&q=${q}`);
  if (!res.ok) throw new DriveAuthError(`list failed (${res.status})`);
  const data = (await res.json()) as { files?: Array<{ id: string }> };
  return data.files?.[0]?.id ?? null;
}

/** Download the sync file bytes, or null if it does not exist yet. */
export async function download(interactive: boolean): Promise<Uint8Array | null> {
  const folderId = await ensureFolderId(interactive);
  const id = await findFileId(interactive, folderId);
  if (!id) return null;
  const res = await authedFetch(interactive, `${API}/files/${id}?alt=media`);
  if (!res.ok) throw new DriveAuthError(`download failed (${res.status})`);
  return new Uint8Array(await res.arrayBuffer());
}

/** Create or overwrite the sync file in the TokenManager folder. */
export async function upload(interactive: boolean, bytes: Uint8Array): Promise<void> {
  const folderId = await ensureFolderId(interactive);
  const id = await findFileId(interactive, folderId);
  const body = new Blob([bytes as BlobPart], { type: 'application/octet-stream' });
  if (id) {
    const res = await authedFetch(interactive, `${UPLOAD}/files/${id}?uploadType=media`, {
      method: 'PATCH',
      body,
    });
    if (!res.ok) throw new DriveAuthError(`update failed (${res.status})`);
  } else {
    const meta = { name: SYNC_FILE, parents: [folderId] };
    const form = new FormData();
    form.append('metadata', new Blob([JSON.stringify(meta)], { type: 'application/json' }));
    form.append('file', body);
    const res = await authedFetch(interactive, `${UPLOAD}/files?uploadType=multipart&fields=id`, {
      method: 'POST',
      body: form,
    });
    if (!res.ok) throw new DriveAuthError(`create failed (${res.status})`);
  }
}
