# Changelog

## v1.0.0

First stable release.

- **Cross-platform sync (opt-in, E2E-encrypted)**: optional Google Drive sync
  shared across Android, Windows, and the Chrome extension. All three clients
  use the Drive API (`drive.file` scope) into a visible `My Drive/TokenManager/`
  folder; the cloud holds only the passphrase-encrypted `.tmbk` blob (same
  Argon2id + AES-256-GCM crypto as backups). Merge is keyed by service name with
  newest-wins + tombstone-aware deletion, and a pre-write re-check guards against
  lost updates. Desktop also supports a plain synced-folder provider.
  - Auth: Android `google_sign_in`; Windows `googleapis_auth` loopback flow;
    extension `chrome.identity.launchWebAuthFlow`. OAuth client ids/secrets come
    only from env / `--dart-define` — never committed.
- **Auto-sync cadence**: off / every 5 minutes / every hour while sync is on
  (app). The extension syncs on each popup open.
- **Quick sync**: a sync button in the main toolbar (app + extension) with
  in-progress and result toasts.
- **Capture protection toggle** (Android): `FLAG_SECURE` on by default, can be
  turned off in Settings.
- **Open URL**: a shortcut button next to a token's URL opens it in the browser.
- **Distinct passphrase-mismatch handling** on sync, separate from connection
  errors.
- **Debug log** tab in Settings (app + extension) for troubleshooting.
- Package id is now `sw2.io.tokenmanager`.
- Android release APK is **arm64-v8a only** (~25 MB, down from a ~70 MB universal
  APK). CI releases use a curated `RELEASE_NOTES.md` body.

## v0.1.1

- **Release signing**: Android release builds are now signed with a real release
  key (stored as GitHub Secrets; keystore kept local & gitignored).
- **Update check**: manual "Check for updates" in Settings (app + extension)
  compares the current version against the latest GitHub Release. The app adds
  the INTERNET permission used *only* for this manual check — token data is
  never transmitted.
- **Backup merge by title**: merge is keyed by service name; on a real
  difference (e.g. local has an expiry, imported does not) a per-conflict prompt
  lets you keep local or use imported.
- **Separate timings**: expiry warning lead time (7/14/30 days before) is now
  distinct from the no-expiry cadence (off/15/30 days), on both app and extension.
- Extension: i18n (7 locales + selector), active-tab autofill, background
  expiry alerts (`alarms`), no-expiry warning.
- Token entries gained a **URL** field.

## v0.0.1

First public build. An offline token-metadata vault that **never stores token
values** — only issuance metadata (service / URL / expiry / note) under
device-bound encryption. Android · Windows · Chrome extension.

### Security
- **Metadata-only**: token values are never stored (no such field in the model).
- **Device-bound encryption**: full-DB SQLCipher; key generated/kept on-device
  with no seed/key in the source — decompile or copy-to-another-device cannot
  decrypt. Android = hardware Keystore (TEE/StrongBox); Windows = DPAPI;
  extension = passphrase-derived (Argon2id).
- **Lock gate**: biometric / Windows Hello / passphrase (skipped on devices with
  no secure lock).
- **Offline-only**: no network permission, zero exfiltration.
- Android: `allowBackup=false`, screenshot block (FLAG_SECURE).

### Features
- Token CRUD; sort by soonest expiry + status filter (soon / expired / no-expiry / valid).
- Note token-pattern warning (non-blocking): `ghp_` / `AKIA` / `sk-` / JWT + high-entropy.
- Expiry alerts with **two distinct timings**: expiry lead time (7/14/30 days
  before) and no-expiry cadence (off / 15 / 30 days).
  - Android: WorkManager background daily scan → local notifications.
  - Windows: launch-at-login + tray-resident periodic scan → tray tooltip.
  - Extension: `alarms` service worker → generic notifications (counts only).
- Passphrase backup/restore — Argon2id + AES-256-GCM (`.tmbk`), interoperable
  between the app and the extension (merge / overwrite).
- 7 languages: Korean / English / Japanese / Chinese (Simplified & Traditional)
  / Spanish / French — system default + English fallback, in-app selector.
- Chrome extension (Svelte + MV3): autofills service name + URL from the active
  tab; passphrase-locked vault; background expiry alerts.

### Tooling
- CI builds Android + Windows + extension in parallel and publishes one GitHub
  Release on push to `main`.

### Known limitations
- Release builds are signed with the debug key (no release signing configured yet).
- Windows shows a tray tooltip for expiry summaries; rich toast notifications are
  a follow-up.
- Extension background notifications show counts only (token identity stays in
  the encrypted vault, which the worker cannot decrypt).
