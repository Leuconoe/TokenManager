// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Chinese (`zh`).
class AppLocalizationsZh extends AppLocalizations {
  AppLocalizationsZh([String locale = 'zh']) : super(locale);

  @override
  String get appTitle => 'TokenManager';

  @override
  String get lockAuthRequired => '需要身份验证';

  @override
  String get lockAuthFailed => '身份验证失败';

  @override
  String get lockUnlock => '解锁';

  @override
  String get lockReason => '打开令牌保管库需要身份验证';

  @override
  String get listTitle => '令牌保管库';

  @override
  String get sortExpiry => '即将过期优先';

  @override
  String get sortName => '按服务名称';

  @override
  String get sortUpdated => '最近更新';

  @override
  String get tooltipBackup => '备份 / 恢复';

  @override
  String get filterAll => '全部';

  @override
  String get statusValid => '有效';

  @override
  String get statusSoon => '临近';

  @override
  String get statusExpired => '已过期';

  @override
  String get statusNoExpiry => '无期限';

  @override
  String get emptyTitle => '尚未记录任何令牌';

  @override
  String get emptyHint => '点击 + 添加令牌签发记录';

  @override
  String get subtitleNoExpiry => '无过期日期';

  @override
  String subtitleExpired(String date) {
    return '已过期 ($date)';
  }

  @override
  String subtitleDday(int days, String date) {
    return '$days 天后过期 ($date)';
  }

  @override
  String get editTitleNew => '添加令牌';

  @override
  String get editTitleEdit => '编辑令牌';

  @override
  String get fieldService => '服务名称 *';

  @override
  String get fieldServiceHint => '例如：GitHub PAT - CI 部署';

  @override
  String get fieldUrl => 'URL（可选）';

  @override
  String get fieldUrlHint => '例如：https://github.com/settings/tokens';

  @override
  String get validationServiceRequired => '请输入服务名称';

  @override
  String get fieldIssued => '签发日期（可选）';

  @override
  String get fieldExpiry => '过期日期（可选，留空表示无期限）';

  @override
  String get hintNoExpiry => '无过期日期 = 永不过期（安全警告对象）';

  @override
  String get fieldNote => '备注';

  @override
  String get fieldNoteHint => '轮换策略、用途等（请勿输入令牌值）';

  @override
  String get securityBanner => '请勿输入令牌值。本应用用于追踪令牌，不建议存储其值。';

  @override
  String get noteWarnTitle => '疑似令牌值';

  @override
  String get noteWarnBody => '备注中似乎包含令牌/密钥值。本应用建议不要存储令牌值。仍要保存吗？';

  @override
  String get actionCancel => '取消';

  @override
  String get actionSaveAnyway => '仍然保存';

  @override
  String get actionSave => '保存';

  @override
  String get actionDelete => '删除';

  @override
  String deleteBody(String name) {
    return '删除“$name”记录吗？';
  }

  @override
  String get dateUnset => '未设置';

  @override
  String get dateSelect => '选择';

  @override
  String get backupTitle => '备份 / 恢复';

  @override
  String get backupInfo => '备份使用口令加密（Argon2id + AES-256-GCM）。若忘记口令，将无法恢复。';

  @override
  String get passphraseLabel => '口令（至少 8 位）';

  @override
  String get passphraseTooShort => '口令至少需要 8 位';

  @override
  String get exportSection => '导出';

  @override
  String get exportSave => '保存到设备';

  @override
  String get exportShare => '分享';

  @override
  String get shareWarn => '⚠️ 请勿将口令与文件一起发送。';

  @override
  String get shareOpened => '已打开分享面板';

  @override
  String get exportSaved => '已保存备份';

  @override
  String exportFailed(String error) {
    return '备份失败：$error';
  }

  @override
  String get restoreSection => '恢复';

  @override
  String get modeMerge => '合并（保留现有 + 添加/更新）';

  @override
  String get modeOverwrite => '覆盖（替换全部）';

  @override
  String get restoreButton => '选择文件并恢复';

  @override
  String restoreDone(int count) {
    return '已恢复 $count 条';
  }

  @override
  String get settingsTitle => '设置';

  @override
  String get noExpiryWarnTitle => '无期限令牌警告周期';

  @override
  String get noExpiryWarnSubtitle => '对没有过期日期的令牌进行定期安全警告';

  @override
  String get intervalOff => '关闭';

  @override
  String get interval15Days => '每 15 天';

  @override
  String get interval30Days => '每 30 天（默认）';

  @override
  String get expiryLeadTitle => '过期警告提前量';

  @override
  String get expiryLeadSubtitle => '对有过期日期的令牌，提前几天开始警告';

  @override
  String get lead7Days => '过期前 7 天';

  @override
  String get lead14Days => '过期前 14 天（默认）';

  @override
  String get lead30Days => '过期前 30 天';

  @override
  String get securitySectionTitle => '安全';

  @override
  String get securityInfo =>
      '数据使用设备 Keystore 密钥加密。代码中不含密钥，因此无法通过反编译或复制到其他设备来恢复。在已 root 的设备上仅显示警告，不会阻止访问。';

  @override
  String notifExpiredTitle(int count) {
    return '$count 个已过期令牌';
  }

  @override
  String notifExpiredBody(String names) {
    return '请立即吊销或轮换：$names';
  }

  @override
  String notifSoonTitle(int count) {
    return '$count 个令牌即将过期';
  }

  @override
  String notifSoonBody(String names) {
    return '即将过期：$names';
  }

  @override
  String notifNoExpiryTitle(int count) {
    return '$count 个无期限令牌';
  }

  @override
  String notifNoExpiryBody(String names) {
    return '建议检查轮换策略：$names';
  }

  @override
  String notifMore(String names, int count) {
    return '$names 等 $count 个';
  }

  @override
  String get restoreAuthError => '口令不正确或备份已损坏';

  @override
  String get restoreFormatError => '不支持的备份文件';

  @override
  String get settingsLanguage => '语言';

  @override
  String get languageSystemDefault => '系统默认';

  @override
  String get settingsAutoStart => '登录时自动启动';

  @override
  String get settingsAutoStartSubtitle => 'Windows 登录时自动启动到系统托盘';
}

/// The translations for Chinese, using the Han script (`zh_Hant`).
class AppLocalizationsZhHant extends AppLocalizationsZh {
  AppLocalizationsZhHant() : super('zh_Hant');

  @override
  String get appTitle => 'TokenManager';

  @override
  String get lockAuthRequired => '需要身分驗證';

  @override
  String get lockAuthFailed => '身分驗證失敗';

  @override
  String get lockUnlock => '解鎖';

  @override
  String get lockReason => '開啟權杖保管庫需要身分驗證';

  @override
  String get listTitle => '權杖保管庫';

  @override
  String get sortExpiry => '即將到期優先';

  @override
  String get sortName => '依服務名稱';

  @override
  String get sortUpdated => '最近更新';

  @override
  String get tooltipBackup => '備份 / 還原';

  @override
  String get filterAll => '全部';

  @override
  String get statusValid => '有效';

  @override
  String get statusSoon => '接近';

  @override
  String get statusExpired => '已過期';

  @override
  String get statusNoExpiry => '無期限';

  @override
  String get emptyTitle => '尚未記錄任何權杖';

  @override
  String get emptyHint => '點選 + 新增權杖簽發紀錄';

  @override
  String get subtitleNoExpiry => '無到期日';

  @override
  String subtitleExpired(String date) {
    return '已過期 ($date)';
  }

  @override
  String subtitleDday(int days, String date) {
    return '$days 天後到期 ($date)';
  }

  @override
  String get editTitleNew => '新增權杖';

  @override
  String get editTitleEdit => '編輯權杖';

  @override
  String get fieldService => '服務名稱 *';

  @override
  String get fieldServiceHint => '例如：GitHub PAT - CI 部署';

  @override
  String get fieldUrl => 'URL（選填）';

  @override
  String get fieldUrlHint => '例如：https://github.com/settings/tokens';

  @override
  String get validationServiceRequired => '請輸入服務名稱';

  @override
  String get fieldIssued => '簽發日期（選填）';

  @override
  String get fieldExpiry => '到期日（選填，留空表示無期限）';

  @override
  String get hintNoExpiry => '無到期日 = 永不過期（安全警告對象）';

  @override
  String get fieldNote => '備註';

  @override
  String get fieldNoteHint => '輪替政策、用途等（請勿輸入權杖值）';

  @override
  String get securityBanner => '請勿輸入權杖值。本應用程式用於追蹤權杖，不建議儲存其值。';

  @override
  String get noteWarnTitle => '疑似權杖值';

  @override
  String get noteWarnBody => '備註中似乎包含權杖/密鑰值。本應用程式建議不要儲存權杖值。仍要儲存嗎？';

  @override
  String get actionCancel => '取消';

  @override
  String get actionSaveAnyway => '仍然儲存';

  @override
  String get actionSave => '儲存';

  @override
  String get actionDelete => '刪除';

  @override
  String deleteBody(String name) {
    return '刪除「$name」紀錄嗎？';
  }

  @override
  String get dateUnset => '未設定';

  @override
  String get dateSelect => '選擇';

  @override
  String get backupTitle => '備份 / 還原';

  @override
  String get backupInfo => '備份使用通關密語加密（Argon2id + AES-256-GCM）。若忘記通關密語，將無法還原。';

  @override
  String get passphraseLabel => '通關密語（至少 8 個字元）';

  @override
  String get passphraseTooShort => '通關密語至少需要 8 個字元';

  @override
  String get exportSection => '匯出';

  @override
  String get exportSave => '儲存到裝置';

  @override
  String get exportShare => '分享';

  @override
  String get shareWarn => '⚠️ 請勿將通關密語與檔案一起傳送。';

  @override
  String get shareOpened => '已開啟分享面板';

  @override
  String get exportSaved => '已儲存備份';

  @override
  String exportFailed(String error) {
    return '備份失敗：$error';
  }

  @override
  String get restoreSection => '還原';

  @override
  String get modeMerge => '合併（保留現有 + 新增/更新）';

  @override
  String get modeOverwrite => '覆寫（全部取代）';

  @override
  String get restoreButton => '選擇檔案並還原';

  @override
  String restoreDone(int count) {
    return '已還原 $count 筆';
  }

  @override
  String get settingsTitle => '設定';

  @override
  String get noExpiryWarnTitle => '無期限權杖警告週期';

  @override
  String get noExpiryWarnSubtitle => '對沒有到期日的權杖進行定期安全警告';

  @override
  String get intervalOff => '關閉';

  @override
  String get interval15Days => '每 15 天';

  @override
  String get interval30Days => '每 30 天（預設）';

  @override
  String get expiryLeadTitle => '到期警告提前量';

  @override
  String get expiryLeadSubtitle => '對有到期日的權杖，提前幾天開始警告';

  @override
  String get lead7Days => '到期前 7 天';

  @override
  String get lead14Days => '到期前 14 天（預設）';

  @override
  String get lead30Days => '到期前 30 天';

  @override
  String get securitySectionTitle => '安全';

  @override
  String get securityInfo =>
      '資料使用裝置 Keystore 金鑰加密。程式碼中不含金鑰，因此無法透過反編譯或複製到其他裝置還原。在已 root 的裝置上僅顯示警告，不會封鎖存取。';

  @override
  String notifExpiredTitle(int count) {
    return '$count 個已過期權杖';
  }

  @override
  String notifExpiredBody(String names) {
    return '請立即撤銷或輪替：$names';
  }

  @override
  String notifSoonTitle(int count) {
    return '$count 個權杖即將到期';
  }

  @override
  String notifSoonBody(String names) {
    return '即將到期：$names';
  }

  @override
  String notifNoExpiryTitle(int count) {
    return '$count 個無期限權杖';
  }

  @override
  String notifNoExpiryBody(String names) {
    return '建議檢查輪替政策：$names';
  }

  @override
  String notifMore(String names, int count) {
    return '$names 等 $count 個';
  }

  @override
  String get restoreAuthError => '通關密語不正確或備份已損毀';

  @override
  String get restoreFormatError => '不支援的備份檔案';

  @override
  String get settingsLanguage => '語言';

  @override
  String get languageSystemDefault => '系統預設';

  @override
  String get settingsAutoStart => '登入時自動啟動';

  @override
  String get settingsAutoStartSubtitle => 'Windows 登入時自動啟動至系統匣';
}
