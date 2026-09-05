import 'drowsiness_state.dart';

class TripSessionSummary {
  const TripSessionSummary({
    required this.tripId,
    required this.startedAt,
    required this.endedAt,
    required this.drivingDuration,
    required this.warningAlerts,
    required this.dangerAlerts,
    required this.yawnCount,
    required this.closedEyeDuration,
    required this.noFaceEvents,
    required this.averageRisk,
    required this.maxRisk,
    required this.dominantLevel,
    this.startBatteryLevel,
    this.endBatteryLevel,
    this.startTemperatureC,
    this.endTemperatureC,
    this.maxTemperatureC,
    this.isCharging = false,
  });

  final String tripId;
  final DateTime startedAt;
  final DateTime endedAt;
  final Duration drivingDuration;
  final int warningAlerts;
  final int dangerAlerts;
  final int yawnCount;
  final Duration closedEyeDuration;
  final int noFaceEvents;
  final double averageRisk;
  final double maxRisk;
  final DrowsinessLevel dominantLevel;
  final double? startBatteryLevel;
  final double? endBatteryLevel;
  final double? startTemperatureC;
  final double? endTemperatureC;
  final double? maxTemperatureC;
  final bool isCharging;

  double? get batteryDelta {
    final start = startBatteryLevel;
    final end = endBatteryLevel;
    if (start == null || end == null) {
      return null;
    }
    return end - start;
  }

  double? get temperatureDelta {
    final start = startTemperatureC;
    final end = endTemperatureC;
    if (start == null || end == null) {
      return null;
    }
    return end - start;
  }

  String get resultTitle {
    if (dangerAlerts > 0 || maxRisk >= 80 || averageRisk >= 55) {
      return 'Se recomienda descansar';
    }
    if (warningAlerts > 0 || yawnCount >= 2 || averageRisk >= 35) {
      return 'Se detectaron senales de cansancio';
    }
    return 'Viaje seguro';
  }

  String get resultMessage {
    if (dangerAlerts > 0) {
      return 'Hubo alertas criticas durante el viaje. Para un producto real, esta senal debe tratarse como prioridad de descanso.';
    }
    if (warningAlerts > 0 || averageRisk >= 35) {
      return 'El viaje tuvo senales leves o moderadas. Conviene revisar postura, iluminacion y descansos.';
    }
    return 'No se registraron eventos relevantes de somnolencia.';
  }
}
