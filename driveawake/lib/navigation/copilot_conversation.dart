import 'dart:async';
import 'package:flutter/foundation.dart';
import '../services/voice_command_service.dart';
import 'conversation_engine.dart';
import 'voice_assistant.dart';

class ConversationMessage {
  const ConversationMessage(this.text, {required this.fromDriver});
  final String text;
  final bool fromDriver;
}

/// One voluntary conversation session, using alternating listen/speak turns.
/// Silence, backgrounding or closing the panel ends the session.
class CopilotConversation extends ChangeNotifier {
  CopilotConversation({
    required this.voice,
    required this.input,
    required this.context,
    required this.onAction,
    required this.language,
    this.echoGuard = const Duration(milliseconds: 400),
  }) {
    _safety = voice.safetySpeaking;
    _beforeSafety = voice.lastUtterance;
    voice.addListener(_onVoice);
    input.addListener(_onInput);
    _previousBeforeSpeak = voice.beforeSpeak;
    voice.beforeSpeak = _beforeSpeak;
  }
  final VoiceAssistant voice;
  final VoiceCommandService input;
  final ConversationContext Function() context;
  final Future<void> Function(VoiceCommand) onAction;
  final String Function() language;
  final Duration echoGuard;
  final engine = ConversationEngine();
  final messages = <ConversationMessage>[];
  Future<void> Function()? _previousBeforeSpeak;
  bool active = false;
  bool _disposed = false;
  bool _working = false;
  bool _safety = false;
  String? _beforeSafety;
  int _generation = 0;
  String status = 'Cuando quieras, conversemos.';

  Future<void> _beforeSpeak() async {
    await input.stop();
    await _previousBeforeSpeak?.call();
  }

  void _add(String message, {bool driver = false}) {
    messages.add(ConversationMessage(message, fromDriver: driver));
    if (messages.length > 12) messages.removeRange(0, messages.length - 12);
    _notify();
  }

  void _notify() {
    if (!_disposed) notifyListeners();
  }

  Future<void> start() async {
    if (_disposed || active) return;
    voice.enabled = true;
    active = true;
    final generation = ++_generation;
    if (voice.safetySpeaking) {
      status = 'Escucha la alerta de seguridad.';
      _notify();
      return;
    }
    if (messages.isEmpty) {
      await _respond('hola', generation, fromDriver: false);
    } else {
      await _listen(generation);
    }
  }

  void _onInput() {
    if (!active || _disposed) return;
    if (input.state == VoiceListeningState.error ||
        input.state == VoiceListeningState.noSpeech) {
      active = false;
      ++_generation;
    }
    if (!voice.speaking) status = input.status;
    _notify();
  }

  void _onVoice() {
    if (_disposed) return;
    if (!voice.enabled) {
      if (active) unawaited(stop());
      return;
    }
    if (voice.safetySpeaking && !_safety) {
      _safety = true;
      _beforeSafety = voice.lastUtterance;
      ++_generation;
      _working = false;
      status = 'Escucha la alerta de seguridad.';
      // VoiceAssistant awaits this cancellation before emitting audio.
    } else if (_safety && !voice.safetySpeaking) {
      _safety = false;
      final message = voice.lastUtterance;
      if (message != null &&
          message != _beforeSafety &&
          (messages.isEmpty || messages.last.text != message)) {
        _add(message);
      }
      if (active) unawaited(_listen(_generation));
    }
    _notify();
  }

  Future<void> _listen(int generation) async {
    if (_disposed ||
        !active ||
        generation != _generation ||
        _working ||
        voice.speaking) {
      return;
    }
    status = 'Preparando escucha…';
    _notify();
    // Let the speaker tail decay; never listen to our own synthesized reply.
    await Future<void>.delayed(echoGuard);
    if (_disposed || !active || generation != _generation || voice.speaking) {
      return;
    }
    await input.listen(
      conversation: true,
      onCommand: (words) {
        if (!_disposed && active && generation == _generation) {
          unawaited(_respond(words, generation));
        }
      },
    );
  }

  Future<void> _respond(
    String words,
    int generation, {
    bool fromDriver = true,
  }) async {
    if (_disposed || generation != _generation) return;
    _working = true;
    if (fromDriver) _add(words, driver: true);
    final reply = engine.respond(
      words,
      context(),
      language: language(),
      lastUtterance: voice.lastUtterance,
    );
    try {
      if (reply.action != null) await onAction(reply.action!);
      if (_disposed || generation != _generation) return;
      _add(reply.text);
      status = 'Hablando contigo…';
      _notify();
      final spoken = await voice.say(
        'conversation',
        reply.text,
        DateTime.now(),
        reply: true,
      );
      if (_disposed || generation != _generation) return;
      if (reply.end || !spoken) {
        active = false;
        status = spoken
            ? 'Conversación terminada. Las alertas siguen activas.'
            : voice.status;
      }
    } catch (_) {
      if (!_disposed && generation == _generation) {
        active = false;
        status =
            'No pude completar la acción. Puedes usar los botones de la pantalla.';
      }
    } finally {
      if (!_disposed && generation == _generation) {
        _working = false;
        _notify();
        if (active) unawaited(_listen(generation));
      }
    }
  }

  Future<void> stop() async {
    active = false;
    ++_generation;
    _working = false;
    await input.stop();
    if (!voice.safetySpeaking) await voice.stop();
    status = 'Conversación terminada. Las alertas siguen activas.';
    _notify();
  }

  @override
  void dispose() {
    _disposed = true;
    active = false;
    ++_generation;
    voice.removeListener(_onVoice);
    input.removeListener(_onInput);
    voice.beforeSpeak = _previousBeforeSpeak;
    unawaited(input.stop());
    if (!voice.safetySpeaking) unawaited(voice.stop());
    messages.clear();
    super.dispose();
  }
}
