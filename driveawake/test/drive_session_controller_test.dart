import 'dart:async';

import 'package:driveawake/features/drive/application/drive_session_controller.dart';
import 'package:driveawake/features/drive/application/drive_state.dart';
import 'package:driveawake/models/drowsiness_state.dart';
import 'package:driveawake/models/trip_session_draft.dart';
import 'package:driveawake/models/trip_session_summary.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('inicia una sesion y activa monitoreo', () async {
    final resources = _FakeResources();
    final controller = DriveSessionController(resources: resources);
    await controller.start();
    expect(controller.state.phase, DriveSessionPhase.active);
    expect(resources.prepareCalls, 1);
    expect(resources.startCalls, 1);
  });

  test('pausa doble es idempotente', () async {
    final resources = _FakeResources();
    final controller = DriveSessionController(resources: resources);
    await controller.start();
    await Future.wait(<Future<void>>[controller.pause(), controller.pause()]);
    expect(controller.state.phase, DriveSessionPhase.paused);
    expect(resources.pauseCalls, 1);
  });

  test('reanudacion doble ejecuta una unica cuenta y stream', () async {
    final resources = _FakeResources();
    final countdowns = <int>[];
    final controller = DriveSessionController(
      resources: resources,
      delay: (_) async {},
    );
    controller.addListener(() {
      final value = controller.state.resumeCountdown;
      if (value != null) countdowns.add(value);
    });
    await controller.start(recoveredDraft: _draft());
    await Future.wait(<Future<void>>[controller.resume(), controller.resume()]);
    expect(countdowns, <int>[3, 2, 1]);
    expect(resources.startCalls, 1);
    expect(controller.state.phase, DriveSessionPhase.active);
  });

  test('background durante reanudacion cancela el inicio', () async {
    final resources = _FakeResources();
    final delayed = Completer<void>();
    final controller = DriveSessionController(
      resources: resources,
      delay: (_) => delayed.future,
    );
    await controller.start(recoveredDraft: _draft());
    final resume = controller.resume();
    await controller.appMovedToBackground();
    delayed.complete();
    await resume;
    expect(resources.startCalls, 0);
    expect(controller.state.phase, DriveSessionPhase.paused);
  });

  test('finalizacion doble es idempotente', () async {
    final resources = _FakeResources();
    final controller = DriveSessionController(resources: resources);
    await controller.start();
    await Future.wait(<Future<void>>[
      controller.finish(discard: false),
      controller.finish(discard: false),
    ]);
    expect(resources.finishCalls, 1);
    expect(controller.state.summary, isNotNull);
    expect(controller.state.phase, DriveSessionPhase.completed);
  });

  test('descarte usa una sola ruta y no finaliza', () async {
    final resources = _FakeResources();
    final controller = DriveSessionController(resources: resources);
    await controller.start();
    await controller.finish(discard: true);
    expect(resources.discardCalls, 1);
    expect(resources.finishCalls, 0);
  });

  test('error de camara queda como recuperable y limpia recursos', () async {
    final resources = _FakeResources()..startError = StateError('camera');
    final controller = DriveSessionController(resources: resources);
    await controller.start();
    expect(controller.state.phase, DriveSessionPhase.recoverableError);
    expect(controller.state.recoverableError, contains('camera'));
    expect(resources.pauseCalls, 1);
  });

  test('error de procesamiento repetido se propaga desde recursos', () async {
    final resources = _FakeResources();
    final controller = DriveSessionController(resources: resources);
    await controller.start();
    resources.emitProcessingError();
    expect(controller.state.phase, DriveSessionPhase.recoverableError);
    expect(controller.state.processingStatus, DriveProcessingStatus.error);
  });

  test('pausa silencia una alarma activa', () async {
    final resources = _FakeResources();
    final controller = DriveSessionController(resources: resources);
    await controller.start();
    resources.emitDangerAlarm();
    expect(controller.state.alarmStatus, DriveAlarmStatus.danger);
    await controller.pause();
    expect(controller.state.alarmStatus, DriveAlarmStatus.silent);
  });
}

class _FakeResources extends ChangeNotifier implements DriveSessionResources {
  DriveState _state = DriveState.idle();
  int prepareCalls = 0;
  int startCalls = 0;
  int pauseCalls = 0;
  int finishCalls = 0;
  int discardCalls = 0;
  Object? startError;

  @override
  DriveState get resourceState => _state;

  @override
  Future<void> prepare({TripSessionDraft? recoveredDraft}) async {
    prepareCalls += 1;
    _state = _state.copyWith(draft: recoveredDraft);
  }

  @override
  Future<void> startMonitoring() async {
    startCalls += 1;
    final error = startError;
    if (error != null) throw error;
    _state = _state.copyWith(
      cameraStatus: DriveCameraStatus.ready,
      streamStatus: DriveStreamStatus.streaming,
    );
    notifyListeners();
  }

  @override
  Future<void> pauseMonitoring() async {
    pauseCalls += 1;
    _state = _state.copyWith(
      cameraStatus: DriveCameraStatus.off,
      streamStatus: DriveStreamStatus.stopped,
      alarmStatus: DriveAlarmStatus.silent,
      clearCameraController: true,
    );
    notifyListeners();
  }

  @override
  Future<TripSessionSummary> finishMonitoring() async {
    finishCalls += 1;
    return _summary();
  }

  @override
  Future<void> discardMonitoring() async {
    discardCalls += 1;
  }

  void emitProcessingError() {
    _state = _state.copyWith(
      phase: DriveSessionPhase.recoverableError,
      processingStatus: DriveProcessingStatus.error,
      recoverableError: 'processing',
    );
    notifyListeners();
  }

  void emitDangerAlarm() {
    _state = _state.copyWith(alarmStatus: DriveAlarmStatus.danger);
    notifyListeners();
  }

  @override
  Future<void> acknowledgeDanger() async {
    _state = _state.copyWith(alarmStatus: DriveAlarmStatus.acknowledged);
    notifyListeners();
  }

  @override
  Future<void> startCalibration() async {}

  @override
  Future<void> disposeResources() async {}
}

TripSessionDraft _draft() {
  final now = DateTime(2026, 7, 17);
  return TripSessionDraft(
    tripId: 'trip_test',
    startedAt: now,
    updatedAt: now,
    drivingDuration: Duration.zero,
    warningAlerts: 0,
    dangerAlerts: 0,
    yawnCount: 0,
    noFaceEvents: 0,
    normalSamples: 0,
    warningSamples: 0,
    dangerSamples: 0,
    sampleCount: 0,
    riskSum: 0,
    maxRisk: 0,
    closedEyeDuration: Duration.zero,
    paused: true,
    incomplete: true,
  );
}

TripSessionSummary _summary() {
  final now = DateTime(2026, 7, 17);
  return TripSessionSummary(
    tripId: 'trip_test',
    startedAt: now,
    endedAt: now.add(const Duration(minutes: 1)),
    drivingDuration: const Duration(minutes: 1),
    warningAlerts: 0,
    dangerAlerts: 0,
    yawnCount: 0,
    closedEyeDuration: Duration.zero,
    noFaceEvents: 0,
    averageRisk: 0,
    maxRisk: 0,
    dominantLevel: DrowsinessLevel.normal,
  );
}
