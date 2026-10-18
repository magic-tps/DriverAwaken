import 'dart:convert';
import 'package:drift/drift.dart';
import '../models/drowsiness_event.dart';
import '../models/drowsiness_state.dart';
import 'incident_classifier.dart';
import 'local_outbox.dart';

/// Persists detection and delivery intent together in SQLite.
/// Cooldown survives process restarts; a critical escalation bypasses it.
class IncidentRepository {
  IncidentRepository(this.outbox);
  final LocalOutbox outbox;
  Future<bool> record(
    DrowsinessEvent event, {
    required String organizationId,
    required String driverId,
    required String cloudTripId,
    required String localTripId,
    DrowsinessState? signal,
    required DateTime queuedAt,
  }) async {
    final payload = IncidentClassifier().classify(
      event,
      organizationId: organizationId,
      tripId: cloudTripId,
      driverId: driverId,
      signal: signal,
    );
    if (payload == null) return false;
    final db = outbox.database;
    return db.transaction(() async {
      final recent =
          await (db.select(db.fleetOutbox)
                ..where(
                  (t) =>
                      t.ownerId.equals(driverId) &
                      t.organizationId.equals(organizationId) &
                      t.cloudTripId.equals(cloudTripId) &
                      t.kind.equals('INCIDENT'),
                )
                ..orderBy([
                  (t) => OrderingTerm.desc(t.createdAt),
                  (t) => OrderingTerm.desc(t.rowId),
                ])
                ..limit(100))
              .get();
      for (final row in recent) {
        final old = jsonDecode(row.payloadJson) as Map<String, dynamic>;
        if (old['type'] != payload['type']) continue;
        final delta =
            event.dateTime.millisecondsSinceEpoch -
            (old['detectedAtMs'] as int);
        if (delta < 30000 &&
            !(old['severity'] == 'WARNING' &&
                payload['severity'] == 'CRITICAL')) {
          return false;
        }
        break;
      }
      return outbox.enqueue(
        id: payload['id'] as String,
        organizationId: organizationId,
        ownerId: driverId,
        cloudTripId: cloudTripId,
        localTripId: localTripId,
        kind: 'INCIDENT',
        payload: payload,
        now: queuedAt,
      );
    });
  }
}
