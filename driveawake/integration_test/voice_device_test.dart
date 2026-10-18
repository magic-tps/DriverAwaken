import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:driveawake/navigation/voice_assistant.dart';
import 'package:driveawake/services/voice_command_service.dart';
import 'package:driveawake/models/drowsiness_state.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  testWidgets(
    'device has usable Spanish TTS and speaks a detector alert',
    (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: Text('Prueba de voz DriverAwaken')),
        ),
      );
      final voice = VoiceAssistant(language: () => 'es');
      final spoke = await voice
          .say(
            'device_test',
            'Hola, soy tu copiloto. Podemos conversar y te avisaré cuando detecte señales de cansancio.',
            DateTime.now(),
            reply: true,
          )
          .timeout(const Duration(seconds: 40));
      expect(spoke, isTrue, reason: voice.status);
      voice.observeSafety(
        DrowsinessState.initial().copyWith(
          level: DrowsinessLevel.danger,
          eyesClosed: true,
        ),
        DateTime.now(),
      );
      await Future<void>.delayed(const Duration(milliseconds: 100));
      while (voice.speaking) {
        await Future<void>.delayed(const Duration(milliseconds: 200));
      }
      expect(voice.lastUtterance, contains('ojos'));
      await voice.stop();
      voice.dispose();
    },
    timeout: const Timeout(Duration(minutes: 2)),
  );

  testWidgets(
    'device speech service can prepare and cancel repeated listening turns',
    (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: Text('Prueba de micrófono DriverAwaken')),
        ),
      );
      final input = VoiceCommandService(language: () => 'es');
      for (var i = 0; i < 2; i++) {
        await input.listen(conversation: true, onCommand: (_) {});
        expect(
          input.state,
          VoiceListeningState.listening,
          reason: input.status,
        );
        await input.stop();
        expect(input.busy, isFalse);
      }
      input.dispose();
    },
    timeout: const Timeout(Duration(minutes: 2)),
  );
}
