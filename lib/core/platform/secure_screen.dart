// Toggles Android FLAG_SECURE (blocks screenshots / recents thumbnail) at
// runtime via a MethodChannel to MainActivity. No-op on non-Android platforms.

import 'dart:io';

import 'package:flutter/services.dart';

class SecureScreen {
  static const _channel = MethodChannel('sw2.io.tokenmanager/secure');

  /// Applies the FLAG_SECURE preference. Android-only; silently ignored
  /// elsewhere or if the platform call fails.
  static Future<void> apply(bool secure) async {
    if (!Platform.isAndroid) return;
    try {
      await _channel.invokeMethod<void>('setSecure', secure);
    } on PlatformException {
      // Best-effort; the native default (secure) already applied in onCreate.
    } on MissingPluginException {
      // Channel not wired (e.g. during tests) — ignore.
    }
  }
}
