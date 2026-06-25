// Design Ref: §F2 / §6 (E-NOTE-01) — non-blocking token-pattern warning.
// Detection only triggers a confirm dialog; it NEVER blocks the save.

import 'dart:math';

class NoteTokenDetector {
  /// Known token/secret prefixes (GitHub, OpenAI, Slack, AWS, Google, JWT).
  static final List<RegExp> _knownPrefixes = [
    RegExp(r'gh[posru]_[A-Za-z0-9]{20,}'), // ghp_/gho_/ghs_/ghu_/ghr_
    RegExp(r'github_pat_[A-Za-z0-9_]{20,}'),
    RegExp(r'sk-[A-Za-z0-9]{20,}'), // OpenAI
    RegExp(r'xox[baprs]-[A-Za-z0-9-]{10,}'), // Slack
    RegExp(r'AKIA[0-9A-Z]{16}'), // AWS access key id
    RegExp(r'AIza[0-9A-Za-z\-_]{35}'), // Google API key
    RegExp(r'eyJ[A-Za-z0-9_-]{8,}\.[A-Za-z0-9_-]{8,}\.[A-Za-z0-9_-]{8,}'), // JWT
  ];

  static final RegExp _contiguous = RegExp(r'[A-Za-z0-9+/=_\-]{32,}');

  /// True if [note] appears to contain a token/secret. Advisory only.
  static bool looksLikeToken(String note) {
    if (note.isEmpty) return false;
    if (_knownPrefixes.any((re) => re.hasMatch(note))) return true;

    // High-entropy contiguous run (≥32 chars) → likely a key/secret blob.
    for (final m in _contiguous.allMatches(note)) {
      final s = m.group(0)!;
      if (_shannonEntropy(s) >= 3.5) return true;
    }
    return false;
  }

  static double _shannonEntropy(String s) {
    final counts = <int, int>{};
    for (final u in s.codeUnits) {
      counts[u] = (counts[u] ?? 0) + 1;
    }
    final n = s.length;
    var e = 0.0;
    for (final c in counts.values) {
      final p = c / n;
      e -= p * (log(p) / ln2);
    }
    return e;
  }
}
