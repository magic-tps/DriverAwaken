import 'dart:convert';
import 'package:crypto/crypto.dart';
import '../models/drowsiness_event.dart';
import '../models/drowsiness_state.dart';

/// Adapts existing temporal decisions; never infers fatigue from missing faces.
class IncidentClassifier {
  static const types = {
    'ojos_cerrados_prolongados': 'PROLONGED_EYE_CLOSURE',
    'perclos_alto': 'HIGH_PERCLOS',
    'bostezo': 'REPEATED_YAWNING',
    'cabeza_caida': 'SUSTAINED_HEAD_DOWN',
    'distraccion': 'POSSIBLE_DISTRACTION',
    'rostro_ausente': 'SIGNAL_UNAVAILABLE',
    'monitoreo_interrumpido': 'MONITORING_INTERRUPTED',
  };

  Map<String, Object?>? classify(
    DrowsinessEvent event, {
    required String organizationId,
    required String tripId,
    required String driverId,
    DrowsinessState? signal,
  }) {
    final type = types[event.eventType];
    if (type == null) {
      return null; // Aggregate alerts are not duplicate incidents.
    }
    if (type == 'REPEATED_YAWNING' && (signal?.yawnCountWindow ?? 0) < 3) {
      return null;
    }
    final unavailable =
        type == 'SIGNAL_UNAVAILABLE' || type == 'MONITORING_INTERRUPTED';
    if (type == 'SIGNAL_UNAVAILABLE' && event.durationSeconds < 3) return null;
    if (!unavailable &&
        signal != null &&
        (!signal.faceDetected ||
            signal.signalQuality < .32 ||
            signal.lowLight)) {
      return null;
    }
    final id = sha256
        .convert(
          utf8.encode(jsonEncode([organizationId, tripId, driverId, event.id])),
        )
        .toString();
    return {
      'id': id,
      'organizationId': organizationId,
      'tripId': tripId,
      'driverId': driverId,
      'type': type,
      'severity': unavailable
          ? 'INFO'
          : event.level == DrowsinessLevel.danger
          ? 'CRITICAL'
          : 'WARNING',
      'detectedAtMs': event.dateTime.millisecondsSinceEpoch,
      'riskScore': unavailable ? 0.0 : event.riskScore.clamp(0, 100),
      'reasonCode': type,
      'signalQuality': unavailable ? 'INSUFFICIENT' : 'RELIABLE',
      'monitoringHealth': unavailable ? 'UNAVAILABLE' : 'HEALTHY',
    };
  }
}
