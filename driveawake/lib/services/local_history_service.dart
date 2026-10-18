import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../data/database/database_provider.dart';
import '../data/repositories/drift_trip_repository.dart';
import '../models/drowsiness_event.dart';
import '../models/trip_session_summary.dart';
import '../models/drowsiness_state.dart';
import '../models/app_settings.dart';
import 'settings_service.dart';

class LocalHistoryService {
  LocalHistoryService._();

  static final LocalHistoryService instance = LocalHistoryService._();
  static const String _storageKey = 'driverawake_event_history_v1';
  static const String _legacyStorageKey = 'magicdrive_event_history_v1';
  static const int _maxEvents = 600;

  DriftTripRepository get _repository =>
      DriftTripRepository(DatabaseProvider.database);

  Future<List<DrowsinessEvent>> loadEvents({DrowsinessLevel? level}) async {
    try {
      await SettingsService.instance.initialize();
      final retention =
          SettingsService.instance.settings.historyRetention.duration;
      if (retention != null) {
        await _repository.applyRetention(DateTime.now().subtract(retention));
      }
      return await _repository.loadEvents(level: level);
    } catch (_) {
      return _loadLegacyFallback(level: level);
    }
  }

  Future<List<TripSessionSummary>> loadTrips() async {
    await SettingsService.instance.initialize();
    final retention =
        SettingsService.instance.settings.historyRetention.duration;
    if (retention != null) {
      await _repository.applyRetention(DateTime.now().subtract(retention));
    }
    return _repository.loadCompletedTrips();
  }

  Future<void> addEvent(DrowsinessEvent event) async {
    try {
      await _repository.addEvent(event);
      final events = await _repository.loadEvents();
      if (events.length <= _maxEvents) return;
      final cutoff = events[_maxEvents - 1].dateTime;
      await _repository.applyRetention(cutoff);
    } catch (_) {
      final events = await _loadLegacyFallback();
      events.insert(0, event);
      if (events.length > _maxEvents) {
        events.removeRange(_maxEvents, events.length);
      }
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(
        _storageKey,
        jsonEncode(events.map((value) => value.toMap()).toList()),
      );
    }
  }

  Future<void> clear() async {
    try {
      await _repository.clearHistory();
    } catch (_) {}
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_storageKey);
    await prefs.remove(_legacyStorageKey);
  }

  Future<void> deleteEventsForTrip(String tripId) =>
      _repository.discardTrip(tripId);

  Future<void> enforceRetentionPolicy() async {
    await SettingsService.instance.initialize();
    final retention =
        SettingsService.instance.settings.historyRetention.duration;
    if (retention != null) {
      try {
        await _repository.applyRetention(DateTime.now().subtract(retention));
      } catch (_) {
        await _loadLegacyFallback();
      }
    }
  }

  Future<List<DrowsinessEvent>> _loadLegacyFallback({
    DrowsinessLevel? level,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final raw =
        prefs.getString(_storageKey) ?? prefs.getString(_legacyStorageKey);
    if (raw == null || raw.isEmpty) return <DrowsinessEvent>[];
    try {
      final decoded = jsonDecode(raw) as List<dynamic>;
      var events =
          decoded
              .whereType<Map<String, dynamic>>()
              .map(DrowsinessEvent.fromMap)
              .toList()
            ..sort((a, b) => b.dateTime.compareTo(a.dateTime));
      final retention =
          SettingsService.instance.settings.historyRetention.duration;
      if (retention != null) {
        final cutoff = DateTime.now().subtract(retention);
        events = events
            .where((event) => !event.dateTime.isBefore(cutoff))
            .toList();
      }
      await prefs.setString(
        _storageKey,
        jsonEncode(events.map((event) => event.toMap()).toList()),
      );
      return level == null
          ? events
          : events.where((event) => event.level == level).toList();
    } catch (_) {
      return <DrowsinessEvent>[];
    }
  }
}
