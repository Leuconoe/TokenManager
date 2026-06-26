// OAuth 2.0 "Web application" client ID, from the SAME Google Cloud project as
// the Android app — that is what makes the Drive appDataFolder (and therefore
// the sync file) shared between the extension and the app.
//
// Setup (see docs/06-setup/google-drive-sync.guide.md):
//   1. Google Cloud → same project → Credentials → Create OAuth client ID →
//      "Web application".
//   2. Authorized redirect URI = the value chrome.identity.getRedirectURL()
//      prints for THIS extension:  https://<EXTENSION_ID>.chromiumapp.org/
//      (the Settings page shows it under "Connect Google Drive").
//   3. Paste the client ID below (or set VITE_GOOGLE_OAUTH_CLIENT_ID at build).
export const GOOGLE_OAUTH_CLIENT_ID: string =
  (import.meta.env?.VITE_GOOGLE_OAUTH_CLIENT_ID as string | undefined) ?? '';
