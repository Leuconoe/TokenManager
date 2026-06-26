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

## 백그라운드 만료 알림
`alarms` + `notifications` 권한 + service worker(`src/background.ts`)로 12시간 주기 점검.
패스프레이즈가 없는 SW는 vault를 복호화할 수 없으므로, 저장 시 **평문 스케줄(만료 시각·개수만, 서비스명/노트 제외)** 을 따로 기록하고 SW는 그것만 읽어 **일반 알림**("만료 N · 임박 M — 열어서 확인")을 띄웁니다. 상세는 팝업 잠금 해제 후 확인.

## 알려진 한계 / 후속
- a11y: 일부 `<label>`–입력 연결 경고(기능 무관)
- 알림은 정체성 비노출을 위해 개수만 표시(설계상 의도)
