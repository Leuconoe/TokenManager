// Manual update check against the GitHub releases API. Network is used ONLY
// here, on explicit user action; no token data is ever transmitted.

import 'dart:convert';
import 'dart:io';

import 'package:package_info_plus/package_info_plus.dart';

class UpdateInfo {
  final bool hasUpdate;
  final String current;
  final String latest; // '' if not resolvable
  final String url;
  const UpdateInfo({
    required this.hasUpdate,
    required this.current,
    required this.latest,
    required this.url,
  });
}

class UpdateService {
  static const _api =
      'https://api.github.com/repos/Leuconoe/TokenManager/releases/latest';

  Future<UpdateInfo> check() async {
    final current = (await PackageInfo.fromPlatform()).version;
    final client = HttpClient();
    try {
      final req = await client.getUrl(Uri.parse(_api));
      req.headers.set(HttpHeaders.acceptHeader, 'application/vnd.github+json');
      req.headers.set(HttpHeaders.userAgentHeader, 'TokenManager');
      final resp = await req.close();
      if (resp.statusCode != 200) {
        return UpdateInfo(hasUpdate: false, current: current, latest: '', url: '');
      }
      final body = await resp.transform(utf8.decoder).join();
      final json = jsonDecode(body) as Map<String, dynamic>;
      final name = '${json['name'] ?? ''} ${json['tag_name'] ?? ''}';
      final latest = RegExp(r'(\d+)\.(\d+)\.(\d+)').firstMatch(name)?.group(0) ?? '';
      final url = (json['html_url'] ?? '').toString();
      return UpdateInfo(
        hasUpdate: latest.isNotEmpty && _isNewer(latest, current),
        current: current,
        latest: latest,
        url: url,
      );
    } finally {
      client.close(force: true);
    }
  }

  /// true if [a] > [b] (semver x.y.z).
  static bool _isNewer(String a, String b) {
    final pa = a.split('.').map((e) => int.tryParse(e) ?? 0).toList();
    final pb = b.split('.').map((e) => int.tryParse(e) ?? 0).toList();
    for (var i = 0; i < 3; i++) {
      final x = i < pa.length ? pa[i] : 0;
      final y = i < pb.length ? pb[i] : 0;
      if (x != y) return x > y;
    }
    return false;
  }
}
