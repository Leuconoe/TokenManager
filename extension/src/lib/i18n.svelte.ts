// Lightweight i18n for the extension — 7 locales matching the app.
// Reactive via a module-level $state (Svelte 5 .svelte.ts). t() re-runs in
// templates when the locale changes.

export type Locale = 'ko' | 'en' | 'ja' | 'zh' | 'zh_Hant' | 'es' | 'fr';
export type LocaleSel = Locale | 'system';

const SUPPORTED: Locale[] = ['ko', 'en', 'ja', 'zh', 'zh_Hant', 'es', 'fr'];
const KEY = 'tm_locale_v1';

export const SELECTABLE: { code: LocaleSel; label: string }[] = [
  { code: 'system', label: 'System' },
  { code: 'ko', label: '한국어' },
  { code: 'en', label: 'English' },
  { code: 'ja', label: '日本語' },
  { code: 'zh', label: '中文' },
  { code: 'zh_Hant', label: '中文 (繁體)' },
  { code: 'es', label: 'Español' },
  { code: 'fr', label: 'Français' },
];

type Dict = Record<string, string>;

const M: Record<Locale, Dict> = {
  ko: {
    titleList: '토큰 보관함', titleAdd: '토큰 추가', titleEdit: '토큰 수정',
    titleBackup: '백업 / 복원', titleSettings: '설정',
    lockUnlockPrompt: '패스프레이즈를 입력해 잠금을 해제하세요',
    lockSetPrompt: '새 패스프레이즈를 설정하세요 (8자 이상)',
    passphrase: '패스프레이즈', unlock: '잠금 해제', start: '시작하기',
    pwTooShort: '패스프레이즈는 8자 이상이어야 합니다', pwWrong: '패스프레이즈가 올바르지 않습니다',
    empty1: '아직 기록된 토큰이 없습니다', empty2: '+ 버튼으로 추가하세요', addToken: '+ 토큰 추가',
    stValid: '유효', stSoon: '임박', stExpired: '만료', stNoExpiry: '무기한',
    noExpiryDate: '만료일 없음', expiredAt: '만료됨 ({date})', dday: '만료 D-{days} ({date})',
    tokenBanner: '⚠️ 토큰 값은 입력하지 마세요. 이 앱은 토큰 추적용이며 값 저장을 권장하지 않습니다.',
    autofilled: '현재 탭에서 자동 입력됨 (수정 가능)',
    fieldService: '서비스 명 *', svcHint: '예: GitHub PAT - CI 배포용', fieldUrl: 'URL (선택)',
    issued: '발급일', expires: '만료일', noExpiryHint: '만료일 미설정 = 무기한(보안 경고 대상)',
    note: '노트', noteHint: '회전 정책, 용도 등 (토큰 값 입력 금지)', errService: '서비스 명을 입력하세요',
    noteWarn: '노트에 토큰 값으로 보이는 내용이 있습니다. 계속 저장할까요?',
    save: '저장', delete: '삭제', cancel: '취소', deleteConfirm: '"{name}" 기록을 삭제할까요?',
    backupInfo: '백업은 패스프레이즈로 암호화됩니다 (Argon2id + AES-256-GCM). 앱의 .tmbk 백업과 호환됩니다.',
    passLabel: '패스프레이즈 (8자 이상)', passShared: '백업/복원 공통',
    exportSection: '내보내기', exportBtn: '백업 파일 내보내기', restoreSection: '복원',
    merge: '병합', overwrite: '덮어쓰기', exported: '백업 파일을 내보냈습니다', restored: '{count}건을 복원했습니다',
    authErr: '비밀번호가 올바르지 않거나 백업이 손상되었습니다', fmtErr: '지원하지 않는 백업 파일입니다',
    shareWarn: '⚠️ 백업 파일을 공유할 때 패스프레이즈를 함께 전송하지 마세요.',
    noExpiryTitle: '무기한 토큰 경고', noExpirySub: '만료일이 없는 토큰에 대한 주기적 보안 경고 알림 주기',
    intervalOff: '끄기', interval15: '15일마다', interval30: '30일마다',
    saved: '저장됨', settingsNote: '알림은 백그라운드에서 동작하며 개수만 표시합니다(어떤 서비스인지 비노출). 상세는 잠금 해제 후 확인하세요.',
    language: '언어', languageSystem: '시스템 기본',
  },
  en: {
    titleList: 'Token Vault', titleAdd: 'Add token', titleEdit: 'Edit token',
    titleBackup: 'Backup / Restore', titleSettings: 'Settings',
    lockUnlockPrompt: 'Enter your passphrase to unlock',
    lockSetPrompt: 'Set a new passphrase (8+ characters)',
    passphrase: 'Passphrase', unlock: 'Unlock', start: 'Get started',
    pwTooShort: 'Passphrase must be at least 8 characters', pwWrong: 'Incorrect passphrase',
    empty1: 'No tokens recorded yet', empty2: 'Tap + to add one', addToken: '+ Add token',
    stValid: 'Valid', stSoon: 'Soon', stExpired: 'Expired', stNoExpiry: 'No expiry',
    noExpiryDate: 'No expiry date', expiredAt: 'Expired ({date})', dday: 'Expires in {days}d ({date})',
    tokenBanner: '⚠️ Do not enter token values. This app tracks tokens and does not recommend storing their values.',
    autofilled: 'Auto-filled from the current tab (editable)',
    fieldService: 'Service name *', svcHint: 'e.g. GitHub PAT - CI deploy', fieldUrl: 'URL (optional)',
    issued: 'Issued', expires: 'Expiry', noExpiryHint: 'No expiry = never expires (security-warning target)',
    note: 'Note', noteHint: 'Rotation policy, usage, etc. (no token values)', errService: 'Please enter a service name',
    noteWarn: 'The note looks like it contains a token value. Save anyway?',
    save: 'Save', delete: 'Delete', cancel: 'Cancel', deleteConfirm: 'Delete the "{name}" record?',
    backupInfo: 'Backups are encrypted with a passphrase (Argon2id + AES-256-GCM). Compatible with the app’s .tmbk backups.',
    passLabel: 'Passphrase (8+ characters)', passShared: 'shared for export/import',
    exportSection: 'Export', exportBtn: 'Export backup file', restoreSection: 'Restore',
    merge: 'Merge', overwrite: 'Overwrite', exported: 'Backup file exported', restored: 'Restored {count} item(s)',
    authErr: 'Wrong passphrase or corrupted backup', fmtErr: 'Unsupported backup file',
    shareWarn: '⚠️ Do not send the passphrase together with the backup file.',
    noExpiryTitle: 'No-expiry warning', noExpirySub: 'Periodic security warning for tokens without an expiry date',
    intervalOff: 'Off', interval15: 'Every 15 days', interval30: 'Every 30 days',
    saved: 'Saved', settingsNote: 'Alerts run in the background and show counts only (not which service). Unlock to see details.',
    language: 'Language', languageSystem: 'System default',
  },
  ja: {
    titleList: 'トークン保管庫', titleAdd: 'トークンを追加', titleEdit: 'トークンを編集',
    titleBackup: 'バックアップ / 復元', titleSettings: '設定',
    lockUnlockPrompt: 'パスフレーズを入力してロック解除',
    lockSetPrompt: '新しいパスフレーズを設定 (8文字以上)',
    passphrase: 'パスフレーズ', unlock: 'ロック解除', start: 'はじめる',
    pwTooShort: 'パスフレーズは8文字以上にしてください', pwWrong: 'パスフレーズが正しくありません',
    empty1: 'まだトークンがありません', empty2: '＋ で追加してください', addToken: '＋ トークンを追加',
    stValid: '有効', stSoon: '間近', stExpired: '期限切れ', stNoExpiry: '無期限',
    noExpiryDate: '有効期限なし', expiredAt: '期限切れ ({date})', dday: '残り {days} 日 ({date})',
    tokenBanner: '⚠️ トークン値は入力しないでください。このアプリは追跡用で、値の保存は推奨しません。',
    autofilled: '現在のタブから自動入力（編集可）',
    fieldService: 'サービス名 *', svcHint: '例: GitHub PAT - CI デプロイ用', fieldUrl: 'URL (任意)',
    issued: '発行日', expires: '有効期限', noExpiryHint: '有効期限なし = 無期限（セキュリティ警告対象）',
    note: 'メモ', noteHint: 'ローテーション方針、用途など（トークン値は入力しない）', errService: 'サービス名を入力してください',
    noteWarn: 'メモにトークン値のような内容があります。保存しますか？',
    save: '保存', delete: '削除', cancel: 'キャンセル', deleteConfirm: '「{name}」の記録を削除しますか？',
    backupInfo: 'バックアップはパスフレーズで暗号化されます（Argon2id + AES-256-GCM）。アプリの .tmbk と互換。',
    passLabel: 'パスフレーズ (8文字以上)', passShared: 'バックアップ/復元 共通',
    exportSection: 'エクスポート', exportBtn: 'バックアップを書き出す', restoreSection: '復元',
    merge: 'マージ', overwrite: '上書き', exported: 'バックアップを書き出しました', restored: '{count} 件を復元しました',
    authErr: 'パスフレーズが違うか、バックアップが破損しています', fmtErr: 'サポートされていないバックアップファイルです',
    shareWarn: '⚠️ バックアップ共有時にパスフレーズを一緒に送らないでください。',
    noExpiryTitle: '無期限トークン警告', noExpirySub: '有効期限のないトークンへの定期的なセキュリティ警告の間隔',
    intervalOff: 'オフ', interval15: '15日ごと', interval30: '30日ごと',
    saved: '保存しました', settingsNote: '通知はバックグラウンドで動作し、件数のみ表示します（サービスは非表示）。詳細はロック解除後に確認。',
    language: '言語', languageSystem: 'システムの既定',
  },
  zh: {
    titleList: '令牌保管库', titleAdd: '添加令牌', titleEdit: '编辑令牌',
    titleBackup: '备份 / 恢复', titleSettings: '设置',
    lockUnlockPrompt: '输入口令以解锁', lockSetPrompt: '设置新口令（至少 8 位）',
    passphrase: '口令', unlock: '解锁', start: '开始',
    pwTooShort: '口令至少需要 8 位', pwWrong: '口令不正确',
    empty1: '尚未记录任何令牌', empty2: '点击 + 添加', addToken: '+ 添加令牌',
    stValid: '有效', stSoon: '临近', stExpired: '已过期', stNoExpiry: '无期限',
    noExpiryDate: '无过期日期', expiredAt: '已过期 ({date})', dday: '{days} 天后过期 ({date})',
    tokenBanner: '⚠️ 请勿输入令牌值。本应用用于追踪令牌，不建议存储其值。',
    autofilled: '已从当前标签页自动填充（可编辑）',
    fieldService: '服务名称 *', svcHint: '例如：GitHub PAT - CI 部署', fieldUrl: 'URL（可选）',
    issued: '签发日期', expires: '过期日期', noExpiryHint: '无过期日期 = 永不过期（安全警告对象）',
    note: '备注', noteHint: '轮换策略、用途等（请勿输入令牌值）', errService: '请输入服务名称',
    noteWarn: '备注中似乎包含令牌值。仍要保存吗？',
    save: '保存', delete: '删除', cancel: '取消', deleteConfirm: '删除“{name}”记录吗？',
    backupInfo: '备份使用口令加密（Argon2id + AES-256-GCM）。与应用的 .tmbk 兼容。',
    passLabel: '口令（至少 8 位）', passShared: '备份/恢复通用',
    exportSection: '导出', exportBtn: '导出备份文件', restoreSection: '恢复',
    merge: '合并', overwrite: '覆盖', exported: '已导出备份文件', restored: '已恢复 {count} 条',
    authErr: '口令不正确或备份已损坏', fmtErr: '不支持的备份文件',
    shareWarn: '⚠️ 分享备份文件时请勿同时发送口令。',
    noExpiryTitle: '无期限令牌警告', noExpirySub: '对没有过期日期的令牌进行定期安全警告的周期',
    intervalOff: '关闭', interval15: '每 15 天', interval30: '每 30 天',
    saved: '已保存', settingsNote: '提醒在后台运行，仅显示数量（不显示具体服务）。详情请解锁查看。',
    language: '语言', languageSystem: '系统默认',
  },
  zh_Hant: {
    titleList: '權杖保管庫', titleAdd: '新增權杖', titleEdit: '編輯權杖',
    titleBackup: '備份 / 還原', titleSettings: '設定',
    lockUnlockPrompt: '輸入通關密語以解鎖', lockSetPrompt: '設定新通關密語（至少 8 個字元）',
    passphrase: '通關密語', unlock: '解鎖', start: '開始',
    pwTooShort: '通關密語至少需要 8 個字元', pwWrong: '通關密語不正確',
    empty1: '尚未記錄任何權杖', empty2: '點選 + 新增', addToken: '+ 新增權杖',
    stValid: '有效', stSoon: '接近', stExpired: '已過期', stNoExpiry: '無期限',
    noExpiryDate: '無到期日', expiredAt: '已過期 ({date})', dday: '{days} 天後到期 ({date})',
    tokenBanner: '⚠️ 請勿輸入權杖值。本應用程式用於追蹤權杖，不建議儲存其值。',
    autofilled: '已從目前分頁自動填入（可編輯）',
    fieldService: '服務名稱 *', svcHint: '例如：GitHub PAT - CI 部署', fieldUrl: 'URL（選填）',
    issued: '簽發日期', expires: '到期日', noExpiryHint: '無到期日 = 永不過期（安全警告對象）',
    note: '備註', noteHint: '輪替政策、用途等（請勿輸入權杖值）', errService: '請輸入服務名稱',
    noteWarn: '備註中似乎包含權杖值。仍要儲存嗎？',
    save: '儲存', delete: '刪除', cancel: '取消', deleteConfirm: '刪除「{name}」紀錄嗎？',
    backupInfo: '備份使用通關密語加密（Argon2id + AES-256-GCM）。與應用程式的 .tmbk 相容。',
    passLabel: '通關密語（至少 8 個字元）', passShared: '備份/還原通用',
    exportSection: '匯出', exportBtn: '匯出備份檔', restoreSection: '還原',
    merge: '合併', overwrite: '覆寫', exported: '已匯出備份檔', restored: '已還原 {count} 筆',
    authErr: '通關密語不正確或備份已損毀', fmtErr: '不支援的備份檔案',
    shareWarn: '⚠️ 分享備份檔時請勿一併傳送通關密語。',
    noExpiryTitle: '無期限權杖警告', noExpirySub: '對沒有到期日的權杖進行定期安全警告的週期',
    intervalOff: '關閉', interval15: '每 15 天', interval30: '每 30 天',
    saved: '已儲存', settingsNote: '提醒於背景執行，僅顯示數量（不顯示服務）。詳情請解鎖查看。',
    language: '語言', languageSystem: '系統預設',
  },
  es: {
    titleList: 'Bóveda de tokens', titleAdd: 'Añadir token', titleEdit: 'Editar token',
    titleBackup: 'Copia / Restaurar', titleSettings: 'Ajustes',
    lockUnlockPrompt: 'Introduce tu frase de contraseña para desbloquear',
    lockSetPrompt: 'Define una frase de contraseña (mín. 8 caracteres)',
    passphrase: 'Frase de contraseña', unlock: 'Desbloquear', start: 'Empezar',
    pwTooShort: 'La frase debe tener al menos 8 caracteres', pwWrong: 'Frase de contraseña incorrecta',
    empty1: 'Aún no hay tokens', empty2: 'Toca + para añadir', addToken: '+ Añadir token',
    stValid: 'Válido', stSoon: 'Pronto', stExpired: 'Caducado', stNoExpiry: 'Sin caducidad',
    noExpiryDate: 'Sin fecha de caducidad', expiredAt: 'Caducado ({date})', dday: 'Caduca en {days} d ({date})',
    tokenBanner: '⚠️ No introduzcas valores de token. Esta app rastrea tokens y no recomienda almacenar sus valores.',
    autofilled: 'Rellenado desde la pestaña actual (editable)',
    fieldService: 'Nombre del servicio *', svcHint: 'p. ej. GitHub PAT - despliegue CI', fieldUrl: 'URL (opcional)',
    issued: 'Emisión', expires: 'Caducidad', noExpiryHint: 'Sin caducidad = nunca caduca (objeto de aviso)',
    note: 'Nota', noteHint: 'Política de rotación, uso, etc. (sin valores de token)', errService: 'Introduce un nombre de servicio',
    noteWarn: 'La nota parece contener un valor de token. ¿Guardar igualmente?',
    save: 'Guardar', delete: 'Eliminar', cancel: 'Cancelar', deleteConfirm: '¿Eliminar el registro "{name}"?',
    backupInfo: 'Las copias se cifran con una frase (Argon2id + AES-256-GCM). Compatible con los .tmbk de la app.',
    passLabel: 'Frase (mín. 8 caracteres)', passShared: 'común para exportar/importar',
    exportSection: 'Exportar', exportBtn: 'Exportar copia', restoreSection: 'Restaurar',
    merge: 'Combinar', overwrite: 'Sobrescribir', exported: 'Copia exportada', restored: '{count} elemento(s) restaurado(s)',
    authErr: 'Frase incorrecta o copia dañada', fmtErr: 'Archivo de copia no compatible',
    shareWarn: '⚠️ No envíes la frase junto con el archivo de copia.',
    noExpiryTitle: 'Aviso sin caducidad', noExpirySub: 'Intervalo de aviso de seguridad para tokens sin fecha de caducidad',
    intervalOff: 'Desactivado', interval15: 'Cada 15 días', interval30: 'Cada 30 días',
    saved: 'Guardado', settingsNote: 'Los avisos se ejecutan en segundo plano y muestran solo recuentos. Desbloquea para ver detalles.',
    language: 'Idioma', languageSystem: 'Predeterminado del sistema',
  },
  fr: {
    titleList: 'Coffre de jetons', titleAdd: 'Ajouter un jeton', titleEdit: 'Modifier le jeton',
    titleBackup: 'Sauvegarde / Restauration', titleSettings: 'Paramètres',
    lockUnlockPrompt: 'Saisissez votre phrase secrète pour déverrouiller',
    lockSetPrompt: 'Définissez une phrase secrète (8 caractères min.)',
    passphrase: 'Phrase secrète', unlock: 'Déverrouiller', start: 'Commencer',
    pwTooShort: 'La phrase doit faire au moins 8 caractères', pwWrong: 'Phrase secrète incorrecte',
    empty1: 'Aucun jeton enregistré', empty2: 'Touchez + pour ajouter', addToken: '+ Ajouter un jeton',
    stValid: 'Valide', stSoon: 'Bientôt', stExpired: 'Expiré', stNoExpiry: 'Sans expiration',
    noExpiryDate: "Pas de date d'expiration", expiredAt: 'Expiré ({date})', dday: 'Expire dans {days} j ({date})',
    tokenBanner: '⚠️ Ne saisissez pas de valeurs de jeton. Cette app suit les jetons et déconseille de stocker leurs valeurs.',
    autofilled: "Rempli depuis l'onglet actuel (modifiable)",
    fieldService: 'Nom du service *', svcHint: 'ex. GitHub PAT - déploiement CI', fieldUrl: 'URL (facultatif)',
    issued: 'Émission', expires: 'Expiration', noExpiryHint: "Sans expiration = n'expire jamais (objet d'alerte)",
    note: 'Note', noteHint: 'Politique de rotation, usage, etc. (pas de valeurs de jeton)', errService: 'Veuillez saisir un nom de service',
    noteWarn: 'La note semble contenir une valeur de jeton. Enregistrer quand même ?',
    save: 'Enregistrer', delete: 'Supprimer', cancel: 'Annuler', deleteConfirm: "Supprimer l'enregistrement « {name} » ?",
    backupInfo: 'Les sauvegardes sont chiffrées par une phrase secrète (Argon2id + AES-256-GCM). Compatible .tmbk de l’app.',
    passLabel: 'Phrase secrète (8 caractères min.)', passShared: 'commune export/import',
    exportSection: 'Exporter', exportBtn: 'Exporter la sauvegarde', restoreSection: 'Restaurer',
    merge: 'Fusionner', overwrite: 'Écraser', exported: 'Sauvegarde exportée', restored: '{count} élément(s) restauré(s)',
    authErr: 'Phrase incorrecte ou sauvegarde corrompue', fmtErr: 'Fichier de sauvegarde non pris en charge',
    shareWarn: '⚠️ N’envoyez pas la phrase secrète avec le fichier de sauvegarde.',
    noExpiryTitle: 'Alerte sans expiration', noExpirySub: "Intervalle d'alerte de sécurité pour les jetons sans date d'expiration",
    intervalOff: 'Désactivé', interval15: 'Tous les 15 jours', interval30: 'Tous les 30 jours',
    saved: 'Enregistré', settingsNote: 'Les alertes s’exécutent en arrière-plan et n’affichent que des nombres. Déverrouillez pour les détails.',
    language: 'Langue', languageSystem: 'Par défaut du système',
  },
};

let locale = $state<Locale>('en');

function detect(): Locale {
  const ui = (typeof chrome !== 'undefined' && chrome.i18n?.getUILanguage?.()) || navigator.language || 'en';
  const lc = ui.toLowerCase();
  if (lc.startsWith('zh')) return /hant|tw|hk|mo/.test(lc) ? 'zh_Hant' : 'zh';
  const base = lc.split('-')[0];
  return (SUPPORTED as string[]).includes(base) ? (base as Locale) : 'en';
}

export async function initLocale(): Promise<void> {
  try {
    const r = await chrome.storage.local.get(KEY);
    const saved = r[KEY] as LocaleSel | undefined;
    if (saved && saved !== 'system' && SUPPORTED.includes(saved)) locale = saved;
    else locale = detect();
  } catch {
    locale = detect();
  }
}

export async function setLocale(sel: LocaleSel): Promise<void> {
  await chrome.storage.local.set({ [KEY]: sel });
  locale = sel === 'system' ? detect() : sel;
}

export async function currentSelection(): Promise<LocaleSel> {
  const r = await chrome.storage.local.get(KEY);
  return (r[KEY] as LocaleSel | undefined) ?? 'system';
}

export function t(key: string, vars?: Record<string, string | number>): string {
  let s = M[locale][key] ?? M.en[key] ?? key;
  if (vars) for (const k of Object.keys(vars)) s = s.replace(`{${k}}`, String(vars[k]));
  return s;
}
