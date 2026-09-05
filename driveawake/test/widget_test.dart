import 'dart:async';
import 'package:driveawake/screens/app_entry_screen.dart';
import 'package:driveawake/screens/login_screen.dart';
import 'package:driveawake/services/account_session.dart';
import 'package:driveawake/widgets/account_card.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('signed out launch shows login and allows local use', (
    tester,
  ) async {
    final session = _Session();
    await tester.pumpWidget(
      MaterialApp(
        home: AppEntryScreen(session: session, home: const Text('Dashboard')),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('Bienvenido de nuevo'), findsOneWidget);
    expect(find.text('Crear cuenta'), findsOneWidget);
    expect(find.text('Dashboard'), findsNothing);
    await tester.ensureVisible(find.text('Continuar sin cuenta'));
    await tester.tap(find.text('Continuar sin cuenta'));
    await tester.pumpAndSettle();
    expect(find.text('Dashboard'), findsOneWidget);
    expect(session.signInCalls, 0);
  });

  testWidgets('restored session opens dashboard', (tester) async {
    final session = _Session()..signedIn = true;
    await tester.pumpWidget(
      MaterialApp(
        home: AppEntryScreen(session: session, home: const Text('Dashboard')),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('Dashboard'), findsOneWidget);
  });

  testWidgets('guest can enter while account restoration is pending', (
    tester,
  ) async {
    final pending = Completer<void>();
    final session = _Session()..restore = pending.future;
    await tester.pumpWidget(
      MaterialApp(
        home: AppEntryScreen(session: session, home: const Text('Dashboard')),
      ),
    );
    await tester.tap(find.text('Continuar sin cuenta'));
    await tester.pump();
    expect(find.text('Dashboard'), findsOneWidget);
    pending.complete();
    await tester.pumpAndSettle();
    expect(find.text('Dashboard'), findsOneWidget);
  });

  testWidgets('valid login enters dashboard; empty fields never call auth', (
    tester,
  ) async {
    final session = _Session();
    await tester.pumpWidget(
      MaterialApp(
        home: AppEntryScreen(session: session, home: const Text('Dashboard')),
      ),
    );
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.byKey(const ValueKey('login-submit')));
    await tester.tap(find.byKey(const ValueKey('login-submit')));
    await tester.pump();
    expect(session.signInCalls, 0);
    expect(find.text('Introduce un correo válido.'), findsOneWidget);
    await tester.enterText(
      find.byKey(const ValueKey('login-email')),
      'test@example.com',
    );
    await tester.enterText(
      find.byKey(const ValueKey('login-password')),
      'test-password',
    );
    await tester.ensureVisible(find.byKey(const ValueKey('login-submit')));
    await tester.tap(find.byKey(const ValueKey('login-submit')));
    await tester.pumpAndSettle();
    expect(session.signInCalls, 1);
    expect(find.text('Dashboard'), findsOneWidget);
  });

  testWidgets(
    'registration checks confirmation and keeps login on network failure',
    (tester) async {
      final session = _Session()
        ..failure = FirebaseException(
          plugin: 'firebase_auth',
          code: 'network-request-failed',
        );
      var authenticated = false;
      await tester.pumpWidget(
        MaterialApp(
          home: LoginScreen(
            session: session,
            onAuthenticated: () {
              authenticated = true;
            },
          ),
        ),
      );
      await tester.tap(find.text('Crear cuenta'));
      await tester.pumpAndSettle();
      await tester.enterText(
        find.byKey(const ValueKey('login-email')),
        'test@example.com',
      );
      await tester.enterText(
        find.byKey(const ValueKey('login-password')),
        'password123',
      );
      await tester.enterText(
        find.byKey(const ValueKey('login-confirmation')),
        'different',
      );
      await tester.ensureVisible(find.byKey(const ValueKey('login-submit')));
      await tester.tap(find.byKey(const ValueKey('login-submit')));
      await tester.pump();
      expect(session.signInCalls, 0);
      expect(find.text('Las contraseñas no coinciden.'), findsOneWidget);
      await tester.enterText(
        find.byKey(const ValueKey('login-confirmation')),
        'password123',
      );
      await tester.ensureVisible(find.byKey(const ValueKey('login-submit')));
      await tester.tap(find.byKey(const ValueKey('login-submit')));
      await tester.pumpAndSettle();
      expect(authenticated, isFalse);
      expect(session.register, isTrue);
      expect(
        find.textContaining('No hay conexión con la nube.'),
        findsOneWidget,
      );
    },
  );

  testWidgets('account actions fit a narrow phone and have visible labels', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SizedBox(
            width: 330,
            child: AccountCard(email: null, onLogin: () {}, onCloud: () {}),
          ),
        ),
      ),
    );
    expect(find.text('Iniciar sesión / Crear cuenta'), findsOneWidget);
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SizedBox(
            width: 330,
            child: AccountCard(
              email: 'test@example.com',
              onLogin: () {},
              onCloud: () {},
            ),
          ),
        ),
      ),
    );
    expect(find.text('Subir informes a la nube'), findsOneWidget);
    expect(find.text('Sesión iniciada'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}

class _Session implements AccountSession {
  @override
  bool signedIn = false;
  Future<void>? restore;
  Object? failure;
  int signInCalls = 0;
  bool register = false;
  @override
  Future<void> initialize() async {
    await restore;
  }

  @override
  Future<void> resetPassword(String email) async {}
  @override
  Future<void> signIn(
    String email,
    String password, {
    required bool register,
  }) async {
    signInCalls++;
    this.register = register;
    if (failure != null) throw failure!;
    signedIn = true;
  }
}
