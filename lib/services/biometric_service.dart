import 'package:local_auth/local_auth.dart';
import 'package:flutter/services.dart';

class BiometricService {
  static final _auth = LocalAuthentication();

  static Future<bool> hasBiometrics() async {
    try {
      return await _auth.canCheckBiometrics || await _auth.isDeviceSupported();
    } on PlatformException {
      return false;
    }
  }

  static Future<bool> authenticate() async {
    final isAvailable = await hasBiometrics();
    if (!isAvailable) return true; // If device doesn't support biometrics, bypass

    try {
      return await _auth.authenticate(
        localizedReason: 'Scan your fingerprint (or face) to secure your financial data',
      );
    } on PlatformException {
      return false;
    }
  }
}
