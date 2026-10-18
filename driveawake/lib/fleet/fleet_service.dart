import 'dart:async';
import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:drift/drift.dart' show BooleanExpressionOperators;
import '../data/database/database_provider.dart';
import '../data/database/driver_awake_database.dart';
import '../models/drowsiness_event.dart';
import '../models/drowsiness_state.dart';
import '../models/app_settings.dart' show HistoryRetentionLabel;
import '../services/cloud_report_service.dart';
import '../services/settings_service.dart';
import 'authorized_cloud_sync.dart';
import 'incident_repository.dart';
import 'local_outbox.dart';

class AssignedFleetTrip {
  const AssignedFleetTrip({
    required this.id,
    required this.organizationId,
    required this.driverId,
    required this.vehicleId,
    required this.origin,
    required this.destination,
  });
  final String id, organizationId, driverId, vehicleId, origin, destination;
}

/// Optional transport domain. Never touches camera processing or local alarms.
class FleetService extends ChangeNotifier {
  FleetService._();
  static final instance = FleetService._();
  DriverAwakeDatabase get _db => DatabaseProvider.database;
  LocalOutbox get _outbox => LocalOutbox(_db);
  String? get _uid => CloudReportService.instance.user?.uid;
  FirebaseFirestore get _store => FirebaseFirestore.instance;
  AssignedFleetTrip? selected;
  String? _localTripId;
  DateTime? _lastHealth;
  String _monitoring = 'UNAVAILABLE';
  int pendingCount = 0;
  int sessionIncidents = 0;
  String status = 'Modo personal · datos solo en este dispositivo';
  Timer? _timer;
  AuthorizedCloudSync? _worker;
  Future<void> _writes = Future.value();

  bool _revoking = false;

  Future<List<AssignedFleetTrip>> loadAssigned(String organizationId) async {
    await CloudReportService.instance.initialize();
    if (_uid == null) {
      throw StateError('Inicia sesión antes de vincular una flota.');
    }
    final org = _store.collection('organizations').doc(organizationId);
    final membership = await org
        .collection('members')
        .doc(_uid)
        .get(const GetOptions(source: Source.server));
    if (membership.data()?['status'] != 'ACTIVE' ||
        membership.data()?['role'] != 'DRIVER') {
      throw StateError(
        'No tienes una membresía de conductor activa en esta flota.',
      );
    }
    final docs = await org
        .collection('trips')
        .where('driverId', isEqualTo: _uid)
        .get(const GetOptions(source: Source.server))
        .timeout(const Duration(seconds: 15));
    return docs.docs
        .where((doc) => ['ASSIGNED', 'ACTIVE'].contains(doc.data()['status']))
        .map(
          (doc) => AssignedFleetTrip(
            id: doc.id,
            organizationId: organizationId,
            driverId: _uid!,
            vehicleId: doc.data()['vehicleId'] as String,
            origin: doc.data()['origin'] as String,
            destination: doc.data()['destination'] as String,
          ),
        )
        .toList();
  }

  Future<void> consent(AssignedFleetTrip trip, {bool shareRest = false}) async {
    if (trip.driverId != _uid) {
      throw StateError('La cuenta cambió. Vuelve a seleccionar el viaje.');
    }
    if (_localTripId != null) {
      throw StateError('Finaliza el monitoreo antes de cambiar de viaje.');
    }
    final prior = await _readConsent();
    if (prior?['shareRest'] == true && !shareRest) {
      await (_db.delete(_db.fleetOutbox)..where(
            (t) =>
                t.ownerId.equals(trip.driverId) &
                t.organizationId.equals(trip.organizationId) &
                t.kind.equals('REST_SESSION'),
          ))
          .go();
    }
    if (prior != null &&
        (prior['ownerId'] != _uid ||
            prior['organizationId'] != trip.organizationId)) {
      throw StateError(
        'Desvincula la flota anterior antes de cambiar de cuenta o empresa.',
      );
    }
    await _db
        .into(_db.appSettings)
        .insertOnConflictUpdate(
          AppSettingsCompanion.insert(
            id: 'guardian_fleet_consent',
            payloadJson: jsonEncode({
              'ownerId': _uid,
              'organizationId': trip.organizationId,
              'consentedAt': DateTime.now().toIso8601String(),
              'version': 1,
              'shareRest': shareRest,
            }),
            updatedAt: DateTime.now(),
          ),
        );
    selected = trip;
    _revoking = false;
    status = 'Modo flota · compartir incidentes autorizado';
    _ensureWorker();
    await refresh();
  }

  Future<Map<String, dynamic>?> _readConsent() async {
    final row = await (_db.select(
      _db.appSettings,
    )..where((t) => t.id.equals('guardian_fleet_consent'))).getSingleOrNull();
    return row == null
        ? null
        : jsonDecode(row.payloadJson) as Map<String, dynamic>;
  }

  void _ensureWorker() {
    _worker ??= AuthorizedCloudSync(
      outbox: _outbox,
      send: _send,
      authorized: (row) async {
        if (_revoking || _uid != row.ownerId) return false;
        final consent = await _readConsent();
        return consent?['ownerId'] == row.ownerId &&
            consent?['organizationId'] == row.organizationId;
      },
    );
    _timer ??= Timer.periodic(
      const Duration(seconds: 15),
      (_) => unawaited(refresh()),
    );
  }

  Future<void> refresh() async {
    try {
      if (_uid == null) {
        status = 'Sin sesión · sincronización detenida';
        notifyListeners();
        return;
      }
      _ensureWorker();
      await SettingsService.instance.initialize();
      final retention =
          SettingsService.instance.settings.historyRetention.duration;
      if (retention != null) {
        await _outbox.retainSince(DateTime.now().subtract(retention));
      }
      await _worker!.flush(_uid!);
      final pending = await _outbox.pending(_uid!);
      pendingCount = pending.length;
      status = pending.isEmpty
          ? 'Sin pendientes de sincronización'
          : pending.first.syncStatus == 'FAILED'
          ? 'Sin confirmación de la central · $pendingCount pendientes'
          : '$pendingCount mensajes pendientes';
    } catch (_) {
      status = 'No se pudo verificar la central · cola local conservada';
    }
    notifyListeners();
  }

  Future<void> revoke() async {
    _revoking = true;
    selected = null;
    _localTripId = null;
    _timer?.cancel();
    _timer = null;
    await _writes;
    final consent = await _readConsent();
    if (consent != null) await _outbox.revoke(consent['ownerId'] as String);
    await (_db.delete(
      _db.appSettings,
    )..where((t) => t.id.equals('guardian_fleet_consent'))).go();
    pendingCount = 0;
    status =
        'Modo personal · cola eliminada; los datos remotos requieren solicitud a la flota';
    notifyListeners();
  }

  void startLocal(String localTripId) {
    if (selected == null || selected!.driverId != _uid || _revoking) return;
    _localTripId = localTripId;
    sessionIncidents = 0;

    _lastHealth = null;
    health('UNAVAILABLE', status: 'ACTIVE');
  }

  void health(String monitoring, {String? status}) {
    final trip = selected;
    final localId = _localTripId;
    if (trip == null || localId == null || _revoking) return;
    final now = DateTime.now();
    // Debounce fluctuating signal quality; explicit pause/end bypass the gate.
    if (status == null &&
        monitoring != 'PAUSED' &&
        _lastHealth != null &&
        now.difference(_lastHealth!) < const Duration(seconds: 15)) {
      return;
    }
    if (status == null &&
        monitoring == _monitoring &&
        _lastHealth != null &&
        now.difference(_lastHealth!) < const Duration(seconds: 60)) {
      return;
    }
    _monitoring = monitoring;
    _lastHealth = now;
    final id = 'health_${localId}_${now.microsecondsSinceEpoch}';
    _serialize(
      () => _outbox.enqueue(
        id: id,
        organizationId: trip.organizationId,
        ownerId: trip.driverId,
        cloudTripId: trip.id,
        localTripId: localId,
        kind: 'TRIP_HEALTH',
        payload: {
          'monitoringStatus': monitoring,
          'observedAtMs': now.millisecondsSinceEpoch,
          if (status != null) 'status': status,
          if (['COMPLETED', 'CANCELLED'].contains(status))
            'endTimeMs': now.millisecondsSinceEpoch,
        },
        now: now,
      ),
    );
  }

  Future<void> capture(DrowsinessEvent event, {DrowsinessState? signal}) async {
    final trip = selected;
    final localId = _localTripId;
    if (trip == null || localId == null || _revoking || trip.driverId != _uid) {
      return;
    }
    await _serialize(() async {
      final added = await IncidentRepository(_outbox).record(
        event,
        organizationId: trip.organizationId,
        driverId: trip.driverId,
        cloudTripId: trip.id,
        localTripId: localId,
        signal: signal,
        queuedAt: DateTime.now(),
      );
      if (added) {
        sessionIncidents++;
        pendingCount++;
      }
    });
  }

  Future<void> _serialize(Future<dynamic> Function() action) {
    _writes = _writes
        .then((_) async {
          await action();
        })
        .catchError((Object error) {
          status =
              'No se pudo guardar el mensaje de flota · revisa almacenamiento y cola';
        });
    return _writes;
  }

  Future<Map<String, Object?>?> restBinding() async {
    final trip = selected;
    final consent = await _readConsent();
    if (trip == null ||
        _revoking ||
        trip.driverId != _uid ||
        consent?['shareRest'] != true) {
      return null;
    }
    return {
      'organizationId': trip.organizationId,
      'cloudTripId': trip.id,
      'ownerId': trip.driverId,
    };
  }

  Future<void> captureRest(RestSessionRow rest) async {
    if (rest.fleetBindingJson == null || rest.endedAt == null || _revoking) {
      return;
    }
    final binding = jsonDecode(rest.fleetBindingJson!) as Map<String, dynamic>;
    final consent = await _readConsent();
    if (consent?['shareRest'] != true ||
        _uid != binding['ownerId'] ||
        consent?['organizationId'] != binding['organizationId']) {
      return;
    }
    await _serialize(
      () => _outbox.enqueue(
        id: rest.id,
        organizationId: binding['organizationId'] as String,
        ownerId: binding['ownerId'] as String,
        cloudTripId: binding['cloudTripId'] as String,
        localTripId: rest.tripId,
        kind: 'REST_SESSION',
        payload: {
          'id': rest.id,
          'organizationId': binding['organizationId'],
          'tripId': binding['cloudTripId'],
          'driverId': binding['ownerId'],
          'startedAtMs': rest.startedAt.millisecondsSinceEpoch,
          'endedAtMs': rest.endedAt!.millisecondsSinceEpoch,
          'durationMs': rest.durationMs,
          'recommendationReason': rest.recommendationReason,
          'voluntarilyConfirmed': true,
        },
        now: DateTime.now(),
      ),
    );
  }

  Future<void> finish({bool discard = false}) async {
    health('PAUSED', status: discard ? 'CANCELLED' : 'COMPLETED');
    await _writes;
    _localTripId = null;
    selected = null;
    unawaited(refresh());
  }

  Future<void> _send(FleetOutboxData row) async {
    final org = _store.collection('organizations').doc(row.organizationId);
    await _store.runTransaction(
      (tx) async {
        final data = jsonDecode(row.payloadJson) as Map<String, dynamic>;
        // Transaction callbacks may retry: consent and identity are checked again.
        if (_revoking || _uid != row.ownerId) {
          throw StateError('Consentimiento revocado');
        }
        final consent = await _readConsent();
        if (consent?['ownerId'] != row.ownerId ||
            consent?['organizationId'] != row.organizationId) {
          throw StateError('Sin consentimiento');
        }
        if (!await _outbox.stillPending(row.id)) {
          throw StateError('Mensaje eliminado localmente');
        }
        final membership = await tx.get(
          org.collection('members').doc(row.ownerId),
        );
        final tripRef = org.collection('trips').doc(row.cloudTripId);
        final trip = await tx.get(tripRef);
        if (membership.data()?['status'] != 'ACTIVE' ||
            membership.data()?['role'] != 'DRIVER' ||
            trip.data()?['driverId'] != row.ownerId) {
          throw StateError('Asignación no autorizada');
        }
        if (row.kind == 'INCIDENT') {
          final ref = org.collection('incidents').doc(row.id);
          final existing = await tx.get(ref);
          if (existing.exists) {
            return; // Lost server acknowledgement: same ID, no second write.
          }
          final detected = data.remove('detectedAtMs') as int;
          tx.set(ref, {
            ...data,
            'detectedAt': Timestamp.fromMillisecondsSinceEpoch(detected),
            'receivedAt': FieldValue.serverTimestamp(),
          });
          tx.update(tripRef, {'lastEventAt': FieldValue.serverTimestamp()});
        } else if (row.kind == 'REST_SESSION') {
          if (consent?['shareRest'] != true) {
            throw StateError('Descansos no autorizados');
          }
          final ref = org.collection('restSessions').doc(row.id);
          if ((await tx.get(ref)).exists) return;
          final start = data.remove('startedAtMs') as int,
              end = data.remove('endedAtMs') as int;
          tx.set(ref, {
            ...data,
            'startedAt': Timestamp.fromMillisecondsSinceEpoch(start),
            'endedAt': Timestamp.fromMillisecondsSinceEpoch(end),
            'receivedAt': FieldValue.serverTimestamp(),
          });
        } else {
          final ended = data.remove('endTimeMs') as int?;
          final observed = data.remove('observedAtMs') as int;
          if (ended != null &&
              trip.data()?['status'] == data['status'] &&
              (trip.data()?['endTime'] as Timestamp?)?.millisecondsSinceEpoch ==
                  ended) {
            return;
          }
          if (ended != null) {
            data['endTime'] = Timestamp.fromMillisecondsSinceEpoch(ended);
          }
          tx.update(tripRef, {
            ...data,
            'lastSeenAt': Timestamp.fromMillisecondsSinceEpoch(observed),
          });
        }
      },
      timeout: const Duration(seconds: 12),
      maxAttempts: 2,
    );
  }
}
