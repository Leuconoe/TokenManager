# Changelog

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
