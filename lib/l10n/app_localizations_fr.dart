// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for French (`fr`).
class AppLocalizationsFr extends AppLocalizations {
  AppLocalizationsFr([String locale = 'fr']) : super(locale);

  @override
  String get appTitle => 'TokenManager';

  @override
  String get lockAuthRequired => 'Authentification requise';

  @override
  String get lockAuthFailed => 'Échec de l\'authentification';

  @override
  String get lockUnlock => 'Déverrouiller';

  @override
  String get lockReason =>
      'Authentifiez-vous pour ouvrir votre coffre de jetons';

  @override
  String get listTitle => 'Coffre de jetons';

  @override
  String get sortExpiry => 'Expiration la plus proche';

  @override
  String get sortName => 'Nom du service';

  @override
  String get sortUpdated => 'Récemment modifiés';

  @override
  String get tooltipBackup => 'Sauvegarde / Restauration';

  @override
  String get filterAll => 'Tous';

  @override
  String get statusValid => 'Valide';

  @override
  String get statusSoon => 'Bientôt';

  @override
  String get statusExpired => 'Expiré';

  @override
  String get statusNoExpiry => 'Sans expiration';

  @override
  String get emptyTitle => 'Aucun jeton enregistré';

  @override
  String get emptyHint => 'Touchez + pour ajouter un enregistrement de jeton';

  @override
  String get subtitleNoExpiry => 'Pas de date d\'expiration';

  @override
  String subtitleExpired(String date) {
    return 'Expiré ($date)';
  }

  @override
  String subtitleDday(int days, String date) {
    return 'Expire dans $days j ($date)';
  }

  @override
  String get editTitleNew => 'Ajouter un jeton';

  @override
  String get editTitleEdit => 'Modifier le jeton';

  @override
  String get fieldService => 'Nom du service *';

  @override
  String get fieldServiceHint => 'ex. GitHub PAT - déploiement CI';

  @override
  String get fieldUrl => 'URL (facultatif)';

  @override
  String get fieldUrlHint => 'ex. https://github.com/settings/tokens';

  @override
  String get validationServiceRequired => 'Veuillez saisir un nom de service';

  @override
  String get fieldIssued => 'Date d\'émission (facultatif)';

  @override
  String get fieldExpiry =>
      'Date d\'expiration (facultatif, vide = sans expiration)';

  @override
  String get hintNoExpiry =>
      'Pas d\'expiration = n\'expire jamais (objet d\'alerte de sécurité)';

  @override
  String get fieldNote => 'Note';

  @override
  String get fieldNoteHint =>
      'Politique de rotation, usage, etc. (ne saisissez pas de valeurs de jeton)';

  @override
  String get securityBanner =>
      'Ne saisissez pas de valeurs de jeton. Cette app sert au suivi des jetons et déconseille de stocker leurs valeurs.';

  @override
  String get noteWarnTitle => 'Ressemble à une valeur de jeton';

  @override
  String get noteWarnBody =>
      'La note semble contenir une valeur de jeton/secret. Cette app déconseille de stocker des valeurs de jeton. Enregistrer quand même ?';

  @override
  String get actionCancel => 'Annuler';

  @override
  String get actionSaveAnyway => 'Enregistrer quand même';

  @override
  String get actionSave => 'Enregistrer';

  @override
  String get actionDelete => 'Supprimer';

  @override
  String deleteBody(String name) {
    return 'Supprimer l\'enregistrement « $name » ?';
  }

  @override
  String get dateUnset => 'Non défini';

  @override
  String get dateSelect => 'Choisir';

  @override
  String get backupTitle => 'Sauvegarde / Restauration';

  @override
  String get backupInfo =>
      'Les sauvegardes sont chiffrées avec une phrase secrète (Argon2id + AES-256-GCM). Si vous l\'oubliez, la restauration est impossible.';

  @override
  String get passphraseLabel => 'Phrase secrète (8 caractères min.)';

  @override
  String get passphraseTooShort =>
      'La phrase secrète doit faire au moins 8 caractères';

  @override
  String get exportSection => 'Exporter';

  @override
  String get exportSave => 'Enregistrer sur l\'appareil';

  @override
  String get exportShare => 'Partager';

  @override
  String get shareWarn =>
      '⚠️ N\'envoyez pas la phrase secrète avec le fichier.';

  @override
  String get shareOpened => 'Panneau de partage ouvert';

  @override
  String get exportSaved => 'Sauvegarde enregistrée';

  @override
  String exportFailed(String error) {
    return 'Échec de la sauvegarde : $error';
  }

  @override
  String get restoreSection => 'Restaurer';

  @override
  String get modeMerge => 'Fusionner (conserver + ajouter/mettre à jour)';

  @override
  String get modeOverwrite => 'Écraser (tout remplacer)';

  @override
  String get restoreButton => 'Choisir un fichier et restaurer';

  @override
  String restoreDone(int count) {
    return '$count élément(s) restauré(s)';
  }

  @override
  String get settingsTitle => 'Paramètres';

  @override
  String get noExpiryWarnTitle => 'Intervalle d\'alerte sans expiration';

  @override
  String get noExpiryWarnSubtitle =>
      'Alerte de sécurité périodique pour les jetons sans date d\'expiration';

  @override
  String get intervalOff => 'Désactivé';

  @override
  String get interval15Days => 'Tous les 15 jours';

  @override
  String get interval30Days => 'Tous les 30 jours (par défaut)';

  @override
  String get expiryLeadTitle => 'Délai d\'alerte d\'expiration';

  @override
  String get expiryLeadSubtitle =>
      'Combien de jours avant l\'expiration alerter (jetons avec date)';

  @override
  String get lead7Days => '7 jours avant';

  @override
  String get lead14Days => '14 jours avant (par défaut)';

  @override
  String get lead30Days => '30 jours avant';

  @override
  String get securitySectionTitle => 'Sécurité';

  @override
  String get securityInfo =>
      'Les données sont chiffrées avec une clé Keystore de l\'appareil. Aucune clé n\'est dans le code : impossible de récupérer par décompilation ou copie vers un autre appareil. Sur les appareils rootés, seul un avertissement s\'affiche, sans blocage.';

  @override
  String get settingsCheckUpdate => 'Rechercher des mises à jour';

  @override
  String get updateChecking => 'Recherche de mises à jour…';

  @override
  String updateUpToDate(String version) {
    return 'Vous avez la dernière version ($version)';
  }

  @override
  String get updateAvailableTitle => 'Mise à jour disponible';

  @override
  String updateAvailableBody(String latest, String current) {
    return 'La version $latest est disponible (actuelle $current). Ouvrir la page de version ?';
  }

  @override
  String get updateOpen => 'Ouvrir';

  @override
  String get updateFailed => 'Échec de la recherche de mises à jour';

  @override
  String mergeConflictTitle(String name) {
    return 'Conflit « $name »';
  }

  @override
  String get mergeConflictBody =>
      'Cette entrée diffère de la locale (ex. date d\'expiration). Laquelle utiliser ?';

  @override
  String get mergeKeepLocal => 'Garder locale';

  @override
  String get mergeUseImported => 'Utiliser importée';

  @override
  String notifExpiredTitle(int count) {
    return '$count jeton(s) expiré(s)';
  }

  @override
  String notifExpiredBody(String names) {
    return 'Révoquez ou renouvelez maintenant : $names';
  }

  @override
  String notifSoonTitle(int count) {
    return '$count jeton(s) bientôt expiré(s)';
  }

  @override
  String notifSoonBody(String names) {
    return 'Expiration proche : $names';
  }

  @override
  String notifNoExpiryTitle(int count) {
    return '$count jeton(s) sans expiration';
  }

  @override
  String notifNoExpiryBody(String names) {
    return 'Vérifiez votre politique de rotation : $names';
  }

  @override
  String notifMore(String names, int count) {
    return '$names et $count de plus';
  }

  @override
  String get restoreAuthError =>
      'Phrase secrète incorrecte ou sauvegarde corrompue';

  @override
  String get restoreFormatError => 'Fichier de sauvegarde non pris en charge';

  @override
  String get settingsLanguage => 'Langue';

  @override
  String get languageSystemDefault => 'Par défaut du système';

  @override
  String get settingsAutoStart => 'Lancer à l\'ouverture de session';

  @override
  String get settingsAutoStartSubtitle =>
      'Démarre dans la barre d\'état lors de la connexion Windows';
}
