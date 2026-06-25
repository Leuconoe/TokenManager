// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class AppLocalizationsEs extends AppLocalizations {
  AppLocalizationsEs([String locale = 'es']) : super(locale);

  @override
  String get appTitle => 'TokenManager';

  @override
  String get lockAuthRequired => 'Se requiere autenticación';

  @override
  String get lockAuthFailed => 'Error de autenticación';

  @override
  String get lockUnlock => 'Desbloquear';

  @override
  String get lockReason => 'Autentícate para abrir tu bóveda de tokens';

  @override
  String get listTitle => 'Bóveda de tokens';

  @override
  String get sortExpiry => 'Caducan antes';

  @override
  String get sortName => 'Nombre del servicio';

  @override
  String get sortUpdated => 'Actualizados recientemente';

  @override
  String get tooltipBackup => 'Copia de seguridad / Restaurar';

  @override
  String get filterAll => 'Todos';

  @override
  String get statusValid => 'Válido';

  @override
  String get statusSoon => 'Pronto';

  @override
  String get statusExpired => 'Caducado';

  @override
  String get statusNoExpiry => 'Sin caducidad';

  @override
  String get emptyTitle => 'Aún no hay tokens registrados';

  @override
  String get emptyHint => 'Toca + para añadir un registro de token';

  @override
  String get subtitleNoExpiry => 'Sin fecha de caducidad';

  @override
  String subtitleExpired(String date) {
    return 'Caducado ($date)';
  }

  @override
  String subtitleDday(int days, String date) {
    return 'Caduca en $days d ($date)';
  }

  @override
  String get editTitleNew => 'Añadir token';

  @override
  String get editTitleEdit => 'Editar token';

  @override
  String get fieldService => 'Nombre del servicio *';

  @override
  String get fieldServiceHint => 'p. ej. GitHub PAT - despliegue CI';

  @override
  String get fieldUrl => 'URL (opcional)';

  @override
  String get fieldUrlHint => 'p. ej. https://github.com/settings/tokens';

  @override
  String get validationServiceRequired => 'Introduce un nombre de servicio';

  @override
  String get fieldIssued => 'Fecha de emisión (opcional)';

  @override
  String get fieldExpiry =>
      'Fecha de caducidad (opcional, vacío = sin caducidad)';

  @override
  String get hintNoExpiry =>
      'Sin fecha de caducidad = nunca caduca (objeto de aviso de seguridad)';

  @override
  String get fieldNote => 'Nota';

  @override
  String get fieldNoteHint =>
      'Política de rotación, uso, etc. (no introduzcas valores de token)';

  @override
  String get securityBanner =>
      'No introduzcas valores de token. Esta app sirve para rastrear tokens y no recomienda almacenar sus valores.';

  @override
  String get noteWarnTitle => 'Parece un valor de token';

  @override
  String get noteWarnBody =>
      'La nota parece contener un valor de token/secreto. Esta app recomienda no almacenar valores de token. ¿Guardar de todos modos?';

  @override
  String get actionCancel => 'Cancelar';

  @override
  String get actionSaveAnyway => 'Guardar igualmente';

  @override
  String get actionSave => 'Guardar';

  @override
  String get actionDelete => 'Eliminar';

  @override
  String deleteBody(String name) {
    return '¿Eliminar el registro \"$name\"?';
  }

  @override
  String get dateUnset => 'Sin definir';

  @override
  String get dateSelect => 'Seleccionar';

  @override
  String get backupTitle => 'Copia de seguridad / Restaurar';

  @override
  String get backupInfo =>
      'Las copias se cifran con una frase de contraseña (Argon2id + AES-256-GCM). Si la olvidas, no se podrá restaurar.';

  @override
  String get passphraseLabel => 'Frase de contraseña (mín. 8 caracteres)';

  @override
  String get passphraseTooShort => 'La frase debe tener al menos 8 caracteres';

  @override
  String get exportSection => 'Exportar';

  @override
  String get exportSave => 'Guardar en el dispositivo';

  @override
  String get exportShare => 'Compartir';

  @override
  String get shareWarn =>
      '⚠️ No envíes la frase de contraseña junto con el archivo.';

  @override
  String get shareOpened => 'Panel de compartir abierto';

  @override
  String get exportSaved => 'Copia guardada';

  @override
  String exportFailed(String error) {
    return 'Error de copia: $error';
  }

  @override
  String get restoreSection => 'Restaurar';

  @override
  String get modeMerge => 'Combinar (conservar + añadir/actualizar)';

  @override
  String get modeOverwrite => 'Sobrescribir (reemplazar todo)';

  @override
  String get restoreButton => 'Elegir archivo y restaurar';

  @override
  String restoreDone(int count) {
    return '$count elemento(s) restaurado(s)';
  }

  @override
  String get settingsTitle => 'Ajustes';

  @override
  String get noExpiryWarnTitle => 'Intervalo de aviso sin caducidad';

  @override
  String get noExpiryWarnSubtitle =>
      'Aviso de seguridad periódico para tokens sin fecha de caducidad';

  @override
  String get intervalOff => 'Desactivado';

  @override
  String get intervalWeekly => 'Semanal (predet.)';

  @override
  String get intervalBiweekly => 'Cada 2 semanas';

  @override
  String get intervalMonthly => 'Mensual';

  @override
  String get securitySectionTitle => 'Seguridad';

  @override
  String get securityInfo =>
      'Los datos se cifran con una clave del Keystore del dispositivo. No hay clave en el código, por lo que no se puede recuperar descompilando ni copiando a otro dispositivo. En dispositivos con root solo se muestra un aviso, sin bloquear el acceso.';

  @override
  String notifExpiredTitle(int count) {
    return '$count token(s) caducado(s)';
  }

  @override
  String notifExpiredBody(String names) {
    return 'Revoca o rota ahora: $names';
  }

  @override
  String notifSoonTitle(int count) {
    return '$count token(s) por caducar';
  }

  @override
  String notifSoonBody(String names) {
    return 'Caducan pronto: $names';
  }

  @override
  String notifNoExpiryTitle(int count) {
    return '$count token(s) sin caducidad';
  }

  @override
  String notifNoExpiryBody(String names) {
    return 'Revisa tu política de rotación: $names';
  }

  @override
  String notifMore(String names, int count) {
    return '$names y $count más';
  }

  @override
  String get restoreAuthError =>
      'Frase de contraseña incorrecta o copia dañada';

  @override
  String get restoreFormatError => 'Archivo de copia no compatible';

  @override
  String get settingsLanguage => 'Idioma';

  @override
  String get languageSystemDefault => 'Predeterminado del sistema';
}
