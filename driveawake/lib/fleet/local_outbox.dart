import 'dart:convert';
import 'dart:math';
import 'package:drift/drift.dart';
import '../data/database/driver_awake_database.dart';

class LocalOutbox {
  LocalOutbox(this.database, {Random? random}) : random = random ?? Random();
  final DriverAwakeDatabase database;
  final Random random;
  static const maxPending = 2000;

  Future<bool> enqueue({
    required String id,
    required String organizationId,
    required String ownerId,
    required String cloudTripId,
    required String localTripId,
    required String kind,
    required Map<String, Object?> payload,
    required DateTime now,
  }) {
    return database.transaction(() async {
      final existing = await (database.select(
        database.fleetOutbox,
      )..where((t) => t.id.equals(id))).getSingleOrNull();
      if (existing != null) return false;
      final count = await (database.select(
        database.fleetOutbox,
      )..where((t) => t.syncStatus.isNotValue('SYNCED'))).get();
      if (count.length >= maxPending) {
        throw StateError('Cola llena: exporta los datos y revisa la conexión.');
      }
      await database
          .into(database.fleetOutbox)
          .insert(
            FleetOutboxCompanion.insert(
              id: id,
              organizationId: organizationId,
              ownerId: ownerId,
              cloudTripId: cloudTripId,
              localTripId: localTripId,
              kind: kind,
              payloadJson: jsonEncode(payload),
              nextAttemptAt: now,
              createdAt: now,
              updatedAt: now,
            ),
          );
      return true;
    });
  }

  Future<List<FleetOutboxData>> pending(String ownerId) =>
      (database.select(database.fleetOutbox)
            ..where(
              (t) =>
                  t.ownerId.equals(ownerId) & t.syncStatus.isNotValue('SYNCED'),
            )
            ..orderBy([
              (t) => OrderingTerm.asc(t.createdAt),
              (t) => OrderingTerm.asc(t.rowId),
            ])
            ..limit(maxPending))
          .get();

  Future<bool> stillPending(String id) async {
    final row = await (database.select(
      database.fleetOutbox,
    )..where((t) => t.id.equals(id))).getSingleOrNull();
    return row != null && row.syncStatus != 'SYNCED';
  }

  Future<void> mark(String id, String status, DateTime now) =>
      (database.update(
        database.fleetOutbox,
      )..where((t) => t.id.equals(id))).write(
        FleetOutboxCompanion(
          syncStatus: Value(status),
          updatedAt: Value(now),
          lastError: const Value(null),
        ),
      );

  Future<void> failed(FleetOutboxData row, DateTime now, String code) async {
    final attempts = row.attempts + 1;
    final seconds = min(900, 5 * pow(2, min(attempts - 1, 8)).toInt());
    await (database.update(
      database.fleetOutbox,
    )..where((t) => t.id.equals(row.id))).write(
      FleetOutboxCompanion(
        syncStatus: const Value('FAILED'),
        attempts: Value(attempts),
        nextAttemptAt: Value(
          now.add(
            Duration(seconds: seconds + random.nextInt(max(1, seconds ~/ 4))),
          ),
        ),
        updatedAt: Value(now),
        lastError: Value(code),
      ),
    );
  }

  Future<void> revoke(String ownerId, {String? organizationId}) async {
    await (database.delete(database.fleetOutbox)..where(
          (t) =>
              t.ownerId.equals(ownerId) &
              (organizationId == null
                  ? const Constant(true)
                  : t.organizationId.equals(organizationId)),
        ))
        .go();
  }

  Future<void> retainSince(DateTime cutoff) async {
    await (database.delete(
      database.fleetOutbox,
    )..where((t) => t.createdAt.isSmallerThanValue(cutoff))).go();
  }
}
