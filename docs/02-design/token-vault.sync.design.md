# token-vault — 동기화 설계 (Synced-Folder File)

> Design addendum. 플랫폼 간 데이터 동기화. **옵트인**(기본 오프라인 유지),
> **인앱 로그인 없음**, **백엔드 없음**. 사용자의 기존 클라우드 동기화 폴더에
> 암호화 파일을 두고 그 클라이언트가 전파하게 한다.

## 1. 결정 / 원칙

| 항목 | 결정 |
|------|------|
| 전송 | **사용자가 지정한 동기화 폴더에 암호화 파일 1개** (Google Drive/OneDrive/Dropbox 데스크톱 폴더, Android SAF) |
| 로그인 | 인앱/백엔드 로그인 **없음**. 클라우드 인증은 사용자의 기존 클라이언트가 담당 |
| 암호화 | **E2E** — 동기화 파일은 **패스프레이즈 기반**(Argon2id + AES-256-GCM, `.tmbk` 포맷). 클라우드엔 **암호문만**. 토큰 값은 애초에 없음(metadata-only) |
| 옵트인 | 설정에서 켤 때만 동작. 기본 OFF(오프라인) |
| 충돌 | 기존 **title(serviceName) 기준 병합 + 충돌 선택** 재사용 |

## 2. 왜 패스프레이즈인가 (기기키와 별개)
- 앱 at-rest 키: Android Keystore / Windows DPAPI → **기기 종속, 타기기 복호 불가**.
- 따라서 기기 간 공유 파일은 기기키로 암호화하면 안 됨 → **사용자 공유 비밀(동기화 패스프레이즈)** 로 암호화.
- 사용자는 **기기마다 1회** 동기화 패스프레이즈 입력 → `flutter_secure_storage`(Keystore/DPAPI)에 보관 → 이후 자동 암복호.
- 이 패스프레이즈는 기존 `.tmbk` 백업 패스프레이즈와 동일 개념(재사용 가능).

## 3. 동기화 파일
- 파일명: `tokenmanager-sync.tmbk` (단일 파일, 폴더 내).
- 내용: `.tmbk` 포맷(헤더 평문 JSON {magic,version,kdf,salt,nonce,mac} + base64 본문). 본문 = `JSON([TokenEntry...])` 암호문.
- **버전/시계**: 헤더에 `updatedAt`(epoch ms), `deviceId`(랜덤, 비식별) 추가 → 변경 감지·충돌 판단용. (기존 `.tmbk`는 백업용으로 유지, 동기화 파일은 헤더 필드 확장 = `magic:"TokenManagerSync"`)

## 4. 동기화 엔진 (공통 로직)
```
SyncService:
  pull(): 원격 파일 읽기 → 복호 → 엔트리
  push(local): 로컬 엔트리 → 암호화 → 원격 파일 쓰기 (updatedAt 갱신)
  syncNow():
    remote = pull()                # 없으면 push(local) 후 종료
    merged, conflicts = mergeByTitle(local, remote)   # 기존 충돌 로직
    if conflicts: 사용자 선택(앱 다이얼로그)
    저장(merged) + push(merged)
  변경 감지: 원격 헤더 updatedAt / 파일 mtime / 본문 hash
```
- **트리거**: (1) 앱 실행/포그라운드 복귀 시 pull+merge, (2) 로컬 저장 시 push(디바운스), (3) 설정에서 "지금 동기화" 수동.
- **안전장치(구현됨)**: push는 절대 blind overwrite 안 함. 쓰기 직전 **원격을 한 번 더 읽어** 우리가 처음 읽은 이후 바뀌었으면 그 최신본을 **다시 병합** 후 기록(lost-update 방지). 쓰기는 **임시파일+rename으로 원자적**(클라이언트가 반쪽 파일 못 읽게).

## 5. 플랫폼별 접근

| 플랫폼 | 폴더/파일 접근 | 비고 |
|--------|----------------|------|
| **Windows/desktop** | 일반 폴더 경로 선택(`file_picker` getDirectoryPath) → 경로 저장 → `dart:io` 읽기/쓰기 | 사용자가 Drive/OneDrive 동기화 폴더 지정 |
| **Android** | **SAF** 폴더 트리 URI(영구 권한) → DocumentFile 쓰기 | `shared_storage`/`saf_util` 또는 플랫폼 채널 필요(가장 까다로운 부분) |
| **익스텐션** | FS 폴더 자동쓰기 **불가**(샌드박스) → **수동 import/export 유지**(이미 동작), 또는 후속에 Drive API 별도 | v1 범위 밖 |

## 6. 설정 UI (앱)
- "동기화" 섹션: 스위치(ON/OFF) → ON 시 (1) 폴더 선택, (2) 동기화 패스프레이즈 입력.
- "지금 동기화" 버튼 + 마지막 동기화 시각 표시.
- ON이면 INTERNET 불필요(로컬 폴더 쓰기만; 클라우드 전파는 외부 클라이언트). **네트워크 권한 추가 없음** ← 큰 장점.

## 7. 보안
- 클라우드엔 **암호문만**. 패스프레이즈 없으면 복호 불가.
- 동기화 패스프레이즈는 secure storage(Keystore/DPAPI)에 기기별 보관, 파일·로그에 평문 없음.
- 폴더 경로/URI도 secure storage 또는 일반 prefs(민감X).
- 옵트인 OFF가 기본 → 오프라인 보안 모델 그대로.

## 8. 구현 모듈 / 단계
| 모듈 | 범위 |
|------|------|
| `sync-1` 코어 | SyncFile 포맷(헤더 확장) + SyncService(pull/push/merge) — 순수 로직 + 단위테스트 |
| `sync-2` Windows | 폴더 선택 + dart:io 읽기/쓰기 + 설정 UI + 트리거 |
| `sync-3` Android | SAF 폴더 URI 영구권한 + DocumentFile IO (가장 큰 미지수) |
| `sync-4` 익스텐션 | (선택) Drive API 또는 수동 유지 |

## 9. 결정 사항 (확정)
1. **패스프레이즈 통합** — 동기화 = `.tmbk` 백업 패스프레이즈 동일 사용.
2. **트리거** — 실행 시 자동 pull+merge + 저장 시 디바운스 push + 수동 "지금 동기화".
3. **Android** — `shared_storage`(SAF) 폴더 트리 영구권한.
4. **삭제 = Tombstone** — 하드 삭제 대신 `deletedAt`(soft delete). 목록은 `deletedAt==null`만 표시. 병합은 title별 `updatedAt` 최신 우선(툼스톤도 엔트리로 취급 → 삭제 전파). 오래된 툼스톤은 주기 정리(예: 90일 경과 시 purge).

### 데이터 모델 변경 (schema v3)
- `TokenEntry.deletedAt: int?` 추가. delete() = `deletedAt=now, updatedAt=now` upsert.
- `list()`는 `deletedAt==null` 필터. `scanStatus()`도 동일.
- 병합: 같은 title이면 `updatedAt`이 큰 쪽 채택(삭제/수정 모두 일관). 백업/동기화 파일엔 툼스톤 포함.

## 10. 권장 순서
**sync-1(코어) → sync-2(Windows, 가장 쉬움)로 PoC → sync-3(Android SAF)**. 익스텐션(sync-4)은 수동 유지하다 필요 시 Drive API.
