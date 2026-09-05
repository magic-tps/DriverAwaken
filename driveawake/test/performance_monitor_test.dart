import 'package:driveawake/features/drive/application/performance_monitor.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('PerformanceMonitor', () {
    test('percentiles with zero samples are zero', () {
      final snapshot = PerformanceMonitor(
        clock: FakeMonotonicClock(),
      ).snapshot();
      final stats = snapshot.stageStats[ProcessingStage.total]!;

      expect(stats.sampleCount, 0);
      expect(stats.p50Ms, 0);
      expect(stats.p95Ms, 0);
      expect(stats.p99Ms, 0);
    });

    test('percentiles with one sample equal that sample', () {
      final monitor = PerformanceMonitor(clock: FakeMonotonicClock());
      monitor.recordLatencyMicros(ProcessingStage.total, 12500);

      final stats = monitor.snapshot().stageStats[ProcessingStage.total]!;
      expect(stats.sampleCount, 1);
      expect(stats.p50Ms, 12.5);
      expect(stats.p95Ms, 12.5);
      expect(stats.p99Ms, 12.5);
    });

    test('circular buffer keeps only newest samples in order', () {
      final buffer = CircularBuffer<int>(3)
        ..add(1)
        ..add(2)
        ..add(3)
        ..add(4);

      expect(buffer.toList(), <int>[2, 3, 4]);
    });

    test('reset clears counters, timestamps and latency samples', () {
      final clock = FakeMonotonicClock();
      final monitor = PerformanceMonitor(clock: clock)
        ..frameReceived()
        ..frameAccepted(requestedFps: 5)
        ..frameProcessed(hasFace: true)
        ..recordLatencyMicros(ProcessingStage.total, 1000)
        ..reset();

      final snapshot = monitor.snapshot();
      expect(snapshot.framesReceived, 0);
      expect(snapshot.framesProcessed, 0);
      expect(snapshot.lastValidFrameMicros, isNull);
      expect(snapshot.stageStats[ProcessingStage.total]!.sampleCount, 0);
    });

    test('tracks busy and scheduler drops separately', () {
      final monitor = PerformanceMonitor(clock: FakeMonotonicClock())
        ..frameReceived()
        ..frameDroppedBusy()
        ..frameReceived()
        ..frameDroppedScheduler();

      final snapshot = monitor.snapshot();
      expect(snapshot.framesDroppedBusy, 1);
      expect(snapshot.framesDroppedScheduler, 1);
      expect(snapshot.framesDropped, 2);
      expect(snapshot.dropRatio, 1);
    });

    test('negative out-of-order latency is ignored', () {
      final monitor = PerformanceMonitor(clock: FakeMonotonicClock())
        ..recordLatencyMicros(ProcessingStage.faceDetection, -1);

      expect(
        monitor
            .snapshot()
            .stageStats[ProcessingStage.faceDetection]!
            .sampleCount,
        0,
      );
    });

    test('actual FPS uses monotonic processed-frame timestamps', () {
      final clock = FakeMonotonicClock();
      final monitor = PerformanceMonitor(clock: clock);
      monitor.frameProcessed(hasFace: true);
      clock.advance(const Duration(milliseconds: 500));
      monitor.frameProcessed(hasFace: true);

      expect(monitor.snapshot().actualFps, 2);
    });

    test('frames without a face do not count as a valid monitoring frame', () {
      final monitor = PerformanceMonitor(clock: FakeMonotonicClock())
        ..frameProcessed(hasFace: false);

      final snapshot = monitor.snapshot();
      expect(snapshot.framesProcessed, 1);
      expect(snapshot.framesWithoutFace, 1);
      expect(snapshot.lastValidFrameMicros, isNull);
    });
  });
}

class FakeMonotonicClock implements MonotonicClock {
  int value = 0;

  void advance(Duration duration) => value += duration.inMicroseconds;

  @override
  int nowMicros() => value;
}
