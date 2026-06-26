// win-3+ — desktop launch-at-login control (Windows registry Run key etc.).
// Wraps launch_at_startup; only meaningful on desktop platforms.

import 'dart:io' show Platform;

import 'package:launch_at_startup/launch_at_startup.dart';
import 'package:package_info_plus/package_info_plus.dart';

class AutoStartService {
  bool _setup = false;

  Future<void> _ensureSetup() async {
    if (_setup) return;
    final info = await PackageInfo.fromPlatform();
    launchAtStartup.setup(
      appName: info.appName,
      appPath: Platform.resolvedExecutable,
      args: ['--minimized'],
    );
    _setup = true;
  }

  Future<bool> isEnabled() async {
    await _ensureSetup();
    return launchAtStartup.isEnabled();
  }

  Future<void> enable() async {
    await _ensureSetup();
    await launchAtStartup.enable();
  }

  Future<void> disable() async {
    await _ensureSetup();
    await launchAtStartup.disable();
  }
}
