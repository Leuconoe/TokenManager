# TokenManager

> 토큰 값을 **저장하지 않고**, 발급 메타데이터(서비스명·URL·만료일·노트)만 기기 종속 암호화로 기록하는 오프라인 우선 보관함. 만료 전에 회전·폐기하도록 알려줍니다. Android · Windows · 크롬 익스텐션.

*Read this in [English](README.md).*

API 키·토큰 탈취 공급망 공격이 늘어나는 가운데, 발급한 토큰의 **수명을 사람이 추적 못 해 방치되는 것**이 근본 원인입니다. TokenManager는 토큰 값 대신 **메타데이터(서비스명·URL·만료일·노트)** 만 기록하고, 만료·무기한 토큰을 알려 회전(rotate)·폐기를 돕습니다.

## 핵심 원칙

- **Metadata-only** — 토큰 값은 저장하지 않습니다(도메인 모델에 필드 부재). 노트에 토큰처럼 보이는 값을 넣으면 경고합니다(비차단).
- **기기 종속 암호화** — DB 전체 SQLCipher 암호화, 키는 기기에서 생성·보관. **코드에 시드/키가 없어** 디컴파일·타기기 복사로 복원 불가.
  - Android: 하드웨어 Keystore(TEE/StrongBox)
  - Windows: DPAPI(사용자 계정 바인딩)
  - 익스텐션: 패스프레이즈 파생키(Argon2id) — `chrome.storage`
- **오프라인 우선** — 완전 오프라인 동작. 네트워크 사용은 모두 **선택(opt-in)**: 수동 "업데이트 확인"과 **선택적** 플랫폼 간 동기화뿐이며, 동기화를 켜지 않는 한 기기 밖으로 나가는 데이터는 없습니다.
- **종단 간 암호화 동기화** — 켰을 때 업로드되는 것은 패스프레이즈로 암호화된 blob(`.tmbk`, Argon2id + AES-256-GCM)뿐입니다. 클라우드는 평문을 볼 수 없고, **애초에 토큰 값은 저장되지도 않습니다.**
- **잠금 게이트** — 생체인증 / Windows Hello / 패스프레이즈 (잠금 미설정 기기는 스킵).

## 기능

| | |
|--|--|
| 기록 | 서비스명 · URL(브라우저 바로가기) · 발급/만료일 · 노트. 만료 임박순 정렬 + 상태 필터 |
| 상태 | 유효 / 임박 / 만료 / 무기한 배지 |
| 만료 알림 | **만료 경고 시점**(7/14/30일 전)과 **무기한 경고 주기**(끄기/15/30일) **분리 설정** |
| 알림 | Android: WorkManager 일일 백그라운드 스캔 → 로컬 알림 · Windows: 로그인 자동실행 + 트레이 상주 스캔 · 익스텐션: `alarms` service worker |
| 백업 | 패스프레이즈 기반 Argon2id + AES-256-GCM (`.tmbk`) — **앱↔익스텐션 교차 호환** |
| 동기화(선택) | Google Drive(`drive.file`, 공유 `내 드라이브/TokenManager/` 폴더) 또는 데스크톱 동기화 폴더로 종단 간 암호화 동기화. 서비스명 기준 병합·최신 우선·툼스톤 삭제 전파·lost-update 방지. 5분/1시간 자동 또는 수동 |
| 보안 | Android 스크린샷·최근앱 차단(`FLAG_SECURE`, 토글) · 기기 종속 DB 키 · 잠금 게이트 |
| 다국어 | 한국어 · English · 日本語 · 中文 · 中文(繁體) · Español · Français (시스템 기본 + 영어 폴백, 인앱 선택) |

## 대상 플랫폼

- **Android** (Flutter, minSdk 23, **arm64-v8a** 전용) — `sw2.io.tokenmanager`
- **Windows** (Flutter 데스크톱 — 트레이, 로그인 자동실행, Windows Hello)
- **크롬 익스텐션** (`extension/` — Svelte + MV3)

## 빌드

사전: Flutter 3.44+, Dart 3.12+

```bash
flutter pub get
dart run build_runner build --delete-conflicting-outputs   # Drift codegen
flutter analyze && flutter test
```

- **Android**: `flutter build apk --release`
- **Windows**: 1회 환경 셋업 필요(OpenSSL + `OPENSSL_ROOT_DIR`, 최신 툴셋 C++ ATL, nuget.org 소스) — [`docs/02-design/token-vault.platform-branching.design.md`](docs/02-design/token-vault.platform-branching.design.md) §9.1 참고 후 `flutter build windows --release`.
- **익스텐션**: `cd extension && npm install && npm run build` → `extension/dist` 로드 ([`extension/README.md`](extension/README.md)).

CI(`.github/workflows/build-release.yml`)는 `pubspec.yaml`의 버전이 올라간 push에서 Android + Windows + 익스텐션을 병렬 빌드해 하나의 GitHub Release로 게시합니다. Android 릴리스 서명 키는 GitHub Secrets에 보관(로컬은 gitignore).

### 선택: Google Drive 동기화 설정

동기화는 기본 꺼짐입니다. 켜려면 본인 Google Cloud OAuth 클라이언트를 만들어야 하며(프로젝트 1개, 전 플랫폼 공유), **비밀은 커밋되지 않고** 빌드/실행 시 env / `--dart-define`로 주입합니다. 전체 절차: [`docs/06-setup/google-drive-sync.guide.md`](docs/06-setup/google-drive-sync.guide.md).

- 익스텐션: `extension/.env`(gitignore)에 `VITE_GOOGLE_OAUTH_CLIENT_ID` 설정.
- Windows: `flutter run -d windows --dart-define-from-file=oauth.local.json`(gitignore).
- Android: 패키지명 + SHA-1로 자동 매칭.

> 토큰 값은 절대 입력하지 마세요. 이 앱은 토큰을 **추적**할 뿐 값을 저장하지 않습니다.

## 문서

- 계획: [`docs/01-plan/token-vault.plan.md`](docs/01-plan/token-vault.plan.md)
- 설계: [`docs/02-design/token-vault.design.md`](docs/02-design/token-vault.design.md) · [플랫폼 분기](docs/02-design/token-vault.platform-branching.design.md) · [동기화](docs/02-design/token-vault.sync.design.md)
- 설정: [Android](docs/06-setup/android-setup.guide.md) · [Google Drive 동기화](docs/06-setup/google-drive-sync.guide.md)
- 변경 이력: [`CHANGELOG.md`](CHANGELOG.md)

## 보안 메모

- 토큰 값은 로컬 DB·백업·동기화 어디에도 저장되지 않습니다.
- 로컬 DB 키는 기기 종속(Keystore/DPAPI)이며 소스에 없습니다.
- 동기화/백업은 암호문만 업로드 — 패스프레이즈를 잃으면 복구 불가.
- **동기화 패스프레이즈**는 무인 자동 동기화를 위해 보안 저장소에 저장됩니다 — 위협 모델을 "클라우드 유출 전용"에서 "기기 탈취"로 바꾸는 의도된 트레이드오프입니다. **보관함 잠금 패스프레이즈**는 저장되지 않습니다.
- OAuth는 최소 권한 `drive.file` 범위 — 앱이 만든 파일만 접근 가능.

## 알려진 제한

- Windows는 만료 요약을 트레이 툴팁으로 표시(리치 토스트 알림은 후속).
- 크롬 익스텐션은 팝업 열 때 동기화합니다(보관함 패스프레이즈 미저장 → 무인 백그라운드 동기화 없음).
