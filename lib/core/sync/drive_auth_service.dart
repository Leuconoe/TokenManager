// Google Drive auth (Android) — OAuth via google_sign_in, scoped to the hidden
// appDataFolder only. Yields an authenticated DriveApi. No app backend.

import 'package:extension_google_sign_in_as_googleapis_auth/extension_google_sign_in_as_googleapis_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:googleapis/drive/v3.dart' as drive;

class DriveAuthService {
  final GoogleSignIn _gsi =
      GoogleSignIn(scopes: const [drive.DriveApi.driveAppdataScope]);

  Future<bool> isSignedIn() => _gsi.isSignedIn();

  Future<String?> currentEmail() async =>
      (_gsi.currentUser ?? await _gsi.signInSilently())?.email;

  /// Interactive sign-in. Returns the account email or null if cancelled.
  Future<String?> signIn() async => (await _gsi.signIn())?.email;

  Future<void> signOut() => _gsi.signOut();

  /// Authenticated DriveApi, or null if not signed in. [interactive] triggers
  /// the consent UI when no cached session exists.
  Future<drive.DriveApi?> driveApi({bool interactive = false}) async {
    var account = _gsi.currentUser ?? await _gsi.signInSilently();
    if (account == null && interactive) account = await _gsi.signIn();
    if (account == null) return null;
    final client = await _gsi.authenticatedClient();
    if (client == null) return null;
    return drive.DriveApi(client);
  }
}
