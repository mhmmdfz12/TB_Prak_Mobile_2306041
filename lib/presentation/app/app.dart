import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../pages/auth/splash_page.dart';

class UasCommerceApp extends StatefulWidget {
  const UasCommerceApp({super.key, required this.prefs});

  final SharedPreferences prefs;

  static UasCommerceAppState of(BuildContext context) {
    return context.findAncestorStateOfType<UasCommerceAppState>()!;
  }

  @override
  State<UasCommerceApp> createState() => UasCommerceAppState();
}

class UasCommerceAppState extends State<UasCommerceApp> {
  bool darkMode = false;

  @override
  void initState() {
    super.initState();
    darkMode = widget.prefs.getBool('dark_mode') ?? false;
  }

  Future<void> setDarkMode(bool value) async {
    setState(() => darkMode = value);
    await widget.prefs.setBool('dark_mode', value);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'TB_2306041',
      themeMode: darkMode ? ThemeMode.dark : ThemeMode.light,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepOrange),
        scaffoldBackgroundColor: const Color(0xfff7f7f8),
      ),
      darkTheme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.deepOrange,
          brightness: Brightness.dark,
        ),
      ),
      home: SplashPage(prefs: widget.prefs),
    );
  }
}
