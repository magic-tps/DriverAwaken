import 'dart:async';

import 'package:flutter_tts/flutter_tts.dart';

import '../l10n/app_strings.dart';
import '../l10n/locale_controller.dart';

abstract interface class VoiceOutput {
  Future<bool> configure(String language);
  Future<void> speak(String message);
  Future<void> stop();
}

class LocalVoiceOutput implements VoiceOutput {
  FlutterTts? _tts;
  String? _language;

  @override
  Future<bool> configure(String language) async {
    if (_language == language) return true;
    final tts = _tts ??= FlutterTts();
    final voices = await tts.getVoices;
    if (voices is! List) return false;
    final offline = voices.whereType<Map>().where((voice) {
      final network = '${voice['network_required']}'.toLowerCase();
      return '${voice['locale']}'.replaceAll('_', '-').split('-').first ==
              language &&
          (network == '0' || network == 'false');
    });
    if (offline.isEmpty) return false;
    await tts.setVoice({
      'name': '${offline.first['name']}',
      'locale': '${offline.first['locale']}',
    });
    await tts.setSpeechRate(.45);
    await tts.setVolume(1);
    await tts.awaitSpeakCompletion(true);
    _language = language;
    return true;
  }

  @override
  Future<void> speak(String message) async {
    final result = await _tts!.speak(message);
    if (result != 1) throw StateError('TTS rejected speech');
  }

  @override
  Future<void> stop() async {
    await _tts?.stop();
  }
}

/// Optional local speech never controls the acoustic/haptic risk alarms.
class VoiceAssistant {
  VoiceAssistant({VoiceOutput? output, String Function()? language})
    : _output = output ?? LocalVoiceOutput(),
      _language =
          language ??
          (() => LocaleController.instance.effectiveLocale.languageCode);

  final VoiceOutput _output;
  final String Function() _language;
  final _said = <String, DateTime>{};
  bool _enabled = false;
  int _generation = 0;
  int _priority = 0;
  DateTime? _lastSpeech;
  String? _lastUtterance;
  Future<void> _configuration = Future.value();
  String status = 'Voz desactivada';

  bool get enabled => _enabled;
  set enabled(bool value) {
    _enabled = value;
    if (!value) {
      status = 'Voz desactivada';
      unawaited(stop());
    }
  }

  Future<void> say(
    String reason,
    String message,
    DateTime now, {
    bool critical = false,
  }) async {
    if (!enabled || (!critical && _priority > 0)) return;
    final last = _said[reason];
    if (last != null && now.difference(last) < const Duration(minutes: 2)) {
      return;
    }
    if (!critical &&
        _lastSpeech != null &&
        now.difference(_lastSpeech!) < const Duration(seconds: 20)) {
      return;
    }

    final generation = ++_generation;
    _priority = critical ? 2 : 1;
    _said[reason] = now;
    bool current() => enabled && generation == _generation;
    try {
      await _output.stop();
      if (!current()) return;
      final language = _language();
      var available = false;
      // Serialize configuration when the user changes the app language.
      final configure = _configuration.then((_) async {
        if (current()) available = await _output.configure(language);
      });
      _configuration = configure.catchError((Object _) {});
      await configure;
      if (!current()) return;
      if (!available) {
        _said.remove(reason);
        status =
            'No hay una voz sin red instalada para el idioma seleccionado.';
        return;
      }
      _lastSpeech = now;
      status = 'Voz sin red seleccionada';
      _lastUtterance = message;
      await _output.speak(AppStrings(language).translate(message));
    } catch (_) {
      if (current()) {
        _said.remove(reason);
        status = 'Voz no disponible; las alarmas locales siguen disponibles';
      }
    } finally {
      if (generation == _generation) _priority = 0;
    }
  }

  Future<void> repeatLast(DateTime now) async {
    final message = _lastUtterance;
    if (message == null) return;
    await say(
      'repeat_${now.microsecondsSinceEpoch}',
      message,
      now,
      critical: true,
    );
  }

  Future<void> stop() async {
    ++_generation;
    _priority = 0;
    try {
      await _output.stop();
    } catch (_) {}
  }
}
