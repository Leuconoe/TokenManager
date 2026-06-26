import { defineManifest } from '@crxjs/vite-plugin';

// MV3 manifest. `wasm-unsafe-eval` is required for hash-wasm (Argon2id WASM,
// inlined — no remote code), used for .tmbk backup interop with the app.
export default defineManifest({
  manifest_version: 3,
  name: 'TokenManager',
  version: '0.0.1',
  description:
    'Offline token-metadata vault — track token expiry, never store token values.',
  action: {
    default_popup: 'index.html',
    default_title: 'TokenManager',
  },
  // activeTab: 아이콘 클릭 시에만 현재 탭 URL/제목 접근(자동 채우기).
  // alarms+notifications: 백그라운드 주기 만료 알림(평문 스케줄만 읽음).
  permissions: ['storage', 'activeTab', 'alarms', 'notifications'],
  background: {
    service_worker: 'src/background.ts',
    type: 'module',
  },
  content_security_policy: {
    extension_pages: "script-src 'self' 'wasm-unsafe-eval'; object-src 'self'",
  },
  icons: {
    '16': 'icons/icon.png',
    '48': 'icons/icon.png',
    '128': 'icons/icon.png',
  },
});
