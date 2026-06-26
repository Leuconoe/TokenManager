// Desktop (Windows) OAuth client — a "Desktop app" OAuth client ID/secret from
// the SAME Google Cloud project as the Android + extension clients (so the Drive
// "TokenManager" folder is shared). For installed/native apps the secret is not
// truly confidential (OAuth public client), but googleapis_auth requires it.
//
// Provide at build/run time so real values aren't committed:
//   flutter run -d windows \
//     --dart-define=TM_DESKTOP_OAUTH_CLIENT_ID=xxxx.apps.googleusercontent.com \
//     --dart-define=TM_DESKTOP_OAUTH_CLIENT_SECRET=xxxx
// See docs/06-setup/google-drive-sync.guide.md §3-C.
const desktopOAuthClientId =
    String.fromEnvironment('TM_DESKTOP_OAUTH_CLIENT_ID');
const desktopOAuthClientSecret =
    String.fromEnvironment('TM_DESKTOP_OAUTH_CLIENT_SECRET');
