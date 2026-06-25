// Design Ref: §F5, §F6 — local notification publishing + background scan registration.

import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:workmanager/workmanager.dart';

import '../../l10n/app_localizations.dart';
import '../domain/token_entry.dart';
import '../domain/token_status.dart';

const String kScanTaskName = 'tm.daily_scan';
const String _channelId = 'tm_expiry';
const String _channelName = '토큰 만료 알림';

class NotificationScheduler {
  final FlutterLocalNotificationsPlugin _plugin;
  NotificationScheduler([FlutterLocalNotificationsPlugin? plugin])
      : _plugin = plugin ?? FlutterLocalNotificationsPlugin();

  Future<void> init() async {
    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    await _plugin.initialize(
      const InitializationSettings(android: android),
    );
    await _plugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.requestNotificationsPermission();
  }

  /// Registers a daily background scan via WorkManager.
  Future<void> registerDailyScan() async {
    await Workmanager().registerPeriodicTask(
      kScanTaskName,
      kScanTaskName,
      frequency: const Duration(hours: 24),
      constraints: Constraints(networkType: NetworkType.notRequired),
      existingWorkPolicy: ExistingPeriodicWorkPolicy.keep,
    );
  }

  static const _details = NotificationDetails(
    android: AndroidNotificationDetails(
      _channelId,
      _channelName,
      channelDescription: '토큰 만료/무기한 보안 경고',
      importance: Importance.high,
      priority: Priority.high,
    ),
  );

  /// Emits notifications for expired / expiring / (optionally) no-expiry groups.
  /// [warnNoExpiry] gated by Settings interval (computed by caller).
  /// [l10n] localizes notification text (loaded by the background isolate).
  Future<void> notifyFromScan(
    Map<TokenStatus, List<TokenEntry>> scan, {
    required bool warnNoExpiry,
    required AppLocalizations l10n,
  }) async {
    final expired = scan[TokenStatus.expired] ?? const [];
    final soon = scan[TokenStatus.expiringSoon] ?? const [];
    final noExpiry = scan[TokenStatus.noExpiry] ?? const [];

    if (expired.isNotEmpty) {
      await _plugin.show(1, l10n.notifExpiredTitle(expired.length),
          l10n.notifExpiredBody(_names(l10n, expired)), _details);
    }
    if (soon.isNotEmpty) {
      await _plugin.show(2, l10n.notifSoonTitle(soon.length),
          l10n.notifSoonBody(_names(l10n, soon)), _details);
    }
    if (warnNoExpiry && noExpiry.isNotEmpty) {
      await _plugin.show(3, l10n.notifNoExpiryTitle(noExpiry.length),
          l10n.notifNoExpiryBody(_names(l10n, noExpiry)), _details);
    }
  }

  static String _names(AppLocalizations l10n, List<TokenEntry> items) {
    final names = items.take(3).map((e) => e.serviceName).join(', ');
    return items.length > 3
        ? l10n.notifMore(names, items.length - 3)
        : names;
  }
}
