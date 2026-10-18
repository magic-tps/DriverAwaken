import 'dart:async';
import 'package:flutter_test/flutter_test.dart';
import 'package:driveawake/navigation/copilot_conversation.dart';
import 'package:driveawake/navigation/conversation_engine.dart';
import 'package:driveawake/navigation/voice_assistant.dart';
import 'package:driveawake/models/drowsiness_state.dart';
import 'package:driveawake/services/voice_command_service.dart';
import 'voice_input_test.dart' show FakeSpeechInput, flush;

class _Voice implements VoiceOutput {
  final spoken = <String>[];
  Completer<void>? pending;
  @override
  Future<bool> configure(String language) async => true;
  @override
  Future<void> speak(String message) async {
    spoken.add(message);
    pending = Completer<void>();
    await pending!.future;
  }

  @override
  Future<void> stop() async {
    finish();
  }

  void finish() {
    if (pending != null && !pending!.isCompleted) pending!.complete();
  }
}

void main() {
  test(
    'multiple real recognition turns alternate with speech and end on silence',
    () async {
      final mic = FakeSpeechInput();
      final input = VoiceCommandService(
        input: mic,
        microphoneAllowed: () async => true,
        language: () => 'es',
      );
      final output = _Voice();
      final voice = VoiceAssistant(output: output, language: () => 'es');
      final controller = CopilotConversation(
        voice: voice,
        input: input,
        context: () => ConversationContext(
          monitoring: DrowsinessState.initial(),
          paused: true,
          reliable: false,
          driving: Duration.zero,
        ),
        onAction: (_) async {},
        language: () => 'es',
        echoGuard: Duration.zero,
      );
      final started = controller.start();
      await flush();
      expect(voice.speaking, isTrue);
      expect(mic.listening, isFalse);
      output.finish();
      await started;
      await flush();
      expect(mic.listening, isTrue);
      mic.say('Cuéntame algo interesante');
      await flush();
      expect(mic.listening, isFalse);
      expect(output.spoken.last, contains('pulpo'));
      output.finish();
      await flush();
      expect(mic.listening, isTrue);
      mic.say('No sabía eso');
      await flush();
      expect(output.spoken.last, contains('otra curiosidad'));
      output.finish();
      await flush();
      mic.error!('error_speech_timeout');
      expect(controller.active, isFalse);
      expect(voice.enabled, isTrue);
      controller.dispose();
      await flush();
      expect(controller.messages, isEmpty);
      input.dispose();
    },
  );
  test(
    'critical alert interrupts a reply, cancels microphone and retains the alarm state',
    () async {
      final mic = FakeSpeechInput();
      final input = VoiceCommandService(
        input: mic,
        microphoneAllowed: () async => true,
        language: () => 'es',
      );
      final output = _Voice();
      final voice = VoiceAssistant(output: output, language: () => 'es');
      var state = DrowsinessState.initial();
      final actions = <VoiceCommand>[];
      final controller = CopilotConversation(
        voice: voice,
        input: input,
        context: () => ConversationContext(
          monitoring: state,
          paused: false,
          reliable: true,
          driving: Duration.zero,
        ),
        onAction: (action) async {
          actions.add(action);
        },
        language: () => 'es',
        echoGuard: Duration.zero,
      );
      final started = controller.start();
      await flush();
      output.finish();
      await started;
      await flush();
      mic.say('Hablemos de música');
      await flush();
      state = state.copyWith(level: DrowsinessLevel.danger, eyesClosed: true);
      voice.observeSafety(state, DateTime(2026));
      await flush();
      expect(voice.safetySpeaking, isTrue);
      expect(mic.listening, isFalse);
      expect(output.spoken.last, contains('Detente'));
      output.finish();
      await flush();
      expect(mic.listening, isTrue);
      mic.say('Voy a parar');
      await flush();
      expect(state.level, DrowsinessLevel.danger);
      expect(actions, isEmpty);
      expect(output.spoken.last, contains('no confirma'));
      output.finish();
      await flush();
      mic.say('Deja de hablar');
      await flush();
      output.finish();
      await flush();
      expect(controller.active, isFalse);
      expect(voice.enabled, isTrue);
      expect(mic.listening, isFalse);
      controller.dispose();
      await flush();
      input.dispose();
    },
  );
}
