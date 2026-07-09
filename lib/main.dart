import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'core/services/notification_service.dart';
import 'presentation/app/app.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Inisialisasi service global sebelum aplikasi dijalankan.
  await NotificationService.init();
  final prefs = await SharedPreferences.getInstance();

  runApp(UasCommerceApp(prefs: prefs));
}
