// Google Drive auth (Android) — OAuth via google_sign_in, scoped to drive.file
// (non-sensitive, per-file access). Yields an authenticated DriveApi. The sync
// file lives in a visible "TokenManager" folder shared across all clients of
// the same Cloud project. No app backend.

import 'package:extension_google_sign_in_as_googleapis_auth/extension_google_sign_in_as_googleapis_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:googleapis/drive/v3.dart' as drive;

import 'drive_auth.dart';

class DriveAuthService implements DriveAuth {
  final GoogleSignIn _gsi =
      GoogleSignIn(scopes: const [drive.DriveApi.driveFileScope]);

  @override
  Future<bool> isSignedIn() => _gsi.isSignedIn();

  @override
  Future<String?> currentEmail() async =>
      (_gsi.currentUser ?? await _gsi.signInSilently())?.email;

  /// Interactive sign-in (reconnect): sign out first so the account chooser
  /// always appears and a fresh authorization is issued.
  @override
  Future<String?> signIn() async {
    await _gsi.signOut();
    return (await _gsi.signIn())?.email;
  }

  @override
  Future<void> signOut() => _gsi.signOut();

  /// Authenticated DriveApi, or null if not signed in. [interactive] triggers
  /// the consent UI when no cached session exists.
  @override
  Future<drive.DriveApi?> driveApi({bool interactive = false}) async {
    var account = _gsi.currentUser ?? await _gsi.signInSilently();
    if (account == null && interactive) account = await _gsi.signIn();
    if (account == null) return null;
    final client = await _gsi.authenticatedClient();
    if (client == null) return null;
    return drive.DriveApi(client);
  }
}
