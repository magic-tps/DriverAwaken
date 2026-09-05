import 'dart:async';
import 'dart:math';

import '../data/database/database_provider.dart';
import '../data/repositories/drift_trip_repository.dart';
import '../models/device_telemetry_snapshot.dart';
import '../models/drowsiness_event.dart';
import '../models/drowsiness_state.dart';
import '../models/trip_session_summary.dart';
import '../models/trip_session_draft.dart';
import '../utils/drowsiness_thresholds.dart';
import 'local_history_service.dart';
import 'trip_session_draft_service.dart';

class TripSessionService {
  final LocalHistoryService _historyService = LocalHistoryService.instance;
  final TripSessionDraftService _draftService =
      TripSessionDraftService.instance;
  DriftTripRepository get _tripRepository =>
      DriftTripRepository(DatabaseProvider.database);

  String? _tripId;
  DateTime? _startedAt;
  DateTime? _lastObservedAt;
  bool _paused = false;
  bool _running = false;

  int _warningAlerts = 0;
  int _dangerAlerts = 0;
  int _yawnCount = 0;
  int _noFaceEvents = 0;
  int _normalSamples = 0;
  int _warningSamples = 0;
  int _dangerSamples = 0;
  int _sampleCount = 0;
  double _riskSum = 0;
  double _maxRisk = 0;
  Duration _closedEyeDuration = Duration.zero;
  Duration _drivingDuration = Duration.zero;
  DeviceTelemetrySnapshot? _firstTelemetry;
  DeviceTelemetrySnapshot? _lastTelemetry;
  double? _maxTemperatureC;

  DrowsinessLevel? _lastLevel;
  bool _lastYawning = false;
  bool _lastNoFace = false;
  final Map<String, DateTime> _lastEventAt = <String, DateTime>{};
  DateTime? _lastDraftSavedAt;
  Future<void> _pendingDraftWrite = Future<void>.value();

  bool get isRunning => _running;
  bool get isPaused => _paused;
  String? get tripId => _tripId;

  Duration get elapsed {
    if (!_running || _startedAt == null) {
      return _drivingDuration;
    }
    return _drivingDuration;
  }

  void start() {
    final now = DateTime.now();
    _tripId = 'trip_${now.millisecondsSinceEpoch}';
    _startedAt = now;
    _lastObservedAt = null;
    _paused = false;
    _running = true;
    _warningAlerts = 0;
    _dangerAlerts = 0;
    _yawnCount = 0;
    _noFaceEvents = 0;
    _normalSamples = 0;
    _warningSamples = 0;
    _dangerSamples = 0;
    _sampleCount = 0;
    _riskSum = 0;
    _maxRisk = 0;
    _closedEyeDuration = Duration.zero;
    _drivingDuration = Duration.zero;
    _firstTelemetry = null;
    _lastTelemetry = null;
    _maxTemperatureC = null;
    _lastLevel = null;
    _lastYawning = false;
    _lastNoFace = false;
    _lastEventAt.clear();
    _lastDraftSavedAt = null;
    unawaited(_saveDraft(now, force: true));
  }

  void restore(TripSessionDraft draft) {
    _tripId = draft.tripId;
    _startedAt = draft.startedAt;
    _lastObservedAt = null;
    _paused = true;
    _running = true;
    _warningAlerts = draft.warningAlerts;
    _dangerAlerts = draft.dangerAlerts;
    _yawnCount = draft.yawnCount;
    _noFaceEvents = draft.noFaceEvents;
    _normalSamples = draft.normalSamples;
    _warningSamples = draft.warningSamples;
    _dangerSamples = draft.dangerSamples;
    _sampleCount = draft.sampleCount;
    _riskSum = draft.riskSum;
    _maxRisk = draft.maxRisk;
    _closedEyeDuration = draft.closedEyeDuration;
    _drivingDuration = draft.drivingDuration;
    _lastDraftSavedAt = draft.updatedAt;
    unawaited(_saveDraft(DateTime.now(), force: true));
  }

  void pause() {
    _paused = true;
    _lastObservedAt = null;
    unawaited(_saveDraft(DateTime.now(), force: true));
  }

  void resume() {
    _paused = false;
    _lastObservedAt = null;
    unawaited(_saveDraft(DateTime.now(), force: true));
  }

  void recordDeviceTelemetry(DeviceTelemetrySnapshot snapshot) {
    if (!_running) {
      return;
    }
    _firstTelemetry ??= snapshot;
    _lastTelemetry = snapshot;
    final temperature = snapshot.temperatureC;
    if (temperature != null) {
      _maxTemperatureC = max(_maxTemperatureC ?? temperature, temperature);
    }
  }

  Future<void> observe(DrowsinessState state, DateTime timestamp) async {
    if (!_running || _paused) {
      return;
    }

    final previousTimestamp = _lastObservedAt;
    final delta = previousTimestamp == null
        ? Duration.zero
        : timestamp.difference(previousTimestamp);
    _lastObservedAt = timestamp;
    if (delta > Duration.zero && delta < const Duration(seconds: 3)) {
      _drivingDuration += delta;
      if (state.eyesClosed) {
        _closedEyeDuration += delta;
      }
    }

    _sampleCount += 1;
    _riskSum += state.riskScore;
    _maxRisk = max(_maxRisk, state.riskScore);
    switch (state.level) {
      case DrowsinessLevel.normal:
        _normalSamples += 1;
      case DrowsinessLevel.warning:
        _warningSamples += 1;
      case DrowsinessLevel.danger:
        _dangerSamples += 1;
    }

    final levelChanged = _lastLevel != state.level;
    if (levelChanged) {
      if (state.level == DrowsinessLevel.warning) {
        _warningAlerts += 1;
        await _recordEvent('alerta_precaucion', state, timestamp);
      } else if (state.level == DrowsinessLevel.danger) {
        _dangerAlerts += 1;
        await _recordEvent('alarma_critica', state, timestamp);
      }
    }

    if (state.yawning && !_lastYawning) {
      _yawnCount += 1;
      await _recordEvent('bostezo', state, timestamp);
    }
    if (!state.faceDetected && !_lastNoFace) {
      _noFaceEvents += 1;
      await _recordEvent('rostro_ausente', state, timestamp);
    }
    if (state.prolongedBlink) {
      await _recordEvent('ojos_cerrados_prolongados', state, timestamp);
    }
    if (state.headDown) {
      await _recordEvent('cabeza_caida', state, timestamp);
    }
    if (state.distracted) {
      await _recordEvent('distraccion', state, timestamp);
    }
    if (state.perclosReady &&
        state.perclos >= DrowsinessThresholds.perclosDanger) {
      await _recordEvent('perclos_alto', state, timestamp);
    }
    if ((state.modelDrowsyProbability ?? 0) >= 0.65) {
      await _recordEvent('modelo_somnolencia', state, timestamp);
    }

    _lastLevel = state.level;
    _lastYawning = state.yawning;
    _lastNoFace = !state.faceDetected;
    await _saveDraft(timestamp, force: levelChanged);
  }

  Future<TripSessionSummary> finish() async {
    final now = DateTime.now();
    final startedAt = _startedAt ?? now;
    final summary = TripSessionSummary(
      tripId: _tripId ?? 'trip_${now.millisecondsSinceEpoch}',
      startedAt: startedAt,
      endedAt: now,
      drivingDuration: _drivingDuration,
      warningAlerts: _warningAlerts,
      dangerAlerts: _dangerAlerts,
      yawnCount: _yawnCount,
      closedEyeDuration: _closedEyeDuration,
      noFaceEvents: _noFaceEvents,
      averageRisk: _sampleCount == 0 ? 0 : _riskSum / _sampleCount,
      maxRisk: _maxRisk,
      dominantLevel: _dominantLevel(),
      startBatteryLevel: _firstTelemetry?.batteryLevel,
      endBatteryLevel: _lastTelemetry?.batteryLevel,
      startTemperatureC: _firstTelemetry?.temperatureC,
      endTemperatureC: _lastTelemetry?.temperatureC,
      maxTemperatureC: _maxTemperatureC,
      isCharging: _lastTelemetry?.isCharging ?? false,
    );
    _running = false;
    _paused = false;
    _lastObservedAt = null;
    await _pendingDraftWrite;
    await _tripRepository.finishTrip(_draftSnapshot(now), summary);
    return summary;
  }

  Future<void> discard() async {
    final id = _tripId;
    _running = false;
    _paused = false;
    _lastObservedAt = null;
    await _pendingDraftWrite;
    if (id != null) {
      await _tripRepository.discardTrip(id);
    } else {
      await _draftService.clear();
    }
  }

  Future<void> _saveDraft(DateTime timestamp, {required bool force}) async {
    if (!_running || _tripId == null || _startedAt == null) {
      return;
    }
    final lastSavedAt = _lastDraftSavedAt;
    if (!force &&
        lastSavedAt != null &&
        timestamp.difference(lastSavedAt) < const Duration(seconds: 15)) {
      return;
    }
    _lastDraftSavedAt = timestamp;
    final draft = _draftSnapshot(timestamp);
    _pendingDraftWrite = _pendingDraftWrite
        .onError((_, _) {})
        .then((_) => _draftService.save(draft));
    await _pendingDraftWrite;
  }

  TripSessionDraft _draftSnapshot(DateTime timestamp) {
    return TripSessionDraft(
      tripId: _tripId!,
      startedAt: _startedAt!,
      updatedAt: timestamp,
      drivingDuration: _drivingDuration,
      warningAlerts: _warningAlerts,
      dangerAlerts: _dangerAlerts,
      yawnCount: _yawnCount,
      noFaceEvents: _noFaceEvents,
      normalSamples: _normalSamples,
      warningSamples: _warningSamples,
      dangerSamples: _dangerSamples,
      sampleCount: _sampleCount,
      riskSum: _riskSum,
      maxRisk: _maxRisk,
      closedEyeDuration: _closedEyeDuration,
      paused: _paused,
      incomplete: true,
    );
  }

  Future<void> _recordEvent(
    String eventType,
    DrowsinessState state,
    DateTime timestamp,
  ) async {
    final lastEventAt = _lastEventAt[eventType];
    if (lastEventAt != null &&
        timestamp.difference(lastEventAt) <
            DrowsinessThresholds.eventCooldown) {
      return;
    }
    _lastEventAt[eventType] = timestamp;

    await _historyService.addEvent(
      DrowsinessEvent(
        id: '${eventType}_${timestamp.microsecondsSinceEpoch}',
        dateTime: timestamp,
        level: state.level,
        eventType: eventType,
        durationSeconds: _durationFor(eventType, state),
        riskScore: state.riskScore,
        perclos: state.perclos,
        modelPrediction: state.modelLabel,
        modelConfidence: state.modelConfidence,
        tripId: _tripId,
        notes: state.riskReason,
      ),
    );
  }

  double _durationFor(String eventType, DrowsinessState state) {
    switch (eventType) {
      case 'ojos_cerrados_prolongados':
        return state.eyeClosedDurationSeconds;
      case 'rostro_ausente':
        return state.noFaceDurationSeconds;
      case 'cabeza_caida':
        return state.headDownDurationSeconds;
      case 'distraccion':
        return state.distractedDurationSeconds;
      default:
        return 0;
    }
  }

  DrowsinessLevel _dominantLevel() {
    if (_dangerSamples >= _warningSamples && _dangerSamples >= _normalSamples) {
      return DrowsinessLevel.danger;
    }
    if (_warningSamples >= _normalSamples) {
      return DrowsinessLevel.warning;
    }
    return DrowsinessLevel.normal;
  }
}
