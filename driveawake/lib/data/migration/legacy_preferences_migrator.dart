import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../features/drive/application/drive_ports.dart';
import '../../models/drowsiness_event.dart';
import '../../models/trip_session_draft.dart';
import '../database/driver_awake_database.dart';
import '../repositories/drift_trip_repository.dart';

class LegacyPreferencesMigrator {
  LegacyPreferencesMigrator({
    required this.database,
    required this.preferences,
    Logger logger = const DebugLogger(),
  }) : _logger = logger;

  static const migrationId = 'legacy_shared_preferences_migration_v1';
  static const _eventKeys = <String>[
    'driverawake_event_history_v1',
    'magicdrive_event_history_v1',
  ];
  static const _draftKey = 'driverawake_incomplete_trip_v1';
  static const _settingKeys = <String>[
    'driverawake_app_settings_v1',
    'magicdrive_app_settings_v1',
  ];
  static const _calibrationKeys = <String>[
    'magicdrive_personal_calibration_v2',
    'magicdrive_personal_calibration_v1',
  ];

  final DriverAwakeDatabase database;
  final SharedPreferences preferences;
  final Logger _logger;

  Future<bool> run() async {
    final completed = await (database.select(
      database.modelMetadata,
    )..where((table) => table.id.equals(migrationId))).getSingleOrNull();
    if (completed != null) return true;

    try {
      final repository = DriftTripRepository(database);
      await database.transaction(() async {
        await _migrateDraft(repository);
        await _migrateEvents(repository);
        await _migrateSettings();
        await _migrateCalibrations();
        await database
            .into(database.modelMetadata)
            .insertOnConflictUpdate(
              ModelMetadataCompanion.insert(
                id: migrationId,
                payloadJson: jsonEncode(<String, Object?>{
                  'completed': true,
                  'source': 'SharedPreferences',
                  'completedAt': DateTime.now().toIso8601String(),
                }),
                updatedAt: DateTime.now(),
              ),
            );
      });
      return true;
    } catch (error, stackTrace) {
      _logger.error(
        'No se pudo completar la migracion a Drift',
        error,
        stackTrace,
      );
      return false;
    }
  }

  Future<void> _migrateDraft(DriftTripRepository repository) async {
    final raw = preferences.getString(_draftKey);
    if (raw == null || raw.isEmpty) return;
    try {
      final decoded = jsonDecode(raw);
      if (decoded is! Map<String, dynamic>) {
        throw const FormatException('El borrador no es un objeto JSON');
      }
      final draft = TripSessionDraft.fromMap(decoded);
      if (draft.incomplete) await repository.saveDraft(draft);
    } catch (error, stackTrace) {
      _logger.warning(
        'Borrador historico corrupto; se conserva como fallback',
        error,
        stackTrace,
      );
    }
  }

  Future<void> _migrateEvents(DriftTripRepository repository) async {
    for (final key in _eventKeys) {
      final raw = preferences.getString(key);
      if (raw == null || raw.isEmpty) continue;
      Object? decoded;
      try {
        decoded = jsonDecode(raw);
      } catch (error, stackTrace) {
        _logger.warning(
          'Historial historico invalido en $key',
          error,
          stackTrace,
        );
        continue;
      }
      if (decoded is! List<dynamic>) {
        _logger.warning('Historial historico no es una lista en $key');
        continue;
      }
      for (var index = 0; index < decoded.length; index += 1) {
        final item = decoded[index];
        try {
          if (item is! Map<String, dynamic>) {
            throw const FormatException('Evento no es un objeto');
          }
          final event = DrowsinessEvent.fromMap(item);
          if (event.id.isEmpty || event.dateTime.millisecondsSinceEpoch == 0) {
            throw const FormatException('Evento sin identidad o timestamp');
          }
          final migrated = event.tripId == null
              ? event
              : DrowsinessEvent(
                  id: event.id,
                  dateTime: event.dateTime,
                  level: event.level,
                  eventType: event.eventType,
                  durationSeconds: event.durationSeconds,
                  notes: event.notes,
                  riskScore: event.riskScore,
                  perclos: event.perclos,
                  modelPrediction: event.modelPrediction,
                  modelConfidence: event.modelConfidence,
                  // Historical events can reference trips that were never
                  // persisted. Keep the event without violating the FK.
                  tripId: await _tripExists(event.tripId!)
                      ? event.tripId
                      : null,
                );
          await repository.addEvent(migrated);
        } catch (error, stackTrace) {
          _logger.warning(
            'Evento historico corrupto en $key[$index]',
            error,
            stackTrace,
          );
        }
      }
    }
  }

  Future<bool> _tripExists(String id) async {
    final row = await (database.select(
      database.trips,
    )..where((table) => table.id.equals(id))).getSingleOrNull();
    return row != null;
  }

  Future<void> _migrateSettings() async {
    for (final key in _settingKeys) {
      final raw = preferences.getString(key);
      if (raw == null || raw.isEmpty) continue;
      try {
        final decoded = jsonDecode(raw);
        if (decoded is! Map<String, dynamic>) {
          throw const FormatException('Ajustes no son un objeto JSON');
        }
        await database
            .into(database.appSettings)
            .insertOnConflictUpdate(
              AppSettingsCompanion.insert(
                id: 'current',
                payloadJson: jsonEncode(decoded),
                updatedAt: DateTime.now(),
              ),
            );
        return;
      } catch (error, stackTrace) {
        _logger.warning(
          'Ajustes historicos corruptos en $key',
          error,
          stackTrace,
        );
      }
    }
  }

  Future<void> _migrateCalibrations() async {
    for (final key in _calibrationKeys) {
      final raw = preferences.getString(key);
      if (raw == null || raw.isEmpty) continue;
      try {
        final decoded = jsonDecode(raw);
        if (decoded is! Map<String, dynamic>) {
          throw const FormatException('Calibracion no es un objeto JSON');
        }
        await database
            .into(database.calibrations)
            .insertOnConflictUpdate(
              CalibrationsCompanion.insert(
                id: key,
                version: Value(key.endsWith('_v2') ? 2 : 1),
                payloadJson: jsonEncode(decoded),
                updatedAt: DateTime.now(),
              ),
            );
      } catch (error, stackTrace) {
        _logger.warning(
          'Calibracion historica corrupta en $key',
          error,
          stackTrace,
        );
      }
    }
  }
}
