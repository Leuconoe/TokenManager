// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Korean (`ko`).
class AppLocalizationsKo extends AppLocalizations {
  AppLocalizationsKo([String locale = 'ko']) : super(locale);

  @override
  String get appTitle => 'TokenManager';

  @override
  String get lockAuthRequired => '인증이 필요합니다';

  @override
  String get lockAuthFailed => '인증에 실패했습니다';

  @override
  String get lockUnlock => '잠금 해제';

  @override
  String get lockReason => '토큰 보관함을 열려면 인증이 필요합니다';

  @override
  String get listTitle => '토큰 보관함';

  @override
  String get sortExpiry => '만료 임박순';

  @override
  String get sortName => '서비스명순';

  @override
  String get sortUpdated => '최근 수정순';

  @override
  String get tooltipBackup => '백업/복원';

  @override
  String get filterAll => '전체';

  @override
  String get statusValid => '유효';

  @override
  String get statusSoon => '임박';

  @override
  String get statusExpired => '만료';

  @override
  String get statusNoExpiry => '무기한';

  @override
  String get emptyTitle => '아직 기록된 토큰이 없습니다';

  @override
  String get emptyHint => '+ 버튼으로 토큰 발급 내역을 추가하세요';

  @override
  String get subtitleNoExpiry => '만료일 없음';

  @override
  String subtitleExpired(String date) {
    return '만료됨 ($date)';
  }

  @override
  String subtitleDday(int days, String date) {
    return '만료 D-$days ($date)';
  }

  @override
  String get editTitleNew => '토큰 추가';

  @override
  String get editTitleEdit => '토큰 수정';

  @override
  String get fieldService => '서비스 명 *';

  @override
  String get fieldServiceHint => '예: GitHub PAT - CI 배포용';

  @override
  String get fieldUrl => 'URL (선택)';

  @override
  String get fieldUrlHint => '예: https://github.com/settings/tokens';

  @override
  String get validationServiceRequired => '서비스 명을 입력하세요';

  @override
  String get fieldIssued => '발급일 (선택)';

  @override
  String get fieldExpiry => '만료일 (선택, 없으면 무기한)';

  @override
  String get hintNoExpiry => '만료일 미설정 = 무기한(보안 경고 대상)';

  @override
  String get fieldNote => '노트';

  @override
  String get fieldNoteHint => '회전 정책, 용도 등 (토큰 값 입력 금지)';

  @override
  String get securityBanner => '토큰 값은 입력하지 마세요. 이 앱은 토큰 추적용이며 값 저장을 권장하지 않습니다.';

  @override
  String get noteWarnTitle => '토큰 값으로 보이는 내용';

  @override
  String get noteWarnBody =>
      '노트에 토큰/시크릿 값으로 보이는 내용이 있습니다. 이 앱은 토큰 값을 저장하지 않는 것을 권장합니다. 계속 저장할까요?';

  @override
  String get actionCancel => '취소';

  @override
  String get actionSaveAnyway => '계속 저장';

  @override
  String get actionSave => '저장';

  @override
  String get actionDelete => '삭제';

  @override
  String deleteBody(String name) {
    return '\"$name\" 기록을 삭제할까요?';
  }

  @override
  String get dateUnset => '미설정';

  @override
  String get dateSelect => '선택';

  @override
  String get backupTitle => '백업 / 복원';

  @override
  String get backupInfo =>
      '백업은 패스프레이즈로 암호화됩니다(Argon2id + AES-256-GCM). 패스프레이즈를 잊으면 복원할 수 없습니다.';

  @override
  String get passphraseLabel => '패스프레이즈 (8자 이상)';

  @override
  String get passphraseTooShort => '패스프레이즈는 8자 이상이어야 합니다';

  @override
  String get exportSection => '내보내기';

  @override
  String get exportSave => '기기에 저장';

  @override
  String get exportShare => '공유';

  @override
  String get shareWarn => '⚠️ 패스프레이즈는 함께 전송하지 마세요.';

  @override
  String get shareOpened => '공유 시트를 열었습니다';

  @override
  String get exportSaved => '백업을 저장했습니다';

  @override
  String exportFailed(String error) {
    return '백업 실패: $error';
  }

  @override
  String get restoreSection => '복원';

  @override
  String get modeMerge => '병합 (기존 유지 + 추가/갱신)';

  @override
  String get modeOverwrite => '덮어쓰기 (기존 전체 교체)';

  @override
  String get restoreButton => '파일 선택 후 복원';

  @override
  String restoreDone(int count) {
    return '$count건을 복원했습니다';
  }

  @override
  String get settingsTitle => '설정';

  @override
  String get noExpiryWarnTitle => '무기한 토큰 경고 주기';

  @override
  String get noExpiryWarnSubtitle => '만료일이 없는 토큰에 대한 주기적 보안 경고';

  @override
  String get intervalOff => '끄기';

  @override
  String get interval15Days => '15일마다';

  @override
  String get interval30Days => '30일마다 (기본)';

  @override
  String get securitySectionTitle => '보안';

  @override
  String get securityInfo =>
      '데이터는 기기 Keystore 키로 암호화됩니다. 코드에 키가 없어 디컴파일·타기기 복사로 복원할 수 없습니다. 루팅 기기에서는 경고만 표시되며 차단하지 않습니다.';

  @override
  String notifExpiredTitle(int count) {
    return '만료된 토큰 $count건';
  }

  @override
  String notifExpiredBody(String names) {
    return '지금 폐기하거나 회전(rotate)하세요: $names';
  }

  @override
  String notifSoonTitle(int count) {
    return '만료 임박 토큰 $count건';
  }

  @override
  String notifSoonBody(String names) {
    return '곧 만료됩니다: $names';
  }

  @override
  String notifNoExpiryTitle(int count) {
    return '만료일 미설정 토큰 $count건';
  }

  @override
  String notifNoExpiryBody(String names) {
    return '회전 정책 확인을 권장합니다: $names';
  }

  @override
  String notifMore(String names, int count) {
    return '$names 외 $count건';
  }

  @override
  String get restoreAuthError => '비밀번호가 올바르지 않거나 백업이 손상되었습니다';

  @override
  String get restoreFormatError => '지원하지 않는 백업 파일입니다';

  @override
  String get settingsLanguage => '언어';

  @override
  String get languageSystemDefault => '시스템 기본';

  @override
  String get settingsAutoStart => '로그인 시 자동 실행';

  @override
  String get settingsAutoStartSubtitle => 'Windows 로그인 시 트레이로 자동 시작';
}
