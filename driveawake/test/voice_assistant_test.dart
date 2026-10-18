import 'dart:async';

import 'package:driveawake/navigation/voice_assistant.dart';
import 'package:driveawake/models/drowsiness_state.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/services.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  test(
    'local TTS configures installed voice and speech audio on Android',
    () async {
      const channel = MethodChannel('flutter_tts');
      final calls = <MethodCall>[];
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(channel, (call) async {
            calls.add(call);
            if (call.method == 'getVoices') {
              return [
                {
                  'name': 'natural',
                  'locale': 'es-MX',
                  'network_required': false,
                  'quality': '500',
                },
              ];
            }
            return 1;
          });
      addTearDown(() {
        TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
            .setMockMethodCallHandler(channel, null);
      });
      final output = LocalVoiceOutput();
      expect(await output.configure('es'), isTrue);
      await output.speak('Hola, te escucho.');
      expect(calls.firstWhere((call) => call.method == 'setVoice').arguments, {
        'name': 'natural',
        'locale': 'es-MX',
      });
      expect(
        calls.any((call) => call.method == 'setAudioAttributesForNavigation'),
        isTrue,
      );
      expect(
        calls
            .firstWhere((call) => call.method == 'awaitSpeakCompletion')
            .arguments,
        isTrue,
      );
      final speech = calls
          .firstWhere((call) => call.method == 'speak')
          .arguments;
      // flutter_tts encodes Android speech as a map, other hosts as a string.
      expect(speech is Map ? speech['text'] : speech, 'Hola, te escucho.');
      await output.stop();
    },
  );
  test('speech failure permits an immediate retry', () async {
    final output = _Output()..failSpeech = true;
    final voice = VoiceAssistant(output: output, language: () => 'es');
    final now = DateTime(2026);
    expect(await voice.say('test', 'Hola', now), isFalse);
    output.failSpeech = false;
    expect(await voice.say('test', 'Hola', now), isTrue);
  });
  test(
    'higher quality Latin American offline voice wins over exact accent',
    () {
      expect(
        selectOfflineVoice([
          {
            'name': 'basic',
            'locale': 'es_PE',
            'network_required': false,
            'quality': '100',
          },
          {
            'name': 'natural',
            'locale': 'es-MX',
            'network_required': false,
            'quality': '500',
          },
          {
            'name': 'online',
            'locale': 'es-PE',
            'network_required': true,
            'quality': '1000',
          },
        ], 'es')?['name'],
        'natural',
      );
    },
  );
  test('warnings vary only after cooldown and danger takes priority', () async {
    final output = _Output();
    final voice = VoiceAssistant(output: output, language: () => 'es');
    final now = DateTime(2026);
    final warning = DrowsinessState.initial().copyWith(
      level: DrowsinessLevel.warning,
      yawning: true,
    );
    voice.observeSafety(warning, now);
    await Future<void>.delayed(Duration.zero);
    expect(output.spoken.single, contains('bostezos'));
    final first = output.spoken.single;
    voice.observeSafety(warning, now.add(const Duration(seconds: 10)));
    await Future<void>.delayed(Duration.zero);
    expect(output.spoken, hasLength(1));
    voice.observeSafety(warning, now.add(const Duration(seconds: 61)));
    await Future<void>.delayed(Duration.zero);
    expect(output.spoken.last, isNot(first));
    expect(output.spoken.last, contains('descansar'));
    voice.observeSafety(
      warning.copyWith(
        level: DrowsinessLevel.danger,
        eyesClosed: true,
        noFaceTooLong: true,
      ),
      now.add(const Duration(seconds: 62)),
    );
    await Future<void>.delayed(Duration.zero);
    expect(output.spoken.last, contains('ojos'));
    expect(output.spoken.last, contains('Detente'));
  });
  test('detector messages use English and explain loss of signal', () async {
    final output = _Output();
    final voice = VoiceAssistant(output: output, language: () => 'en');
    final now = DateTime(2026);
    final missing = DrowsinessState.initial().copyWith(noFaceTooLong: true);
    voice.observeSafety(missing, now);
    await Future<void>.delayed(Duration.zero);
    expect(output.spoken.single, contains('cannot see your face'));
    voice.observeSafety(missing, now.add(const Duration(seconds: 61)));
    await Future<void>.delayed(Duration.zero);
    expect(output.spoken.last, contains('cannot assess tiredness'));
  });
  test('offline selection prefers installed Latin American voices', () {
    final voice = selectOfflineVoice([
      {'name': 'network', 'locale': 'es-PE', 'network_required': true},
      {
        'name': 'missing',
        'locale': 'es-PE',
        'network_required': false,
        'features': 'notInstalled',
      },
      {'name': 'spain', 'locale': 'es-ES', 'network_required': '0'},
      {'name': 'mexico', 'locale': 'es-MX', 'network_required': 'false'},
    ], 'es');
    expect(voice?['name'], 'mexico');
    expect(selectOfflineVoice([], 'es'), isNull);
  });
  test(
    'spoken alerts default on and conversation replies bypass chatter cooldown',
    () async {
      final output = _Output();
      final voice = VoiceAssistant(output: output, language: () => 'es');
      final order = <String>[];
      voice.beforeSpeak = () async {
        order.add('microphone off');
      };
      final now = DateTime(2026);
      expect(voice.enabled, isTrue);
      await voice.say('chat', 'Hola', now, reply: true);
      await voice.say('chat', 'Te escucho', now, reply: true);
      expect(output.spoken, ['Hola', 'Te escucho']);
      expect(order.length, 2);
    },
  );
  test(
    'detector alerts interrupt chat and repeat sustained danger after 30 seconds',
    () async {
      final output = _Output()..speaking = Completer<void>();
      final voice = VoiceAssistant(output: output, language: () => 'es');
      final now = DateTime(2026);
      final chat = voice.say('chat', 'Charlemos', now, reply: true);
      await Future<void>.delayed(Duration.zero);
      final danger = DrowsinessState.initial().copyWith(
        level: DrowsinessLevel.danger,
        eyesClosed: true,
      );
      voice.observeSafety(danger, now);
      await Future<void>.delayed(Duration.zero);
      expect(voice.safetySpeaking, isTrue);
      expect(output.spoken.last, contains('ojos'));
      expect(await voice.say('chat', 'Otro dato', now, reply: true), isFalse);
      output.speaking!.complete();
      await chat;
      await Future<void>.delayed(Duration.zero);
      voice.observeSafety(danger, now.add(const Duration(seconds: 5)));
      await Future<void>.delayed(Duration.zero);
      expect(output.spoken.length, 2);
      voice.observeSafety(danger, now.add(const Duration(seconds: 31)));
      await Future<void>.delayed(Duration.zero);
      expect(output.spoken.length, 3);
    },
  );
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
  bool failSpeech = false;
  @override
  Future<bool> configure(String language) async {
    languages.add(language);
    return configuration == null ? available : configuration!.future;
  }

  @override
  Future<void> speak(String message) async {
    spoken.add(message);
    if (failSpeech) throw StateError('Speaker unavailable');
    await speaking?.future;
  }

  @override
  Future<void> stop() async {}
}
