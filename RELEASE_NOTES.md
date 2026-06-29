# TokenManager v1.0.4

**An offline-first vault that never stores token values.** It records only the *metadata* of your API tokens / keys — service name, URL, issued/expiry dates, a note — and reminds you to rotate or revoke them before they expire. Available on **Android**, **Windows**, and as a **Chrome extension**.

## 🆕 New in v1.0.4

- **Windows auto-update** — when an update is available, choose "Update & restart" and the app downloads, installs, and relaunches itself (no manual unzip). *(Takes effect from the next release onward.)*
- **Search** the list by title / site / note.
- **Sort** by expiry / created / name / site, ascending or descending (remembered).
- **Trash (recycle bin)** — restore or permanently delete soft-deleted tokens, with a bulk *empty trash*; tombstones auto-clear after 30 days.
- **App version** shown in Settings.

## 🛠 Fixed

- **Emptying the Trash now sticks across sync** — permanent delete also removes the record from the cloud file, so it isn't re-added by the next merge.
- **Google Drive sync recovery** — a failed sync drops the connection (except a wrong passphrase); reconnecting runs a fresh consent, recovering from a broken/expired token.
- **Deleted tokens no longer reappear after sync** (monotonic timestamps; deterministic merge that converges on every device).
- **Extension popup** is a fixed height and the list scrolls (no unbounded growth).

---

> The root cause behind token/API-key supply-chain incidents is that issued tokens are **left unrotated because nobody tracks their lifetime**. TokenManager tracks the lifetime — not the secret.

---

## 📦 Downloads

| Asset | Platform | How to install |
|-------|----------|----------------|
| `TokenManager-*-arm64.apk` | Android (arm64-v8a) | Sideload the APK (allow "install from unknown sources"). minSdk 23. Most modern phones are arm64. |
| `TokenManager-*-windows-x64.zip` | Windows 10/11 x64 | Unzip anywhere and run `token_manager.exe` (keep the folder contents together). |
| `TokenManager-*-extension.zip` | Chrome / Edge (Chromium) | Unzip → `chrome://extensions` → enable Developer mode → **Load unpacked** → select the folder. |

---

## ✨ Features

- **Metadata-only by design** — there is no field to store a token value. If a note looks like it contains a secret, the app warns you (non-blocking).
- **Lifetime tracking & alerts** — Valid / Expiring soon / Expired / No-expiry badges, with **separate timings**: expiry lead time (7 / 14 / 30 days before) and a no-expiry reminder cadence (off / 15 / 30 days).
- **Notifications** — Android: daily background scan (WorkManager) → local notification · Windows: launch-at-login, tray-resident scan · Extension: `alarms` service worker.
- **Encrypted backup** — passphrase-based `.tmbk` file (Argon2id + AES-256-GCM), **interoperable between the app and the extension**.
- **Cross-platform sync (opt-in, end-to-end encrypted)** — sync your vault across Android, Windows, and the extension via **Google Drive** (or a synced folder on desktop). The cloud only ever holds the passphrase-encrypted blob; merge is by service name with newest-wins and tombstone-aware deletes, plus a pre-write re-check to avoid lost updates. Auto-sync every **5 minutes / 1 hour**, or on demand from the toolbar **🔄** button.
- **Quick actions** — open a token's URL directly from the list; one-tap sync with in-progress/result toasts.
- **7 languages** — 한국어 · English · 日本語 · 中文 · 中文(繁體) · Español · Français (follows system, English fallback, in-app selector).

## 🔒 Security model

- **Device-bound DB encryption** — the entire database is encrypted with SQLCipher; the key is generated on-device and **never present in the source**, so a decompiled binary or a copy to another device cannot decrypt it.
  - Android → hardware Keystore (TEE/StrongBox) · Windows → DPAPI (user-account bound) · Extension → Argon2id passphrase-derived key in `chrome.storage`.
- **Offline-first** — fully usable with no network. The only network use is opt-in: the manual "Check for updates" action and optional sync.
- **E2E-encrypted sync** — only ciphertext leaves the device; token values were never stored to begin with.
- **Minimal OAuth scope** — sync uses Google's non-sensitive `drive.file` scope, so the app can only access the files it created (a visible `My Drive/TokenManager/` folder).
- **Screenshot/recents protection** (Android `FLAG_SECURE`, on by default, toggleable) and a **lock gate** (biometric / Windows Hello / passphrase).
- The **sync passphrase** is stored in secure storage so auto-sync can run unattended (a documented tradeoff); the **vault unlock passphrase** is never persisted.

## ☁️ Enabling Google Drive sync (optional)

Sync is **off by default**. To turn it on you create your own Google Cloud OAuth clients (one project shared by all platforms). No secrets are committed — they are supplied at build/run time. Full step-by-step guide: [`docs/06-setup/google-drive-sync.guide.md`](https://github.com/Leuconoe/TokenManager/blob/main/docs/06-setup/google-drive-sync.guide.md).

## ⚠️ Known limitations

- Android APK is **arm64-v8a only** and release-signed; **Windows and the extension builds are not code-signed** — your OS/browser may warn on first launch.
- Windows shows expiry summaries via a tray tooltip (rich toast notifications are a follow-up).
- The Chrome extension syncs when you open its popup (no unattended background sync — it never persists the vault passphrase).

---

> **Never enter token values.** This app *tracks* tokens; it does not store their values.

---

## 🇰🇷 한국어 요약

발급한 토큰/API 키의 **값은 저장하지 않고** 메타데이터(서비스명·URL·만료일·노트)만 기록해, 만료 전에 회전·폐기하도록 알려주는 **오프라인 우선 보관함**입니다. Android·Windows·크롬 익스텐션 지원.

- **메타데이터 전용** — 토큰 값 저장 필드 자체가 없음(토큰처럼 보이면 경고).
- **만료 추적/알림** — 유효/임박/만료/무기한 배지, 만료 경고 시점(7/14/30일 전)과 무기한 주기(끄기/15/30일) 분리.
- **암호화 백업** — 패스프레이즈 기반 `.tmbk`(Argon2id + AES-256-GCM), 앱↔익스텐션 호환.
- **플랫폼 간 동기화(선택, 종단 간 암호화)** — Google Drive(또는 데스크톱 동기화 폴더). 클라우드엔 암호문만 저장, 서비스명 기준 병합·삭제 전파·lost-update 방지, 5분/1시간 자동 또는 수동.
- **보안** — SQLCipher 기기 종속 키(Keystore/DPAPI, 소스에 키 없음), 최소 권한 `drive.file`, 화면 캡처 차단(FLAG_SECURE) 토글, 잠금 게이트.

**설치**: Android는 arm64 APK 사이드로드, Windows는 zip 풀고 `token_manager.exe` 실행, 익스텐션은 `chrome://extensions`에서 압축 해제 후 "압축해제된 확장 프로그램 로드". Drive 동기화는 기본 꺼짐이며 본인 OAuth 클라이언트 설정 필요(가이드 참고).

> 토큰 값은 절대 입력하지 마세요. 이 앱은 토큰을 **추적**할 뿐 값을 저장하지 않습니다.
