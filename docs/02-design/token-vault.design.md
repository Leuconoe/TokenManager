# token-vault Design Document

> **Summary**: 다양한 서비스의 토큰 발급 메타데이터(서비스명/만료일/노트)를 기기 종속 암호화로 안전 저장하고, 만료·무기한 토큰을 로컬 알림으로 경고하는 오프라인 Flutter 앱.
>
> **Project**: TokenManager
> **Author**: rnd1
> **Date**: 2026-06-12
> **Status**: Draft
> **Planning Doc**: [token-vault.plan.md](../01-plan/token-vault.plan.md)
> **Architecture**: Option C — Pragmatic (feature-first + 얇은 Repository, 암호화 계층만 Port 격리)

---

## Context Anchor

| Key | Value |
|-----|-------|
| **WHY** | 토큰 탈취 공급망 공격 증가 → 발급한 토큰의 수명을 사람이 추적 못 해 방치되는 게 근본 원인. 만료 추적 + 위생 경고로 노출 표면 축소. |
| **WHO** | 여러 서비스(GitHub/AWS/CI 등)에 토큰을 발급하는 개발자·운영자 본인. |
| **RISK** | 앱이 토큰 저장소가 되면 탈취 표적 → **토큰 값 절대 미저장(metadata-only)**. |
| **SUCCESS** | 만료 임박/만료/무기한 토큰을 놓치지 않고 알림받아 회전·폐기. |
| **SCOPE** | 로컬 전용·오프라인·자동연동 없음. 메타데이터 CRUD + 기기종속 암호화 + 로컬 알림 + 패스프레이즈 백업. |

---

## 1. Overview

### 1.1 Design Goals
- 토큰 값을 저장하지 않고도 토큰 수명 주기를 추적·경고.
- 코드에 시드/키 없이 기기 하드웨어 종속 암호화 → 디컴파일·데이터 탈취 무력화.
- 기기 변경 시 패스프레이즈 기반 백업/복원으로 연속성 유지.

### 1.2 Design Principles
- **Metadata-only**: 토큰 값은 도메인 모델에 필드 자체가 없음.
- **Crypto isolation**: 암호화/Keystore 로직은 단일 Port 뒤에 격리, 나머지 계층은 평문 도메인 객체만 취급.
- **Offline-first**: 네트워크 권한 불필요. 외부 전송 0.
- **2-Key model**: 일상 at-rest(Keystore 하드웨어 키) ↔ 백업(사용자 패스프레이즈) 분리.

---

## 2. Architecture (Option C — Pragmatic)

### 2.0 Selected Architecture
**Selected**: Option C — **Rationale**: 보안 핵심(암호화/Keystore)은 Port로 격리해 단위 테스트·감사 가능하게 만들되, 로컬 전용 단일 앱에 풀 Clean Architecture(UseCase 전체)는 과잉이므로 feature-first repository로 나머지를 단순화.

### 2.1 Component Diagram

```
┌──────────────── Presentation (Flutter / Riverpod) ────────────────┐
│  LockScreen  TokenListPage  TokenEditPage  BackupPage  SettingsPage │
└───────────────────────────────┬───────────────────────────────────┘
                                 │ (providers)
┌───────────────────────────────▼───────────────────────────────────┐
│                     Application (Repositories)                      │
│  TokenRepository   BackupRepository   NotificationScheduler         │
└───────┬───────────────────┬───────────────────────┬────────────────┘
        │                   │                        │
┌───────▼────────┐  ┌───────▼─────────┐    ┌─────────▼──────────┐
│  CryptoPort     │  │  Drift DB        │    │ flutter_local_     │
│ (격리·테스트)   │  │  (SQLCipher)     │    │ notifications +    │
│  ├ KeyStore impl│  │                  │    │ workmanager        │
│  └ Passphrase   │  └──────────────────┘    └────────────────────┘
│    impl (백업)  │
└────────┬────────┘
         │
┌────────▼─────────────────────────┐
│  Android Keystore (TEE/StrongBox) │  ← 키 격리, 읽기 불가
│  via flutter_secure_storage       │
└───────────────────────────────────┘
```

### 2.2 Data Flow

```
[일상 저장]
사용자 입력 → 노트 토큰패턴 경고(비차단) → 도메인 검증
  → TokenRepository → Drift(SQLCipher, 키=Keystore에서 로드) → 저장

[앱 진입]
앱 시작/포그라운드 복귀 → LockScreen → local_auth(생체/PIN)
  → 성공 시 CryptoPort.keystore가 DB키 언락 → DB open → 목록 표시

[백업]
BackupPage → 패스프레이즈 입력 → 전체 메타 JSON 직렬화
  → CryptoPort.passphrase (Argon2id+AES-GCM) → 암호문 파일 export(SAF)

[복원]
파일 선택 → 패스프레이즈 입력 → 복호화 → 병합/덮어쓰기 선택 → DB 반영

[알림]
workmanager 일1회 → TokenRepository.scanStatus()
  → expired/expiringSoon/noExpiry 분류 → local_notifications 발행
```

### 2.3 Dependencies

| Component | Depends On | Purpose |
|-----------|-----------|---------|
| TokenRepository | Drift DB, CryptoPort(keystore) | 메타 CRUD + DB 키 언락 |
| BackupRepository | CryptoPort(passphrase), TokenRepository | export/import 암복호화 |
| NotificationScheduler | TokenRepository, local_notifications, workmanager | 상태 스캔 후 알림 발행 |
| CryptoPort(keystore) | flutter_secure_storage | DB 키 안전 저장/로드 |

---

## 3. Data Model

### 3.1 Entity Definition

```dart
// 토큰 값 필드는 의도적으로 존재하지 않음 (metadata-only)
class TokenEntry {
  final String id;            // UUID v4
  final String serviceName;   // 필수. 예: "GitHub PAT - CI 배포용"
  final DateTime? issuedAt;    // 선택. 발급일
  final DateTime? expiresAt;   // 선택. null = 무기한(경고 대상)
  final String note;          // 토큰 값 금지(경고만). 메모/회전정책 등
  final DateTime createdAt;
  final DateTime updatedAt;
}

enum TokenStatus { valid, expiringSoon, expired, noExpiry }
// 파생 계산: expiresAt==null → noExpiry
//            expiresAt<now → expired
//            expiresAt-now <= 14d → expiringSoon
//            else → valid
```

### 3.3 Database Schema (Drift / SQLCipher)

```sql
CREATE TABLE token_entries (
  id          TEXT PRIMARY KEY NOT NULL,
  service_name TEXT NOT NULL,
  issued_at   INTEGER,           -- epoch millis, nullable
  expires_at  INTEGER,           -- epoch millis, nullable (NULL=무기한)
  note        TEXT NOT NULL DEFAULT '',
  created_at  INTEGER NOT NULL,
  updated_at  INTEGER NOT NULL
);
CREATE INDEX idx_expires_at ON token_entries(expires_at);
-- DB 파일 전체가 SQLCipher로 암호화됨. PRAGMA key = <Keystore에서 로드한 256bit>
```

### 3.4 Backup File Format

```
TokenManagerBackup v1
┌─ header (평문 JSON) ─────────────────────────┐
│ { "version":1, "kdf":"argon2id",            │
│   "salt":"<base64>", "nonce":"<base64>",    │
│   "params":{"memKiB":65536,"iter":3,"par":1}}│
├─ body (암호문) ──────────────────────────────┤
│ AES-256-GCM( key=Argon2id(passphrase,salt),  │
│   plaintext = JSON([TokenEntry...]) )        │
└──────────────────────────────────────────────┘
```

---

## 4. API Specification

> 외부/서버 API 없음 (오프라인 로컬 전용). 내부 Repository 계약으로 대체.

### 4.1 Internal Contracts

```dart
abstract class CryptoPort {
  // 일상 at-rest: Keystore 하드웨어 키
  Future<String> loadOrCreateDbKey();       // 최초 랜덤생성→Keystore저장, 이후 로드
  // 백업: 패스프레이즈 파생
  Future<Uint8List> encryptBackup(Uint8List plain, String passphrase);
  Future<Uint8List> decryptBackup(Uint8List cipher, String passphrase); // 실패 시 throw
}

abstract class TokenRepository {
  Future<List<TokenEntry>> list({TokenSort sort = TokenSort.expirySoonest});
  Future<TokenEntry?> getById(String id);
  Future<void> upsert(TokenEntry e);
  Future<void> delete(String id);
  Future<Map<TokenStatus, List<TokenEntry>>> scanStatus(); // 알림용 분류
}

abstract class BackupRepository {
  Future<File> export(String passphrase);                  // SAF 저장
  Future<int> import(File f, String passphrase, ImportMode mode); // 반환=반영 건수
}
enum ImportMode { merge, overwrite }
```

---

## 5. UI/UX Design

### 5.2 User Flow

```
앱 실행 → LockScreen(생체/PIN) → TokenListPage
  ├ (+) → TokenEditPage(추가) → 저장 → List
  ├ 항목 탭 → TokenEditPage(수정/삭제)
  ├ 메뉴 → BackupPage(export/import)
  └ 메뉴 → SettingsPage(무기한 경고 주기, 루팅 경고 등)
알림 탭 → 해당 TokenEditPage 직행
```

### 5.3 Component List

| Component | Location | Responsibility |
|-----------|----------|----------------|
| LockScreen | lib/features/lock/ | 진입 생체인증 게이트 |
| TokenListPage | lib/features/tokens/ | 만료 임박순 목록 + 상태 배지 |
| TokenEditPage | lib/features/tokens/ | 추가/수정/삭제 폼 + 노트 경고 |
| BackupPage | lib/features/backup/ | 패스프레이즈 export/import |
| SettingsPage | lib/features/settings/ | 경고 주기/루팅 정책 |
| StatusBadge | lib/shared/widgets/ | valid/soon/expired/noExpiry 색상 배지 |

### 5.4 Page UI Checklist

#### TokenListPage
- [ ] List: 항목 카드 (서비스명, 만료일/D-day, 상태 배지)
- [ ] Badge: 상태 4종 — valid(녹색)/expiringSoon(주황)/expired(빨강)/noExpiry(회색 ⚠)
- [ ] Sort: 만료 임박순(기본) / 서비스명 / 최근수정
- [ ] FAB: 항목 추가 (+)
- [ ] Empty state: "아직 기록된 토큰이 없습니다" 안내

#### TokenEditPage
- [ ] Input: 서비스명 (필수, 빈값 검증)
- [ ] DatePicker: 발급일 (선택, clear 가능)
- [ ] DatePicker: 만료일 (선택, clear 가능 → 무기한)
- [ ] Toggle/Hint: "만료일 없음 = 무기한(보안 경고 대상)" 안내
- [ ] TextArea: 노트
- [ ] Banner: "⚠️ 토큰 값은 입력하지 마세요. 이 앱은 토큰 추적용입니다." (상단 고정)
- [ ] Warning dialog: 노트에 토큰 패턴 감지 시 "계속 저장할까요?" (저장/취소) — **비차단**
- [ ] Button: 저장 / 삭제(수정 모드)

#### BackupPage
- [ ] Input: 패스프레이즈 (export/import 공통, 강도 표시)
- [ ] Button: 백업 내보내기 (SAF 파일 저장)
- [ ] Button: 복원 가져오기 (파일 선택)
- [ ] Radio: 복원 모드 — 병합(merge, 기본) / 덮어쓰기(overwrite)
- [ ] Result: 성공/실패 메시지 (복호화 실패 시 "비밀번호가 올바르지 않습니다")

---

## 6. Error Handling

| Code | 상황 | 처리 |
|------|------|------|
| E-AUTH-01 | 생체인증 실패/취소 | 잠금 유지, 데이터 미표시, 재시도 버튼 |
| E-KEY-01 | Keystore 키 로드 실패(기기 손상 등) | 복구 안내 + 백업 복원 유도 |
| E-VAL-01 | 서비스명 빈값 | 인라인 에러, 저장 차단 |
| E-NOTE-01 | 노트 토큰 패턴 감지 | **경고 다이얼로그(비차단)** — 사용자 선택 |
| E-BAK-01 | 복원 복호화 실패(잘못된 패스프레이즈) | "비밀번호가 올바르지 않습니다" |
| E-BAK-02 | 백업 파일 포맷/버전 불일치 | "지원하지 않는 백업 파일" |

---

## 7. Security Considerations

- [x] **기기종속 암호화**: DB는 SQLCipher, 키는 Android Keystore(TEE/StrongBox) — 코드에 시드 0.
- [x] **생체인증 게이트**: 진입/포그라운드 복귀 시 잠금. `setUserAuthenticationRequired`로 키를 인증에 바인딩.
- [x] **토큰 미저장**: 도메인 모델에 토큰 값 필드 부재. 노트는 패턴 경고(비차단).
- [x] **백업 암호화**: Argon2id + AES-256-GCM, 패스프레이즈 기반. 헤더 평문/본문 암호문.
- [x] **네트워크 차단**: INTERNET 권한 미요청(또는 미사용) → 외부 전송 불가.
- [x] **백업 제외**: `android:allowBackup="false"`, `fullBackupContent` 제외로 adb 평문 백업 방지.
- [ ] **루팅 탐지**(선택): 경고 배너 (Design §미해결 #4 → 기본 경고만).
- [x] **클립보드/스크린샷**: 민감 화면 `FLAG_SECURE` 적용 검토.

---

## 8. Test Plan

### 8.1 Test Scope

| Type | Target | Tool | Phase |
|------|--------|------|-------|
| L1: Unit | CryptoPort(암복호 왕복), 상태 분류 로직 | flutter_test | Do |
| L2: Widget | TokenEditPage 검증·노트 경고, StatusBadge | flutter_test + widget | Do |
| L3: Integration | 추가→목록→백업→복원→복원검증 전체 흐름 | integration_test | Do |

### 8.2 L1 Unit 시나리오

| # | 대상 | 테스트 | 기대 |
|---|------|--------|------|
| 1 | CryptoPort.encrypt/decryptBackup | 동일 패스프레이즈 왕복 | 원본 == 복호 결과 |
| 2 | decryptBackup | 잘못된 패스프레이즈 | throw (E-BAK-01) |
| 3 | TokenStatus 계산 | expiresAt=null | noExpiry |
| 4 | TokenStatus 계산 | expiresAt = now+10d | expiringSoon |
| 5 | TokenStatus 계산 | expiresAt = now-1d | expired |
| 6 | 노트 패턴 탐지 | "ghp_xxxx...", JWT, 고엔트로피 | 경고 플래그 true (저장은 허용) |

### 8.3 L2 Widget 시나리오

| # | Page | Action | 기대 |
|---|------|--------|------|
| 1 | TokenEditPage | 서비스명 빈값 저장 | 인라인 에러, 저장 안 됨 |
| 2 | TokenEditPage | 노트에 토큰 입력 후 저장 | 경고 다이얼로그 표시, "저장" 선택 시 저장됨 |
| 3 | TokenListPage | 무기한 항목 렌더 | noExpiry 배지(⚠) 표시 |
| 4 | BackupPage | 잘못된 패스프레이즈 복원 | "비밀번호가 올바르지 않습니다" |

### 8.4 L3 Integration 시나리오

| # | 시나리오 | Steps | 성공 기준 |
|---|----------|-------|-----------|
| 1 | 핵심 흐름 | 잠금해제→추가→목록확인→백업export→데이터삭제→import→복원확인 | 복원 후 항목 동일 |
| 2 | 만료 알림 | 만료 임박/만료/무기한 항목 시드 → scanStatus | 3분류 정확 |
| 3 | 잠금 게이트 | 앱 재시작 | 인증 전 목록 비표시 |

### 8.5 Seed Data

| Entity | Min Count | Key Fields |
|--------|:---------:|-----------|
| TokenEntry | 4 | 각 status 1건: valid/expiringSoon/expired/noExpiry |

---

## 9. Clean Architecture (경량 적용)

### 9.1 Layer Structure

| Layer | 책임 | 위치 |
|-------|------|------|
| Presentation | 화면, Riverpod provider | `lib/features/*/`, `lib/shared/widgets/` |
| Application | Repository, Scheduler (오케스트레이션) | `lib/features/*/data/`, `lib/core/notification/` |
| Domain | Entity, TokenStatus, 순수 규칙 | `lib/core/domain/` |
| Infrastructure | Drift, Keystore, secure_storage, notifications | `lib/core/db/`, `lib/core/crypto/` |

### 9.3 Import Rules

| From | Can Import | Cannot Import |
|------|-----------|---------------|
| Presentation | Application, Domain | Infrastructure 직접 |
| Application | Domain, Infrastructure | Presentation |
| Domain | (순수, 외부 의존 0) | 모든 외부 |
| Infrastructure | Domain | Application, Presentation |

### 9.4 Layer Assignment

| Component | Layer | Location |
|-----------|-------|----------|
| TokenEntry, TokenStatus | Domain | `lib/core/domain/token_entry.dart` |
| CryptoPort (interface) | Domain | `lib/core/domain/crypto_port.dart` |
| KeystoreCryptoImpl | Infrastructure | `lib/core/crypto/keystore_crypto.dart` |
| AppDatabase (Drift) | Infrastructure | `lib/core/db/app_database.dart` |
| TokenRepository | Application | `lib/features/tokens/data/token_repository.dart` |
| NotificationScheduler | Application | `lib/core/notification/scheduler.dart` |
| *Page widgets | Presentation | `lib/features/*/` |

---

## 10. Coding Convention (Dart/Flutter)

| Target | Rule | Example |
|--------|------|---------|
| Classes/Types | PascalCase | `TokenEntry`, `CryptoPort` |
| Functions/vars | camelCase | `loadOrCreateDbKey()` |
| Constants | lowerCamelCase (Dart 관례) | `expiringSoonDays` |
| Files | snake_case.dart | `token_repository.dart` |
| Folders | snake_case | `features/tokens/` |
| State | Riverpod Notifier/AsyncNotifier | `tokenListProvider` |

---

## 11. Implementation Guide

### 11.1 File Structure

```
lib/
├── main.dart
├── core/
│   ├── domain/        token_entry.dart, token_status.dart, crypto_port.dart
│   ├── crypto/        keystore_crypto.dart, passphrase_crypto.dart
│   ├── db/            app_database.dart (Drift+SQLCipher)
│   └── notification/  scheduler.dart, workmanager_callback.dart
├── features/
│   ├── lock/          lock_screen.dart, biometric_service.dart
│   ├── tokens/        token_list_page.dart, token_edit_page.dart,
│   │                  data/token_repository.dart, note_token_detector.dart
│   ├── backup/        backup_page.dart, data/backup_repository.dart
│   └── settings/      settings_page.dart
└── shared/widgets/    status_badge.dart
```

### 11.2 Implementation Order
1. [ ] Domain: TokenEntry + TokenStatus 계산 + 단위테스트
2. [ ] Infra: CryptoPort(keystore) + Drift/SQLCipher 연결
3. [ ] Application: TokenRepository CRUD + scanStatus
4. [ ] Presentation: LockScreen → List → Edit (노트 경고 포함)
5. [ ] Notification: workmanager 일1회 스캔 + 알림
6. [ ] Backup: passphrase crypto + export/import
7. [ ] Settings + 하드닝(allowBackup=false, FLAG_SECURE)

### 11.3 Session Guide

#### Module Map

| Module | Scope Key | Description | Est. Turns |
|--------|-----------|-------------|:----------:|
| Core(도메인+암호화+DB) | `module-1` | TokenEntry, CryptoPort/Keystore, Drift+SQLCipher | 40-50 |
| Tokens(CRUD+잠금+UI) | `module-2` | LockScreen, List/Edit, Repository, 노트 경고 | 45-55 |
| Notify+Backup | `module-3` | 알림 스케줄 + 패스프레이즈 백업/복원 | 40-50 |

#### Recommended Session Plan

| Session | Phase | Scope | Turns |
|---------|-------|-------|:-----:|
| Session 1 | Plan + Design | 전체 | 완료 |
| Session 2 | Do | `--scope module-1` | 40-50 |
| Session 3 | Do | `--scope module-2` | 45-55 |
| Session 4 | Do | `--scope module-3` | 40-50 |
| Session 5 | Check + Report | 전체 | 30-40 |

---

## 확정 결정 (2026-06-12)
1. 무기한 경고 주기 — **Settings 노출, 기본 weekly**, 무기한 0건이면 알림 스킵. (`NoExpiryWarnInterval{off,weekly,biweekly,monthly}`)
2. 검색/태그 — **v1 제외**. 정렬 3종 + 상태 필터 칩만. 태그는 v2 후보.
3. 백업 파일 공유 — **SAF 저장(기본) + 공유 시트(share_plus) 보조**. 파일명 `tokenmanager-backup-<YYYYMMDD>.tmbk`. 공유 시 패스프레이즈 동반 금지 경고.
4. 루팅 탐지 — **경고 배너만(비차단)**. 정당 루팅 사용자 배제 안 함. 핵심 방어는 Keystore라 차단 불필요.
5. KDF — **Argon2id**(memory=64MiB, iter=3, par=1, salt 16B, key 32B) + AES-256-GCM(nonce 12B). 폴백 PBKDF2-HMAC-SHA256(iter≥600k), 헤더 `kdf` 필드로 구분.

---

## Version History

| Version | Date | Changes | Author |
|---------|------|---------|--------|
| 0.1 | 2026-06-12 | Initial draft (Option C) | rnd1 |
