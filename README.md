# TokenManager

> An offline-first vault that **never stores token values** — it records only token issuance metadata (service name, URL, expiry, note) under device-bound encryption, and reminds you to rotate or revoke before tokens expire. Android · Windows · Chrome extension.

*Read this in [한국어](README.ko.md).*

As token / API-key supply-chain attacks rise, the root problem is that issued tokens are **left unrotated because no one tracks their lifetime**. TokenManager records **metadata only** (service / URL / expiry / note) and alerts you about expiring and never-expiring tokens so you can rotate or revoke them in time.

## Principles

- **Metadata-only** — token values are never stored (the domain model has no such field). If a note looks like it contains a token, the app warns (non-blocking).
- **Device-bound encryption** — the whole DB is encrypted with SQLCipher; the key is generated and kept on-device. With **no seed/key in the source**, a decompiled binary or a copy to another device cannot decrypt it.
  - Android: hardware Keystore (TEE/StrongBox)
  - Windows: DPAPI (user-account bound)
  - Extension: passphrase-derived key (Argon2id) in `chrome.storage`
- **Offline-first** — works fully offline. The only network use is **opt-in**: the manual "Check for updates" action, and **optional** cross-platform sync. Nothing leaves the device unless you turn sync on.
- **End-to-end encrypted sync** — when enabled, only a passphrase-encrypted blob (`.tmbk`, Argon2id + AES-256-GCM) is uploaded. The cloud provider never sees plaintext, and **token values were never stored to begin with**.
- **Lock gate** — biometric / Windows Hello / passphrase on entry (skipped where the device has no secure lock).

## Features

| | |
|--|--|
| Record | Service name · URL (with open-in-browser shortcut) · issued/expiry dates · note. Sort by soonest expiry + status filter |
| Status | Valid / Expiring soon / Expired / No-expiry badges |
| Expiry alerts | Separate **lead time** (7/14/30 days before) and **no-expiry cadence** (off/15/30 days) |
| Notifications | Android: WorkManager daily background scan → local notification · Windows: launch-at-login + tray-resident scan · Extension: `alarms` service worker |
| Backup | Passphrase-based Argon2id + AES-256-GCM (`.tmbk`) — **interoperable across app and extension** |
| Sync (opt-in) | E2E-encrypted cross-platform sync via Google Drive (`drive.file`, shared `My Drive/TokenManager/` folder) or a synced folder on desktop. Merge by service name, newest-wins, tombstone-aware deletes, lost-update guard. Auto-sync every 5 min / 1 hour, or manual |
| Security | Android screenshot/recents block (`FLAG_SECURE`, toggleable) · device-bound DB key · lock gate |
| i18n | Korean · English · 日本語 · 中文 · 中文(繁體) · Español · Français (system default + English fallback, in-app selector) |

## Targets

- **Android** (Flutter, minSdk 23, **arm64-v8a** only) — `sw2.io.tokenmanager`
- **Windows** (Flutter desktop — tray, launch-at-login, Windows Hello)
- **Chrome extension** (`extension/` — Svelte + MV3)

## Build

Prerequisites: Flutter 3.44+, Dart 3.12+.

```bash
flutter pub get
dart run build_runner build --delete-conflicting-outputs   # Drift codegen
flutter analyze && flutter test
```

- **Android**: `flutter build apk --release`
- **Windows**: needs one-time setup (OpenSSL + `OPENSSL_ROOT_DIR`, latest-toolset C++ ATL, nuget.org source) — see [`docs/02-design/token-vault.platform-branching.design.md`](docs/02-design/token-vault.platform-branching.design.md) §9.1, then `flutter build windows --release`.
- **Extension**: `cd extension && npm install && npm run build` → load `extension/dist` (see [`extension/README.md`](extension/README.md)).

CI (`.github/workflows/build-release.yml`) builds Android + Windows + extension in parallel and publishes them to a single GitHub Release on push to `main`. Android release signing uses a keystore stored in GitHub Secrets (kept local & gitignored).

### Optional: Google Drive sync setup

Sync is off by default. To enable it you create your own Google Cloud OAuth clients (one project, shared across all platforms) — **no secrets are committed**; they are supplied at build/run time via env / `--dart-define`. Full walkthrough: [`docs/06-setup/google-drive-sync.guide.md`](docs/06-setup/google-drive-sync.guide.md).

- Extension: set `VITE_GOOGLE_OAUTH_CLIENT_ID` in `extension/.env` (gitignored).
- Windows: `flutter run -d windows --dart-define-from-file=oauth.local.json` (gitignored).
- Android: matched automatically by package name + SHA-1.

> Never enter token values. This app **tracks** tokens; it does not store their values.

## Docs

- Plan: [`docs/01-plan/token-vault.plan.md`](docs/01-plan/token-vault.plan.md)
- Design: [`docs/02-design/token-vault.design.md`](docs/02-design/token-vault.design.md) · [platform branching](docs/02-design/token-vault.platform-branching.design.md) · [sync](docs/02-design/token-vault.sync.design.md)
- Setup: [Android](docs/06-setup/android-setup.guide.md) · [Google Drive sync](docs/06-setup/google-drive-sync.guide.md)
- Changelog: [`CHANGELOG.md`](CHANGELOG.md)

## Security notes

- Token values are never stored anywhere — local DB, backups, or sync.
- The local DB key is device-bound (Keystore/DPAPI) and absent from source.
- Sync/backup uploads ciphertext only; lose the passphrase and it is unrecoverable.
- The **sync passphrase** is persisted (secure storage) so auto-sync can run unattended — a deliberate tradeoff that turns the threat model from cloud-breach-only into device-compromise. The **vault unlock passphrase** is never persisted.
- OAuth uses the minimal `drive.file` scope; the app can only see files it created.

## Known limitations

- Windows uses a tray tooltip for expiry summaries (rich toast notifications are a follow-up).
- The Chrome extension syncs on popup open (no unattended background sync — it never persists the vault passphrase).
