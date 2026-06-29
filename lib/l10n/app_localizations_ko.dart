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
  String get searchHint => '제목 / 사이트 / 노트 검색';

  @override
  String get searchNoResults => '검색 결과 없음';

  @override
  String get sortExpiry => '만료 임박순';

  @override
  String get sortName => '서비스명순';

  @override
  String get sortBy => '정렬 기준';

  @override
  String get sortCreated => '생성일순';

  @override
  String get sortSite => '사이트순';

  @override
  String get sortAsc => '오름차순';

  @override
  String get sortDesc => '내림차순';

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
  String get versionTitle => '버전';

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
  String get expiryLeadTitle => '만료 경고 시점';

  @override
  String get expiryLeadSubtitle => '만료일이 있는 토큰을 만료 며칠 전부터 경고할지';

  @override
  String get lead7Days => '만료 7일 전';

  @override
  String get lead14Days => '만료 14일 전 (기본)';

  @override
  String get lead30Days => '만료 30일 전';

  @override
  String get securitySectionTitle => '보안';

  @override
  String get securityInfo =>
      '데이터는 기기 Keystore 키로 암호화됩니다. 코드에 키가 없어 디컴파일·타기기 복사로 복원할 수 없습니다. 루팅 기기에서는 경고만 표시되며 차단하지 않습니다.';

  @override
  String get captureProtectionTitle => '화면 캡처 차단';

  @override
  String get captureProtectionSubtitle =>
      '스크린샷을 막고 최근 앱 미리보기에서 내용을 숨깁니다 (Android)';

  @override
  String get debugLogTitle => '디버그 로그';

  @override
  String get debugLogClear => '지우기';

  @override
  String get trashTitle => '휴지통';

  @override
  String get trashSubtitle => '최근 삭제된 토큰 (30일 후 자동 정리)';

  @override
  String get trashEmpty => '휴지통이 비어 있습니다';

  @override
  String get trashHint => '토큰을 복원하거나 완전 삭제할 수 있습니다. 30일 지난 삭제 항목은 자동 정리됩니다.';

  @override
  String get trashRestore => '복원';

  @override
  String get trashPurge => '완전 삭제';

  @override
  String get trashPurgeAll => '휴지통 비우기';

  @override
  String get trashPurgeAllConfirm => '휴지통의 모든 항목을 완전 삭제할까요?';

  @override
  String trashDeletedOn(Object date) {
    return '삭제일 $date';
  }

  @override
  String get settingsCheckUpdate => '업데이트 확인';

  @override
  String get updateChecking => '업데이트 확인 중…';

  @override
  String updateUpToDate(String version) {
    return '최신 버전입니다 ($version)';
  }

  @override
  String get updateAvailableTitle => '업데이트 가능';

  @override
  String updateAvailableBody(String latest, String current) {
    return '새 버전 $latest 이(가) 있습니다 (현재 $current). 릴리즈 페이지를 열까요?';
  }

  @override
  String get updateOpen => '열기';

  @override
  String get updateFailed => '업데이트 확인에 실패했습니다';

  @override
  String mergeConflictTitle(String name) {
    return '\'$name\' 충돌';
  }

  @override
  String get mergeConflictBody => '이 항목이 로컬과 다릅니다(예: 만료일 차이). 어느 값을 사용할까요?';

  @override
  String get mergeKeepLocal => '로컬 유지';

  @override
  String get mergeUseImported => '가져온 값';

  @override
  String get syncSectionTitle => '폴더 동기화';

  @override
  String get syncEnableSubtitle =>
      '지정한 폴더에 암호화 파일로 동기화 (Drive/OneDrive 등 동기화 폴더 권장)';

  @override
  String get syncFolderTitle => '동기화 폴더';

  @override
  String get syncPassphraseTitle => '동기화 패스프레이즈';

  @override
  String get syncValueNotSet => '미설정';

  @override
  String get syncValueSet => '설정됨';

  @override
  String get syncNowAction => '지금 동기화';

  @override
  String get syncInProgress => '동기화 중…';

  @override
  String get syncIntervalTitle => '자동 동기화';

  @override
  String get syncIntervalSubtitle => '동기화가 켜져 있을 때 선택한 주기로 자동 동기화';

  @override
  String get syncInterval5m => '5분마다';

  @override
  String get syncInterval1h => '1시간마다';

  @override
  String syncResultDone(int count) {
    return '$count건 동기화됨';
  }

  @override
  String get syncResultFailed => '동기화 실패 — 패스프레이즈/폴더를 확인하세요';

  @override
  String get syncNeedSetup => '폴더와 패스프레이즈를 먼저 설정하세요';

  @override
  String get passphraseMin8 => '8자 이상';

  @override
  String get syncProviderFolder => '폴더 (SAF)';

  @override
  String get syncProviderDrive => 'Google Drive';

  @override
  String get syncDriveConnect => 'Google Drive 연결';

  @override
  String get syncDriveNotConnected => '연결 안 됨';

  @override
  String get syncDriveSignInFailed =>
      'Google Drive 로그인 실패. OAuth 설정(패키지명 + SHA-1)을 확인하세요.';

  @override
  String get syncPassMismatchTitle => '동기화 패스프레이즈 불일치';

  @override
  String get syncPassMismatchBody =>
      '클라우드에 이미 있는 데이터와 동기화 패스프레이즈가 다릅니다. 다른 기기에서 사용한 것과 동일한 패스프레이즈를 입력하거나, 클라우드 파일을 삭제해 동기화를 초기화하세요.';

  @override
  String get syncPassReenter => '패스프레이즈 다시 입력';

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
