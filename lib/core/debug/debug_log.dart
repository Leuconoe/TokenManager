// In-memory capped debug log, surfaced in Settings → Debug log. Usable from
// non-widget code (services) via the top-level dlog(). Not persisted (the app
// stays alive across the desktop OAuth browser round-trip).

import 'package:flutter/foundation.dart';

class DebugLog {
  DebugLog._();
  static final DebugLog instance = DebugLog._();

  static const _cap = 200;
  final ValueNotifier<List<String>> entries = ValueNotifier<List<String>>([]);

  void log(String message) {
    final ts = DateTime.now().toIso8601String();
    final line = '${ts.substring(11, 19)}  $message';
    final next = [...entries.value, line];
    if (next.length > _cap) next.removeRange(0, next.length - _cap);
    entries.value = next;
    if (kDebugMode) debugPrint('[dlog] $message');
  }

  void clear() => entries.value = [];
}

/// Append a line to the in-app debug log.
void dlog(String message) => DebugLog.instance.log(message);
