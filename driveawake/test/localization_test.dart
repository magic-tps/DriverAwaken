import 'package:driveawake/app/app.dart';
import 'package:driveawake/l10n/app_strings.dart';
import 'package:driveawake/l10n/locale_controller.dart';
import 'package:driveawake/l10n/localized_text.dart';
import 'package:driveawake/l10n/messages.dart';
import 'package:driveawake/screens/login_screen.dart';
import 'package:driveawake/screens/privacy_policy_screen.dart';
import 'package:driveawake/services/account_session.dart';
import 'package:driveawake/widgets/account_card.dart';
import 'package:driveawake/widgets/language_selector.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

class _Session implements AccountSession {
  @override
  bool get signedIn => false;
  @override
  Future<void> initialize() async {}
  @override
  Future<void> resetPassword(String email) async {}
  @override
  Future<void> signIn(
    String email,
    String password, {
    required bool register,
  }) async {}
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    SharedPreferences.setMockInitialValues({
      LocaleController.preferenceKey: 'es',
    });
    await LocaleController.instance.initialize();
  });

  test(
    'language preference survives a new controller and resolves device locale',
    () async {
      await LocaleController.instance.select('en');
      final restored = LocaleController();
      await restored.initialize();
      expect(restored.locale, const Locale('en'));
      await restored.select('system');
      expect(restored.locale, isNull);
      expect(
        LocaleController.resolve([const Locale('en', 'GB')]),
        const Locale('en'),
      );
      expect(
        LocaleController.resolve([const Locale('es', 'PE')]),
        const Locale('es'),
      );
      expect(
        LocaleController.resolve([const Locale('fr'), const Locale('en')]),
        const Locale('en'),
      );
      expect(
        LocaleController.resolve([const Locale('fr')]),
        const Locale('es'),
      );
      await expectLater(restored.select('unsupported'), throwsArgumentError);
      restored.dispose();
    },
  );

  test(
    'catalog preserves every placeholder and translates dynamic messages',
    () {
      final slots = RegExp(r'\{\d+\}');
      const english = AppStrings('en');
      for (final entry in englishMessages.entries) {
        final sourceSlots = slots
            .allMatches(entry.key)
            .map((m) => m[0])
            .toSet();
        expect(
          slots.allMatches(entry.value).map((m) => m[0]).toSet(),
          sourceSlots,
          reason: entry.key,
        );
        final rendered = entry.key.replaceAllMapped(
          slots,
          (m) => 'value${m[0]!.replaceAll(RegExp(r'\D'), '')}',
        );
        final expected = entry.value.replaceAllMapped(
          slots,
          (m) => 'value${m[0]!.replaceAll(RegExp(r'\D'), '')}',
        );
        expect(english.translate(rendered), expected, reason: entry.key);
      }
      expect(
        english.translate('Cuidado: Ojos cerrados y cabeza caida'),
        'Caution: Eyes closed and head drooping',
      );
      expect(
        english.translate(
          'Subida confirmada: 3 informes guardados en tu cuenta.',
        ),
        'Upload confirmed: 3 reports saved to your account.',
      );
      expect(english.translate('OJOS'), 'EYES');
      expect(english.translate('owner@example.com'), 'owner@example.com');
      expect(english.translate('trip_123'), 'trip_123');
      expect(const AppStrings('es').translate('PELIGRO'), 'PELIGRO');
    },
  );

  testWidgets(
    'selector translates login in place, preserving entered data and validation',
    (tester) async {
      await tester.pumpWidget(
        AppConductoresApp(
          home: LoginScreen(
            session: _Session(),
            onAuthenticated: () {},
            onGuest: () {},
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('Bienvenido de nuevo'), findsOneWidget);
      await tester.enterText(
        find.byKey(const ValueKey('login-email')),
        'owner@example.com',
      );
      await tester.ensureVisible(find.byType(LanguageSelector));
      await tester.tap(find.byType(DropdownButtonFormField<String>));
      await tester.pumpAndSettle();
      await tester.tap(find.text('English').last);
      await tester.pumpAndSettle();
      expect(find.text('Welcome back'), findsOneWidget);
      expect(find.text('Email address'), findsOneWidget);
      expect(find.text('owner@example.com'), findsOneWidget);
      expect(LocaleController.instance.selection, 'en');
      await tester.ensureVisible(find.byKey(const ValueKey('login-submit')));
      await tester.tap(find.byKey(const ValueKey('login-submit')));
      await tester.pumpAndSettle();
      expect(find.text('Enter your password.'), findsOneWidget);
      await LocaleController.instance.select('es');
      await tester.pumpAndSettle();
      expect(find.text('Introduce tu contraseña.'), findsOneWidget);
      expect(find.text('owner@example.com'), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'locale changes preserve the active route and translate constant privacy sections',
    (tester) async {
      await tester.pumpWidget(
        AppConductoresApp(
          home: Builder(
            builder: (context) => Scaffold(
              body: TextButton(
                onPressed: () => Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (_) => const PrivacyPolicyScreen(),
                  ),
                ),
                child: const Text('Open privacy'),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.text('Open privacy'));
      await tester.pumpAndSettle();
      await LocaleController.instance.select('en');
      await tester.pumpAndSettle();
      expect(find.byType(PrivacyPolicyScreen), findsOneWidget);
      expect(find.text('Privacy'), findsOneWidget);
      expect(find.text('Preliminary privacy notice'), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );

  for (final language in ['es', 'en']) {
    testWidgets('account and safety messages fit a narrow phone in $language', (
      tester,
    ) async {
      await tester.binding.setSurfaceSize(const Size(330, 780));
      addTearDown(() => tester.binding.setSurfaceSize(null));
      await LocaleController.instance.select(language);
      await tester.pumpWidget(
        AppConductoresApp(
          home: Scaffold(
            body: ListView(
              children: [
                AccountCard(
                  email: 'owner@example.com',
                  onLogin: () {},
                  onCloud: () {},
                ),
                const LocalizedText(
                  'No se están recibiendo datos confiables.\nDetente en un lugar seguro y revisa la cámara.',
                ),
                const LocalizedText('DETENTE Y DESCANSA'),
              ],
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(
        find.text(
          language == 'en'
              ? 'Upload reports to the cloud'
              : 'Subir informes a la nube',
        ),
        findsOneWidget,
      );
      expect(
        find.text(language == 'en' ? 'STOP AND REST' : 'DETENTE Y DESCANSA'),
        findsOneWidget,
      );
      expect(tester.takeException(), isNull);
    });
  }
}
