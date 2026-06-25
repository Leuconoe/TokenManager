// Design Ref: §F4 / §6 (E-AUTH-01) — biometric / device-credential gate.

import 'package:local_auth/local_auth.dart';

class BiometricService {
  final LocalAuthentication _auth;
  BiometricService([LocalAuthentication? auth])
      : _auth = auth ?? LocalAuthentication();

  /// Whether the device CAN gate the app — true only if a secure lock exists
  /// (biometric enrolled OR device credential PIN/pattern/password set).
  /// On a device with no screen lock, isDeviceSupported() returns false, so we
  /// skip the lock gate entirely (can't lock what the OS can't secure).
  Future<bool> canAuthenticate() async {
    try {
      return await _auth.isDeviceSupported();
    } catch (_) {
      return false;
    }
  }

  /// Prompts for auth. Returns true on success, false on cancel/failure.
  /// biometricOnly:false → falls back to device PIN when biometrics absent.
  Future<bool> authenticate({required String reason}) async {
    try {
      return await _auth.authenticate(
        localizedReason: reason,
        options: const AuthenticationOptions(
          stickyAuth: true,
          biometricOnly: false,
        ),
      );
    } catch (_) {
      return false;
    }
  }
}
