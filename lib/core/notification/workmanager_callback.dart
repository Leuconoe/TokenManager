// Design Ref: §F5/§F6, §2.2 — Android background scan isolate.
// Runs in a separate isolate; constructs its own DI (Keystore key is reachable
// in background, DB file decrypts the same way). No network used.
// Delegates the actual scan+notify to the shared ScanService (win-3).

import 'package:workmanager/workmanager.dart';

import '../../features/settings/settings_repository.dart';
import '../../features/tokens/data/token_repository.dart';
import '../crypto/keystore_crypto.dart';
import '../db/app_database.dart';
import '../scan/scan_service.dart';
import 'scheduler.dart';

@pragma('vm:entry-point')
void callbackDispatcher() {
  Workmanager().executeTask((task, _) async {
    if (task != kScanTaskName) return true;
    try {
      final crypto = AppCryptoPort();
      final db = AppDatabase(crypto);
      try {
        final scan = ScanService(
          DriftTokenRepository(db),
          SettingsRepository(),
          NotificationScheduler(),
        );
        await scan.run();
      } finally {
        await db.close();
      }
      return true;
    } catch (_) {
      // Swallow — background task must not crash loop; will retry next cycle.
      return true;
    }
  });
}
