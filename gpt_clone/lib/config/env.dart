import 'dart:io' show Platform;

import 'package:flutter/foundation.dart' show kIsWeb;

class Env {
  Env._();

  static const String _override = String.fromEnvironment('API_BASE_URL');

  // Emulador Android acessa o host pelo IP especial 10.0.2.2.
  static const String androidBaseUrl = 'http://10.0.2.2:8080';
  static const String iosBaseUrl = 'http://localhost:8080';

  static String get baseUrl {
    if (_override.isNotEmpty) return _override;
    if (kIsWeb) return iosBaseUrl;
    if (Platform.isAndroid) return androidBaseUrl;
    return iosBaseUrl;
  }
}
