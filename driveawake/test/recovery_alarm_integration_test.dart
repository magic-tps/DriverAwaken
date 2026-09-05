import 'package:camera/camera.dart';
import 'package:driveawake/features/drive/application/drive_ports.dart';
import 'package:driveawake/features/drive/application/drive_repositories.dart';
import 'package:driveawake/features/drive/application/monitoring_watchdog.dart';
import 'package:driveawake/features/drive/application/performance_monitor.dart';
import 'package:driveawake/features/drive/infrastructure/flutter_drive_session_resources.dart';
import 'package:driveawake/models/device_telemetry_snapshot.dart';
import 'package:driveawake/models/drowsiness_state.dart';
import 'package:driveawake/models/trip_session_draft.dart';
import 'package:driveawake/models/trip_session_summary.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';

void main() {
  test('alarm is stopped when watchdog enters recovery', () async {
    final camera = FakeCamera();
    final alarm = FakeAlarm();
    final monotonicClock = FakeMonotonicClock();
    final resources = FlutterDriveSessionResources(
      camera: camera,
      faceDetection: FakeFaceDetection(),
      analyzer: FakeAnalyzer(),
      alarm: alarm,
      trip: FakeTrip(),
      telemetry: FakeTelemetry(),
      clock: FakeWallClock(),
      performanceMonitor: PerformanceMonitor(clock: monotonicClock),
      watchdog: const MonitoringWatchdog(
        config: MonitoringWatchdogConfig(
          staleFrameAfter: Duration.zero,
          criticalFrameAfter: Duration.zero,
          maximumRecoveryAttempts: 1,
          recoveryBackoff: Duration.zero,
        ),
      ),
      watchdogInterval: const Duration(milliseconds: 5),
      delay: (_) async {},
    );

    await resources.prepare();
    await resources.startMonitoring();
    await Future<void>.delayed(const Duration(milliseconds: 30));

    expect(alarm.stopCalls, greaterThanOrEqualTo(1));
    expect(camera.initializeCalls, greaterThanOrEqualTo(2));
    expect(
      resources.resourceState.monitoringHealth,
      anyOf(MonitoringHealth.recovering, MonitoringHealth.unavailable),
    );
    await resources.disposeResources();
  });
}

class FakeMonotonicClock implements MonotonicClock {
  @override
  int nowMicros() => 0;
}

class FakeWallClock implements Clock {
  @override
  DateTime now() => DateTime(2026, 7, 18);
}

class FakeCamera implements CameraRepository {
  int initializeCalls = 0;
  bool initialized = false;

  @override
  CameraDescription? get camera => null;
  @override
  CameraController? get controller => null;
  @override
  bool get isInitialized => initialized;

  @override
  Future<void> initialize() async {
    initializeCalls++;
    initialized = true;
  }

  @override
  Future<void> startStream(void Function(CameraImage image) onImage) async {}

  @override
  Future<void> stopAndDispose() async {
    initialized = false;
  }
}

class FakeFaceDetection implements FaceDetectionRepository {
  @override
  Future<void> close() async {}
  @override
  Future<List<Face>> detect(InputImage image) async => <Face>[];
}

class FakeAnalyzer implements DrowsinessAnalyzer {
  @override
  Future<void> close() async {}
  @override
  Future<void> initialize() async {}
  @override
  void resetTemporalState() {}
  @override
  Future<void> startCalibration() async {}
  @override
  Future<DrowsinessState> analyze({
    required List<Face> faces,
    required DateTime timestamp,
    required double? imageBrightness,
    required int imageWidth,
    required int imageHeight,
    required double fps,
  }) async => DrowsinessState.initial();
}

class FakeAlarm implements AlarmController {
  int stopCalls = 0;
  @override
  Future<void> close() async {}
  @override
  Future<void> handle(DrowsinessState state) async {}
  @override
  Future<void> stop() async {
    stopCalls++;
  }
}

class FakeTrip implements TripRepository {
  @override
  Future<void> discard() async {}
  @override
  Future<TripSessionSummary> finish() => throw UnimplementedError();
  @override
  Future<void> observe(DrowsinessState state, DateTime timestamp) async {}
  @override
  void pause() {}
  @override
  void recordTelemetry(DeviceTelemetrySnapshot snapshot) {}
  @override
  void restore(TripSessionDraft draft) {}
  @override
  void resume() {}
  @override
  void start() {}
}

class FakeTelemetry implements TelemetryRepository {
  @override
  Future<void> keepScreenAwake(bool enabled) async {}
  @override
  Future<DeviceTelemetrySnapshot?> read() async => DeviceTelemetrySnapshot(
    timestamp: DateTime(2026, 7, 18),
    batteryLevel: 80,
    temperatureC: 30,
    voltageMv: 4000,
    status: 1,
    plugged: 0,
  );
}
