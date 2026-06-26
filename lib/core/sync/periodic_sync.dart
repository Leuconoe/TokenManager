// Auto-sync heartbeat: a 1-minute timer that runs a quiet sync whenever the
// chosen cadence (5 min / 1 hour) has elapsed since the last sync. Self-adjusts
// to setting changes without restart (it re-reads the interval each tick).
// Runs while the app is alive (desktop tray-resident; Android foreground).

import 'dart:async';

import '../../features/settings/settings_repository.dart';
import '../debug/debug_log.dart';
import 'sync_controller.dart';

class PeriodicSync {
  final SettingsRepository settings;
  final SyncController controller;
  Timer? _timer;
  bool _running = false;

  PeriodicSync(this.settings, this.controller);

  void start() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(minutes: 1), (_) => _tick());
  }

  void stop() {
    _timer?.cancel();
    _timer = null;
  }

  Future<void> _tick() async {
    if (_running) return; // don't overlap a slow sync
    final interval = await settings.getSyncInterval();
    if (interval == SyncInterval.off) return;
    if (!await settings.getSyncEnabled()) return;
    final last = await settings.getSyncLast();
    final due = last == null ||
        DateTime.now().difference(last).inMinutes >= interval.minutes;
    if (!due) return;
    _running = true;
    dlog('periodic-sync: due (every ${interval.minutes}m)');
    try {
      await controller.syncQuietly();
    } finally {
      _running = false;
    }
  }
}
