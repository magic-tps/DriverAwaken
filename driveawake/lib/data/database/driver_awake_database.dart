import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

part 'driver_awake_database.g.dart';

@DataClassName('TripRow')
class Trips extends Table {
  TextColumn get id => text()();
  DateTimeColumn get startedAt => dateTime()();
  DateTimeColumn get endedAt => dateTime().nullable()();
  TextColumn get status => text().withDefault(const Constant('active'))();
  IntColumn get drivingDurationMs => integer().withDefault(const Constant(0))();
  IntColumn get warningAlerts => integer().withDefault(const Constant(0))();
  IntColumn get dangerAlerts => integer().withDefault(const Constant(0))();
  IntColumn get yawnCount => integer().withDefault(const Constant(0))();
  IntColumn get noFaceEvents => integer().withDefault(const Constant(0))();
  IntColumn get normalSamples => integer().withDefault(const Constant(0))();
  IntColumn get warningSamples => integer().withDefault(const Constant(0))();
  IntColumn get dangerSamples => integer().withDefault(const Constant(0))();
  IntColumn get sampleCount => integer().withDefault(const Constant(0))();
  RealColumn get riskSum => real().withDefault(const Constant(0))();
  RealColumn get maxRisk => real().withDefault(const Constant(0))();
  IntColumn get closedEyeDurationMs =>
      integer().withDefault(const Constant(0))();
  RealColumn get startBatteryLevel => real().nullable()();
  RealColumn get endBatteryLevel => real().nullable()();
  RealColumn get startTemperatureC => real().nullable()();
  RealColumn get endTemperatureC => real().nullable()();
  RealColumn get maxTemperatureC => real().nullable()();
  BoolColumn get isCharging => boolean().withDefault(const Constant(false))();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

@DataClassName('TripEventRow')
@TableIndex(name: 'trip_events_by_time', columns: {#occurredAt})
@TableIndex(name: 'trip_events_by_trip', columns: {#tripId})
@TableIndex(name: 'trip_events_by_level', columns: {#level})
class TripEvents extends Table {
  TextColumn get id => text()();
  TextColumn get tripId =>
      text().nullable().references(Trips, #id, onDelete: KeyAction.cascade)();
  DateTimeColumn get occurredAt => dateTime()();
  TextColumn get level => text()();
  TextColumn get eventType => text()();
  RealColumn get durationSeconds => real().withDefault(const Constant(0))();
  RealColumn get riskScore => real().withDefault(const Constant(0))();
  RealColumn get perclos => real().withDefault(const Constant(0))();
  TextColumn get modelPrediction => text().nullable()();
  RealColumn get modelConfidence => real().nullable()();
  TextColumn get notes => text().withDefault(const Constant(''))();
  DateTimeColumn get createdAt => dateTime()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

@DataClassName('SessionDraftRow')
class SessionDrafts extends Table {
  TextColumn get tripId =>
      text().references(Trips, #id, onDelete: KeyAction.cascade)();
  TextColumn get payloadJson => text()();
  DateTimeColumn get startedAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();
  BoolColumn get incomplete => boolean().withDefault(const Constant(true))();

  @override
  Set<Column<Object>> get primaryKey => {tripId};
}

@DataClassName('CalibrationRow')
class Calibrations extends Table {
  TextColumn get id => text()();
  IntColumn get version => integer().withDefault(const Constant(1))();
  TextColumn get payloadJson => text()();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

@DataClassName('AppSettingRow')
class AppSettings extends Table {
  TextColumn get id => text()();
  IntColumn get version => integer().withDefault(const Constant(1))();
  TextColumn get payloadJson => text()();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

@DataClassName('ModelMetadataRow')
class ModelMetadata extends Table {
  TextColumn get id => text()();
  TextColumn get payloadJson => text()();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

// Detection payloads are immutable. Only delivery metadata changes on retry.
// This table also stores ordered, bounded trip-health messages.
class FleetOutbox extends Table {
  TextColumn get id => text()();
  TextColumn get organizationId => text()();
  TextColumn get ownerId => text()();
  TextColumn get cloudTripId => text()();
  TextColumn get localTripId => text()();
  TextColumn get kind => text()();
  TextColumn get payloadJson => text()();
  TextColumn get syncStatus => text().withDefault(const Constant('QUEUED'))();
  IntColumn get attempts => integer().withDefault(const Constant(0))();
  DateTimeColumn get nextAttemptAt => dateTime()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();
  TextColumn get lastError => text().nullable()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

@DataClassName('RestSessionRow')
class RestSessions extends Table {
  TextColumn get id => text()();
  TextColumn get tripId =>
      text().references(Trips, #id, onDelete: KeyAction.cascade)();
  DateTimeColumn get startedAt => dateTime()();
  DateTimeColumn get endedAt => dateTime().nullable()();
  IntColumn get durationMs => integer().withDefault(const Constant(0))();
  TextColumn get recommendationReason => text()();
  BoolColumn get voluntarilyConfirmed => boolean()();
  TextColumn get fleetBindingJson => text().nullable()();
  @override
  Set<Column<Object>> get primaryKey => {id};
}

@DriftDatabase(
  tables: <Type>[
    Trips,
    TripEvents,
    SessionDrafts,
    Calibrations,
    AppSettings,
    ModelMetadata,
    FleetOutbox,
    RestSessions,
  ],
)
class DriverAwakeDatabase extends _$DriverAwakeDatabase {
  DriverAwakeDatabase([QueryExecutor? executor])
    : super(executor ?? _openConnection());

  @override
  int get schemaVersion => 3;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (migrator) async => migrator.createAll(),
    onUpgrade: (migrator, from, to) async {
      if (from < 2) await migrator.createTable(fleetOutbox);
      if (from < 3) await migrator.createTable(restSessions);
    },
    beforeOpen: (details) async {
      await customStatement('PRAGMA foreign_keys = ON');
    },
  );

  static LazyDatabase _openConnection() {
    return LazyDatabase(() async {
      final directory = await getApplicationDocumentsDirectory();
      return NativeDatabase.createInBackground(
        File(p.join(directory.path, 'driverawake.sqlite')),
      );
    });
  }
}
