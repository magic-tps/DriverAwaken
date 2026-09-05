import 'package:driveawake/screens/privacy_policy_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('privacy notice is honest about pending legal identity', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        locale: Locale('es'),
        supportedLocales: <Locale>[Locale('es')],
        localizationsDelegates: GlobalMaterialLocalizations.delegates,
        home: PrivacyPolicyScreen(),
      ),
    );

    expect(find.text('Aviso preliminar de privacidad'), findsOneWidget);
    expect(find.text('No es una politica definitiva'), findsOneWidget);
    await tester.scrollUntilVisible(find.text('Responsable pendiente'), 300);
    expect(find.text('Responsable pendiente'), findsOneWidget);
  });
}
