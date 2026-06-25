# token-vault — 플랫폼 분기 설계 (Android + Windows)

> Design addendum. 기존 [token-vault.design.md](./token-vault.design.md) 위에 Windows 데스크톱 지원과
> 인앱 언어 선택을 추가. Option C(Pragmatic) 구조 유지 — 플랫폼 종속 부분만 Port로 격리.

## 1. 목표 / 결정사항

| # | 결정 | 비고 |
|---|------|------|
| 1 | Windows 데스크톱 지원 추가 | UI·DB·로직은 공유, 플랫폼 종속만 분기 |
| 2 | 스크린샷 차단(FLAG_SECURE) | **Windows 미적용**(Android 전용 유지) |
| 3 | 만료 스캔 | Android=백그라운드(workmanager), **Windows=자동실행 + 트레이 상주 주기 스캔** |
| 4 | Windows 자동실행 | 로그인 시 최소화 실행 → 스캔 → 트레이 상주 |
| 5 | Windows 잠금 | **Windows Hello**(local_auth_windows), 미설정 시 자동 스킵 |
| 6 | 인앱 언어 선택 | 설정에서 시스템 기본 + 7개 언어 수동 선택, 영구 저장 |

## 2. 플랫폼 능력 매트릭스

| 기능 | Android | Windows | 분기 전략 |
|------|---------|---------|-----------|
| DB 암호화 | SQLCipher + Keystore 키 | SQLCipher + DPAPI 키 | **키 출처만 분기**(CryptoPort 유지). ⚠️ SQLCipher Windows 바이너리 검증 필요 |
| 키 저장 | Android Keystore(TEE) | flutter_secure_storage(DPAPI) | flutter_secure_storage가 양쪽 처리. 보안 강도 차이 문서화 |
| 잠금 게이트 | BiometricPrompt | Windows Hello | local_auth 공통, `canAuthenticate()` 그대로 |
| 만료 스캔 | workmanager 주기 | 트레이 상주 + Timer + 실행 시 | **ScanScheduler Port로 분기** |
| 알림 | flutter_local_notifications(채널) | flutter_local_notifications(Windows) | 공통 API, 초기화만 분기 |
| 자동실행 | (불필요) | launch_at_startup | Windows 전용 |
| 트레이 | (없음) | tray_manager + window_manager | Windows 전용 |
| 스크린샷 차단 | FLAG_SECURE | 없음 | Android 네이티브 유지(분기 불필요) |

## 3. 아키텍처 — 추가 Port & 분기

```
Application
 ├ ScanService            (공통) scanStatus → NotificationScheduler.notifyFromScan
 ├ ScanScheduler (port)   ── AndroidWorkmanagerScheduler   (registerPeriodic)
 │                        └─ DesktopTrayScheduler          (launch_at_startup + Timer + tray)
 ├ CryptoPort (기존)       Keystore↔DPAPI 차이는 flutter_secure_storage가 흡수
 └ LocaleController        (공통) 저장된 로케일 → MaterialApp.locale
```

### 3.1 ScanScheduler Port (신규)

```dart
abstract interface class ScanScheduler {
  Future<void> ensureScheduled();   // Android: 주기 작업 등록 / Windows: 자동실행 등록 + Timer
  Future<void> runOnce();           // 즉시 1회 스캔+알림 (앱 실행/포그라운드 복귀 시 공통 호출)
}
```

- **공통 ScanService.runScanAndNotify()**: `TokenRepository.scanStatus()` → `NotificationScheduler.notifyFromScan(l10n)`. 모든 플랫폼이 실행 시 1회 호출(scan-on-launch).
- **AndroidWorkmanagerScheduler**: 기존 `registerPeriodicTask` + `workmanager_callback`(백그라운드 isolate) 유지. `Platform.isAndroid`에서만 사용.
- **DesktopTrayScheduler**:
  - `launch_at_startup`로 로그인 자동실행 등록(`--minimized` 인자).
  - 앱 상주 중 `Timer.periodic(6h)`로 재스캔.
  - 트레이 메뉴: 열기 / 지금 스캔 / 종료. 창 닫기 = 트레이로 최소화(window_manager `setPreventClose`).

### 3.2 플랫폼 팩토리 (providers.dart)

```dart
final scanSchedulerProvider = Provider<ScanScheduler>((ref) {
  if (Platform.isAndroid) return AndroidWorkmanagerScheduler(ref);
  return DesktopTrayScheduler(ref);   // windows/macos/linux
});
```
> workmanager 호출은 Android 분기에만 존재 → Windows 빌드에서 MissingPluginException 회피.

## 4. 인앱 언어 선택 (공통)

### 4.1 모델
```dart
// null = 시스템 기본(Locale 자동). 그 외 = 강제 로케일.
class LocaleController extends Notifier<Locale?> { ... }   // Riverpod
```
- `SettingsRepository.getLocaleTag()/setLocaleTag(String?)` — secure_storage에 BCP47 태그 저장("system" = null).
- `main.dart`: `MaterialApp(locale: ref.watch(localeControllerProvider), ...)`.
- 지원 목록: 시스템 기본 + ko, en, ja, zh, zh_Hant, es, fr.

### 4.2 설정 UI (SettingsPage 확장)
- "언어 / Language" ListTile → 드롭다운/라디오: 시스템 기본 + 7개 언어(각 언어의 자기 이름으로 표시: 한국어/English/日本語/中文/中文(繁體)/Español/Français).
- 선택 즉시 적용(MaterialApp 리빌드) + 저장.
- ARB 신규 키: `settingsLanguage`, `languageSystemDefault`.

## 5. 보안 모델 차이 (정직 고지)

| | Android | Windows |
|--|---------|---------|
| 키 격리 | 하드웨어 TEE/StrongBox (추출 불가) | DPAPI (사용자 계정 종속, OS 보호) |
| 디컴파일 방어 | ✅ 코드 시드 없음 동일 | ✅ 동일(키 코드에 없음) |
| 타기기 복사 | ✅ 불가(하드웨어 바인딩) | △ 같은 Windows 사용자 프로필 내에서만 복호화 |

> Windows는 하드웨어 바인딩이 아닌 **DPAPI(사용자 계정 바인딩)**. 모바일보다 보안 강도는 낮지만
> 코드에 키가 없고 OS 사용자 보호를 받으므로 "메타데이터 전용" 위협 모델에는 충분. 설정 보안 안내문에 플랫폼별 문구 분기.

## 6. 의존성 추가 (데스크톱 전용, 가드)

```yaml
dependencies:
  launch_at_startup: ^0.5.1     # Windows 자동실행
  tray_manager: ^0.3.2          # 시스템 트레이
  window_manager: ^0.4.3        # 최소화/트레이 토글
  package_info_plus: ^8.0.0     # launch_at_startup가 앱 식별에 사용
```
- workmanager는 유지하되 Android 분기에서만 호출.
- local_auth는 Windows Hello를 위해 `local_auth_windows`가 자동 포함됨(별도 추가 불필요).

## 7. 네이티브/빌드 작업 (Windows)

- `flutter config --enable-windows-desktop`
- `flutter create . --platforms=windows` (windows/ 러너 생성)
- **SQLCipher Windows 검증**(최우선 리스크): `sqlcipher_flutter_libs`가 Windows 바이너리를 제공하는지 빌드로 확인. 미지원 시 대안:
  - (a) `sqlcipher_flutter_libs` Windows 지원 버전/포크, 또는
  - (b) Windows만 `sqlite3_flutter_libs` + 앱 레벨 암호화(필드 암호화)로 대체, 또는
  - (c) Windows DB도 평문 SQLite + DPAPI로 파일 암호화 래핑.
- 트레이 아이콘: 기존 `assets/icon/icon.png` 재사용(`.ico` 변환 필요 시 생성).

## 8. 테스트 추가

| Level | 항목 |
|-------|------|
| L1 | LocaleController 저장/복원, ScanService.runScanAndNotify 호출(모의 repo) |
| L1 | _deviceLocale/지원 로케일 매칭 |
| Manual(Win) | 자동실행 등록 확인, 트레이 상주/복원, Windows Hello 프롬프트, 언어 전환 즉시 반영 |
| Manual(Win) | SQLCipher 암호화 동작(가장 큰 리스크) |

## 9. 구현 모듈 (분할)

| Module | Scope Key | 내용 | 플랫폼 |
|--------|-----------|------|--------|
| 언어 선택 | `win-1` (먼저, 공통) | LocaleController + SettingsRepository + Settings UI + ARB 2키 | 공통 |
| 스캔 추상화 | `win-2` | ScanScheduler Port + AndroidWorkmanagerScheduler(기존 이관) + ScanService 공통화 | 공통 |
| Windows 런타임 | `win-3` | windows 플랫폼 생성 + DesktopTrayScheduler(자동실행+트레이+Timer) + Windows Hello 확인 | Windows |
| SQLCipher 검증/대안 | `win-4` (리스크) | Windows DB 암호화 빌드 검증, 필요 시 대안 적용 | Windows |

## 9.1 진행 현황 (2026-06-12)

- **win-1 언어 선택 — 완료** ✅ (LocaleController + SettingsRepository.localeTag + Settings UI + ARB 2키 7로케일 + main locale/영어폴백 배선). Android analyze 0 / test 11 / 빌드·실행 OK.
- **win-2 완료** ✅: ScanScheduler Port + ScanService 공통화. AndroidWorkmanagerScheduler(기존 이관) + DesktopTrayScheduler. workmanager_callback도 ScanService 사용으로 리팩터.
- **win-3 완료** ✅: DesktopTrayScheduler(launch_at_startup 로그인 자동실행 + tray_manager 트레이 상주 + window_manager 닫기=트레이 최소화 + 6h Timer 재스캔). main에서 데스크톱 window init. **Windows release 빌드 + 실행 검증**(트레이 init 무크래시, Windows Hello 잠금 게이트 동작, 자동실행 레지스트리 등록 확인). 알림: OS 토스트는 Android 전용(flutter_local_notifications 18, `windows:` 미지원), **Windows는 트레이 툴팁으로 만료 요약**(expired/soon/no-expiry). 리치 Windows 토스트는 flutter_local_notifications_windows 후속.
- **win-4 Windows 빌드 검증 — 타당성 확정** ✅ (Debug 빌드 성공 + exe 실행 확인). 해결한 빌드 환경 이슈 체인:
  1. **nuget.org 소스 누락**: `%APPDATA%\NuGet\NuGet.Config`의 `<packageSources>`가 비어 있어 온라인 소스 0개 → `dotnet nuget add source https://api.nuget.org/v3/index.json -n nuget.org`로 해결. (local_auth_windows의 WIL nuget 복원 가능해짐)
  2. **local_auth_windows coroutine**: 최신 MSVC(14.5x)가 `<experimental/coroutine>` 하드에러 → `windows/CMakeLists.txt`에 `add_compile_definitions(_SILENCE_EXPERIMENTAL_COROUTINE_DEPRECATION_WARNINGS)` 추가로 해결.
  3. **SQLCipher OpenSSL**: `sqlcipher_flutter_libs/windows`가 OpenSSL 요구 → `choco install openssl` + `OPENSSL_ROOT_DIR` 설정으로 **컴파일 성공**. dumpbin 결과 sqlite3.dll이 **OpenSSL을 정적 링크**(libcrypto 런타임 DLL 불필요, CRYPT32만 사용).
  4. **flutter_secure_storage ATL**: `atlstr.h` 필요 → VS "C++ ATL" 컴포넌트.
  5. **Debug CRT 비재배포**: `--debug` exe는 `VCRUNTIME140D/ucrtbased` 등 디버그 CRT 의존 → standalone 실행 시 DLL 누락(0xC0000135). **배포는 `--release`** (릴리스 CRT는 시스템/재배포 가능).
  6. **ATL on latest toolset**: BuildTools 최신 툴셋 14.51에 ATL 미설치였음 → VS Installer에서 "최신 v143 빌드 도구용 C++ ATL" 추가로 해결.
  - ✅ **최종: `flutter build windows --release` 성공 + release exe standalone 실행 확인**(pid 정상, OpenSSL/VS 없는 PATH, Release 폴더에 libcrypto 없음 = SQLCipher 정적링크). **Windows 빌드·실행 완전 검증 완료.**

### 빌드 전 1회 환경 셋업 요약 (Windows)
1. `dotnet nuget add source https://api.nuget.org/v3/index.json -n nuget.org`
2. `choco install openssl` + `OPENSSL_ROOT_DIR` = OpenSSL 설치 경로
3. VS Installer: **최신 v143 툴셋용 C++ ATL** 컴포넌트
4. `windows/CMakeLists.txt`에 coroutine 무력화 정의(리포에 커밋됨)
5. 배포는 `flutter build windows --release` (Debug CRT 비재배포)

### win-3 런타임 잔여(미구현)
release exe는 실행되나 **Windows용 알림 init(WindowsInitializationSettings)·트레이·자동실행·ScanScheduler는 미구현**(현재 알림 init은 Android 설정만이라 Windows에선 no-op). → win-3에서 완성.
- **URL 컬럼 추가 — 완료** ✅: TokenEntry.url + Drift schema v2 + onUpgrade addColumn(실기 마이그레이션 검증) + 편집 폼 필드 + 목록 표시 + 백업 JSON 하위호환.

## 10. 권장 순서
1. **win-1 언어 선택**(공통, 즉시 가치, 위험 낮음) — 지금 바로 구현 가능
2. win-2 스캔 추상화(리팩터, Android 무회귀 확인)
3. win-4 SQLCipher Windows 빌드 검증(가장 큰 미지수 — 먼저 찔러보는 것도 가능)
4. win-3 Windows 런타임(트레이/자동실행/Hello)

> 권고: **win-1을 먼저 구현**하고, 병행해서 win-4(SQLCipher Windows 빌드 가능 여부)를 1회 검증해 Windows 진행 타당성을 확정.
