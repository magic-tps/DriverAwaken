import 'dart:convert';
import 'dart:io';

import 'package:drift/native.dart';
import 'package:driveawake/data/database/driver_awake_database.dart'
    hide AppSettings;
import 'package:driveawake/data/migration/legacy_preferences_migrator.dart';
import 'package:driveawake/data/repositories/drift_trip_repository.dart';
import 'package:driveawake/models/app_settings.dart';
import 'package:driveawake/models/drowsiness_event.dart';
import 'package:driveawake/models/drowsiness_state.dart';
import 'package:driveawake/models/trip_session_draft.dart';
import 'package:driveawake/models/trip_session_summary.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('migracion SharedPreferences a Drift', () {
    late DriverAwakeDatabase database;

    setUp(() {
      database = DriverAwakeDatabase(NativeDatabase.memory());
    });

    tearDown(() => database.close());

    test(
      'migra datos realistas, conserva corruptos y marca finalizacion',
      () async {
        final draft = _draft('trip_legacy', DateTime(2026, 7, 17));
        final event = _event('event_1', draft.tripId, draft.startedAt);
        SharedPreferences.setMockInitialValues(<String, Object>{
          'driverawake_incomplete_trip_v1': jsonEncode(draft.toMap()),
          'driverawake_event_history_v1': jsonEncode(<Object?>[
            event.toMap(),
            'elemento_corrupto',
          ]),
          'driverawake_app_settings_v1': jsonEncode(
            AppSettings.defaults().toMap(),
          ),
          'magicdrive_personal_calibration_v2': jsonEncode(<String, Object?>{
            'earOpenBaseline': 0.28,
          }),
        });
        final prefs = await SharedPreferences.getInstance();
        final migrated = await LegacyPreferencesMigrator(
          database: database,
          preferences: prefs,
        ).run();
        expect(migrated, isTrue);
        expect(await database.select(database.trips).get(), hasLength(1));
        expect(await database.select(database.tripEvents).get(), hasLength(1));
        expect(
          await database.select(database.sessionDrafts).get(),
          hasLength(1),
        );
        expect(await database.select(database.appSettings).get(), hasLength(1));
        expect(
          await database.select(database.calibrations).get(),
          hasLength(1),
        );
        expect(
          await (database.select(database.modelMetadata)..where(
                (table) =>
                    table.id.equals(LegacyPreferencesMigrator.migrationId),
              ))
              .getSingleOrNull(),
          isNotNull,
        );
        expect(prefs.getString('driverawake_event_history_v1'), isNotNull);
      },
    );

    test('ejecutar migracion dos veces no duplica eventos', () async {
      final event = _event('event_unique', null, DateTime(2026, 7, 17));
      SharedPreferences.setMockInitialValues(<String, Object>{
        'driverawake_event_history_v1': jsonEncode(<Object?>[event.toMap()]),
      });
      final prefs = await SharedPreferences.getInstance();
      final migrator = LegacyPreferencesMigrator(
        database: database,
        preferences: prefs,
      );
      expect(await migrator.run(), isTrue);
      expect(await migrator.run(), isTrue);
      expect(await database.select(database.tripEvents).get(), hasLength(1));
    });

    test('JSON global corrupto no bloquea la migracion', () async {
      SharedPreferences.setMockInitialValues(<String, Object>{
        'driverawake_event_history_v1': '{invalido',
        'driverawake_incomplete_trip_v1': '[]',
      });
      final prefs = await SharedPreferences.getInstance();
      expect(
        await LegacyPreferencesMigrator(
          database: database,
          preferences: prefs,
        ).run(),
        isTrue,
      );
      expect(await database.select(database.tripEvents).get(), isEmpty);
      expect(await database.select(database.modelMetadata).get(), hasLength(1));
    });
  });

  group('transacciones de viajes', () {
    late DriverAwakeDatabase database;
    late DriftTripRepository repository;

    setUp(() {
      database = DriverAwakeDatabase(NativeDatabase.memory());
      repository = DriftTripRepository(database);
    });

    tearDown(() => database.close());

    test('finalizar guarda viaje y elimina borrador atomico', () async {
      final draft = _draft('trip_finish', DateTime(2026, 7, 17));
      await repository.saveDraft(draft);
      await repository.addEvent(
        _event('event_finish', draft.tripId, draft.startedAt),
      );
      await repository.finishTrip(draft, _summary(draft));
      final trip = await database.select(database.trips).getSingle();
      expect(trip.status, 'completed');
      expect(trip.endedAt, isNotNull);
      expect(await database.select(database.sessionDrafts).get(), isEmpty);
      expect(await database.select(database.tripEvents).get(), hasLength(1));
    });

    test('recupera borrador despues de recrear repositorio', () async {
      final draft = _draft('trip_recovery', DateTime(2026, 7, 17));
      await repository.saveDraft(draft);
      final recovered = await DriftTripRepository(database).loadDraft();
      expect(recovered?.tripId, draft.tripId);
      expect(recovered?.incomplete, isTrue);
    });

    test('descartar elimina borrador, viaje y eventos asociados', () async {
      final draft = _draft('trip_discard', DateTime(2026, 7, 17));
      await repository.saveDraft(draft);
      await repository.addEvent(
        _event('event_discard', draft.tripId, draft.startedAt),
      );
      await repository.discardTrip(draft.tripId);
      expect(await database.select(database.trips).get(), isEmpty);
      expect(await database.select(database.sessionDrafts).get(), isEmpty);
      expect(await database.select(database.tripEvents).get(), isEmpty);
    });

    test('retencion elimina viaje vencido y conserva el reciente', () async {
      final old = _draft('trip_old', DateTime(2025, 1, 1));
      final recent = _draft('trip_recent', DateTime(2026, 7, 17));
      await repository.saveDraft(old);
      await repository.finishTrip(old, _summary(old));
      await repository.addEvent(_event('old_event', old.tripId, old.startedAt));
      await repository.saveDraft(recent);
      await repository.finishTrip(recent, _summary(recent));
      await repository.addEvent(
        _event('recent_event', recent.tripId, recent.startedAt),
      );
      await repository.applyRetention(DateTime(2026, 1, 1));
      final trips = await database.select(database.trips).get();
      final events = await database.select(database.tripEvents).get();
      expect(trips.map((row) => row.id), <String>['trip_recent']);
      expect(events.map((row) => row.id), <String>['recent_event']);
    });
  });

  test('datos sobreviven reinicio de la base SQLite', () async {
    final directory = await Directory.systemTemp.createTemp('driverawake_db_');
    final file = File('${directory.path}${Platform.pathSeparator}test.sqlite');
    final first = DriverAwakeDatabase(NativeDatabase(file));
    final draft = _draft('trip_restart', DateTime(2026, 7, 17));
    await DriftTripRepository(first).saveDraft(draft);
    await first.close();

    final second = DriverAwakeDatabase(NativeDatabase(file));
    final recovered = await DriftTripRepository(second).loadDraft();
    expect(recovered?.tripId, 'trip_restart');
    await second.close();
    await directory.delete(recursive: true);
  });
}

TripSessionDraft _draft(String id, DateTime startedAt) => TripSessionDraft(
  tripId: id,
  startedAt: startedAt,
  updatedAt: startedAt.add(const Duration(minutes: 1)),
  drivingDuration: const Duration(minutes: 1),
  warningAlerts: 1,
  dangerAlerts: 0,
  yawnCount: 1,
  noFaceEvents: 0,
  normalSamples: 8,
  warningSamples: 2,
  dangerSamples: 0,
  sampleCount: 10,
  riskSum: 180,
  maxRisk: 44,
  closedEyeDuration: const Duration(seconds: 2),
  paused: true,
  incomplete: true,
);

DrowsinessEvent _event(String id, String? tripId, DateTime at) =>
    DrowsinessEvent(
      id: id,
      dateTime: at,
      level: DrowsinessLevel.warning,
      eventType: 'alerta_precaucion',
      durationSeconds: 1.2,
      notes: 'fixture historico',
      riskScore: 44,
      perclos: 0.2,
      tripId: tripId,
    );

TripSessionSummary _summary(TripSessionDraft draft) => TripSessionSummary(
  tripId: draft.tripId,
  startedAt: draft.startedAt,
  endedAt: draft.updatedAt,
  drivingDuration: draft.drivingDuration,
  warningAlerts: draft.warningAlerts,
  dangerAlerts: draft.dangerAlerts,
  yawnCount: draft.yawnCount,
  closedEyeDuration: draft.closedEyeDuration,
  noFaceEvents: draft.noFaceEvents,
  averageRisk: draft.riskSum / draft.sampleCount,
  maxRisk: draft.maxRisk,
  dominantLevel: draft.dominantLevel,
);
