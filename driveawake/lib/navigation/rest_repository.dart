import 'dart:convert';
import 'dart:math';
import 'package:crypto/crypto.dart';
import 'package:drift/drift.dart';
import '../data/database/driver_awake_database.dart';

class RestRepository {
  RestRepository(this.database);
  final DriverAwakeDatabase database;
  Future<RestSessionRow> start(
    String tripId,
    DateTime now,
    String reason, {
    Map<String, Object?>? fleetBinding,
  }) async {
    now = DateTime.fromMillisecondsSinceEpoch(
      (now.millisecondsSinceEpoch ~/ 1000) * 1000,
    );
    return database.transaction(() async {
      final open = await (database.select(
        database.restSessions,
      )..where((t) => t.endedAt.isNull())).getSingleOrNull();
      if (open != null) {
        throw StateError('Termina el descanso declarado que sigue abierto.');
      }
      final id = sha256
          .convert(
            utf8.encode(
              '$tripId:${now.microsecondsSinceEpoch}:${Random.secure().nextInt(1 << 32)}',
            ),
          )
          .toString();
      await database
          .into(database.restSessions)
          .insert(
            RestSessionsCompanion.insert(
              id: id,
              tripId: tripId,
              startedAt: now,
              recommendationReason: reason,
              voluntarilyConfirmed: true,
              fleetBindingJson: Value(
                fleetBinding == null ? null : jsonEncode(fleetBinding),
              ),
            ),
          );
      return (database.select(
        database.restSessions,
      )..where((t) => t.id.equals(id))).getSingle();
    });
  }

  Future<RestSessionRow?> finish(String tripId, DateTime now) async {
    now = DateTime.fromMillisecondsSinceEpoch(
      (now.millisecondsSinceEpoch ~/ 1000) * 1000,
    );
    return database.transaction(() async {
      final row =
          await (database.select(database.restSessions)
                ..where((t) => t.tripId.equals(tripId) & t.endedAt.isNull()))
              .getSingleOrNull();
      if (row == null) return null;
      if (now.isBefore(row.startedAt)) {
        throw StateError(
          'La hora del dispositivo retrocedió. Revisa el reloj.',
        );
      }
      await (database.update(
        database.restSessions,
      )..where((t) => t.id.equals(row.id))).write(
        RestSessionsCompanion(
          endedAt: Value(now),
          durationMs: Value(now.difference(row.startedAt).inMilliseconds),
        ),
      );
      return (database.select(
        database.restSessions,
      )..where((t) => t.id.equals(row.id))).getSingle();
    });
  }

  Future<List<RestSessionRow>> history() =>
      (database.select(database.restSessions)
            ..orderBy([(t) => OrderingTerm.desc(t.startedAt)])
            ..limit(100))
          .get();
}
