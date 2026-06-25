// win-3 — platform-branched expiry scan scheduling.
// Android: WorkManager periodic background task.
// Desktop: launch-at-startup + tray-resident periodic Timer.

abstract interface class ScanScheduler {
  /// Registers the recurring scan mechanism for the platform.
  Future<void> ensureScheduled();

  /// Runs a single scan + notify immediately (scan-on-launch / manual).
  Future<void> runOnce();
}
