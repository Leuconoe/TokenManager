# Google Drive 동기화 설정 가이드 (Android 앱 + 크롬 익스텐션)

> Google Drive 동기화는 Google Cloud OAuth 설정이 1회 필요합니다.
> 비용 0(Testing 모드). 데이터는 본인 Drive의 숨김 **appDataFolder**에 암호문으로만 저장됩니다.
> (Windows 데스크톱은 폴더 동기화 사용 — 별도 설정 불필요.)
>
> **핵심:** Android 앱과 크롬 익스텐션이 **같은 동기화 파일**(`tokenmanager-sync.tmbk`)을
> 공유하려면, 두 OAuth 클라이언트를 **같은 Google Cloud 프로젝트** 안에 만들어야 합니다.
> `appDataFolder`는 (사용자별 × 프로젝트별)로 격리되기 때문입니다.

## 1. Google Cloud 프로젝트 (1개만)
1. https://console.cloud.google.com → 프로젝트 생성(예: `tokenmanager`).
2. **API 및 서비스 → 라이브러리 → "Google Drive API" 사용 설정**.

## 2. OAuth 동의 화면 / "Google Auth Platform" (공통)
> ⚠️ 콘솔 개편으로 **User Type(External/Internal)** 은 클라이언트 만들기 화면이 아니라
> **"Google Auth Platform"의 "대상(Audience)"** 에 있습니다.

1. **API 및 서비스 → OAuth 동의 화면** → (미설정 시) **"시작하기(Get started)"**.
2. **앱 정보**: 앱 이름 `TokenManager` + **User support email = `sw2io@googlegroups.com`**.
   - 그룹이 드롭다운에 뜨려면 **로그인 계정이 그 그룹의 멤버**여야 합니다
     (groups.google.com → 그룹 → 멤버에 본인 계정 추가).
3. **대상(Audience)** → **External(외부)** 선택.
   - Internal(내부)은 **Workspace 조직 소속 계정 전용**이라 일반/테스트 계정엔 부적합 → External.
4. **연락처**: `sw2io@googlegroups.com` 입력(자유 입력) → 완료.
5. **데이터 액세스(Scopes)** → 범위 추가. 전체 URL을 정확히 입력:
   `https://www.googleapis.com/auth/drive.appdata` (앱 데이터 폴더).
   - "잘못된 범위" 오류 = (a) Drive API 미활성(§1 먼저 사용 설정) 또는 (b) `...` 줄임표를 그대로 입력.
   - 테스트 모드면 이 등록을 건너뛰어도 런타임 동의는 동작(공개 배포 시에만 필수).
6. **게시 상태 = "테스트"** 유지 → **테스트 사용자**에 동기화에 쓸 Google 계정 추가.
   - 테스트 모드면 검수 불필요·무료. (공개 배포 시에만 검수 필요)

## 3-A. Android OAuth 클라이언트 ID
**사용자 인증 정보 → 사용자 인증 정보 만들기 → OAuth 클라이언트 ID → Android**
- **패키지 이름**: `sw2.io.tokenmanager`
- **SHA-1 인증서 지문**: 아래 둘 다 등록(디버그·릴리스 빌드 모두 동작하게)

| 빌드 | SHA-1 |
|------|-------|
| Debug | `9F:72:B8:8D:62:F7:9C:36:B3:01:7E:DB:89:CD:F7:02:2B:BE:DD:A5` |
| Release | `8E:74:C1:BD:62:0B:F6:1A:32:5D:FB:65:CC:5B:DD:D5:24:E5:1C:44` |

> Android는 클라이언트 ID를 코드에 넣지 않습니다 — google_sign_in이 패키지+SHA-1로 자동 매칭.
> (CI 릴리스 키를 교체하면 SHA-1이 바뀌므로 다시 등록.)
> SHA-1 재확인: `keytool -list -v -keystore <debug.keystore|release.jks> -alias <androiddebugkey|tokenmanager>`

## 3-B. 크롬 익스텐션 OAuth 클라이언트 ID (같은 프로젝트)
**사용자 인증 정보 → 사용자 인증 정보 만들기 → OAuth 클라이언트 ID → 웹 애플리케이션**
> ⚠️ 유형 목록에 "Chrome 확장 프로그램"이 보여도 **선택하지 마세요** — 그 유형은
> `chrome.identity.getAuthToken`(Chrome 전용)용입니다. 본 익스텐션은 `launchWebAuthFlow`를
> 쓰므로 **"웹 애플리케이션"** + chromiumapp.org 리디렉션 URI 방식이어야 합니다.
- **승인된 리디렉션 URI** (manifest의 `key`로 ID가 고정되어 있음):
  ```
  https://olgcmaiafneffolejiknemocbecoanfd.chromiumapp.org/
  ```
  - 고정 ID: `olgcmaiafneffolejiknemocbecoanfd` (manifest.config.ts의 `key` 공개키에서 파생).
  - 익스텐션 **설정 → Google Drive 동기화** 화면에도 같은 값이 "리디렉션 URI"로 표시됩니다(`chrome.identity.getRedirectURL()`).
  - `key`를 바꾸지 않는 한 PC/재로드와 무관하게 이 ID·URI가 유지됩니다.
- 만들어진 **클라이언트 ID**를 익스텐션 빌드에 주입:
  - `extension/.env`에 `VITE_GOOGLE_OAUTH_CLIENT_ID=...apps.googleusercontent.com`
  - 또는 `extension/src/lib/oauth.config.ts`의 기본값을 직접 채움.
- 빌드: `cd extension && npm run build` → `dist/` 를 `chrome://extensions`에서 "압축해제된 확장 프로그램 로드".

> ⚠️ 익스텐션 ID가 바뀌면(다른 PC에서 unpacked 재로드 등) 리디렉션 URI도 바뀝니다.
> ID를 고정하려면 manifest에 `key`를 넣거나, 웹스토어 게시본의 고정 ID를 사용하세요.

## 3-C. Windows 데스크톱 OAuth 클라이언트 ID (같은 프로젝트)
**사용자 인증 정보 → 사용자 인증 정보 만들기 → OAuth 클라이언트 ID → 데스크톱 앱**
- 리디렉션 URI 등록 불필요 — 데스크톱(installed) 클라이언트는 **loopback(localhost)** 리디렉션이 자동 허용됩니다.
- 발급된 **클라이언트 ID + 보안 비밀**을 gitignore된 `oauth.local.json`에 넣고 빌드/실행 시 주입:
  ```json
  {
    "TM_DESKTOP_OAUTH_CLIENT_ID": "....apps.googleusercontent.com",
    "TM_DESKTOP_OAUTH_CLIENT_SECRET": "GOCSPX-..."
  }
  ```
  ```
  flutter run   -d windows --dart-define-from-file=oauth.local.json
  flutter build windows --release --dart-define-from-file=oauth.local.json
  ```
> 데스크톱 앱의 secret은 OAuth 사양상 "공개 클라이언트"로 취급돼 기밀이 아니지만,
> googleapis_auth가 요구하므로 포함합니다. `oauth.local.json`은 커밋하지 않습니다(.gitignore).

## 4. 사용
### Android 앱
설정 → **폴더 동기화 ON** → 방식 **Google Drive** → **"Google Drive 연결"**(계정 동의)
→ **동기화 패스프레이즈**(8자+, 모든 기기 동일) → **지금 동기화**.

### 크롬 익스텐션
설정 → **Google Drive 동기화** → **"Google Drive 연결"**(동의 창)
→ **동기화 패스프레이즈**(앱과 **동일** 값) 저장 → **지금 동기화**.
- 익스텐션은 보안상 vault 패스프레이즈를 영구 저장하지 않으므로 **백그라운드 자동 동기화는 없음** —
  팝업을 열 때(잠금 해제 시) + "지금 동기화" 버튼으로 동기화합니다.

공통:
- 같은 Google 계정 + 같은 동기화 패스프레이즈면 앱↔익스텐션 양방향 병합.
- 충돌은 title + 최신 updatedAt + 툼스톤(삭제 전파)으로 자동 병합, push 전 재확인으로 lost-update 방지.

## 5. 동작/보안 요점
- 범위 `drive.appdata` → 앱 전용 숨김 폴더만 접근(사용자의 다른 Drive 파일 접근 불가).
- 동기화 파일 = 패스프레이즈 기반 AES-256-GCM 암호문(`tokenmanager-sync.tmbk`). Google은 암호문만 보관.
- 토큰 값은 애초에 저장하지 않음(metadata-only).
- 익스텐션은 OAuth access token만 `chrome.storage.local`에 캐시(refresh token 없음, 만료 시 재인증).
  동기화 패스프레이즈도 `storage.local`에 저장(평문) — 이는 의도된 트레이드오프이며,
  로컬 vault 패스프레이즈(세션 메모리, 미저장)와는 별개입니다.

## 6. 미검증
- 이 흐름은 **사용자의 OAuth 설정(클라이언트 ID + 리디렉션 URI) 후** 실기기/실브라우저에서 검증 필요.
- 코드/빌드/타입 통과: 앱(google_sign_in 6.x + googleapis 13), 익스텐션(launchWebAuthFlow + Drive REST, drive.appdata).
