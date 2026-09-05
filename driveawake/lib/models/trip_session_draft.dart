import 'drowsiness_state.dart';

class TripSessionDraft {
  const TripSessionDraft({
    required this.tripId,
    required this.startedAt,
    required this.updatedAt,
    required this.drivingDuration,
    required this.warningAlerts,
    required this.dangerAlerts,
    required this.yawnCount,
    required this.noFaceEvents,
    required this.normalSamples,
    required this.warningSamples,
    required this.dangerSamples,
    required this.sampleCount,
    required this.riskSum,
    required this.maxRisk,
    required this.closedEyeDuration,
    required this.paused,
    required this.incomplete,
  });

  final String tripId;
  final DateTime startedAt;
  final DateTime updatedAt;
  final Duration drivingDuration;
  final int warningAlerts;
  final int dangerAlerts;
  final int yawnCount;
  final int noFaceEvents;
  final int normalSamples;
  final int warningSamples;
  final int dangerSamples;
  final int sampleCount;
  final double riskSum;
  final double maxRisk;
  final Duration closedEyeDuration;
  final bool paused;
  final bool incomplete;

  DrowsinessLevel get dominantLevel {
    if (dangerSamples >= warningSamples && dangerSamples >= normalSamples) {
      return DrowsinessLevel.danger;
    }
    if (warningSamples >= normalSamples) {
      return DrowsinessLevel.warning;
    }
    return DrowsinessLevel.normal;
  }

  Map<String, Object?> toMap() => <String, Object?>{
    'tripId': tripId,
    'startedAt': startedAt.toIso8601String(),
    'updatedAt': updatedAt.toIso8601String(),
    'drivingDurationMs': drivingDuration.inMilliseconds,
    'warningAlerts': warningAlerts,
    'dangerAlerts': dangerAlerts,
    'yawnCount': yawnCount,
    'noFaceEvents': noFaceEvents,
    'normalSamples': normalSamples,
    'warningSamples': warningSamples,
    'dangerSamples': dangerSamples,
    'sampleCount': sampleCount,
    'riskSum': riskSum,
    'maxRisk': maxRisk,
    'closedEyeDurationMs': closedEyeDuration.inMilliseconds,
    'paused': paused,
    'incomplete': incomplete,
  };

  factory TripSessionDraft.fromMap(Map<String, dynamic> map) {
    return TripSessionDraft(
      tripId: map['tripId'] as String,
      startedAt: DateTime.parse(map['startedAt'] as String),
      updatedAt: DateTime.parse(map['updatedAt'] as String),
      drivingDuration: Duration(
        milliseconds: (map['drivingDurationMs'] as num).toInt(),
      ),
      warningAlerts: (map['warningAlerts'] as num).toInt(),
      dangerAlerts: (map['dangerAlerts'] as num).toInt(),
      yawnCount: (map['yawnCount'] as num).toInt(),
      noFaceEvents: (map['noFaceEvents'] as num).toInt(),
      normalSamples: (map['normalSamples'] as num).toInt(),
      warningSamples: (map['warningSamples'] as num).toInt(),
      dangerSamples: (map['dangerSamples'] as num).toInt(),
      sampleCount: (map['sampleCount'] as num).toInt(),
      riskSum: (map['riskSum'] as num).toDouble(),
      maxRisk: (map['maxRisk'] as num).toDouble(),
      closedEyeDuration: Duration(
        milliseconds: (map['closedEyeDurationMs'] as num).toInt(),
      ),
      paused: map['paused'] as bool? ?? true,
      incomplete: map['incomplete'] as bool? ?? true,
    );
  }
}
