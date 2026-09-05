class PerclosTracker {
  PerclosTracker({
    required this.window,
    this.maximumSampleGap = const Duration(milliseconds: 600),
    this.minimumValidObservedDuration = const Duration(seconds: 10),
    this.minimumValidCoverage = 0.55,
  }) : assert(maximumSampleGap > Duration.zero),
       assert(minimumValidObservedDuration >= Duration.zero),
       assert(minimumValidCoverage >= 0 && minimumValidCoverage <= 1);

  Duration window;
  final Duration maximumSampleGap;
  final Duration minimumValidObservedDuration;
  final double minimumValidCoverage;

  final List<PerclosSample> _samples = <PerclosSample>[];
  DateTime? _lastAcceptedTimestamp;
  PerclosSnapshot _lastSnapshot = PerclosSnapshot.empty;

  int get sampleCount => _samples.length;
  bool get isReady => _lastSnapshot.hasSufficientSignal;
  double get perclos => _lastSnapshot.perclos;
  double get validCoverage => _lastSnapshot.validCoverage;
  Duration get validObservedDuration => _lastSnapshot.validObservedDuration;
  Duration get observedWindowDuration => _lastSnapshot.windowDuration;
  PerclosSnapshot get lastSnapshot => _lastSnapshot;

  void addSample({
    required DateTime timestamp,
    required bool eyesClosed,
    required bool valid,
  }) {
    final lastTimestamp = _lastAcceptedTimestamp;
    if (lastTimestamp != null && !timestamp.isAfter(lastTimestamp)) {
      return;
    }

    _samples.add(
      PerclosSample(timestamp: timestamp, eyesClosed: eyesClosed, valid: valid),
    );
    _lastAcceptedTimestamp = timestamp;
    purge(timestamp);
  }

  void purge(DateTime timestamp) {
    final cutoff = timestamp.subtract(window);
    while (_samples.length > 1 && !_samples[1].timestamp.isAfter(cutoff)) {
      _samples.removeAt(0);
    }
  }

  double valueAt(DateTime timestamp) => snapshotAt(timestamp).perclos;

  PerclosSnapshot snapshotAt(DateTime timestamp) {
    purge(timestamp);
    if (_samples.length < 2) {
      _lastSnapshot = PerclosSnapshot.empty;
      return _lastSnapshot;
    }

    final cutoff = timestamp.subtract(window);
    final firstObservedAt = _samples.first.timestamp.isAfter(cutoff)
        ? _samples.first.timestamp
        : cutoff;
    final observedWindow = timestamp.isAfter(firstObservedAt)
        ? timestamp.difference(firstObservedAt)
        : Duration.zero;

    var validMicroseconds = 0;
    var closedMicroseconds = 0;

    for (var index = 0; index < _samples.length - 1; index += 1) {
      final current = _samples[index];
      final next = _samples[index + 1];
      if (!next.timestamp.isAfter(current.timestamp)) {
        continue;
      }

      final rawGap = next.timestamp.difference(current.timestamp);
      if (rawGap > maximumSampleGap || !current.valid || !next.valid) {
        continue;
      }

      final segmentStart = current.timestamp.isBefore(cutoff)
          ? cutoff
          : current.timestamp;
      final segmentEnd = next.timestamp.isAfter(timestamp)
          ? timestamp
          : next.timestamp;
      if (!segmentEnd.isAfter(segmentStart)) {
        continue;
      }

      final segmentMicroseconds = segmentEnd
          .difference(segmentStart)
          .inMicroseconds;
      validMicroseconds += segmentMicroseconds;
      if (current.eyesClosed) {
        closedMicroseconds += segmentMicroseconds;
      }
    }

    final validDuration = Duration(microseconds: validMicroseconds);
    final coverage = observedWindow == Duration.zero
        ? 0.0
        : (validMicroseconds / observedWindow.inMicroseconds)
              .clamp(0, 1)
              .toDouble();
    final perclosValue = validMicroseconds == 0
        ? 0.0
        : (closedMicroseconds / validMicroseconds).clamp(0, 1).toDouble();
    final requiredDuration = minimumValidObservedDuration > window
        ? window
        : minimumValidObservedDuration;

    _lastSnapshot = PerclosSnapshot(
      perclos: perclosValue,
      validCoverage: coverage,
      validObservedDuration: validDuration,
      windowDuration: observedWindow,
      hasSufficientSignal:
          validDuration >= requiredDuration && coverage >= minimumValidCoverage,
    );
    return _lastSnapshot;
  }

  void reset() {
    _samples.clear();
    _lastAcceptedTimestamp = null;
    _lastSnapshot = PerclosSnapshot.empty;
  }
}

class PerclosSnapshot {
  const PerclosSnapshot({
    required this.perclos,
    required this.validCoverage,
    required this.validObservedDuration,
    required this.windowDuration,
    required this.hasSufficientSignal,
  });

  static const PerclosSnapshot empty = PerclosSnapshot(
    perclos: 0,
    validCoverage: 0,
    validObservedDuration: Duration.zero,
    windowDuration: Duration.zero,
    hasSufficientSignal: false,
  );

  final double perclos;
  final double validCoverage;
  final Duration validObservedDuration;
  final Duration windowDuration;
  final bool hasSufficientSignal;
}

class PerclosSample {
  const PerclosSample({
    required this.timestamp,
    required this.eyesClosed,
    required this.valid,
  });

  final DateTime timestamp;
  final bool eyesClosed;
  final bool valid;
}
