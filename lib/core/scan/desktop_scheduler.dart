// win-3 — Desktop (Windows) scan scheduler: launch-at-startup + system tray
// resident + periodic Timer. Closing the window hides to tray instead of exiting.

import 'dart:async';
import 'dart:io' show Platform;

import 'package:launch_at_startup/launch_at_startup.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:tray_manager/tray_manager.dart';
import 'package:window_manager/window_manager.dart';

import '../domain/token_status.dart';
import 'scan_scheduler.dart';
import 'scan_service.dart';

class DesktopTrayScheduler
    with TrayListener, WindowListener
    implements ScanScheduler {
  final ScanService _scan;
  Timer? _timer;

  DesktopTrayScheduler(this._scan);

  @override
  Future<void> ensureScheduled() async {
    // 1) Launch at login (minimized arg reserved for future start-hidden).
    final info = await PackageInfo.fromPlatform();
    launchAtStartup.setup(
      appName: info.appName,
      appPath: Platform.resolvedExecutable,
      args: ['--minimized'],
    );
    await launchAtStartup.enable();

    // 2) System tray.
    trayManager.addListener(this);
    await trayManager.setIcon('assets/icon/app_icon.ico');
    await trayManager.setContextMenu(Menu(items: [
      MenuItem(key: 'show', label: 'Open'),
      MenuItem(key: 'scan', label: 'Scan now'),
      MenuItem.separator(),
      MenuItem(key: 'quit', label: 'Quit'),
    ]));

    // 3) Close button hides to tray instead of quitting.
    windowManager.addListener(this);
    await windowManager.setPreventClose(true);

    // 4) Periodic re-scan while resident.
    _timer = Timer.periodic(const Duration(hours: 6), (_) => runOnce());
  }

  @override
  Future<void> runOnce() async {
    final scan = await _scan.run();
    // Desktop alert surface: reflect expiry summary in the tray tooltip.
    final expired = scan[TokenStatus.expired]?.length ?? 0;
    final soon = scan[TokenStatus.expiringSoon]?.length ?? 0;
    final noExpiry = scan[TokenStatus.noExpiry]?.length ?? 0;
    await trayManager.setToolTip(
      'TokenManager — expired:$expired soon:$soon no-expiry:$noExpiry',
    );
  }

  // --- Tray events ---
  @override
  void onTrayIconMouseDown() {
    windowManager.show();
    windowManager.focus();
  }

  @override
  void onTrayIconRightMouseDown() => trayManager.popUpContextMenu();

  @override
  void onTrayMenuItemClick(MenuItem menuItem) async {
    switch (menuItem.key) {
      case 'show':
        await windowManager.show();
        await windowManager.focus();
      case 'scan':
        await runOnce();
      case 'quit':
        _timer?.cancel();
        await trayManager.destroy();
        await windowManager.destroy();
    }
  }

  // --- Window events ---
  @override
  void onWindowClose() async {
    if (await windowManager.isPreventClose()) {
      await windowManager.hide();
    }
  }
}
