import '../models/drowsiness_state.dart';

class RestRecommendation {
  const RestRecommendation(this.reason, this.message, {this.critical = false});
  final String reason, message;
  final bool critical;
}

/// Consumes the existing detector; it does not calculate a second fatigue score.
class RestRecommendationEngine {
  DateTime? _warningSince;
  DateTime? _lastClosure;
  final List<DateTime> _closures = [];
  RestRecommendation? evaluate(
    DrowsinessState state,
    DateTime now,
    Duration drivingSinceRest, {
    Duration drivingLimit = const Duration(hours: 2),
    bool manual = false,
  }) {
    if (manual) {
      return const RestRecommendation(
        'MANUAL',
        'Consulta opciones solo cuando estés estacionado.',
      );
    }
    if (!state.faceDetected || state.signalQuality < .32) {
      _warningSince = null;
      return const RestRecommendation(
        'SIGNAL_UNAVAILABLE',
        'Monitoreo no disponible. Revisa la cámara al detenerte en un lugar seguro.',
      );
    }
    if (state.level == DrowsinessLevel.danger) {
      return const RestRecommendation(
        'CRITICAL_SIGNAL',
        'Se detectó una señal crítica. Detente en un lugar seguro tan pronto sea posible; no continúes para buscar café.',
        critical: true,
      );
    }
    if (state.prolongedBlink &&
        (_lastClosure == null ||
            now.difference(_lastClosure!) >= const Duration(seconds: 30))) {
      _lastClosure = now;
      _closures.add(now);
    }
    _closures.removeWhere(
      (at) => now.difference(at) > const Duration(minutes: 5),
    );
    if (_closures.length >= 3) {
      return const RestRecommendation(
        'REPEATED_CLOSURE',
        'Cierres oculares repetidos. Busca un lugar seguro para detenerte.',
      );
    }
    if (state.level == DrowsinessLevel.warning) {
      _warningSince ??= now;
    } else {
      _warningSince = null;
    }
    if (_warningSince != null &&
        now.difference(_warningSince!) >= const Duration(seconds: 20)) {
      return const RestRecommendation(
        'SUSTAINED_WARNING',
        'Se detectaron señales sostenidas de fatiga. Busca un lugar seguro para detenerte.',
      );
    }
    if (drivingSinceRest >= drivingLimit) {
      return const RestRecommendation(
        'DRIVING_DURATION',
        'Has alcanzado el intervalo de conducción configurado. Planifica una pausa segura.',
      );
    }
    return null;
  }

  void reset() {
    _warningSince = null;
    _lastClosure = null;
    _closures.clear();
  }
}
