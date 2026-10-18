import 'dart:async';

import 'package:driveawake/navigation/voice_assistant.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test(
    'pause cancels speech waiting for offline engine configuration',
    () async {
      final output = _Output()..configuration = Completer<bool>();
      final voice = VoiceAssistant(output: output, language: () => 'es')
        ..enabled = true;
      final pending = voice.say('WARNING', 'Pausa segura', DateTime(2026));
      await Future<void>.delayed(Duration.zero);
      await voice.stop();
      output.configuration!.complete(true);
      await pending;
      expect(output.spoken, isEmpty);
    },
  );

  test(
    'critical speech bypasses global cooldown and cancels lower priority',
    () async {
      final output = _Output()..speaking = Completer<void>();
      final voice = VoiceAssistant(output: output, language: () => 'es')
        ..enabled = true;
      final now = DateTime(2026);
      final first = voice.say('BREAK', 'Descanso', now);
      await Future<void>.delayed(Duration.zero);
      final critical = voice.say('DANGER', 'Detente', now, critical: true);
      await Future<void>.delayed(Duration.zero);
      await voice.say('OTHER', 'No interrumpir', now);
      expect(output.spoken, ['Descanso', 'Detente']);
      output.speaking!.complete();
      await Future.wait([first, critical]);
      await voice.say(
        'DANGER',
        'Detente otra vez',
        now.add(const Duration(seconds: 10)),
        critical: true,
      );
      expect(output.spoken.length, 2);
    },
  );

  test('selected English locale translates the safety message', () async {
    final output = _Output();
    final voice = VoiceAssistant(output: output, language: () => 'en')
      ..enabled = true;
    await voice.say(
      'TEST',
      'Busca un lugar seguro para detenerte.',
      DateTime(2026),
    );
    expect(output.languages, ['en']);
    expect(output.spoken, ['Find a safe place to stop.']);
  });

  test(
    'missing offline voice remains recoverable without consuming cooldown',
    () async {
      final output = _Output()..available = false;
      final voice = VoiceAssistant(output: output, language: () => 'es')
        ..enabled = true;
      await voice.say('TEST', 'Pausa', DateTime(2026));
      expect(output.spoken, isEmpty);
      output.available = true;
      await voice.say('TEST', 'Pausa', DateTime(2026));
      expect(output.spoken, ['Pausa']);
    },
  );

  test('disabling voice invalidates pending speech', () async {
    final output = _Output()..configuration = Completer<bool>();
    final voice = VoiceAssistant(output: output, language: () => 'es')
      ..enabled = true;
    final pending = voice.say('TEST', 'Pausa', DateTime(2026));
    await Future<void>.delayed(Duration.zero);
    voice.enabled = false;
    output.configuration!.complete(true);
    await pending;
    expect(output.spoken, isEmpty);
  });
}

class _Output implements VoiceOutput {
  final spoken = <String>[];
  final languages = <String>[];
  Completer<bool>? configuration;
  Completer<void>? speaking;
  bool available = true;
  @override
  Future<bool> configure(String language) async {
    languages.add(language);
    return configuration == null ? available : configuration!.future;
  }

  @override
  Future<void> speak(String message) async {
    spoken.add(message);
    await speaking?.future;
  }

  @override
  Future<void> stop() async {}
}
