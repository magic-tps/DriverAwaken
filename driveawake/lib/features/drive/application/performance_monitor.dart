import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/foundation.dart';

enum ProcessingStage {
  imageConversion,
  faceDetection,
  faceSelection,
  featureExtraction,
  perclos,
  riskEngine,
  modelInference,
  persistence,
  stateUpdate,
  total,
}

abstract interface class MonotonicClock {
  int nowMicros();
}

class StopwatchMonotonicClock implements MonotonicClock {
  StopwatchMonotonicClock() : _stopwatch = Stopwatch()..start();

  final Stopwatch _stopwatch;

  @override
  int nowMicros() => _stopwatch.elapsedMicroseconds;
}

@immutable
class StageLatencyStats {
  const StageLatencyStats({
    required this.sampleCount,
    required this.averageMs,
    required this.p50Ms,
    required this.p90Ms,
    required this.p95Ms,
    required this.p99Ms,
    required this.maxMs,
  });

  const StageLatencyStats.empty()
    : sampleCount = 0,
      averageMs = 0,
      p50Ms = 0,
      p90Ms = 0,
      p95Ms = 0,
      p99Ms = 0,
      maxMs = 0;

  final int sampleCount;
  final double averageMs;
  final double p50Ms;
  final double p90Ms;
  final double p95Ms;
  final double p99Ms;
  final double maxMs;
}

class CircularBuffer<T> {
  CircularBuffer(this.capacity) : assert(capacity > 0);

  final int capacity;
  final List<T> _values = <T>[];
  int _next = 0;

  int get length => _values.length;
  bool get isEmpty => _values.isEmpty;

  void add(T value) {
    if (_values.length < capacity) {
      _values.add(value);
      return;
    }
    _values[_next] = value;
    _next = (_next + 1) % capacity;
  }

  List<T> toList() {
    if (_values.length < capacity || _next == 0) {
      return List<T>.unmodifiable(_values);
    }
    return List<T>.unmodifiable(<T>[
      ..._values.sublist(_next),
      ..._values.sublist(0, _next),
    ]);
  }

  void clear() {
    _values.clear();
    _next = 0;
  }
}

@immutable
class PerformanceSnapshot {
  const PerformanceSnapshot({
    required this.framesReceived,
    required this.framesAccepted,
    required this.framesProcessed,
    required this.framesDroppedBusy,
    required this.framesDroppedScheduler,
    required this.framesFailed,
    required this.framesWithoutFace,
    required this.requestedFps,
    required this.actualFps,
    required this.lastFrameReceivedMicros,
    required this.lastValidFrameMicros,
    required this.stageStats,
    required this.errorsByStage,
  });

  final int framesReceived;
  final int framesAccepted;
  final int framesProcessed;
  final int framesDroppedBusy;
  final int framesDroppedScheduler;
  final int framesFailed;
  final int framesWithoutFace;
  final double requestedFps;
  final double actualFps;
  final int? lastFrameReceivedMicros;
  final int? lastValidFrameMicros;
  final Map<ProcessingStage, StageLatencyStats> stageStats;
  final Map<ProcessingStage, int> errorsByStage;

  int get framesDropped => framesDroppedBusy + framesDroppedScheduler;
  double get dropRatio =>
      framesReceived == 0 ? 0 : framesDropped / framesReceived;
  double get totalP95Ms => stageStats[ProcessingStage.total]?.p95Ms ?? 0;
}

class PerformanceMonitor {
  PerformanceMonitor({
    MonotonicClock? clock,
    this.enabled = true,
    int bufferCapacity = 240,
  }) : _clock = clock ?? StopwatchMonotonicClock(),
       _processedTimes = CircularBuffer<int>(bufferCapacity),
       _requestedFps = CircularBuffer<double>(bufferCapacity) {
    for (final stage in ProcessingStage.values) {
      _latencies[stage] = CircularBuffer<int>(bufferCapacity);
    }
  }

  final MonotonicClock _clock;
  final bool enabled;
  final Map<ProcessingStage, CircularBuffer<int>> _latencies = {};
  final Map<ProcessingStage, int> _errors = {};
  final CircularBuffer<int> _processedTimes;
  final CircularBuffer<double> _requestedFps;

  int _framesReceived = 0;
  int _framesAccepted = 0;
  int _framesProcessed = 0;
  int _framesDroppedBusy = 0;
  int _framesDroppedScheduler = 0;
  int _framesFailed = 0;
  int _framesWithoutFace = 0;
  int? _lastFrameReceivedMicros;
  int? _lastValidFrameMicros;

  int nowMicros() => _clock.nowMicros();

  void frameReceived() {
    if (!enabled) return;
    _framesReceived++;
    _lastFrameReceivedMicros = nowMicros();
  }

  void frameAccepted({required double requestedFps}) {
    if (!enabled) return;
    _framesAccepted++;
    if (requestedFps.isFinite && requestedFps >= 0) {
      _requestedFps.add(requestedFps);
    }
  }

  void frameDroppedBusy() {
    if (enabled) _framesDroppedBusy++;
  }

  void frameDroppedScheduler() {
    if (enabled) _framesDroppedScheduler++;
  }

  void frameProcessed({required bool hasFace}) {
    if (!enabled) return;
    _framesProcessed++;
    if (!hasFace) _framesWithoutFace++;
    final now = nowMicros();
    if (hasFace) _lastValidFrameMicros = now;
    _processedTimes.add(now);
  }

  void beginMonitoringEpisode() {
    if (!enabled) return;
    _lastFrameReceivedMicros = null;
    _lastValidFrameMicros = null;
    _processedTimes.clear();
    _requestedFps.clear();
  }

  void frameFailed([ProcessingStage? stage]) {
    if (!enabled) return;
    _framesFailed++;
    if (stage != null) recordError(stage);
  }

  void recordError(ProcessingStage stage) {
    if (!enabled) return;
    _errors.update(stage, (value) => value + 1, ifAbsent: () => 1);
  }

  void recordLatencyMicros(ProcessingStage stage, int elapsedMicros) {
    if (!enabled || elapsedMicros < 0) return;
    _latencies[stage]!.add(elapsedMicros);
  }

  T measureSync<T>(ProcessingStage stage, T Function() operation) {
    if (!enabled) return operation();
    final start = nowMicros();
    try {
      return operation();
    } catch (_) {
      recordError(stage);
      rethrow;
    } finally {
      recordLatencyMicros(stage, nowMicros() - start);
    }
  }

  Future<T> measure<T>(
    ProcessingStage stage,
    FutureOr<T> Function() operation,
  ) async {
    if (!enabled) return operation();
    final start = nowMicros();
    try {
      return await operation();
    } catch (_) {
      recordError(stage);
      rethrow;
    } finally {
      recordLatencyMicros(stage, nowMicros() - start);
    }
  }

  PerformanceSnapshot snapshot() {
    final stats = <ProcessingStage, StageLatencyStats>{};
    for (final stage in ProcessingStage.values) {
      stats[stage] = _stats(_latencies[stage]!.toList());
    }
    return PerformanceSnapshot(
      framesReceived: _framesReceived,
      framesAccepted: _framesAccepted,
      framesProcessed: _framesProcessed,
      framesDroppedBusy: _framesDroppedBusy,
      framesDroppedScheduler: _framesDroppedScheduler,
      framesFailed: _framesFailed,
      framesWithoutFace: _framesWithoutFace,
      requestedFps: _average(_requestedFps.toList()),
      actualFps: _actualFps(_processedTimes.toList()),
      lastFrameReceivedMicros: _lastFrameReceivedMicros,
      lastValidFrameMicros: _lastValidFrameMicros,
      stageStats: Map.unmodifiable(stats),
      errorsByStage: Map.unmodifiable(_errors),
    );
  }

  void reset() {
    _framesReceived = 0;
    _framesAccepted = 0;
    _framesProcessed = 0;
    _framesDroppedBusy = 0;
    _framesDroppedScheduler = 0;
    _framesFailed = 0;
    _framesWithoutFace = 0;
    _lastFrameReceivedMicros = null;
    _lastValidFrameMicros = null;
    _errors.clear();
    for (final buffer in _latencies.values) {
      buffer.clear();
    }
    _processedTimes.clear();
    _requestedFps.clear();
  }

  static StageLatencyStats _stats(List<int> values) {
    if (values.isEmpty) return const StageLatencyStats.empty();
    final sorted = List<int>.of(values)..sort();
    final total = sorted.fold<int>(0, (sum, value) => sum + value);
    double percentile(double fraction) {
      final index = ((sorted.length - 1) * fraction).ceil();
      return sorted[index.clamp(0, sorted.length - 1)] / 1000;
    }

    return StageLatencyStats(
      sampleCount: sorted.length,
      averageMs: total / sorted.length / 1000,
      p50Ms: percentile(0.50),
      p90Ms: percentile(0.90),
      p95Ms: percentile(0.95),
      p99Ms: percentile(0.99),
      maxMs: sorted.last / 1000,
    );
  }

  static double _average(List<double> values) =>
      values.isEmpty ? 0 : values.reduce((a, b) => a + b) / values.length;

  static double _actualFps(List<int> times) {
    if (times.length < 2) return 0;
    final elapsedMicros = math.max(0, times.last - times.first);
    return elapsedMicros == 0
        ? 0
        : (times.length - 1) * 1000000 / elapsedMicros;
  }
}
