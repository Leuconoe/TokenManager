import { defineManifest } from '@crxjs/vite-plugin';

// MV3 manifest. `wasm-unsafe-eval` is required for hash-wasm (Argon2id WASM,
// inlined — no remote code), used for .tmbk backup interop with the app.
export default defineManifest({
  manifest_version: 3,
  name: 'TokenManager',
  version: '1.0.5',
  description:
    'Offline token-metadata vault — track token expiry, never store token values.',
  // Pins the extension ID to a fixed value so the OAuth redirect URI
  // (https://<ID>.chromiumapp.org/) stays valid across machines/reloads.
  // ID = olgcmaiafneffolejiknemocbecoanfd  (public key only — safe to commit).
  key: 'MIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEA1KBVhJ25gbOpmB+mIHDn6bQrpW8gjQjRY4BJpuOPi5MQ5n5Yx8f8SRdFK2Gp7TPzU94zgosufSY+7OoNRK9f5uyalaQQOGwxmIW0ImJo9I+x+kN72ZCW9jnD/qrdn4QiS+G9BFKWdFQN3SvZfsXIkTdubLQ4/9kPe5Q0mPFUt1dOTEOmtbMAKV7uyvHZFICK439p/frIzvUtdWEXKBNe6b2eOxaUj3eJs4E2nkKLX+R5CmA/gEqTaCHXN5TCvJBXds2yYpA1K6u+/a+YgiBzCA2Cy27a/YR+Kx2Lz7e9eqKlGRIfMuZOkKOwm4CQu5ZxQq1PS+a4CfvXvMOsdkmMcQIDAQAB',
  action: {
    default_popup: 'index.html',
    default_title: 'TokenManager',
  },
  // activeTab: 아이콘 클릭 시에만 현재 탭 URL/제목 접근(자동 채우기).
  // alarms+notifications: 백그라운드 주기 만료 알림(평문 스케줄만 읽음).
  // identity: Google Drive sync OAuth via launchWebAuthFlow (drive.appdata).
  permissions: ['storage', 'activeTab', 'alarms', 'notifications', 'identity'],
  // GitHub releases API (update check) + Google Drive REST (appDataFolder sync).
  host_permissions: ['https://api.github.com/*', 'https://www.googleapis.com/*'],
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
