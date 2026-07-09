import 'package:flutter/foundation.dart';

class ApiConstants {
  ApiConstants._();

  // Android emulator tidak dapat mengakses localhost host machine secara langsung.
  static String get baseUrl {
    if (kIsWeb)
      return 'https://backendprakmobile-production.up.railway.app/api';
    if (defaultTargetPlatform == TargetPlatform.android) {
      return 'https://backendprakmobile-production.up.railway.app/api';
    }
    return 'https://backendprakmobile-production.up.railway.app/api';
  }
}
