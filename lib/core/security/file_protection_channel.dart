import 'package:flutter/services.dart';

class FileProtectionChannel {
  static const _channel = MethodChannel('com.vaultofus.security/file_protection');

  /// Aplica NSFileProtection no iOS. Falha silenciosamente em outras plataformas.
  static Future<bool> setProtection(String filePath, {bool sensitive = true}) async {
    try {
      final result = await _channel.invokeMethod('setFileProtection', {
        'filePath': filePath,
        'protectionLevel': sensitive ? 'complete' : 'completeUntilFirstUserAuthentication',
      });
      return result == true;
    } catch (e) {
      return false;
    }
  }
}
