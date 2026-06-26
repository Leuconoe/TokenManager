# TokenManager — Browser Extension

[TokenManager](../README.md) 앱의 크롬(MV3) 익스텐션. 토큰 값을 저장하지 않고
발급 내역만 기록하며, 앱의 `.tmbk` 백업과 **상호 호환**됩니다.

## 스택
Svelte 5 + TypeScript + Vite + [@crxjs/vite-plugin](https://crxjs.dev) (MV3) · 암호화는 hash-wasm(Argon2id) + WebCrypto(AES-256-GCM).

## 보안 모델
- **Metadata-only** — 토큰 값 미저장. 노트에 토큰 패턴 감지 시 경고(비차단)
- **패스프레이즈 잠금** — `chrome.storage.local`을 Argon2id 파생키 + AES-256-GCM으로 암호화, 세션마다 잠금 해제
- **백업 상호운용** — 앱과 동일한 `.tmbk` 포맷(Argon2id 64MiB/3/1 + AES-256-GCM, 헤더 JSON + base64 본문). 앱↔익스텐션 백업 파일 교차 복원 가능
- 오프라인 — `storage` 권한만, 네트워크 권한 없음

## 빌드 / 로드
```bash
cd extension
npm install
npm run build        # → dist/
```
크롬: `chrome://extensions` → 개발자 모드 ON → **압축해제된 확장 프로그램 로드** → `extension/dist` 선택.

개발: `npm run dev` (HMR).

## 구조
```
src/
├── App.svelte            잠금 게이트 + 뷰 라우팅
├── components/           TokenList · TokenEdit · Backup
└── lib/
    ├── domain.ts         TokenEntry, statusOf()
    ├── crypto.ts         Argon2id + AES-GCM, .tmbk export/import
    ├── vault.ts          chrome.storage 암호화 저장(잠금/CRUD)
    └── noteDetector.ts   토큰 패턴 경고
```

## 알려진 한계 / 후속
- a11y: 일부 `<label>`–입력 연결 경고(기능 무관)
- 만료 알림: 현재 팝업 진입 시 상태 표시. 백그라운드 주기 알림(`chrome.alarms` + `chrome.notifications`)은 후속
