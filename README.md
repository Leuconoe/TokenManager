# TokenManager

> 토큰을 **저장하지 않고**, 발급 내역만 기기 종속 암호화로 기록하는 오프라인 토큰 메타데이터 보관함. (Android + Windows)

API 키·토큰 탈취를 통한 공급망 공격이 늘어나는 가운데, 발급한 토큰의 **수명을 사람이 추적하지 못해 방치되는 것**이 근본 원인입니다. TokenManager는 토큰 값 대신 **메타데이터(서비스명·URL·만료일·노트)** 만 기록하고, 만료·무기한 토큰을 알려 회전(rotate)·폐기를 돕습니다.

## 핵심 원칙

- **Metadata-only** — 토큰 값 자체는 저장하지 않습니다(도메인 모델에 필드가 없음). 노트에 토큰처럼 보이는 값을 넣으면 경고합니다(비차단).
- **기기 종속 암호화** — DB 전체를 SQLCipher로 암호화하고, 키는 기기에서 생성·보관합니다. **코드에 시드/키가 없어** 디컴파일·타기기 복사로 복원할 수 없습니다.
  - Android: 하드웨어 Keystore (TEE/StrongBox)
  - Windows: DPAPI (사용자 계정 바인딩)
- **오프라인 전용** — 네트워크 권한 없음, 외부 전송 0. 자동 연동 없음.
- **잠금 게이트** — 진입 시 생체인증 / Windows Hello (잠금 미설정 기기는 자동 스킵).

## 기능

| | |
|--|--|
| 토큰 기록 | 서비스명·URL·발급일·만료일·노트. 만료 임박순 정렬 + 상태 필터 |
| 상태 분류 | 유효 / 임박(≤14일) / 만료 / 무기한 배지 |
| 만료 알림 | Android: WorkManager 백그라운드 일일 스캔 → 로컬 알림 · Windows: 로그인 자동실행 + 트레이 상주 + 주기 스캔 → 트레이 툴팁 |
| 무기한 경고 | 만료일 없는 토큰 주기 경고(끄기/주1회/2주/월1회) |
| 백업/복원 | 패스프레이즈 기반 Argon2id + AES-256-GCM (병합/덮어쓰기) |
| 다국어 | 한국어 · English · 日本語 · 中文 · 中文(繁體) · Español · Français (시스템 자동 + 영어 폴백, 설정에서 수동 선택) |

## 기술 스택

Flutter · Riverpod · Drift + SQLCipher · flutter_secure_storage · local_auth · flutter_local_notifications · workmanager(Android) · window_manager/tray_manager/launch_at_startup(Windows) · cryptography(Argon2id/AES-GCM)

아키텍처는 feature-first + 얇은 Repository이며, 보안 핵심(암호화/Keystore)만 `CryptoPort` 인터페이스로 격리해 단위 테스트가 가능합니다.

```
lib/
├── core/
│   ├── domain/      TokenEntry, TokenStatus, CryptoPort
│   ├── crypto/      Keystore DB키 + Argon2id 백업 cipher
│   ├── db/          Drift + SQLCipher
│   ├── notification/  로컬 알림
│   └── scan/        ScanScheduler(Android=WorkManager / Desktop=tray+startup)
├── features/        lock · tokens · backup · settings
└── l10n/            ARB 7개 로케일
```

## 빌드 / 실행

사전: Flutter 3.44+, Dart 3.12+

```bash
flutter pub get
dart run build_runner build --delete-conflicting-outputs   # Drift codegen
flutter analyze && flutter test
```

### Android
```bash
flutter build apk --release
# 또는 에뮬레이터 실행 파이프라인:
./run_emulator.bat
```

### Windows
빌드 전 1회 환경 셋업이 필요합니다 — 자세한 내용은
[`docs/02-design/token-vault.platform-branching.design.md`](docs/02-design/token-vault.platform-branching.design.md) §9.1 참고.

1. `dotnet nuget add source https://api.nuget.org/v3/index.json -n nuget.org`
2. OpenSSL 설치(`choco install openssl`) + `OPENSSL_ROOT_DIR` 설정
3. Visual Studio: **최신 v143 빌드 도구용 C++ ATL** 컴포넌트
4. 빌드: `flutter build windows --release`

> 토큰 값을 절대 입력하지 마세요. 이 앱은 토큰을 **추적**할 뿐, 값을 저장하지 않습니다.

## 문서

- 계획: [`docs/01-plan/token-vault.plan.md`](docs/01-plan/token-vault.plan.md)
- 설계: [`docs/02-design/token-vault.design.md`](docs/02-design/token-vault.design.md) · [플랫폼 분기](docs/02-design/token-vault.platform-branching.design.md)
- Android 셋업: [`docs/06-setup/android-setup.guide.md`](docs/06-setup/android-setup.guide.md)
- 변경 이력: [`CHANGELOG.md`](CHANGELOG.md)

## 알려진 제한

- 릴리스 빌드는 디버그 키 서명(배포 키 미구성)
- Windows OS 토스트 알림 미지원 → 트레이 툴팁으로 대체
- Windows 자동실행 ON/OFF 토글 없음(기본 활성)
