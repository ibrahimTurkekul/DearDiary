import 'package:flutter/services.dart';
import 'package:local_auth/local_auth.dart';

class FingerprintService {
  final LocalAuthentication _localAuth = LocalAuthentication();

  // Cihazda biyometrik doğrulamanın mevcut olup olmadığını kontrol et
  Future<bool> isBiometricAvailable() async {
    try {
      return await _localAuth.canCheckBiometrics;
    } on PlatformException catch (e) {
      print('Biometric availability check failed: $e');
      return false;
    }
  }

  // Parmak izi doğrulama
  Future<bool> authenticateWithFingerprint() async {
    try {
      return await _localAuth.authenticate(
        localizedReason: 'Kilit açmak için parmak izinizi kullanın',
        options: const AuthenticationOptions(
          biometricOnly: true,
        ),
      );
    } on PlatformException catch (e) {
      print('Fingerprint authentication failed: $e');
      return false;
    }
  }
}