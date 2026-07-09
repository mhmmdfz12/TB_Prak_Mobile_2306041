import 'package:flutter/foundation.dart';

class ApiConstants {
  ApiConstants._();

  // Android emulator tidak dapat mengakses localhost host machine secara langsung.
  static String get baseUrl {
    if (kIsWeb) return 'http://localhost:3000/api';
    if (defaultTargetPlatform == TargetPlatform.android) {
      return 'http://10.0.2.2:3000/api';
    }
    return 'http://localhost:3000/api';
  }
}
