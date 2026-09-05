class DrowsinessFrameMetrics {
  const DrowsinessFrameMetrics({
    required this.timestamp,
    required this.faceDetected,
    required this.eyesClosed,
    required this.yawning,
    required this.perclos,
    required this.ear,
    required this.mar,
    required this.headX,
    required this.headY,
    required this.eyeClosedDurationSeconds,
    required this.faceMissingDurationSeconds,
    required this.headDownDurationSeconds,
    required this.signalQuality,
    required this.lowLight,
  });

  final DateTime timestamp;
  final bool faceDetected;
  final bool eyesClosed;
  final bool yawning;
  final double perclos;
  final double? ear;
  final double? mar;
  final double? headX;
  final double? headY;
  final double eyeClosedDurationSeconds;
  final double faceMissingDurationSeconds;
  final double headDownDurationSeconds;
  final double signalQuality;
  final bool lowLight;

  double? get yawProxy {
    final value = headY;
    if (value == null) {
      return null;
    }
    return value / 100.0;
  }

  double? get pitchProxy {
    final value = headX;
    if (value == null) {
      return null;
    }
    return value / 100.0;
  }
}
