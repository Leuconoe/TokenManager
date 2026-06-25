// win-3 — Android scan scheduler (WorkManager periodic background task).

import 'package:workmanager/workmanager.dart';

import '../notification/scheduler.dart';
import '../notification/workmanager_callback.dart';
import 'scan_scheduler.dart';
import 'scan_service.dart';

class AndroidWorkmanagerScheduler implements ScanScheduler {
  final ScanService _scan;
  final NotificationScheduler _notifier;

  AndroidWorkmanagerScheduler(this._scan, this._notifier);

  @override
  Future<void> ensureScheduled() async {
    await Workmanager().initialize(callbackDispatcher);
    await _notifier.registerDailyScan();
  }

  @override
  Future<void> runOnce() async => _scan.run();
}
