import 'drowsiness_state.dart';

class DrowsinessEvent {
  const DrowsinessEvent({
    required this.id,
    required this.dateTime,
    required this.level,
    required this.eventType,
    required this.durationSeconds,
    required this.notes,
    this.riskScore = 0,
    this.perclos = 0,
    this.modelPrediction,
    this.modelConfidence,
    this.tripId,
  });

  final String id;
  final DateTime dateTime;
  final DrowsinessLevel level;
  final String eventType;
  final double durationSeconds;
  final String notes;
  final double riskScore;
  final double perclos;
  final String? modelPrediction;
  final double? modelConfidence;
  final String? tripId;

  Map<String, Object?> toMap() {
    return <String, Object?>{
      'id': id,
      'dateTime': dateTime.toIso8601String(),
      'level': level.name,
      'eventType': eventType,
      'durationSeconds': durationSeconds,
      'notes': notes,
      'riskScore': riskScore,
      'perclos': perclos,
      'modelPrediction': modelPrediction,
      'modelConfidence': modelConfidence,
      'tripId': tripId,
    };
  }

  factory DrowsinessEvent.fromMap(Map<String, Object?> map) {
    final levelName = map['level'] as String? ?? DrowsinessLevel.warning.name;

    return DrowsinessEvent(
      id: map['id'] as String? ?? '',
      dateTime:
          DateTime.tryParse(map['dateTime'] as String? ?? '') ??
          DateTime.fromMillisecondsSinceEpoch(0),
      level: DrowsinessLevel.values.firstWhere(
        (level) => level.name == levelName,
        orElse: () => DrowsinessLevel.warning,
      ),
      eventType: map['eventType'] as String? ?? 'unknown',
      durationSeconds: (map['durationSeconds'] as num?)?.toDouble() ?? 0,
      notes: map['notes'] as String? ?? '',
      riskScore: (map['riskScore'] as num?)?.toDouble() ?? 0,
      perclos: (map['perclos'] as num?)?.toDouble() ?? 0,
      modelPrediction: map['modelPrediction'] as String?,
      modelConfidence: (map['modelConfidence'] as num?)?.toDouble(),
      tripId: map['tripId'] as String?,
    );
  }
}
