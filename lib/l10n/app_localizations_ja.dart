// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Japanese (`ja`).
class AppLocalizationsJa extends AppLocalizations {
  AppLocalizationsJa([String locale = 'ja']) : super(locale);

  @override
  String get appTitle => 'TokenManager';

  @override
  String get lockAuthRequired => '認証が必要です';

  @override
  String get lockAuthFailed => '認証に失敗しました';

  @override
  String get lockUnlock => 'ロック解除';

  @override
  String get lockReason => 'トークン保管庫を開くには認証が必要です';

  @override
  String get listTitle => 'トークン保管庫';

  @override
  String get sortExpiry => '有効期限が近い順';

  @override
  String get sortName => 'サービス名順';

  @override
  String get sortUpdated => '最近更新順';

  @override
  String get tooltipBackup => 'バックアップ / 復元';

  @override
  String get filterAll => 'すべて';

  @override
  String get statusValid => '有効';

  @override
  String get statusSoon => '間近';

  @override
  String get statusExpired => '期限切れ';

  @override
  String get statusNoExpiry => '無期限';

  @override
  String get emptyTitle => 'まだ記録されたトークンはありません';

  @override
  String get emptyHint => '＋ ボタンでトークンの発行記録を追加してください';

  @override
  String get subtitleNoExpiry => '有効期限なし';

  @override
  String subtitleExpired(String date) {
    return '期限切れ ($date)';
  }

  @override
  String subtitleDday(int days, String date) {
    return '残り $days 日 ($date)';
  }

  @override
  String get editTitleNew => 'トークンを追加';

  @override
  String get editTitleEdit => 'トークンを編集';

  @override
  String get fieldService => 'サービス名 *';

  @override
  String get fieldServiceHint => '例: GitHub PAT - CI デプロイ用';

  @override
  String get fieldUrl => 'URL (任意)';

  @override
  String get fieldUrlHint => '例: https://github.com/settings/tokens';

  @override
  String get validationServiceRequired => 'サービス名を入力してください';

  @override
  String get fieldIssued => '発行日 (任意)';

  @override
  String get fieldExpiry => '有効期限 (任意、未設定なら無期限)';

  @override
  String get hintNoExpiry => '有効期限なし = 無期限（セキュリティ警告の対象）';

  @override
  String get fieldNote => 'メモ';

  @override
  String get fieldNoteHint => 'ローテーション方針、用途など（トークン値は入力しない）';

  @override
  String get securityBanner => 'トークン値は入力しないでください。このアプリはトークンの追跡用で、値の保存は推奨しません。';

  @override
  String get noteWarnTitle => 'トークン値のような内容';

  @override
  String get noteWarnBody =>
      'メモにトークン／シークレット値のような内容があります。このアプリはトークン値を保存しないことを推奨します。このまま保存しますか？';

  @override
  String get actionCancel => 'キャンセル';

  @override
  String get actionSaveAnyway => '保存する';

  @override
  String get actionSave => '保存';

  @override
  String get actionDelete => '削除';

  @override
  String deleteBody(String name) {
    return '「$name」の記録を削除しますか？';
  }

  @override
  String get dateUnset => '未設定';

  @override
  String get dateSelect => '選択';

  @override
  String get backupTitle => 'バックアップ / 復元';

  @override
  String get backupInfo =>
      'バックアップはパスフレーズで暗号化されます（Argon2id + AES-256-GCM）。パスフレーズを忘れると復元できません。';

  @override
  String get passphraseLabel => 'パスフレーズ (8文字以上)';

  @override
  String get passphraseTooShort => 'パスフレーズは8文字以上にしてください';

  @override
  String get exportSection => 'エクスポート';

  @override
  String get exportSave => '端末に保存';

  @override
  String get exportShare => '共有';

  @override
  String get shareWarn => '⚠️ パスフレーズを一緒に送らないでください。';

  @override
  String get shareOpened => '共有シートを開きました';

  @override
  String get exportSaved => 'バックアップを保存しました';

  @override
  String exportFailed(String error) {
    return 'バックアップ失敗: $error';
  }

  @override
  String get restoreSection => '復元';

  @override
  String get modeMerge => 'マージ（既存を保持 + 追加／更新）';

  @override
  String get modeOverwrite => '上書き（すべて置き換え）';

  @override
  String get restoreButton => 'ファイルを選んで復元';

  @override
  String restoreDone(int count) {
    return '$count 件を復元しました';
  }

  @override
  String get settingsTitle => '設定';

  @override
  String get noExpiryWarnTitle => '無期限トークンの警告間隔';

  @override
  String get noExpiryWarnSubtitle => '有効期限のないトークンへの定期的なセキュリティ警告';

  @override
  String get intervalOff => 'オフ';

  @override
  String get intervalWeekly => '週1回 (既定)';

  @override
  String get intervalBiweekly => '2週間に1回';

  @override
  String get intervalMonthly => '月1回';

  @override
  String get securitySectionTitle => 'セキュリティ';

  @override
  String get securityInfo =>
      'データは端末の Keystore 鍵で暗号化されます。コードに鍵がないため、逆コンパイルや他端末へのコピーでは復元できません。root 化端末では警告のみ表示し、ブロックはしません。';

  @override
  String notifExpiredTitle(int count) {
    return '期限切れトークン $count 件';
  }

  @override
  String notifExpiredBody(String names) {
    return '今すぐ失効またはローテーションしてください: $names';
  }

  @override
  String notifSoonTitle(int count) {
    return 'まもなく期限切れ $count 件';
  }

  @override
  String notifSoonBody(String names) {
    return 'まもなく期限切れ: $names';
  }

  @override
  String notifNoExpiryTitle(int count) {
    return '無期限トークン $count 件';
  }

  @override
  String notifNoExpiryBody(String names) {
    return 'ローテーション方針の確認を推奨します: $names';
  }

  @override
  String notifMore(String names, int count) {
    return '$names ほか $count 件';
  }

  @override
  String get restoreAuthError => 'パスフレーズが正しくないか、バックアップが破損しています';

  @override
  String get restoreFormatError => 'サポートされていないバックアップファイルです';

  @override
  String get settingsLanguage => '言語';

  @override
  String get languageSystemDefault => 'システムの既定';

  @override
  String get settingsAutoStart => 'ログイン時に自動起動';

  @override
  String get settingsAutoStartSubtitle => 'Windows サインイン時にトレイへ自動起動';
}
