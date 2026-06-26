// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'TokenManager';

  @override
  String get lockAuthRequired => 'Authentication required';

  @override
  String get lockAuthFailed => 'Authentication failed';

  @override
  String get lockUnlock => 'Unlock';

  @override
  String get lockReason => 'Authenticate to open your token vault';

  @override
  String get listTitle => 'Token Vault';

  @override
  String get sortExpiry => 'Expiring soonest';

  @override
  String get sortName => 'Service name';

  @override
  String get sortUpdated => 'Recently updated';

  @override
  String get tooltipBackup => 'Backup / Restore';

  @override
  String get filterAll => 'All';

  @override
  String get statusValid => 'Valid';

  @override
  String get statusSoon => 'Soon';

  @override
  String get statusExpired => 'Expired';

  @override
  String get statusNoExpiry => 'No expiry';

  @override
  String get emptyTitle => 'No tokens recorded yet';

  @override
  String get emptyHint => 'Tap + to add a token issuance record';

  @override
  String get subtitleNoExpiry => 'No expiry date';

  @override
  String subtitleExpired(String date) {
    return 'Expired ($date)';
  }

  @override
  String subtitleDday(int days, String date) {
    return 'Expires in ${days}d ($date)';
  }

  @override
  String get editTitleNew => 'Add token';

  @override
  String get editTitleEdit => 'Edit token';

  @override
  String get fieldService => 'Service name *';

  @override
  String get fieldServiceHint => 'e.g. GitHub PAT - CI deploy';

  @override
  String get fieldUrl => 'URL (optional)';

  @override
  String get fieldUrlHint => 'e.g. https://github.com/settings/tokens';

  @override
  String get validationServiceRequired => 'Please enter a service name';

  @override
  String get fieldIssued => 'Issued date (optional)';

  @override
  String get fieldExpiry => 'Expiry date (optional, none = no expiry)';

  @override
  String get hintNoExpiry =>
      'No expiry date = never expires (security warning target)';

  @override
  String get fieldNote => 'Note';

  @override
  String get fieldNoteHint =>
      'Rotation policy, usage, etc. (do not enter token values)';

  @override
  String get securityBanner =>
      'Do not enter token values. This app is for tracking tokens and does not recommend storing their values.';

  @override
  String get noteWarnTitle => 'Looks like a token value';

  @override
  String get noteWarnBody =>
      'The note appears to contain a token/secret value. This app recommends not storing token values. Save anyway?';

  @override
  String get actionCancel => 'Cancel';

  @override
  String get actionSaveAnyway => 'Save anyway';

  @override
  String get actionSave => 'Save';

  @override
  String get actionDelete => 'Delete';

  @override
  String deleteBody(String name) {
    return 'Delete the \"$name\" record?';
  }

  @override
  String get dateUnset => 'Not set';

  @override
  String get dateSelect => 'Select';

  @override
  String get backupTitle => 'Backup / Restore';

  @override
  String get backupInfo =>
      'Backups are encrypted with a passphrase (Argon2id + AES-256-GCM). If you forget the passphrase, the backup cannot be restored.';

  @override
  String get passphraseLabel => 'Passphrase (8+ characters)';

  @override
  String get passphraseTooShort => 'Passphrase must be at least 8 characters';

  @override
  String get exportSection => 'Export';

  @override
  String get exportSave => 'Save to device';

  @override
  String get exportShare => 'Share';

  @override
  String get shareWarn =>
      '⚠️ Do not send the passphrase together with the file.';

  @override
  String get shareOpened => 'Share sheet opened';

  @override
  String get exportSaved => 'Backup saved';

  @override
  String exportFailed(String error) {
    return 'Backup failed: $error';
  }

  @override
  String get restoreSection => 'Restore';

  @override
  String get modeMerge => 'Merge (keep existing + add/update)';

  @override
  String get modeOverwrite => 'Overwrite (replace everything)';

  @override
  String get restoreButton => 'Pick file and restore';

  @override
  String restoreDone(int count) {
    return 'Restored $count item(s)';
  }

  @override
  String get settingsTitle => 'Settings';

  @override
  String get noExpiryWarnTitle => 'No-expiry warning interval';

  @override
  String get noExpiryWarnSubtitle =>
      'Periodic security warning for tokens without an expiry date';

  @override
  String get intervalOff => 'Off';

  @override
  String get interval15Days => 'Every 15 days';

  @override
  String get interval30Days => 'Every 30 days (default)';

  @override
  String get expiryLeadTitle => 'Expiry warning lead time';

  @override
  String get expiryLeadSubtitle =>
      'How many days before expiry to warn (for tokens with one)';

  @override
  String get lead7Days => '7 days before';

  @override
  String get lead14Days => '14 days before (default)';

  @override
  String get lead30Days => '30 days before';

  @override
  String get securitySectionTitle => 'Security';

  @override
  String get securityInfo =>
      'Data is encrypted with a device Keystore key. No key exists in the code, so it cannot be recovered by decompiling or copying to another device. On rooted devices a warning is shown but access is not blocked.';

  @override
  String get settingsCheckUpdate => 'Check for updates';

  @override
  String get updateChecking => 'Checking for updates…';

  @override
  String updateUpToDate(String version) {
    return 'You\'re on the latest version ($version)';
  }

  @override
  String get updateAvailableTitle => 'Update available';

  @override
  String updateAvailableBody(String latest, String current) {
    return 'Version $latest is available (current $current). Open the release page?';
  }

  @override
  String get updateOpen => 'Open';

  @override
  String get updateFailed => 'Update check failed';

  @override
  String mergeConflictTitle(String name) {
    return '\'$name\' conflict';
  }

  @override
  String get mergeConflictBody =>
      'This entry differs from the local one (e.g. expiry date). Which one to use?';

  @override
  String get mergeKeepLocal => 'Keep local';

  @override
  String get mergeUseImported => 'Use imported';

  @override
  String get syncSectionTitle => 'Folder sync';

  @override
  String get syncEnableSubtitle =>
      'Sync as an encrypted file in a chosen folder (a Drive/OneDrive synced folder is ideal)';

  @override
  String get syncFolderTitle => 'Sync folder';

  @override
  String get syncPassphraseTitle => 'Sync passphrase';

  @override
  String get syncValueNotSet => 'Not set';

  @override
  String get syncValueSet => 'Set';

  @override
  String get syncNowAction => 'Sync now';

  @override
  String syncResultDone(int count) {
    return 'Synced $count item(s)';
  }

  @override
  String get syncResultFailed => 'Sync failed — check passphrase/folder';

  @override
  String get syncNeedSetup => 'Set the folder and passphrase first';

  @override
  String get passphraseMin8 => '8+ characters';

  @override
  String get syncProviderFolder => 'Folder (SAF)';

  @override
  String get syncProviderDrive => 'Google Drive';

  @override
  String get syncDriveConnect => 'Connect Google Drive';

  @override
  String get syncDriveNotConnected => 'Not connected';

  @override
  String notifExpiredTitle(int count) {
    return '$count expired token(s)';
  }

  @override
  String notifExpiredBody(String names) {
    return 'Revoke or rotate now: $names';
  }

  @override
  String notifSoonTitle(int count) {
    return '$count token(s) expiring soon';
  }

  @override
  String notifSoonBody(String names) {
    return 'Expiring soon: $names';
  }

  @override
  String notifNoExpiryTitle(int count) {
    return '$count token(s) without expiry';
  }

  @override
  String notifNoExpiryBody(String names) {
    return 'Review your rotation policy: $names';
  }

  @override
  String notifMore(String names, int count) {
    return '$names and $count more';
  }

  @override
  String get restoreAuthError => 'Wrong passphrase or corrupted backup';

  @override
  String get restoreFormatError => 'Unsupported backup file';

  @override
  String get settingsLanguage => 'Language';

  @override
  String get languageSystemDefault => 'System default';

  @override
  String get settingsAutoStart => 'Launch at login';

  @override
  String get settingsAutoStartSubtitle =>
      'Start to the system tray when Windows signs in';
}
