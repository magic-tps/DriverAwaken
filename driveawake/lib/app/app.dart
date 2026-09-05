import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import '../screens/app_entry_screen.dart';
import '../l10n/app_strings.dart';
import '../l10n/locale_controller.dart';
import 'app_config.dart';
import 'app_theme.dart';

final scaffoldMessengerKey = GlobalKey<ScaffoldMessengerState>();

class AppConductoresApp extends StatelessWidget {
  const AppConductoresApp({super.key, this.home});
  final Widget? home;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: LocaleController.instance,
      builder: (context, _) => MaterialApp(
        title: AppConfig.productName,
        scaffoldMessengerKey: scaffoldMessengerKey,
        debugShowCheckedModeBanner: false,
        themeMode: ThemeMode.dark,
        locale: LocaleController.instance.locale,
        supportedLocales: LocaleController.supportedLocales,
        localeListResolutionCallback: (locales, _) =>
            LocaleController.resolve(locales),
        localizationsDelegates: const [
          AppStrings.delegate,
          ...GlobalMaterialLocalizations.delegates,
        ],
        theme: AppTheme.dark(),
        highContrastTheme: AppTheme.dark(highContrast: true),
        home: home ?? const AppEntryScreen(),
      ),
    );
  }
}
