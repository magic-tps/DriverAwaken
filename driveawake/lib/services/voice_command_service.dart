import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:permission_handler/permission_handler.dart';
import '../l10n/locale_controller.dart';

enum VoiceCommand { pause, resume, map, sos, rest, silence, repeat, status }

VoiceCommand? parseVoiceCommand(String words) {
  var text = words.toLowerCase();
  const accented = 'áàäéèëíìïóòöúùü';
  const plain = 'aaaeeeiiiooouuu';
  for (var i = 0; i < accented.length; i++) {
    text = text.replaceAll(accented[i], plain[i]);
  }
  text = text
      .replaceAll(RegExp(r'[^a-zñ\s]'), ' ')
      .replaceAll(RegExp(r'\s+'), ' ')
      .trim();
  if (text.isEmpty || RegExp(r'\b(no|nunca|jamas|sin)\b').hasMatch(text)) {
    return null;
  }
  // A short command is accepted even when the recognizer prefixes a polite
  // request. We do not match arbitrary substrings such as "despausar".
  var previous = '';
  while (previous != text) {
    previous = text;
    text = text.replaceFirst(
      RegExp(
        r'^(oye|hola|copiloto|driverawaken|driver awake|por favor|puedes|podrias|quiero que|necesito que|please|could you|can you|hey)\s+',
      ),
      '',
    );
  }
  text = text.replaceFirst(RegExp(r' por favor$'), '');
  const english = {
    'pause': VoiceCommand.pause,
    'pause monitoring': VoiceCommand.pause,
    'resume': VoiceCommand.resume,
    'resume monitoring': VoiceCommand.resume,
    'open maps': VoiceCommand.map,
    'emergency': VoiceCommand.sos,
    'i need a break': VoiceCommand.rest,
    'i am tired': VoiceCommand.rest,
    'i feel sleepy': VoiceCommand.rest,
    'stop talking': VoiceCommand.silence,
    'repeat': VoiceCommand.repeat,
    'how am i doing': VoiceCommand.status,
    'status': VoiceCommand.status,
  };
  if (english.containsKey(text)) return english[text];
  if (RegExp(
    r'^(pausa|pausar|deten|detener|suspende|suspender)( el| la)?( monitoreo| detector| camara| seguimiento)?$',
  ).hasMatch(text)) {
    return VoiceCommand.pause;
  }
  if (RegExp(
    r'^(reanuda|reanudar|continua|continuar|retoma|retomar|activa|activar)( el| la)?( monitoreo| detector| camara| seguimiento)?$',
  ).hasMatch(text)) {
    return VoiceCommand.resume;
  }
  if (RegExp(
        r'^(mapa|navegacion|abre|abrir|muestra|mostrar|busca|buscar)( el| la| en)?( mapa| google maps| navegacion| paradas| estacionamiento| gasolinera| grifo| cafeteria| restaurante| hospedaje)?$',
      ).hasMatch(text) &&
      !RegExp(r'^(abre|abrir|muestra|mostrar|busca|buscar)$').hasMatch(text)) {
    return VoiceCommand.map;
  }
  if (RegExp(
    r'^(sos|s o s|emergencia|abrir sos|abre sos|necesito ayuda urgente|llamar emergencia)$',
  ).hasMatch(text)) {
    return VoiceCommand.sos;
  }
  if (RegExp(
    r'^(necesito descansar|quiero descansar|necesito un descanso|quiero un descanso|estoy cansado|estoy cansada|tengo sueño|tengo sueno|necesito parar|busca un descanso)$',
  ).hasMatch(text)) {
    return VoiceCommand.rest;
  }
  if (RegExp(
    r'^(silencio|silenciar voz|callate|deja de hablar|apaga la voz)$',
  ).hasMatch(text)) {
    return VoiceCommand.silence;
  }
  if (RegExp(r'^(repite|repetir|dilo otra vez|que dijiste)$').hasMatch(text)) {
    return VoiceCommand.repeat;
  }
  if (RegExp(
    r'^(estado|como voy|como estoy|estado del monitoreo|cual es mi estado)$',
  ).hasMatch(text)) {
    return VoiceCommand.status;
  }
  return null;
}

enum VoiceListeningState {
  idle,
  preparing,
  listening,
  delivering,
  noSpeech,
  error,
}

class VoiceLocale {
  const VoiceLocale(this.id);
  final String id;
}

abstract interface class SpeechInput {
  Future<bool> initialize({
    required void Function(String) onStatus,
    required void Function(String) onError,
  });
  Future<List<VoiceLocale>> locales();
  Future<void> listen({
    required String locale,
    required void Function(String, bool) onResult,
  });
  Future<void> cancel();
}

class AndroidSpeechInput implements SpeechInput {
  final _speech = SpeechToText();
  @override
  Future<bool> initialize({
    required void Function(String) onStatus,
    required void Function(String) onError,
  }) => _speech.initialize(
    onStatus: onStatus,
    onError: (error) => onError(error.errorMsg),
  );
  @override
  Future<List<VoiceLocale>> locales() async => (await _speech.locales())
      .map((value) => VoiceLocale(value.localeId))
      .toList();
  @override
  Future<void> listen({
    required String locale,
    required void Function(String, bool) onResult,
  }) => _speech.listen(
    listenOptions: SpeechListenOptions(
      localeId: locale,
      listenFor: const Duration(seconds: 25),
      pauseFor: const Duration(seconds: 5),
      cancelOnError: true,
      partialResults: true,
      listenMode: ListenMode.dictation,
    ),
    onResult: (result) => onResult(result.recognizedWords, result.finalResult),
  );
  @override
  Future<void> cancel() => _speech.cancel();
}

class _ListeningTurn {
  _ListeningTurn(this.generation, this.onWords, this.conversation);
  final int generation;
  final void Function(String) onWords;
  final bool conversation;
  String words = '';
  bool started = false;
}

/// Initialization callbacks read the current turn, never a captured first turn.
class VoiceCommandService extends ChangeNotifier {
  VoiceCommandService({
    SpeechInput? input,
    Future<bool> Function()? microphoneAllowed,
    String Function()? language,
    this.finalResultGrace = const Duration(milliseconds: 450),
  }) : _speech = input ?? AndroidSpeechInput(),
       _microphoneAllowed =
           microphoneAllowed ??
           (() async => (await Permission.microphone.status).isGranted),
       _language =
           language ??
           (() => LocaleController.instance.effectiveLocale.languageCode);
  static final instance = VoiceCommandService();
  final SpeechInput _speech;
  final Future<bool> Function() _microphoneAllowed;
  final String Function() _language;
  final Duration finalResultGrace;
  int _generation = 0;
  bool _initialized = false;
  Future<bool>? _initializing;
  _ListeningTurn? _turn;
  Timer? _finishTimer;
  Timer? _deadline;
  Future<void> _cancelling = Future<void>.value();
  bool busy = false;
  VoiceListeningState state = VoiceListeningState.idle;
  String status = 'Pulsa el micrófono para hablar conmigo.';

  void _update(String message) {
    status = message;
    notifyListeners();
  }

  Future<void> listen({
    required void Function(String command) onCommand,
    bool conversation = false,
  }) async {
    if (busy) return;
    final generation = ++_generation;
    final turn = _ListeningTurn(generation, onCommand, conversation);
    _turn = turn;
    busy = true;
    state = VoiceListeningState.preparing;
    _update('Preparando micrófono…');
    try {
      final allowed = await _microphoneAllowed();
      if (generation != _generation) return;
      if (!allowed) {
        _fail(
          'Autoriza el micrófono antes de iniciar el viaje o desde los ajustes de Android.',
        );
        return;
      }
      await _cancelling;
      if (generation != _generation) return;
      _initializing ??= _speech.initialize(
        onStatus: _onStatus,
        onError: _onError,
      );
      final available = await _initializing!;
      _initialized = available;
      if (!available) _initializing = null;
      if (generation != _generation) return;
      if (!available) {
        _fail(
          'Reconocimiento no disponible. Revisa el micrófono y el servicio de voz de Android.',
        );
        return;
      }
      final locales = await _speech.locales();
      if (generation != _generation) return;
      final language = _language();
      final matching = locales
          .where((locale) => locale.id.toLowerCase().startsWith(language))
          .toList();
      if (matching.isEmpty) {
        _fail(
          language == 'es'
              ? 'Instala español en el servicio de voz de Android.'
              : 'Install English in Android speech recognition.',
        );
        return;
      }
      final preferred = matching.where((locale) {
        final id = locale.id.toLowerCase().replaceAll('-', '_');
        return language == 'es'
            ? id == 'es_pe' || id == 'es_419'
            : id == 'en_us';
      });
      turn.started = true;
      state = VoiceListeningState.listening;
      _update('Escuchando…');
      _deadline = Timer(const Duration(seconds: 28), () => _finish(turn));
      await _speech.listen(
        locale: preferred.isNotEmpty ? preferred.first.id : matching.first.id,
        onResult: (recognized, finalResult) {
          if (generation != _generation || _turn != turn) return;
          final words = recognized.trim();
          if (words.isEmpty) return;
          turn.words = words;
          if (!finalResult) {
            _update('Escuchando: $words');
            return;
          }
          if (!conversation && parseVoiceCommand(words) == null) {
            _fail('No reconocí un comando. Puedes volver a intentarlo.');
            return;
          }
          unawaited(_deliver(turn));
        },
      );
    } catch (_) {
      if (generation == _generation) {
        _initializing = null;
        _fail(
          'No se pudo iniciar el reconocimiento de voz. Inténtalo de nuevo.',
        );
      }
    }
  }

  void _onStatus(String value) {
    final turn = _turn;
    if (turn == null || !turn.started) return;
    if (value == 'done' || value == 'notListening') {
      // Android can deliver `done` just before its final transcription.
      _finishTimer?.cancel();
      _finishTimer = Timer(finalResultGrace, () => _finish(turn));
    }
  }

  void _onError(String error) {
    if (_turn == null) return;
    if (error == 'error_no_match' || error == 'error_speech_timeout') {
      _fail(
        'No te escuché. Cuando quieras, vuelve a pulsar el micrófono.',
        noSpeech: true,
      );
    } else {
      _fail(
        'No se pudo reconocer la voz. Revisa el permiso de micrófono y el servicio de voz de Android.',
      );
    }
  }

  void _finish(_ListeningTurn turn) {
    if (_turn != turn) return;
    // Only low-impact commands may use an unfinished hypothesis. Conversation
    // and actions such as resume/maps require an actual final recognition.
    if (!turn.conversation &&
        {
          VoiceCommand.pause,
          VoiceCommand.rest,
          VoiceCommand.silence,
          VoiceCommand.status,
        }.contains(parseVoiceCommand(turn.words))) {
      unawaited(_deliver(turn));
    } else {
      _fail(
        turn.words.isEmpty
            ? 'No te escuché. Cuando quieras, vuelve a pulsar el micrófono.'
            : 'No confirmé lo que dijiste. Puedes volver a intentarlo.',
        noSpeech: true,
      );
    }
  }

  Future<void> _deliver(_ListeningTurn turn) async {
    if (_turn != turn) return;
    _turn = null;
    _finishTimer?.cancel();
    _deadline?.cancel();
    state = VoiceListeningState.delivering;
    await _cancelInput();
    if (turn.generation != _generation) return;
    busy = false;
    state = VoiceListeningState.idle;
    _update('Te escuché: ${turn.words}');
    turn.onWords(turn.words);
  }

  void _fail(String message, {bool noSpeech = false}) {
    _turn = null;
    ++_generation;
    _finishTimer?.cancel();
    _deadline?.cancel();
    busy = false;
    state = noSpeech ? VoiceListeningState.noSpeech : VoiceListeningState.error;
    if (_initialized) unawaited(_cancelInput());
    _update(message);
  }

  Future<void> stop() async {
    ++_generation;
    _turn = null;
    _finishTimer?.cancel();
    _deadline?.cancel();
    busy = false;
    state = VoiceListeningState.idle;
    _update('Micrófono apagado');
    try {
      if (_initialized) await _cancelInput();
    } catch (_) {
      // Cancellation is also used before the recognizer has initialized.
    }
  }

  Future<void> _cancelInput() => _cancelling = _cancelling.then((_) async {
    try {
      await _speech.cancel();
    } catch (_) {}
  });

  @override
  void dispose() {
    _turn = null;
    ++_generation;
    _finishTimer?.cancel();
    _deadline?.cancel();
    super.dispose();
  }
}
