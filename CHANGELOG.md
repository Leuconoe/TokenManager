# Changelog

## v0.0.1 — 2026-06-26

첫 공개 빌드. **토큰을 저장하지 않고** 발급 내역(서비스명/URL/만료일/노트)만
기기 종속 암호화로 기록하는 오프라인 토큰 메타데이터 보관함. Android + Windows.

### 보안
- **Metadata-only**: 토큰 값 자체는 저장하지 않음 (도메인 모델에 필드 부재)
- **기기 종속 암호화**: DB 전체 SQLCipher 암호화, 키는 기기에서 생성·보관
  (코드에 시드/키 없음 → 디컴파일·타기기 복사로 복원 불가)
  - Android: 하드웨어 Keystore(TEE/StrongBox)
  - Windows: DPAPI(사용자 계정 바인딩)
- **잠금 게이트**: 진입 시 생체인증/Windows Hello (잠금 미설정 기기는 자동 스킵)
- **오프라인 전용**: 네트워크 권한 없음, 외부 전송 0
- Android: `allowBackup=false`, 스크린샷 차단(FLAG_SECURE)

### 기능
- 토큰 추가/수정/삭제, 만료 임박순 정렬 + 상태 필터(임박/만료/무기한/유효)
- 상태 배지 4종(유효/임박/만료/무기한)
- 노트 토큰-입력 경고(비차단) — `ghp_`/`AKIA`/`sk-`/JWT 등 패턴 + 고엔트로피 감지
- 만료/만료임박 알림
  - Android: WorkManager 백그라운드 일일 스캔 → 로컬 알림
  - Windows: 로그인 자동실행 + 트레이 상주 + 주기 스캔 → 트레이 툴팁 요약
- 무기한 토큰 보안 경고(주기 설정: 끄기/주1회/2주/월1회)
- 패스프레이즈 백업/복원 — Argon2id + AES-256-GCM (SAF 저장 + 공유, 병합/덮어쓰기)
- 다국어 7개: 한국어/English/日本語/中文/中文(繁體)/Español/Français
  (시스템 언어 자동 + 영어 폴백, 설정에서 수동 선택)

### 플랫폼
- **Android**: minSdk 23, 빌드·실행·테스트 검증
- **Windows**: 데스크톱 빌드·실행 검증 (SQLCipher OpenSSL 정적링크,
  트레이/자동실행/Windows Hello)

### 알려진 제한
- Windows OS 토스트 알림 미지원 → 트레이 툴팁으로 만료 요약 (후속: flutter_local_notifications_windows)
- Windows 자동실행 ON/OFF 설정 토글 없음(기본 활성)
- 릴리스 빌드는 디버그 키 서명 (배포 키 미구성)
