# TokenManager

> 토큰 값을 **저장하지 않고**, 발급 메타데이터(서비스명·URL·만료일·노트)만 기기 종속 암호화로 기록하는 오프라인 보관함. Android · Windows · 크롬 익스텐션.

*Read this in [English](README.md).*

API 키·토큰 탈취 공급망 공격이 늘어나는 가운데, 발급한 토큰의 **수명을 사람이 추적 못 해 방치되는 것**이 근본 원인입니다. TokenManager는 토큰 값 대신 **메타데이터(서비스명·URL·만료일·노트)** 만 기록하고, 만료·무기한 토큰을 알려 회전(rotate)·폐기를 돕습니다.

## 핵심 원칙

- **Metadata-only** — 토큰 값은 저장하지 않습니다(도메인 모델에 필드 부재). 노트에 토큰처럼 보이는 값을 넣으면 경고합니다(비차단).
- **기기 종속 암호화** — DB 전체 SQLCipher 암호화, 키는 기기에서 생성·보관. **코드에 시드/키가 없어** 디컴파일·타기기 복사로 복원 불가.
  - Android: 하드웨어 Keystore(TEE/StrongBox)
  - Windows: DPAPI(사용자 계정 바인딩)
  - 익스텐션: 패스프레이즈 파생키(Argon2id) — `chrome.storage`
- **오프라인 전용** — 네트워크 권한 없음, 외부 전송 0. 자동 연동 없음.
- **잠금 게이트** — 생체인증 / Windows Hello / 패스프레이즈 (잠금 미설정 기기는 스킵).

## 기능

| | |
|--|--|
| 기록 | 서비스명 · URL · 발급/만료일 · 노트. 만료 임박순 정렬 + 상태 필터 |
| 상태 | 유효 / 임박 / 만료 / 무기한 배지 |
| 만료 알림 | **만료 경고 시점**(7/14/30일 전)과 **무기한 경고 주기**(끄기/15/30일) **분리 설정** |
| 알림 | Android: WorkManager 일일 백그라운드 스캔 → 로컬 알림 · Windows: 로그인 자동실행 + 트레이 상주 스캔 · 익스텐션: `alarms` service worker |
| 백업 | 패스프레이즈 기반 Argon2id + AES-256-GCM (`.tmbk`) — **앱↔익스텐션 교차 호환** |
| 다국어 | 한국어 · English · 日本語 · 中文 · 中文(繁體) · Español · Français (시스템 기본 + 영어 폴백, 인앱 선택) |

## 대상 플랫폼

- **Android** (Flutter, minSdk 23)
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

CI(`.github/workflows/build-release.yml`)는 main push 시 Android + Windows + 익스텐션을 병렬 빌드해 하나의 GitHub Release로 게시합니다.

> 토큰 값은 절대 입력하지 마세요. 이 앱은 토큰을 **추적**할 뿐 값을 저장하지 않습니다.

## 문서

- 계획: [`docs/01-plan/token-vault.plan.md`](docs/01-plan/token-vault.plan.md)
- 설계: [`docs/02-design/token-vault.design.md`](docs/02-design/token-vault.design.md) · [플랫폼 분기](docs/02-design/token-vault.platform-branching.design.md)
- Android 셋업: [`docs/06-setup/android-setup.guide.md`](docs/06-setup/android-setup.guide.md)
- 변경 이력: [`CHANGELOG.md`](CHANGELOG.md)

## 알려진 제한

- 릴리스 빌드는 디버그 키 서명(배포 키 미구성).
- Windows는 만료 요약을 트레이 툴팁으로 표시(리치 토스트 알림은 후속).
