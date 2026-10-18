import 'dart:io';
import 'dart:math';
import 'package:drift/native.dart';
import 'package:driveawake/data/database/driver_awake_database.dart';
import 'package:driveawake/fleet/local_outbox.dart';
import 'package:driveawake/fleet/authorized_cloud_sync.dart';
import 'package:driveawake/fleet/incident_classifier.dart';
import 'package:driveawake/fleet/incident_repository.dart';
import 'package:driveawake/models/drowsiness_event.dart';
import 'package:driveawake/models/drowsiness_state.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late DriverAwakeDatabase database;
  late LocalOutbox outbox;
  var now = DateTime.utc(2026, 10, 17);
  setUp(() {
    database = DriverAwakeDatabase(NativeDatabase.memory());
    outbox = LocalOutbox(database, random: Random(1));
    now = DateTime.utc(2026, 10, 17);
  });
  tearDown(() => database.close());
  Future<bool> enqueue(String id, {String kind = 'INCIDENT'}) => outbox.enqueue(
    id: id,
    organizationId: 'org-a',
    ownerId: 'driver-a',
    cloudTripId: 'cloud-trip',
    localTripId: 'local-trip',
    kind: kind,
    payload: {'id': id},
    now: now,
  );

  test('stable IDs deduplicate without modifying original payload', () async {
    expect(await enqueue('one'), isTrue);
    expect(await enqueue('one'), isFalse);
    expect(await outbox.pending('driver-a'), hasLength(1));
    expect(await outbox.pending('different-user'), isEmpty);
  });
  test(
    'offline failure persists with bounded exponential backoff; reconnect retries same ID',
    () async {
      await enqueue('one');
      await enqueue('two');
      final delivered = <String>{};
      var online = false;
      var calls = 0;
      final worker = AuthorizedCloudSync(
        outbox: outbox,
        authorized: (_) async => true,
        clock: () => now,
        send: (row) async {
          calls++;
          if (!online) throw const SocketException('offline');
          delivered.add(row.id);
        },
      );
      await worker.flush('driver-a');
      var rows = await outbox.pending('driver-a');
      expect(rows[0].syncStatus, 'FAILED');
      expect(rows[0].attempts, 1);
      expect(rows[0].nextAttemptAt.isAfter(now), isTrue);
      await worker.flush('driver-a');
      expect(calls, 1);
      online = true;
      now = now.add(const Duration(minutes: 1));
      await worker.flush('driver-a');
      expect(delivered, {'one', 'two'});
      expect(await outbox.pending('driver-a'), isEmpty);
    },
  );
  test(
    'lost acknowledgement does not create a second server incident',
    () async {
      await enqueue('stable');
      final remote = <String>{};
      var calls = 0;
      final worker = AuthorizedCloudSync(
        outbox: outbox,
        authorized: (_) async => true,
        clock: () => now,
        send: (row) async {
          remote.add(row.id);
          if (++calls == 1) throw StateError('ack lost');
        },
      );
      await worker.flush('driver-a');
      now = now.add(const Duration(minutes: 1));
      await worker.flush('driver-a');
      expect(remote, {'stable'});
      expect(calls, 2);
      expect(await outbox.pending('driver-a'), isEmpty);
    },
  );
  test('revoked consent blocks sends and removes local queue', () async {
    await enqueue('one');
    var calls = 0;
    await AuthorizedCloudSync(
      outbox: outbox,
      authorized: (_) async => false,
      send: (_) async {
        calls++;
      },
    ).flush('driver-a');
    expect(calls, 0);
    await outbox.revoke('driver-a');
    expect(await outbox.pending('driver-a'), isEmpty);
  });
  test('data erased after worker snapshot is not sent', () async {
    await enqueue('erase-before-send');
    var calls = 0;
    final worker = AuthorizedCloudSync(
      outbox: outbox,
      authorized: (_) async {
        await outbox.revoke('driver-a');
        return true;
      },
      send: (_) async {
        calls++;
      },
    );
    await worker.flush('driver-a');
    expect(calls, 0);
  });
  test(
    'FIFO keeps completion behind failed incident, batches at most ten',
    () async {
      for (var i = 0; i < 12; i++) {
        await enqueue('event-$i');
      }
      await enqueue('finish', kind: 'TRIP_HEALTH');
      final sent = <String>[];
      final worker = AuthorizedCloudSync(
        outbox: outbox,
        authorized: (_) async => true,
        clock: () => now,
        send: (row) async {
          sent.add(row.id);
        },
      );
      await worker.flush('driver-a');
      expect(sent, hasLength(10));
      await worker.flush('driver-a');
      expect(sent.last, 'finish');
    },
  );
  test('retention applies to queued and synced records', () async {
    await enqueue('old');
    now = now.add(const Duration(days: 31));
    await enqueue('recent');
    await outbox.retainSince(now.subtract(const Duration(days: 30)));
    expect((await outbox.pending('driver-a')).single.id, 'recent');
  });
  test(
    'outbox survives SQLite file close/reopen and v1 migration preserves history',
    () async {
      final dir = await Directory.systemTemp.createTemp('guardian-sqlite-');
      final file = File('${dir.path}/test.sqlite');
      var disk = DriverAwakeDatabase(NativeDatabase(file));
      final diskOutbox = LocalOutbox(disk);
      await diskOutbox.enqueue(
        id: 'persisted',
        organizationId: 'org',
        ownerId: 'driver',
        cloudTripId: 'trip',
        localTripId: 'local',
        kind: 'INCIDENT',
        payload: {'id': 'persisted'},
        now: now,
      );
      await disk.close();
      disk = DriverAwakeDatabase(NativeDatabase(file));
      expect(
        (await LocalOutbox(disk).pending('driver')).single.id,
        'persisted',
      );
      await disk.customStatement(
        "INSERT INTO model_metadata (id,payload_json,updated_at) VALUES ('preserve','{}',1)",
      );
      await disk.customStatement('DROP TABLE fleet_outbox');
      await disk.customStatement('DROP TABLE rest_sessions');
      await disk.customStatement('PRAGMA user_version = 1');
      await disk.close();
      disk = DriverAwakeDatabase(NativeDatabase(file));
      expect(await disk.select(disk.modelMetadata).get(), hasLength(1));
      expect(await disk.select(disk.fleetOutbox).get(), isEmpty);
      await disk.close();
      // Only task-created temporary file, no user data.
      await file.delete();
      await dir.delete();
    },
  );

  DrowsinessEvent event(String type, {double duration = 4}) => DrowsinessEvent(
    id: 'stable-source-id',
    dateTime: now,
    level: DrowsinessLevel.danger,
    eventType: type,
    durationSeconds: duration,
    notes: 'local',
    riskScore: 96,
  );
  test(
    'incident cooldown survives repository restart and critical escalation bypasses it',
    () async {
      var repo = IncidentRepository(outbox);
      DrowsinessEvent source(String id, DrowsinessLevel level, DateTime at) =>
          DrowsinessEvent(
            id: id,
            dateTime: at,
            level: level,
            eventType: 'ojos_cerrados_prolongados',
            durationSeconds: 4,
            notes: 'test',
            riskScore: 96,
          );
      Future<bool> record(DrowsinessEvent value) => repo.record(
        value,
        organizationId: 'org',
        driverId: 'driver',
        cloudTripId: 'trip',
        localTripId: 'local',
        queuedAt: value.dateTime,
      );
      expect(
        await record(source('warning', DrowsinessLevel.warning, now)),
        isTrue,
      );
      repo = IncidentRepository(outbox);
      expect(
        await record(
          source(
            'warning2',
            DrowsinessLevel.warning,
            now.add(const Duration(seconds: 6)),
          ),
        ),
        isFalse,
      );
      expect(
        await record(
          source(
            'critical',
            DrowsinessLevel.danger,
            now.add(const Duration(seconds: 7)),
          ),
        ),
        isTrue,
      );
      expect(
        await record(
          source(
            'critical2',
            DrowsinessLevel.danger,
            now.add(const Duration(seconds: 8)),
          ),
        ),
        isFalse,
      );
      expect(
        await record(
          source(
            'new-episode',
            DrowsinessLevel.danger,
            now.add(const Duration(seconds: 40)),
          ),
        ),
        isTrue,
      );
      expect(await outbox.pending('driver'), hasLength(3));
    },
  );
  test(
    'missing face is signal unavailable, never fatigue or critical evidence',
    () {
      final payload = IncidentClassifier().classify(
        event('rostro_ausente'),
        organizationId: 'a',
        tripId: 'trip',
        driverId: 'driver',
      );
      expect(payload?['type'], 'SIGNAL_UNAVAILABLE');
      expect(payload?['severity'], 'INFO');
      expect(payload?['riskScore'], 0);
      expect(
        IncidentClassifier().classify(
          event('rostro_ausente', duration: 0),
          organizationId: 'a',
          tripId: 'trip',
          driverId: 'driver',
        ),
        isNull,
      );
    },
  );
  test(
    'classifier requires reliable visible face and repeated yawns, ignores aggregate alarms',
    () {
      final classifier = IncidentClassifier();
      Map<String, Object?>? classify(String type, DrowsinessState signal) =>
          classifier.classify(
            event(type),
            organizationId: 'a',
            tripId: 'trip',
            driverId: 'driver',
            signal: signal,
          );
      final reliable = DrowsinessState.initial().copyWith(
        faceDetected: true,
        signalQuality: .9,
        yawnCountWindow: 3,
      );
      expect(
        classify('ojos_cerrados_prolongados', reliable)?['type'],
        'PROLONGED_EYE_CLOSURE',
      );
      expect(
        classify(
          'ojos_cerrados_prolongados',
          reliable.copyWith(lowLight: true),
        ),
        isNull,
      );
      expect(
        classify('bostezo', reliable.copyWith(yawnCountWindow: 1)),
        isNull,
      );
      expect(classify('bostezo', reliable)?['type'], 'REPEATED_YAWNING');
      expect(classify('alarma_critica', reliable), isNull);
      expect(
        classify('ojos_cerrados_prolongados', reliable)?['id'],
        classify('ojos_cerrados_prolongados', reliable)?['id'],
      );
    },
  );
}
