# Changelog

## v1.0.8

- **Fix: Windows auto-update now actually runs.** The updater launched its helper
  with `Process.start(detached)`, which did not reliably spawn the process — the
  app closed but nothing downloaded/installed. It now launches via `cmd /c start`,
  verified to survive the app exiting and complete the download/extract/install.

## v1.0.7

- Test release to exercise the Windows auto-update flow (no functional changes
  from v1.0.6).

## v1.0.6

- **Windows auto-update hardening**: the update helper now forces TLS 1.2 (Windows
  PowerShell 5.1 otherwise fails to download from GitHub) and writes a step-by-step
  log to `%TEMP%\tokenmanager_update\update.log` for diagnosing failed updates.
- Extension manifest version bumped to match the release.

## v1.0.5

- **Release builds now include Google Drive sync** out of the box — CI injects
  the OAuth client id/secret from repository secrets, so the distributed Windows
  app and Chrome extension can connect to Drive without a local build. (No code
  change from v1.0.4; this is the first release built with the secrets.)

## v1.0.4

- **Windows auto-update**: when an update is available, Windows offers
  "Update & restart" — a detached helper waits for the app to exit, downloads
  the release zip, installs it over the app folder, and relaunches.
- **Fix: emptying the Trash now sticks across sync.** Permanent delete (per-item
  and bulk) also strips the tombstone from the remote sync file, so it is no
  longer re-added by the next merge.

## v1.0.3

- **Search** the list by title / site / note (app + extension).
- **Sort** by expiry / created / name / site, each ascending or descending — the
  choice is remembered (app + extension).
- **Version shown in Settings** (app + extension).
- **Drive sync resilience**: a failed sync now drops the Drive connection (except
  a wrong passphrase), and connecting always runs a fresh consent — this recovers
  from a broken/expired refresh token (the desktop "Could not determine client ID"
  error) instead of getting stuck.
- **Extension popup** is a fixed height now; the list scrolls instead of the
  window growing without bound.

## v1.0.2

- **Trash (recycle bin)**: a dedicated view lists soft-deleted tokens. Each can be
  **restored** or **permanently deleted**, plus a **bulk "empty trash"**. Tombstones
  older than 30 days are auto-purged on launch (assumes all devices have synced
  the deletion by then). App: Settings → Trash. Extension: 🗑 in the toolbar.
- **Deterministic merge tiebreak**: when two entries share a title and the exact
  same `updatedAt` (possible from clock-skewed concurrent edits), the merge now
  resolves by a stable total order — deletion wins a tie, otherwise higher id —
  so every device converges to the same result instead of diverging.

## v1.0.1

- **Fix: deleted tokens reappearing after sync.** Deletes/edits now use a
  monotonic `updatedAt` (`max(now, previous+1)`) so a deletion always supersedes
  the version it was applied to — previously a remote/local copy carrying a
  future timestamp from a clock-skewed device could resurrect a deleted entry.
  Applies to the app and the extension. Added a "RESURRECTED …" diagnostic line
  to the extension's debug log.

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
