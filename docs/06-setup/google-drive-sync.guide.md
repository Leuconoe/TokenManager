# Google Drive 동기화 설정 가이드 (Android)

> Android에서 **Google Drive 동기화**를 쓰려면 Google Cloud OAuth 설정이 1회 필요합니다.
> 비용 0(개인 사용·Testing 모드). 데이터는 본인 Drive의 숨김 **appDataFolder**에 암호문으로만 저장됩니다.
> (Windows는 폴더 동기화 사용 — 별도 설정 불필요.)

## 1. Google Cloud 프로젝트
1. https://console.cloud.google.com → 프로젝트 생성(예: `tokenmanager`).
2. **API 및 서비스 → 라이브러리 → "Google Drive API" 사용 설정**.

## 2. OAuth 동의 화면
1. **API 및 서비스 → OAuth 동의 화면** → User Type **External** → 만들기.
2. 앱 이름/이메일 입력(최소).
3. **범위(Scopes) 추가** → `.../auth/drive.appdata` (앱 데이터 폴더) 검색해 추가.
4. **게시 상태 = "테스트"** 유지 → **테스트 사용자**에 본인 Google 계정 추가.
   - 테스트 모드면 검수 불필요·무료. (공개 배포 시에만 검수 필요)

## 3. Android OAuth 클라이언트 ID
**API 및 서비스 → 사용자 인증 정보 → 사용자 인증 정보 만들기 → OAuth 클라이언트 ID → Android**
- **패키지 이름**: `com.example.token_manager`
- **SHA-1 인증서 지문**: 아래 둘 다 등록(디버그·릴리스 빌드 모두 동작하게)

| 빌드 | SHA-1 |
|------|-------|
| Debug | `9F:72:B8:8D:62:F7:9C:36:B3:01:7E:DB:89:CD:F7:02:2B:BE:DD:A5` |
| Release | `8E:74:C1:BD:62:0B:F6:1A:32:5D:FB:65:CC:5B:DD:D5:24:E5:1C:44` |

> 클라이언트 ID는 코드에 넣지 않습니다 — google_sign_in이 패키지+SHA-1로 자동 매칭합니다.
> (CI 릴리스 키를 교체하면 SHA-1이 바뀌므로 다시 등록.)
> SHA-1 재확인:
> ```
> keytool -list -v -keystore <debug.keystore|release.jks> -alias <androiddebugkey|tokenmanager>
> ```

## 4. 앱에서 사용
설정 → **폴더 동기화 ON** → 방식 **Google Drive** 선택 → **"Google Drive 연결"**(계정 동의) → **동기화 패스프레이즈**(8자+, 다른 기기와 동일) 설정 → **지금 동기화**.

- 다른 기기(같은 Google 계정 + 같은 패스프레이즈)에서 켜면 양방향 병합.
- 충돌은 title + 최신 updatedAt + 툼스톤으로 자동 병합, push 전 재확인으로 lost-update 방지.

## 5. 동작/보안 요점
- 범위 `drive.appdata` → 앱 전용 숨김 폴더만 접근(사용자의 다른 Drive 파일 접근 불가).
- 동기화 파일 = 패스프레이즈 기반 AES-256-GCM 암호문(`tokenmanager-sync.tmbk`). Google은 암호문만 보관.
- 토큰 값은 애초에 저장하지 않음(metadata-only).

## 6. 미검증
- 이 흐름은 **사용자의 OAuth 설정 후** 실기기에서 검증 필요. 코드/빌드/타입은 통과(google_sign_in 6.x + googleapis 13 + drive.appdata).
