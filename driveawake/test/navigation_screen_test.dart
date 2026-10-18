import 'package:driveawake/app/app_theme.dart';
import 'package:driveawake/models/drowsiness_state.dart';
import 'package:driveawake/navigation/smart_navigation.dart';
import 'package:driveawake/navigation/voice_assistant.dart';
import 'package:driveawake/screens/navigation_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:url_launcher/url_launcher.dart';

void main() {
  testWidgets('sustained fatigue displays a Smart Rest recommendation', (
    tester,
  ) async {
    final output = _VoiceOutput();
    final nav = SmartNavigation(
      launcher: (_, _) async => true,
      voice: VoiceAssistant(output: output, language: () => 'es'),
    );
    final warning = DrowsinessState.initial().copyWith(
      faceDetected: true,
      signalQuality: .9,
      level: DrowsinessLevel.warning,
    );
    final now = DateTime.utc(2026, 10, 18);
    nav.observe(warning, now, Duration.zero);
    nav.observe(
      warning,
      now.add(const Duration(seconds: 21)),
      const Duration(seconds: 21),
    );
    await tester.pumpWidget(
      MaterialApp(home: NavigationScreen(navigation: nav)),
    );
    await tester.pump();
    expect(find.text('SMART REST'), findsOneWidget);
    expect(find.textContaining('señales sostenidas'), findsOneWidget);
    expect(output.spoken.single, contains('cansancio'));
  });

  testWidgets('external search requires stopped confirmation and warning', (
    tester,
  ) async {
    final launched = <Uri>[];
    final nav = SmartNavigation(
      launcher: (uri, mode) async {
        expect(mode, LaunchMode.externalApplication);
        launched.add(uri);
        return true;
      },
    );
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.dark(),
        home: NavigationScreen(navigation: nav),
      ),
    );
    await tester.pump();
    expect(find.text('MONITOREO PAUSADO'), findsOneWidget);
    final cafe = find.widgetWithText(OutlinedButton, 'Cafeterías cercanas');
    expect(tester.widget<OutlinedButton>(cafe).onPressed, isNull);

    await tester.tap(find.byType(CheckboxListTile));
    await tester.pump();
    await tester.tap(cafe);
    await tester.pumpAndSettle();
    expect(
      find.textContaining('el monitoreo de DriverAwaken se pausará'),
      findsOneWidget,
    );
    await tester.tap(find.text('Continuar'));
    await tester.pumpAndSettle();
    expect(launched.single.queryParameters['query'], 'cafeterías cercanas');
  });

  testWidgets('destination opens official directions URL', (tester) async {
    Uri? launched;
    final nav = SmartNavigation(
      launcher: (uri, _) async {
        launched = uri;
        return true;
      },
    );
    await tester.pumpWidget(
      MaterialApp(home: NavigationScreen(navigation: nav)),
    );
    await tester.pump();
    await tester.tap(find.byType(CheckboxListTile));
    await tester.scrollUntilVisible(
      find.byType(TextField),
      250,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.enterText(
      find.byType(TextField),
      'Terminal terrestre Arequipa',
    );
    await tester.pump();
    await tester.scrollUntilVisible(
      find.text('Abrir navegación externa'),
      120,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.tap(find.text('Abrir navegación externa'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Continuar'));
    await tester.pumpAndSettle();
    expect(launched?.path, '/maps/dir/');
    expect(
      launched?.queryParameters['destination'],
      'Terminal terrestre Arequipa',
    );
  });
}

class _VoiceOutput implements VoiceOutput {
  final spoken = <String>[];
  @override
  Future<bool> configure(String language) async => true;
  @override
  Future<void> speak(String message) async => spoken.add(message);
  @override
  Future<void> stop() async {}
}
