// Google Drive auth for desktop (Windows) via a googleapis_auth loopback flow:
// opens the system browser, the user consents, Google redirects to a transient
// localhost server. Credentials (incl. refresh token) are cached in secure
// storage (DPAPI) so later syncs refresh silently. Scoped to drive.file.

import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:googleapis/drive/v3.dart' as drive;
import 'package:googleapis_auth/auth_io.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';

import '../debug/debug_log.dart';
import 'desktop_oauth_config.dart';
import 'drive_auth.dart';

class DesktopDriveAuthService implements DriveAuth {
  static const _credKey = 'tm_desktop_drive_creds_v1';
  static const _scopes = [drive.DriveApi.driveFileScope];

  final FlutterSecureStorage _store;
  DesktopDriveAuthService([FlutterSecureStorage? store])
      : _store = store ?? const FlutterSecureStorage();

  ClientId get _clientId =>
      ClientId(desktopOAuthClientId, desktopOAuthClientSecret);

  @override
  Future<bool> isSignedIn() async => (await _loadCreds()) != null;

  @override
  Future<String?> currentEmail() async =>
      (await isSignedIn()) ? 'Google Drive' : null;

  @override
  Future<String?> signIn() async {
    final api = await driveApi(interactive: true);
    return api == null ? null : 'Google Drive';
  }

  @override
  Future<void> signOut() => _store.delete(key: _credKey);

  @override
  Future<drive.DriveApi?> driveApi({bool interactive = false}) async {
    final saved = await _loadCreds();
    if (saved != null) {
      dlog('desktop-auth: using saved credentials');
      final client = autoRefreshingClient(_clientId, saved, http.Client());
      client.credentialUpdates.listen(_saveCreds);
      return drive.DriveApi(client);
    }
    if (!interactive) {
      dlog('desktop-auth: no creds, non-interactive -> null');
      return null;
    }
    if (desktopOAuthClientId.isEmpty) {
      dlog('desktop-auth: client id NOT configured (dart-define missing)');
      throw StateError('desktop-oauth-not-configured');
    }
    dlog('desktop-auth: starting browser consent (loopback)…');
    try {
      final client = await clientViaUserConsent(_clientId, _scopes, (url) {
        dlog('desktop-auth: opening browser for consent');
        launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
      });
      await _saveCreds(client.credentials);
      client.credentialUpdates.listen(_saveCreds);
      dlog('desktop-auth: consent OK, credentials saved');
      return drive.DriveApi(client);
    } catch (e) {
      dlog('desktop-auth: consent ERROR $e');
      rethrow;
    }
  }

  Future<void> _saveCreds(AccessCredentials c) async {
    final json = jsonEncode({
      'type': c.accessToken.type,
      'data': c.accessToken.data,
      'expiry': c.accessToken.expiry.toUtc().toIso8601String(),
      'refresh': c.refreshToken,
      'idToken': c.idToken,
      'scopes': c.scopes,
    });
    await _store.write(key: _credKey, value: json);
  }

  Future<AccessCredentials?> _loadCreds() async {
    final raw = await _store.read(key: _credKey);
    if (raw == null) return null;
    try {
      final m = jsonDecode(raw) as Map<String, dynamic>;
      return AccessCredentials(
        AccessToken(
          m['type'] as String,
          m['data'] as String,
          DateTime.parse(m['expiry'] as String).toUtc(),
        ),
        m['refresh'] as String?,
        (m['scopes'] as List).cast<String>(),
        idToken: m['idToken'] as String?,
      );
    } catch (_) {
      return null; // corrupt — treat as signed out
    }
  }
}
