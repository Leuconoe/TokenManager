# TokenManager

> An offline vault that **never stores token values** — it records only token issuance metadata (service name, URL, expiry, note) under device-bound encryption. Android · Windows · Chrome extension.

*Read this in [한국어](README.ko.md).*

As token/API-key supply-chain attacks rise, the root problem is that issued tokens are **left unrotated because no one tracks their lifetime**. TokenManager records **metadata only** (service / URL / expiry / note) and alerts you about expiring and never-expiring tokens so you can rotate or revoke them in time.

## Principles

- **Metadata-only** — token values are never stored (the domain model has no such field). If a note looks like it contains a token, the app warns (non-blocking).
- **Device-bound encryption** — the whole DB is encrypted with SQLCipher; the key is generated and kept on-device. With **no seed/key in the source**, a decompiled binary or a copy to another device cannot decrypt it.
  - Android: hardware Keystore (TEE/StrongBox)
  - Windows: DPAPI (user-account bound)
  - Extension: passphrase-derived key (Argon2id) in `chrome.storage`
- **Offline-only** — no network permission, zero exfiltration. No auto-sync.
- **Lock gate** — biometric / Windows Hello / passphrase on entry (skipped where the device has no secure lock).

## Features

| | |
|--|--|
| Record | Service name · URL · issued/expiry dates · note. Sort by soonest expiry + status filter |
| Status | Valid / Expiring soon / Expired / No-expiry badges |
| Expiry alerts | Separate **lead time** (7/14/30 days before) and **no-expiry cadence** (off/15/30 days) |
| Notifications | Android: WorkManager daily background scan → local notification · Windows: launch-at-login + tray-resident scan · Extension: `alarms` service worker |
| Backup | Passphrase-based Argon2id + AES-256-GCM (`.tmbk`) — **interoperable across app and extension** |
| i18n | Korean · English · 日本語 · 中文 · 中文(繁體) · Español · Français (system default + English fallback, in-app selector) |

## Targets

- **Android** (Flutter, minSdk 23)
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

CI (`.github/workflows/build-release.yml`) builds Android + Windows + extension in parallel and publishes them to a single GitHub Release on push to `main`.

> Never enter token values. This app **tracks** tokens; it does not store their values.

## Docs

- Plan: [`docs/01-plan/token-vault.plan.md`](docs/01-plan/token-vault.plan.md)
- Design: [`docs/02-design/token-vault.design.md`](docs/02-design/token-vault.design.md) · [platform branching](docs/02-design/token-vault.platform-branching.design.md)
- Android setup: [`docs/06-setup/android-setup.guide.md`](docs/06-setup/android-setup.guide.md)
- Changelog: [`CHANGELOG.md`](CHANGELOG.md)

## Known limitations

- Release builds are signed with the debug key (no release signing configured yet).
- Windows uses a tray tooltip for expiry summaries (rich toast notifications are a follow-up).
