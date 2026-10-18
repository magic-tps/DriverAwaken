import 'dart:async';
import 'package:flutter_test/flutter_test.dart';
import 'package:driveawake/services/voice_command_service.dart';

class FakeSpeechInput implements SpeechInput {
  void Function(String)? status;
  void Function(String)? error;
  void Function(String, bool)? result;
  int initializations = 0;
  int cancellations = 0;
  int listens = 0;
  bool listening = false;
  String? locale;
  @override
  Future<bool> initialize({
    required void Function(String) onStatus,
    required void Function(String) onError,
  }) async {
    initializations++;
    status ??= onStatus;
    error ??= onError;
    return true;
  }

  @override
  Future<List<VoiceLocale>> locales() async => [
    const VoiceLocale('es_PE'),
    const VoiceLocale('en_US'),
  ];
  @override
  Future<void> listen({
    required String locale,
    required void Function(String, bool) onResult,
  }) async {
    this.locale = locale;
    result = onResult;
    listening = true;
    listens++;
  }

  @override
  Future<void> cancel() async {
    cancellations++;
    listening = false;
  }

  void say(String words, {bool finalResult = true}) =>
      result!(words, finalResult);
}

Future<void> flush() => Future<void>.delayed(const Duration(milliseconds: 8));

void main() {
  test(
    'callbacks survive repeated turns and final free speech is delivered once',
    () async {
      final input = FakeSpeechInput();
      final service = VoiceCommandService(
        input: input,
        microphoneAllowed: () async => true,
        language: () => 'es',
        finalResultGrace: const Duration(milliseconds: 1),
      );
      final words = <String>[];
      await service.listen(onCommand: words.add, conversation: true);
      input.say('Cuéntame algo interesante');
      input.say('Cuéntame algo interesante');
      await flush();
      expect(words, ['Cuéntame algo interesante']);
      expect(input.listening, isFalse);
      await service.listen(onCommand: words.add, conversation: true);
      input.status!('done');
      await flush();
      expect(service.busy, isFalse);
      expect(service.state, VoiceListeningState.noSpeech);
      await service.listen(onCommand: words.add, conversation: true);
      input.error!('error_audio');
      expect(service.state, VoiceListeningState.error);
      expect(input.initializations, 1);
      await service.stop();
      service.dispose();
    },
  );
  test(
    'final result after done wins while partial resume is never executed',
    () async {
      final input = FakeSpeechInput();
      final service = VoiceCommandService(
        input: input,
        microphoneAllowed: () async => true,
        language: () => 'es',
        finalResultGrace: const Duration(milliseconds: 20),
      );
      final words = <String>[];
      await service.listen(onCommand: words.add);
      input.status!('done');
      input.say('pausar');
      await flush();
      expect(words, ['pausar']);
      await service.listen(onCommand: words.add);
      input.say('reanudar', finalResult: false);
      input.status!('notListening');
      await Future<void>.delayed(const Duration(milliseconds: 30));
      expect(words, ['pausar']);
      expect(service.busy, isFalse);
      await service.stop();
      service.dispose();
    },
  );
  test(
    'denied microphone and cancellation during permission check never listen',
    () async {
      final input = FakeSpeechInput();
      final permission = Completer<bool>();
      final service = VoiceCommandService(
        input: input,
        microphoneAllowed: () => permission.future,
      );
      final pending = service.listen(onCommand: (_) => fail('late result'));
      await service.stop();
      permission.complete(true);
      await pending;
      expect(input.listens, 0);
      service.dispose();
      final denied = VoiceCommandService(
        input: input,
        microphoneAllowed: () async => false,
      );
      await denied.listen(onCommand: (_) => fail('permission denied'));
      expect(denied.state, VoiceListeningState.error);
      expect(input.initializations, 0);
      denied.dispose();
    },
  );
  test(
    'English selection and stale results are isolated to their turn',
    () async {
      final input = FakeSpeechInput();
      final service = VoiceCommandService(
        input: input,
        microphoneAllowed: () async => true,
        language: () => 'en',
      );
      final words = <String>[];
      await service.listen(onCommand: words.add, conversation: true);
      final stale = input.result!;
      await service.stop();
      await service.listen(onCommand: words.add, conversation: true);
      stale('resume monitoring', true);
      input.say('hello');
      await flush();
      expect(words, ['hello']);
      expect(input.locale, 'en_US');
      await service.stop();
      service.dispose();
    },
  );
}
