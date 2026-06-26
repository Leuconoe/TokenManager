import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_es.dart';
import 'app_localizations_fr.dart';
import 'app_localizations_ja.dart';
import 'app_localizations_ko.dart';
import 'app_localizations_zh.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
      : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('es'),
    Locale('fr'),
    Locale('ja'),
    Locale('ko'),
    Locale('zh'),
    Locale.fromSubtags(languageCode: 'zh', scriptCode: 'Hant')
  ];

  /// No description provided for @appTitle.
  ///
  /// In ko, this message translates to:
  /// **'TokenManager'**
  String get appTitle;

  /// No description provided for @lockAuthRequired.
  ///
  /// In ko, this message translates to:
  /// **'인증이 필요합니다'**
  String get lockAuthRequired;

  /// No description provided for @lockAuthFailed.
  ///
  /// In ko, this message translates to:
  /// **'인증에 실패했습니다'**
  String get lockAuthFailed;

  /// No description provided for @lockUnlock.
  ///
  /// In ko, this message translates to:
  /// **'잠금 해제'**
  String get lockUnlock;

  /// No description provided for @lockReason.
  ///
  /// In ko, this message translates to:
  /// **'토큰 보관함을 열려면 인증이 필요합니다'**
  String get lockReason;

  /// No description provided for @listTitle.
  ///
  /// In ko, this message translates to:
  /// **'토큰 보관함'**
  String get listTitle;

  /// No description provided for @sortExpiry.
  ///
  /// In ko, this message translates to:
  /// **'만료 임박순'**
  String get sortExpiry;

  /// No description provided for @sortName.
  ///
  /// In ko, this message translates to:
  /// **'서비스명순'**
  String get sortName;

  /// No description provided for @sortUpdated.
  ///
  /// In ko, this message translates to:
  /// **'최근 수정순'**
  String get sortUpdated;

  /// No description provided for @tooltipBackup.
  ///
  /// In ko, this message translates to:
  /// **'백업/복원'**
  String get tooltipBackup;

  /// No description provided for @filterAll.
  ///
  /// In ko, this message translates to:
  /// **'전체'**
  String get filterAll;

  /// No description provided for @statusValid.
  ///
  /// In ko, this message translates to:
  /// **'유효'**
  String get statusValid;

  /// No description provided for @statusSoon.
  ///
  /// In ko, this message translates to:
  /// **'임박'**
  String get statusSoon;

  /// No description provided for @statusExpired.
  ///
  /// In ko, this message translates to:
  /// **'만료'**
  String get statusExpired;

  /// No description provided for @statusNoExpiry.
  ///
  /// In ko, this message translates to:
  /// **'무기한'**
  String get statusNoExpiry;

  /// No description provided for @emptyTitle.
  ///
  /// In ko, this message translates to:
  /// **'아직 기록된 토큰이 없습니다'**
  String get emptyTitle;

  /// No description provided for @emptyHint.
  ///
  /// In ko, this message translates to:
  /// **'+ 버튼으로 토큰 발급 내역을 추가하세요'**
  String get emptyHint;

  /// No description provided for @subtitleNoExpiry.
  ///
  /// In ko, this message translates to:
  /// **'만료일 없음'**
  String get subtitleNoExpiry;

  /// No description provided for @subtitleExpired.
  ///
  /// In ko, this message translates to:
  /// **'만료됨 ({date})'**
  String subtitleExpired(String date);

  /// No description provided for @subtitleDday.
  ///
  /// In ko, this message translates to:
  /// **'만료 D-{days} ({date})'**
  String subtitleDday(int days, String date);

  /// No description provided for @editTitleNew.
  ///
  /// In ko, this message translates to:
  /// **'토큰 추가'**
  String get editTitleNew;

  /// No description provided for @editTitleEdit.
  ///
  /// In ko, this message translates to:
  /// **'토큰 수정'**
  String get editTitleEdit;

  /// No description provided for @fieldService.
  ///
  /// In ko, this message translates to:
  /// **'서비스 명 *'**
  String get fieldService;

  /// No description provided for @fieldServiceHint.
  ///
  /// In ko, this message translates to:
  /// **'예: GitHub PAT - CI 배포용'**
  String get fieldServiceHint;

  /// No description provided for @fieldUrl.
  ///
  /// In ko, this message translates to:
  /// **'URL (선택)'**
  String get fieldUrl;

  /// No description provided for @fieldUrlHint.
  ///
  /// In ko, this message translates to:
  /// **'예: https://github.com/settings/tokens'**
  String get fieldUrlHint;

  /// No description provided for @validationServiceRequired.
  ///
  /// In ko, this message translates to:
  /// **'서비스 명을 입력하세요'**
  String get validationServiceRequired;

  /// No description provided for @fieldIssued.
  ///
  /// In ko, this message translates to:
  /// **'발급일 (선택)'**
  String get fieldIssued;

  /// No description provided for @fieldExpiry.
  ///
  /// In ko, this message translates to:
  /// **'만료일 (선택, 없으면 무기한)'**
  String get fieldExpiry;

  /// No description provided for @hintNoExpiry.
  ///
  /// In ko, this message translates to:
  /// **'만료일 미설정 = 무기한(보안 경고 대상)'**
  String get hintNoExpiry;

  /// No description provided for @fieldNote.
  ///
  /// In ko, this message translates to:
  /// **'노트'**
  String get fieldNote;

  /// No description provided for @fieldNoteHint.
  ///
  /// In ko, this message translates to:
  /// **'회전 정책, 용도 등 (토큰 값 입력 금지)'**
  String get fieldNoteHint;

  /// No description provided for @securityBanner.
  ///
  /// In ko, this message translates to:
  /// **'토큰 값은 입력하지 마세요. 이 앱은 토큰 추적용이며 값 저장을 권장하지 않습니다.'**
  String get securityBanner;

  /// No description provided for @noteWarnTitle.
  ///
  /// In ko, this message translates to:
  /// **'토큰 값으로 보이는 내용'**
  String get noteWarnTitle;

  /// No description provided for @noteWarnBody.
  ///
  /// In ko, this message translates to:
  /// **'노트에 토큰/시크릿 값으로 보이는 내용이 있습니다. 이 앱은 토큰 값을 저장하지 않는 것을 권장합니다. 계속 저장할까요?'**
  String get noteWarnBody;

  /// No description provided for @actionCancel.
  ///
  /// In ko, this message translates to:
  /// **'취소'**
  String get actionCancel;

  /// No description provided for @actionSaveAnyway.
  ///
  /// In ko, this message translates to:
  /// **'계속 저장'**
  String get actionSaveAnyway;

  /// No description provided for @actionSave.
  ///
  /// In ko, this message translates to:
  /// **'저장'**
  String get actionSave;

  /// No description provided for @actionDelete.
  ///
  /// In ko, this message translates to:
  /// **'삭제'**
  String get actionDelete;

  /// No description provided for @deleteBody.
  ///
  /// In ko, this message translates to:
  /// **'\"{name}\" 기록을 삭제할까요?'**
  String deleteBody(String name);

  /// No description provided for @dateUnset.
  ///
  /// In ko, this message translates to:
  /// **'미설정'**
  String get dateUnset;

  /// No description provided for @dateSelect.
  ///
  /// In ko, this message translates to:
  /// **'선택'**
  String get dateSelect;

  /// No description provided for @backupTitle.
  ///
  /// In ko, this message translates to:
  /// **'백업 / 복원'**
  String get backupTitle;

  /// No description provided for @backupInfo.
  ///
  /// In ko, this message translates to:
  /// **'백업은 패스프레이즈로 암호화됩니다(Argon2id + AES-256-GCM). 패스프레이즈를 잊으면 복원할 수 없습니다.'**
  String get backupInfo;

  /// No description provided for @passphraseLabel.
  ///
  /// In ko, this message translates to:
  /// **'패스프레이즈 (8자 이상)'**
  String get passphraseLabel;

  /// No description provided for @passphraseTooShort.
  ///
  /// In ko, this message translates to:
  /// **'패스프레이즈는 8자 이상이어야 합니다'**
  String get passphraseTooShort;

  /// No description provided for @exportSection.
  ///
  /// In ko, this message translates to:
  /// **'내보내기'**
  String get exportSection;

  /// No description provided for @exportSave.
  ///
  /// In ko, this message translates to:
  /// **'기기에 저장'**
  String get exportSave;

  /// No description provided for @exportShare.
  ///
  /// In ko, this message translates to:
  /// **'공유'**
  String get exportShare;

  /// No description provided for @shareWarn.
  ///
  /// In ko, this message translates to:
  /// **'⚠️ 패스프레이즈는 함께 전송하지 마세요.'**
  String get shareWarn;

  /// No description provided for @shareOpened.
  ///
  /// In ko, this message translates to:
  /// **'공유 시트를 열었습니다'**
  String get shareOpened;

  /// No description provided for @exportSaved.
  ///
  /// In ko, this message translates to:
  /// **'백업을 저장했습니다'**
  String get exportSaved;

  /// No description provided for @exportFailed.
  ///
  /// In ko, this message translates to:
  /// **'백업 실패: {error}'**
  String exportFailed(String error);

  /// No description provided for @restoreSection.
  ///
  /// In ko, this message translates to:
  /// **'복원'**
  String get restoreSection;

  /// No description provided for @modeMerge.
  ///
  /// In ko, this message translates to:
  /// **'병합 (기존 유지 + 추가/갱신)'**
  String get modeMerge;

  /// No description provided for @modeOverwrite.
  ///
  /// In ko, this message translates to:
  /// **'덮어쓰기 (기존 전체 교체)'**
  String get modeOverwrite;

  /// No description provided for @restoreButton.
  ///
  /// In ko, this message translates to:
  /// **'파일 선택 후 복원'**
  String get restoreButton;

  /// No description provided for @restoreDone.
  ///
  /// In ko, this message translates to:
  /// **'{count}건을 복원했습니다'**
  String restoreDone(int count);

  /// No description provided for @settingsTitle.
  ///
  /// In ko, this message translates to:
  /// **'설정'**
  String get settingsTitle;

  /// No description provided for @noExpiryWarnTitle.
  ///
  /// In ko, this message translates to:
  /// **'무기한 토큰 경고 주기'**
  String get noExpiryWarnTitle;

  /// No description provided for @noExpiryWarnSubtitle.
  ///
  /// In ko, this message translates to:
  /// **'만료일이 없는 토큰에 대한 주기적 보안 경고'**
  String get noExpiryWarnSubtitle;

  /// No description provided for @intervalOff.
  ///
  /// In ko, this message translates to:
  /// **'끄기'**
  String get intervalOff;

  /// No description provided for @interval15Days.
  ///
  /// In ko, this message translates to:
  /// **'15일마다'**
  String get interval15Days;

  /// No description provided for @interval30Days.
  ///
  /// In ko, this message translates to:
  /// **'30일마다 (기본)'**
  String get interval30Days;

  /// No description provided for @securitySectionTitle.
  ///
  /// In ko, this message translates to:
  /// **'보안'**
  String get securitySectionTitle;

  /// No description provided for @securityInfo.
  ///
  /// In ko, this message translates to:
  /// **'데이터는 기기 Keystore 키로 암호화됩니다. 코드에 키가 없어 디컴파일·타기기 복사로 복원할 수 없습니다. 루팅 기기에서는 경고만 표시되며 차단하지 않습니다.'**
  String get securityInfo;

  /// No description provided for @notifExpiredTitle.
  ///
  /// In ko, this message translates to:
  /// **'만료된 토큰 {count}건'**
  String notifExpiredTitle(int count);

  /// No description provided for @notifExpiredBody.
  ///
  /// In ko, this message translates to:
  /// **'지금 폐기하거나 회전(rotate)하세요: {names}'**
  String notifExpiredBody(String names);

  /// No description provided for @notifSoonTitle.
  ///
  /// In ko, this message translates to:
  /// **'만료 임박 토큰 {count}건'**
  String notifSoonTitle(int count);

  /// No description provided for @notifSoonBody.
  ///
  /// In ko, this message translates to:
  /// **'곧 만료됩니다: {names}'**
  String notifSoonBody(String names);

  /// No description provided for @notifNoExpiryTitle.
  ///
  /// In ko, this message translates to:
  /// **'만료일 미설정 토큰 {count}건'**
  String notifNoExpiryTitle(int count);

  /// No description provided for @notifNoExpiryBody.
  ///
  /// In ko, this message translates to:
  /// **'회전 정책 확인을 권장합니다: {names}'**
  String notifNoExpiryBody(String names);

  /// No description provided for @notifMore.
  ///
  /// In ko, this message translates to:
  /// **'{names} 외 {count}건'**
  String notifMore(String names, int count);

  /// No description provided for @restoreAuthError.
  ///
  /// In ko, this message translates to:
  /// **'비밀번호가 올바르지 않거나 백업이 손상되었습니다'**
  String get restoreAuthError;

  /// No description provided for @restoreFormatError.
  ///
  /// In ko, this message translates to:
  /// **'지원하지 않는 백업 파일입니다'**
  String get restoreFormatError;

  /// No description provided for @settingsLanguage.
  ///
  /// In ko, this message translates to:
  /// **'언어'**
  String get settingsLanguage;

  /// No description provided for @languageSystemDefault.
  ///
  /// In ko, this message translates to:
  /// **'시스템 기본'**
  String get languageSystemDefault;

  /// No description provided for @settingsAutoStart.
  ///
  /// In ko, this message translates to:
  /// **'로그인 시 자동 실행'**
  String get settingsAutoStart;

  /// No description provided for @settingsAutoStartSubtitle.
  ///
  /// In ko, this message translates to:
  /// **'Windows 로그인 시 트레이로 자동 시작'**
  String get settingsAutoStartSubtitle;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>[
        'en',
        'es',
        'fr',
        'ja',
        'ko',
        'zh'
      ].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when language+script codes are specified.
  switch (locale.languageCode) {
    case 'zh':
      {
        switch (locale.scriptCode) {
          case 'Hant':
            return AppLocalizationsZhHant();
        }
        break;
      }
  }

  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'es':
      return AppLocalizationsEs();
    case 'fr':
      return AppLocalizationsFr();
    case 'ja':
      return AppLocalizationsJa();
    case 'ko':
      return AppLocalizationsKo();
    case 'zh':
      return AppLocalizationsZh();
  }

  throw FlutterError(
      'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
      'an issue with the localizations generation tool. Please file an issue '
      'on GitHub with a reproducible sample app and the gen-l10n configuration '
      'that was used.');
}
