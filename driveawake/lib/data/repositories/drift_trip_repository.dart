import 'dart:convert';

import 'package:drift/drift.dart';

import '../../models/drowsiness_event.dart';
import '../../models/drowsiness_state.dart';
import '../../models/trip_session_draft.dart';
import '../../models/trip_session_summary.dart';
import '../database/driver_awake_database.dart';

class DriftTripRepository {
  const DriftTripRepository(this.database);

  final DriverAwakeDatabase database;

  Future<void> createTrip(TripSessionDraft draft) async {
    await database
        .into(database.trips)
        .insertOnConflictUpdate(_tripFromDraft(draft));
  }

  Future<void> saveDraft(TripSessionDraft draft) async {
    await database.transaction(() async {
      await database
          .into(database.trips)
          .insertOnConflictUpdate(_tripFromDraft(draft));
      await database
          .into(database.sessionDrafts)
          .insertOnConflictUpdate(
            SessionDraftsCompanion.insert(
              tripId: draft.tripId,
              payloadJson: jsonEncode(draft.toMap()),
              startedAt: draft.startedAt,
              updatedAt: draft.updatedAt,
              incomplete: Value(draft.incomplete),
            ),
          );
    });
  }

  Future<TripSessionDraft?> loadDraft() async {
    final row =
        await (database.select(database.sessionDrafts)
              ..where((table) => table.incomplete.equals(true))
              ..orderBy([(table) => OrderingTerm.desc(table.updatedAt)])
              ..limit(1))
            .getSingleOrNull();
    if (row == null) return null;
    return TripSessionDraft.fromMap(
      jsonDecode(row.payloadJson) as Map<String, dynamic>,
    );
  }

  Future<void> clearDraft() => database.delete(database.sessionDrafts).go();

  Future<void> addEvent(DrowsinessEvent event) async {
    await database
        .into(database.tripEvents)
        .insertOnConflictUpdate(
          TripEventsCompanion.insert(
            id: event.id,
            tripId: Value(event.tripId),
            occurredAt: event.dateTime,
            level: event.level.name,
            eventType: event.eventType,
            durationSeconds: Value(event.durationSeconds),
            riskScore: Value(event.riskScore),
            perclos: Value(event.perclos),
            modelPrediction: Value(event.modelPrediction),
            modelConfidence: Value(event.modelConfidence),
            notes: Value(event.notes),
            createdAt: event.dateTime,
          ),
        );
  }

  Future<List<DrowsinessEvent>> loadEvents({DrowsinessLevel? level}) async {
    final query = database.select(database.tripEvents)
      ..orderBy([(table) => OrderingTerm.desc(table.occurredAt)]);
    if (level != null) {
      query.where((table) => table.level.equals(level.name));
    }
    final rows = await query.get();
    return rows
        .map(
          (row) => DrowsinessEvent(
            id: row.id,
            dateTime: row.occurredAt,
            level: DrowsinessLevel.values.firstWhere(
              (value) => value.name == row.level,
              orElse: () => DrowsinessLevel.warning,
            ),
            eventType: row.eventType,
            durationSeconds: row.durationSeconds,
            notes: row.notes,
            riskScore: row.riskScore,
            perclos: row.perclos,
            modelPrediction: row.modelPrediction,
            modelConfidence: row.modelConfidence,
            tripId: row.tripId,
          ),
        )
        .toList(growable: false);
  }

  Future<void> finishTrip(
    TripSessionDraft draft,
    TripSessionSummary summary,
  ) async {
    await database.transaction(() async {
      await database
          .into(database.trips)
          .insertOnConflictUpdate(
            TripsCompanion.insert(
              id: summary.tripId,
              startedAt: summary.startedAt,
              endedAt: Value(summary.endedAt),
              status: const Value('completed'),
              drivingDurationMs: Value(summary.drivingDuration.inMilliseconds),
              warningAlerts: Value(summary.warningAlerts),
              dangerAlerts: Value(summary.dangerAlerts),
              yawnCount: Value(summary.yawnCount),
              noFaceEvents: Value(summary.noFaceEvents),
              normalSamples: Value(draft.normalSamples),
              warningSamples: Value(draft.warningSamples),
              dangerSamples: Value(draft.dangerSamples),
              sampleCount: Value(draft.sampleCount),
              riskSum: Value(draft.riskSum),
              maxRisk: Value(summary.maxRisk),
              closedEyeDurationMs: Value(
                summary.closedEyeDuration.inMilliseconds,
              ),
              startBatteryLevel: Value(summary.startBatteryLevel),
              endBatteryLevel: Value(summary.endBatteryLevel),
              startTemperatureC: Value(summary.startTemperatureC),
              endTemperatureC: Value(summary.endTemperatureC),
              maxTemperatureC: Value(summary.maxTemperatureC),
              isCharging: Value(summary.isCharging),
              createdAt: summary.startedAt,
              updatedAt: summary.endedAt,
            ),
          );
      await (database.delete(
        database.sessionDrafts,
      )..where((table) => table.tripId.equals(summary.tripId))).go();
    });
  }

  Future<void> discardTrip(String tripId) async {
    await database.transaction(() async {
      await (database.delete(
        database.sessionDrafts,
      )..where((table) => table.tripId.equals(tripId))).go();
      await (database.delete(
        database.tripEvents,
      )..where((table) => table.tripId.equals(tripId))).go();
      await (database.delete(
        database.trips,
      )..where((table) => table.id.equals(tripId))).go();
    });
  }

  Future<void> clearHistory() async {
    await database.transaction(() async {
      await database.delete(database.tripEvents).go();
      await (database.delete(
        database.trips,
      )..where((table) => table.status.isNotValue('active'))).go();
    });
  }

  Future<void> applyRetention(DateTime cutoff) async {
    await database.transaction(() async {
      await (database.delete(
        database.tripEvents,
      )..where((table) => table.occurredAt.isSmallerThanValue(cutoff))).go();
      await (database.delete(database.trips)..where(
            (table) =>
                table.status.isNotValue('active') &
                table.endedAt.isSmallerThanValue(cutoff),
          ))
          .go();
    });
  }

  TripsCompanion _tripFromDraft(TripSessionDraft draft) {
    return TripsCompanion.insert(
      id: draft.tripId,
      startedAt: draft.startedAt,
      status: Value(draft.incomplete ? 'active' : 'completed'),
      drivingDurationMs: Value(draft.drivingDuration.inMilliseconds),
      warningAlerts: Value(draft.warningAlerts),
      dangerAlerts: Value(draft.dangerAlerts),
      yawnCount: Value(draft.yawnCount),
      noFaceEvents: Value(draft.noFaceEvents),
      normalSamples: Value(draft.normalSamples),
      warningSamples: Value(draft.warningSamples),
      dangerSamples: Value(draft.dangerSamples),
      sampleCount: Value(draft.sampleCount),
      riskSum: Value(draft.riskSum),
      maxRisk: Value(draft.maxRisk),
      closedEyeDurationMs: Value(draft.closedEyeDuration.inMilliseconds),
      createdAt: draft.startedAt,
      updatedAt: draft.updatedAt,
    );
  }
}
