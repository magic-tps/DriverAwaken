import 'package:flutter/foundation.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:permission_handler/permission_handler.dart';

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
  text = text.replaceFirst(
    RegExp(
      r'^(oye|hola|driverawaken|driver awake|por favor|puedes|podrias|quiero que|necesito que)\s+',
    ),
    '',
  );
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

/// One recognizer for the app: Android retains the initialization callbacks.
class VoiceCommandService extends ChangeNotifier {
  VoiceCommandService._();
  static final instance = VoiceCommandService._();
  final SpeechToText _speech = SpeechToText();
  int _generation = 0;
  bool busy = false;
  String status = 'Pulsa el micrófono y di un comando.';

  void _update(String message) {
    status = message;
    notifyListeners();
  }

  Future<void> listen({
    required void Function(String command) onCommand,
  }) async {
    if (busy) return;
    final generation = ++_generation;
    busy = true;
    _update('Preparando micrófono…');
    var delivered = false;
    var listeningStarted = false;
    var lastWords = '';
    void deliver(String words) {
      if (generation != _generation ||
          delivered ||
          parseVoiceCommand(words) == null) {
        return;
      }
      delivered = true;
      busy = false;
      _update('Comando reconocido: $words');
      onCommand(words);
    }

    try {
      if (!(await Permission.microphone.status).isGranted) {
        busy = false;
        _update(
          'Autoriza el micrófono antes de iniciar el viaje o desde los ajustes de Android.',
        );
        return;
      }
      if (generation != _generation) return;
      final available = await _speech.initialize(
        onError: (_) {
          if (generation != _generation) return;
          busy = false;
          _update(
            'No se pudo reconocer la voz. Revisa el permiso de micrófono y el servicio de voz de Android.',
          );
        },
        onStatus: (value) {
          if (generation != _generation || !listeningStarted) return;
          if (value == 'done' || value == 'notListening') {
            busy = false;
            if (!delivered &&
                {
                  VoiceCommand.pause,
                  VoiceCommand.rest,
                  VoiceCommand.silence,
                  VoiceCommand.status,
                }.contains(parseVoiceCommand(lastWords))) {
              deliver(lastWords);
            } else if (!delivered && lastWords.isEmpty) {
              _update('No escuché un comando. Puedes volver a intentarlo.');
            } else if (!delivered) {
              _update('No confirmé «$lastWords». Repite el comando.');
            }
          }
        },
      );
      if (generation != _generation) return;
      if (!available) {
        busy = false;
        _update(
          'Reconocimiento no disponible. Revisa el micrófono y el servicio de voz de Android.',
        );
        return;
      }
      final locales = await _speech.locales();
      if (generation != _generation) return;
      final spanish = locales
          .where((locale) => locale.localeId.toLowerCase().startsWith('es'))
          .toList();
      if (spanish.isEmpty) {
        busy = false;
        _update('Instala español en el servicio de voz de Android.');
        return;
      }
      final preferred = spanish.where((locale) {
        final id = locale.localeId.toLowerCase().replaceAll('-', '_');
        return id == 'es_pe' || id == 'es_419';
      });
      _update('Escuchando…');
      listeningStarted = true;
      await _speech.listen(
        listenOptions: SpeechListenOptions(
          localeId: preferred.isNotEmpty
              ? preferred.first.localeId
              : spanish.first.localeId,
          listenFor: const Duration(seconds: 20),
          pauseFor: const Duration(seconds: 4),
          cancelOnError: true,
          partialResults: true,
          listenMode: ListenMode.dictation,
        ),
        onResult: (result) {
          if (generation != _generation || delivered) return;
          final words = result.recognizedWords.trim();
          if (words.isEmpty) return;
          lastWords = words;
          if (!result.finalResult) {
            _update('Escuchando: $words');
            return;
          }
          if (parseVoiceCommand(words) == null) {
            _update(
              'Escuché «$words», pero no es un comando seguro. Prueba con “pausar”, “necesito descansar” o “SOS”.',
            );
            return;
          }
          deliver(words);
        },
      );
    } catch (_) {
      if (generation == _generation) {
        busy = false;
        _update(
          'No se pudo iniciar el reconocimiento de voz. Inténtalo de nuevo.',
        );
      }
    }
  }

  Future<void> stop() async {
    ++_generation;
    busy = false;
    try {
      await _speech.cancel();
    } catch (_) {
      // Cancellation is also used before the recognizer has initialized.
    }
  }
}
