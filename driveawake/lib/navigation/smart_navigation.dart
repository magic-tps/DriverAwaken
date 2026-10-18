import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

import '../data/database/database_provider.dart';
import '../data/database/driver_awake_database.dart';
import '../fleet/fleet_service.dart';
import '../models/drowsiness_state.dart';
import '../services/settings_service.dart';
import 'navigation_contracts.dart';
import 'rest_recommendation_engine.dart';
import 'rest_repository.dart';
import 'voice_assistant.dart';

typedef ExternalUrlLauncher = Future<bool> Function(Uri uri, LaunchMode mode);

/// Smart Rest state and voluntary hand-off to Google Maps.
///
/// This service intentionally has no GPS, tile, geocoding or places provider.
class SmartNavigation extends ChangeNotifier {
  SmartNavigation({ExternalUrlLauncher? launcher, VoiceAssistant? voice})
    : _launcher = launcher ?? _defaultLauncher,
      voice = voice ?? VoiceAssistant();

  static final instance = SmartNavigation();

  final ExternalUrlLauncher _launcher;
  final restEngine = RestRecommendationEngine();
  final VoiceAssistant voice;

  List<RestSessionRow> rests = [];
  RestRecommendation? recommendation;
  Duration drivingLimit = const Duration(hours: 2);
  Duration driving = Duration.zero;
  Duration _atLastRest = Duration.zero;
  String? tripId;
  String? error;
  bool openingExternalMap = false;

  RestRepository get _rest => RestRepository(DatabaseProvider.database);

  RestSessionRow? get openRest {
    for (final rest in rests) {
      if (rest.endedAt == null) return rest;
    }
    return null;
  }

  Future<void> load() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      voice.enabled = prefs.getBool('guardian_spoken_alerts_enabled') ?? true;
      drivingLimit = Duration(
        minutes: (prefs.getInt('guardian_rest_interval_minutes') ?? 120).clamp(
          15,
          240,
        ),
      );
      rests = await _rest.history();
      for (final rest in rests.where(
        (value) => value.endedAt != null && value.fleetBindingJson != null,
      )) {
        await FleetService.instance.captureRest(rest);
      }
    } catch (_) {
      error = 'No se pudo leer parte del historial de descansos.';
    }
    notifyListeners();
  }

  void startTrip(String id) {
    if (tripId == id) return;
    tripId = id;
    driving = Duration.zero;
    _atLastRest = Duration.zero;
    recommendation = null;
    restEngine.reset();
    notifyListeners();
  }

  void observe(DrowsinessState state, DateTime now, Duration elapsed) {
    driving = elapsed;
    if (SettingsService.instance.settings.soundEnabled) {
      voice.observeSafety(state, now);
    }
    final next = restEngine.evaluate(
      state,
      now,
      driving - _atLastRest,
      drivingLimit: drivingLimit,
    );
    if (recommendation?.reason == 'MANUAL' &&
        (next == null || next.reason == 'SIGNAL_UNAVAILABLE')) {
      return;
    }
    if (next?.reason == recommendation?.reason) return;
    recommendation = next;
    if (next != null &&
        SettingsService.instance.settings.soundEnabled &&
        state.level == DrowsinessLevel.normal &&
        !state.noFaceTooLong) {
      unawaited(
        voice.say(
          next.reason,
          next.critical
              ? 'Detente en un lugar seguro tan pronto como sea posible.'
              : next.message,
          now,
          critical: next.critical,
          safety: true,
        ),
      );
    }
    notifyListeners();
  }

  Future<void> setVoiceEnabled(bool enabled) async {
    voice.enabled = enabled;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('guardian_spoken_alerts_enabled', enabled);
  }

  void requestRest() {
    // A driver's request is not a detector result and must never lower a
    // critical recommendation already on screen.
    if (recommendation?.critical == true) return;
    recommendation = const RestRecommendation(
      'MANUAL',
      'Solicitaste un descanso. Detente en un lugar seguro antes de buscar una parada.',
    );
    notifyListeners();
  }

  Future<bool> searchCategory(MapsSearchCategory category) =>
      _open(mapsSearchUri(category.query));

  Future<bool> search(String query) => _open(mapsSearchUri(query));

  Future<bool> navigate(String destination) =>
      _open(mapsDirectionsUri(destination));

  Future<bool> _open(Uri uri) async {
    if (openingExternalMap) return false;
    openingExternalMap = true;
    error = null;
    notifyListeners();
    try {
      var opened = false;
      try {
        opened = await _launcher(uri, LaunchMode.externalApplication);
      } catch (_) {
        // Android resolvers can throw instead of returning false.
      }
      // An HTTPS browser is a valid fallback when the Google Maps app is absent.
      if (!opened) opened = await _launcher(uri, LaunchMode.platformDefault);
      if (!opened) {
        error = 'No hay Google Maps ni un navegador compatible disponible.';
      }
      return opened;
    } catch (_) {
      error = 'No hay una aplicación compatible disponible.';
      return false;
    } finally {
      openingExternalMap = false;
      notifyListeners();
    }
  }

  static Future<bool> _defaultLauncher(Uri uri, LaunchMode mode) =>
      launchUrl(uri, mode: mode);

  Future<void> setInterval(int minutes) async {
    drivingLimit = Duration(minutes: minutes.clamp(15, 240));
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(
      'guardian_rest_interval_minutes',
      drivingLimit.inMinutes,
    );
    notifyListeners();
  }

  Future<void> startRest() async {
    final id = tripId;
    if (id == null) {
      throw StateError('Inicia un viaje local antes de registrar un descanso.');
    }
    await _rest.start(
      id,
      DateTime.now(),
      recommendation?.reason ?? 'MANUAL',
      fleetBinding: await FleetService.instance.restBinding(),
    );
    rests = await _rest.history();
    notifyListeners();
  }

  Future<void> endRest({DateTime? at, String? forTrip}) async {
    final id = forTrip ?? openRest?.tripId;
    if (id == null) return;
    final completed = await _rest.finish(id, at ?? DateTime.now());
    if (completed != null) await FleetService.instance.captureRest(completed);
    _atLastRest = driving;
    rests = await _rest.history();
    restEngine.reset();
    recommendation = null;
    notifyListeners();
  }
}
