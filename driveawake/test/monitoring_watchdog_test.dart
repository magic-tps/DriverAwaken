import 'package:driveawake/features/drive/application/drive_state.dart';
import 'package:driveawake/features/drive/application/monitoring_watchdog.dart';
import 'package:driveawake/features/drive/application/performance_monitor.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const watchdog = MonitoringWatchdog(
    config: MonitoringWatchdogConfig(
      staleFrameAfter: Duration(seconds: 3),
      criticalFrameAfter: Duration(seconds: 8),
      minimumActualFps: 2,
      maximumDropRatio: 0.5,
      maximumTotalP95Ms: 500,
    ),
  );

  MonitoringAssessment assess(
    PerformanceSnapshot performance, {
    int nowMicros = 2000000,
    bool recovering = false,
    bool recoveryExhausted = false,
  }) => watchdog.evaluate(
    performance: performance,
    nowMicros: nowMicros,
    streamStatus: DriveStreamStatus.streaming,
    cameraStatus: DriveCameraStatus.ready,
    lifecycleActive: true,
    thermalStatus: DriveThermalStatus.normal,
    telemetryAvailable: true,
    consecutiveFailures: 0,
    persistentDriftErrors: 0,
    recovering: recovering,
    recoveryExhausted: recoveryExhausted,
  );

  test('healthy with recent valid frames and acceptable latency', () {
    final fixture = PerformanceFixture()..processedFrames(5, 250000);
    expect(assess(fixture.monitor.snapshot()).health, MonitoringHealth.healthy);
  });

  test('degraded when total P95 is high', () {
    final fixture = PerformanceFixture()
      ..processedFrames(5, 250000)
      ..monitor.recordLatencyMicros(ProcessingStage.total, 700000);
    expect(
      assess(fixture.monitor.snapshot()).health,
      MonitoringHealth.degraded,
    );
  });

  test(
    'degraded when eligible frames are lost to real processing overload',
    () {
      final fixture = PerformanceFixture()..processedFrames(5, 250000);
      for (var index = 0; index < 6; index++) {
        fixture.monitor
          ..frameReceived()
          ..frameDroppedBusy();
      }
      expect(
        assess(fixture.monitor.snapshot()).health,
        MonitoringHealth.degraded,
      );
    },
  );

  test('intentional sampling at 4 FPS from a 30 FPS camera is healthy', () {
    final fixture = PerformanceFixture()..processedFrames(5, 250000);
    for (var index = 0; index < 25; index++) {
      fixture.monitor
        ..frameReceived()
        ..frameDroppedScheduler();
    }
    final snapshot = fixture.monitor.snapshot();
    expect(snapshot.dropRatio, greaterThan(.8));
    expect(snapshot.busyDropRatio, 0);
    expect(assess(snapshot).health, MonitoringHealth.healthy);
  });

  test('recovering has explicit priority', () {
    final fixture = PerformanceFixture()..processedFrames(5, 250000);
    expect(
      assess(fixture.monitor.snapshot(), recovering: true).health,
      MonitoringHealth.recovering,
    );
  });

  test('unavailable after recovery attempts are exhausted', () {
    final fixture = PerformanceFixture()..processedFrames(5, 250000);
    expect(
      assess(fixture.monitor.snapshot(), recoveryExhausted: true).health,
      MonitoringHealth.unavailable,
    );
  });

  test('unavailable when valid frame is critically stale', () {
    final fixture = PerformanceFixture()..processedFrames(2, 250000);
    expect(
      assess(fixture.monitor.snapshot(), nowMicros: 10000000).health,
      MonitoringHealth.unavailable,
    );
  });
}

class PerformanceFixture {
  PerformanceFixture() {
    monitor = PerformanceMonitor(clock: clock);
  }

  final FakeClock clock = FakeClock();
  late final PerformanceMonitor monitor;

  void processedFrames(int count, int intervalMicros) {
    for (var index = 0; index < count; index++) {
      monitor
        ..frameReceived()
        ..frameAccepted(requestedFps: 4)
        ..frameProcessed(hasFace: true);
      clock.value += intervalMicros;
    }
  }
}

class FakeClock implements MonotonicClock {
  int value = 0;
  @override
  int nowMicros() => value;
}
