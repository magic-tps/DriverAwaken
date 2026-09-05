import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import '../screens/home_screen.dart';
import 'app_config.dart';
import 'app_theme.dart';

final scaffoldMessengerKey = GlobalKey<ScaffoldMessengerState>();

class AppConductoresApp extends StatelessWidget {
  const AppConductoresApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: AppConfig.productName,
      scaffoldMessengerKey: scaffoldMessengerKey,
      debugShowCheckedModeBanner: false,
      themeMode: ThemeMode.dark,
      locale: AppConfig.locale,
      supportedLocales: const <Locale>[AppConfig.locale],
      localizationsDelegates: GlobalMaterialLocalizations.delegates,
      theme: AppTheme.dark(),
      highContrastTheme: AppTheme.dark(highContrast: true),
      home: const HomeScreen(),
    );
  }
}
