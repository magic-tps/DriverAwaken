import 'dart:async';

import 'package:flutter_tts/flutter_tts.dart';
import 'package:flutter/foundation.dart';

import '../l10n/app_strings.dart';
import '../l10n/locale_controller.dart';
import '../models/drowsiness_state.dart';
import 'spoken_safety_alert.dart';

/// Prefer an installed offline voice with good quality and a Latin American
/// Spanish accent. A downloadable voice is not usable until installed.
Map? selectOfflineVoice(List voices, String language) {
  final candidates = voices.whereType<Map>().where((voice) {
    final network = '${voice['network_required']}'.toLowerCase();
    final features = '${voice['features']}'.toLowerCase();
    return '${voice['locale']}'
                .replaceAll('_', '-')
                .split('-')
                .first
                .toLowerCase() ==
            language.toLowerCase() &&
        (network == '0' || network == 'false') &&
        !features.contains('notinstalled');
  }).toList();
  int rank(Map voice) {
    final locale = '${voice['locale']}'.replaceAll('_', '-').toLowerCase();
    final preferred = language == 'es'
        ? ['es-pe', 'es-mx', 'es-us', 'es-419', 'es-co', 'es-ar', 'es-cl']
        : ['en-us', 'en-gb'];
    final index = preferred.indexOf(locale);
    final quality = (int.tryParse('${voice['quality']}') ?? 0).clamp(0, 1000);
    return (index < 0 ? 0 : 10000 + preferred.length - index) + quality * 10;
  }

  candidates.sort((a, b) => rank(b).compareTo(rank(a)));
  return candidates.isEmpty ? null : candidates.first;
}

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
    final offline = selectOfflineVoice(voices, language);
    if (offline == null) return false;
    if (await tts.setVoice({
          'name': '${offline['name']}',
          'locale': '${offline['locale']}',
        }) !=
        1) {
      return false;
    }
    await tts.setSpeechRate(.47);
    await tts.setPitch(1.0);
    await tts.setVolume(1);
    if (!kIsWeb && defaultTargetPlatform == TargetPlatform.android) {
      await tts.setAudioAttributesForNavigation();
    }
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
class VoiceAssistant extends ChangeNotifier {
  VoiceAssistant({VoiceOutput? output, String Function()? language})
    : _output = output ?? LocalVoiceOutput(),
      _language =
          language ??
          (() => LocaleController.instance.effectiveLocale.languageCode);

  final VoiceOutput _output;
  final String Function() _language;
  final _said = <String, DateTime>{};
  final _safetyAttempts = <String, DateTime>{};
  final _safetyDeliveries = <String, int>{};
  bool _enabled = true;
  int _generation = 0;
  int _priority = 0;
  DateTime? _lastSpeech;
  String? _lastUtterance;
  Future<void> _configuration = Future.value();
  String status = 'Alertas habladas activadas';
  Future<void> Function()? beforeSpeak;

  bool get speaking => _priority > 0;
  bool get safetySpeaking => _priority >= 2;
  String? get lastUtterance => _lastUtterance;

  bool get enabled => _enabled;
  set enabled(bool value) {
    if (_enabled == value) return;
    _enabled = value;
    if (!value) {
      status = 'Voz desactivada';
      unawaited(stop());
    } else {
      status = 'Alertas habladas activadas';
    }
    notifyListeners();
  }

  Future<bool> say(
    String reason,
    String message,
    DateTime now, {
    bool critical = false,
    bool safety = false,
    bool reply = false,
    Duration? cooldown,
  }) async {
    final priority = critical
        ? 3
        : safety
        ? 2
        : 1;
    if (!enabled || (speaking && priority <= _priority)) return false;
    final last = _said[reason];
    if (!reply &&
        last != null &&
        now.difference(last) < (cooldown ?? const Duration(minutes: 2))) {
      return false;
    }
    if (!critical &&
        !safety &&
        !reply &&
        _lastSpeech != null &&
        now.difference(_lastSpeech!) < const Duration(seconds: 20)) {
      return false;
    }

    final generation = ++_generation;
    _priority = priority;
    notifyListeners();
    bool current() => enabled && generation == _generation;
    try {
      await beforeSpeak?.call();
      if (!current()) return false;
      await _output.stop();
      if (!current()) return false;
      final language = _language();
      var available = false;
      // Serialize configuration when the user changes the app language.
      final configure = _configuration.then((_) async {
        if (current()) {
          available = await _output
              .configure(language)
              .timeout(const Duration(seconds: 8));
        }
      });
      _configuration = configure.catchError((Object _) {});
      await configure;
      if (!current()) return false;
      if (!available) {
        _said.remove(reason);
        status =
            'Instala una voz sin conexión en Ajustes de Android → Texto a voz y vuelve a probar.';
        return false;
      }
      status = 'Voz sin red seleccionada';
      _lastUtterance = message;
      await _output
          .speak(AppStrings(language).translate(message))
          .timeout(const Duration(seconds: 45));
      if (current()) {
        _lastSpeech = now;
        _said[reason] = now;
      }
      return current();
    } catch (_) {
      if (current()) {
        _said.remove(reason);
        status = 'Voz no disponible; las alarmas locales siguen disponibles';
        try {
          await _output.stop().timeout(const Duration(seconds: 2));
        } catch (_) {}
      }
      return false;
    } finally {
      if (generation == _generation) {
        _priority = 0;
        notifyListeners();
      }
    }
  }

  /// Called without awaiting by the detector; speaking never holds up a frame.
  void observeSafety(DrowsinessState state, DateTime now) {
    final alert = spokenSafetyAlert(state);
    if (alert == null) {
      _safetyDeliveries.clear();
      return;
    }
    if (!enabled) return;
    final reason = alert.reason;
    final cue = alert.message('es', 0);
    final delivery = _safetyDeliveries[cue] ?? 0;
    final attempted = _safetyAttempts[reason];
    if (attempted != null &&
        now.difference(attempted) < const Duration(seconds: 5)) {
      return;
    }
    _safetyAttempts[reason] = now;
    unawaited(
      say(
        reason,
        alert.message(_language(), delivery),
        now,
        critical: alert.critical,
        safety: true,
        cooldown: Duration(seconds: alert.critical ? 30 : 60),
      ).then((spoken) {
        if (spoken) _safetyDeliveries[cue] = delivery + 1;
      }),
    );
  }

  Future<bool> repeatLast(DateTime now) async {
    final message = _lastUtterance;
    if (message == null) return false;
    return say(
      'repeat_${now.microsecondsSinceEpoch}',
      message,
      now,
      reply: true,
    );
  }

  Future<void> stop() async {
    ++_generation;
    _priority = 0;
    notifyListeners();
    try {
      await _output.stop();
    } catch (_) {}
  }
}
