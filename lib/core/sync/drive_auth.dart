// Platform-agnostic Google Drive auth surface. Android uses google_sign_in;
// desktop (Windows) uses a googleapis_auth loopback flow. Both yield an
// authenticated DriveApi scoped to drive.file.

import 'package:googleapis/drive/v3.dart' as drive;

abstract interface class DriveAuth {
  /// True if a usable (cached) session exists without prompting.
  Future<bool> isSignedIn();

  /// Account label (email) if known, else null.
  Future<String?> currentEmail();

  /// Interactive sign-in. Returns an account label, or null if cancelled.
  Future<String?> signIn();

  Future<void> signOut();

  /// Authenticated DriveApi, or null if not signed in. [interactive] triggers
  /// the consent UI when no cached session exists.
  Future<drive.DriveApi?> driveApi({bool interactive = false});
}
