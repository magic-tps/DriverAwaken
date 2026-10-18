import 'dart:math';

import '../models/app_settings.dart';
import '../models/drowsiness_state.dart';
import '../models/ml_prediction.dart';
import '../utils/drowsiness_thresholds.dart';

class DrowsinessEngine {
  double _smoothedRisk = 0;
  DrowsinessLevel _lastLevel = DrowsinessLevel.normal;
  DateTime? _dangerSince;

  double get smoothedRisk => _smoothedRisk;

  RiskDecision evaluate(DrowsinessSignalSnapshot signal) {
    var ruleRisk = 0.0;
    var reason = 'Conduccion normal';
    var forcedDanger = false;

    void raise(double score, String nextReason, {bool critical = false}) {
      if (score > ruleRisk) {
        ruleRisk = score;
        reason = nextReason;
      }
      forcedDanger = forcedDanger || critical;
    }

    if (signal.lowLight) {
      raise(22, 'Iluminacion insuficiente');
    }

    // Missing face means unavailable observation, not evidence of fatigue.
    if (signal.noFaceDuration > Duration.zero) {
      reset();
      return const RiskDecision(
        level: DrowsinessLevel.normal,
        ruleRisk: 0,
        modelRisk: 0,
        totalRisk: 0,
        reason: 'SIGNAL_UNAVAILABLE',
        message:
            'Señal insuficiente. Revisa la cámara al detenerte en un lugar seguro.',
        alertTier: 0,
        sustainedDangerDuration: Duration.zero,
      );
    }

    if (signal.closedEyeDuration >= DrowsinessThresholds.prolongedBlinkDanger) {
      raise(96, 'Ojos cerrados mas de 3 segundos', critical: true);
    } else if (signal.closedEyeDuration >=
        DrowsinessThresholds.prolongedBlinkWarning) {
      raise(56, 'Parpadeo prolongado');
    } else if (signal.eyesClosed) {
      raise(25, 'Ojos cerrados');
    }

    if (signal.eyesClosed &&
        signal.headDownDuration >=
            DrowsinessThresholds.sustainedHeadDownWarning) {
      raise(92, 'Ojos cerrados y cabeza caida', critical: true);
    }

    if (!signal.lowLight && signal.perclosReady) {
      if (signal.perclos >= DrowsinessThresholds.perclosDanger) {
        raise(78, 'PERCLOS alto sostenido');
      } else if (signal.perclos >= DrowsinessThresholds.perclosWarning) {
        raise(44, 'PERCLOS en aumento');
      }
    }

    if (signal.yawnCountWindow >= DrowsinessThresholds.yawnDangerCount) {
      raise(76, 'Bostezos repetidos');
    } else if (signal.yawning) {
      raise(30, 'Bostezo detectado');
    }

    if (signal.headDownDuration >=
        DrowsinessThresholds.sustainedHeadDownWarning) {
      raise(42, 'Cabeza inclinada');
    }

    if (signal.distractedDuration >=
        DrowsinessThresholds.sustainedDistractionWarning) {
      raise(41, 'Mirada fuera del camino');
    }

    if (signal.signalQuality < 0.32 && !forcedDanger) {
      ruleRisk = min(ruleRisk, 48);
      if (ruleRisk < 35) {
        reason = signal.lowLight
            ? 'Iluminacion insuficiente'
            : 'Baja confianza de rostro';
      }
    }

    final modelRisk = signal.modelEnabled && !signal.lowLight
        ? _modelRisk(signal.prediction, signal.signalQuality)
        : 0.0;
    var targetRisk = max(ruleRisk, modelRisk);
    if (ruleRisk >= 40 && modelRisk >= 35) {
      // El modelo actual es experimental: puede reforzar una precaucion, pero
      // no convertir por si mismo una regla debil en peligro.
      targetRisk = max(targetRisk, 64);
      reason = '$reason + IA detecta cansancio';
    }

    if (!forcedDanger) {
      targetRisk = (targetRisk * signal.settings.sensitivity.riskMultiplier)
          .clamp(0, 100)
          .toDouble();
    }

    final totalRisk = forcedDanger
        ? targetRisk.clamp(70, 100).toDouble()
        : _smooth(targetRisk);

    final level = _levelFor(totalRisk, forcedDanger);
    final now = signal.timestamp;
    if (level == DrowsinessLevel.danger) {
      _dangerSince ??= now;
    } else {
      _dangerSince = null;
    }
    _lastLevel = level;

    final sustainedDangerDuration = _dangerSince == null
        ? Duration.zero
        : now.difference(_dangerSince!);
    final alertTier = _alertTierFor(level, totalRisk, sustainedDangerDuration);

    return RiskDecision(
      level: level,
      ruleRisk: ruleRisk.clamp(0, 100).toDouble(),
      modelRisk: modelRisk.clamp(0, 100).toDouble(),
      totalRisk: totalRisk.clamp(0, 100).toDouble(),
      reason: reason,
      message: _messageFor(level, reason, signal),
      alertTier: alertTier,
      sustainedDangerDuration: sustainedDangerDuration,
    );
  }

  void reset() {
    _smoothedRisk = 0;
    _lastLevel = DrowsinessLevel.normal;
    _dangerSince = null;
  }

  double _smooth(double targetRisk) {
    final rising = targetRisk > _smoothedRisk;
    final alpha = rising ? 0.48 : 0.16;
    _smoothedRisk += (targetRisk - _smoothedRisk) * alpha;
    if ((_smoothedRisk - targetRisk).abs() < 1) {
      _smoothedRisk = targetRisk;
    }
    return _smoothedRisk;
  }

  DrowsinessLevel _levelFor(double risk, bool forcedDanger) {
    if (forcedDanger || risk >= DrowsinessThresholds.dangerRiskScore) {
      return DrowsinessLevel.danger;
    }
    if (_lastLevel == DrowsinessLevel.danger && risk >= 62) {
      return DrowsinessLevel.danger;
    }
    if (risk >= DrowsinessThresholds.warningRiskScore) {
      return DrowsinessLevel.warning;
    }
    if (_lastLevel == DrowsinessLevel.warning && risk >= 34) {
      return DrowsinessLevel.warning;
    }
    return DrowsinessLevel.normal;
  }

  int _alertTierFor(
    DrowsinessLevel level,
    double risk,
    Duration sustainedDangerDuration,
  ) {
    if (level == DrowsinessLevel.danger &&
        sustainedDangerDuration >= DrowsinessThresholds.sustainedDangerTier4) {
      return 4;
    }
    if (level == DrowsinessLevel.danger) {
      return 3;
    }
    if (level == DrowsinessLevel.warning && risk >= 55) {
      return 2;
    }
    if (level == DrowsinessLevel.warning) {
      return 1;
    }
    return 0;
  }

  double _modelRisk(MlPrediction? prediction, double signalQuality) {
    if (prediction == null || signalQuality < 0.34) {
      return 0;
    }

    final drowsy = prediction.drowsyProbability;
    final fatigue = prediction.fatigueProbability;
    final awake = prediction.awakeProbability;
    var risk = (drowsy * 44) + (fatigue * 24) - (awake * 8);

    if (prediction.predictedClass == 2 && prediction.confidence >= 0.80) {
      risk = max(risk, 66);
    } else if (prediction.predictedClass == 2 &&
        prediction.confidence >= 0.65) {
      risk = max(risk, 48);
    } else if (prediction.predictedClass == 1 &&
        prediction.confidence >= 0.60) {
      risk = max(risk, 36);
    }

    return risk.clamp(0, 82).toDouble();
  }

  String _messageFor(
    DrowsinessLevel level,
    String reason,
    DrowsinessSignalSnapshot signal,
  ) {
    if (signal.lowLight && level != DrowsinessLevel.danger) {
      return 'Iluminacion insuficiente. Mejora la luz o sube el brillo.';
    }

    switch (level) {
      case DrowsinessLevel.normal:
        return 'Conduccion normal';
      case DrowsinessLevel.warning:
        return 'Cuidado: $reason';
      case DrowsinessLevel.danger:
        return signal.noFaceDuration >= const Duration(seconds: 4)
            ? 'ALERTA: no se detecta rostro'
            : 'ALERTA: posible somnolencia';
    }
  }
}

class DrowsinessSignalSnapshot {
  const DrowsinessSignalSnapshot({
    required this.timestamp,
    required this.settings,
    required this.modelEnabled,
    required this.eyesClosed,
    required this.yawning,
    required this.perclosReady,
    required this.perclos,
    required this.yawnCountWindow,
    required this.closedEyeDuration,
    required this.noFaceDuration,
    required this.headDownDuration,
    required this.distractedDuration,
    required this.lowLight,
    required this.signalQuality,
    required this.prediction,
  });

  final DateTime timestamp;
  final AppSettings settings;
  final bool modelEnabled;
  final bool eyesClosed;
  final bool yawning;
  final bool perclosReady;
  final double perclos;
  final int yawnCountWindow;
  final Duration closedEyeDuration;
  final Duration noFaceDuration;
  final Duration headDownDuration;
  final Duration distractedDuration;
  final bool lowLight;
  final double signalQuality;
  final MlPrediction? prediction;
}

class RiskDecision {
  const RiskDecision({
    required this.level,
    required this.ruleRisk,
    required this.modelRisk,
    required this.totalRisk,
    required this.reason,
    required this.message,
    required this.alertTier,
    required this.sustainedDangerDuration,
  });

  final DrowsinessLevel level;
  final double ruleRisk;
  final double modelRisk;
  final double totalRisk;
  final String reason;
  final String message;
  final int alertTier;
  final Duration sustainedDangerDuration;
}

class RollingValueSmoother {
  RollingValueSmoother({required this.maxSamples});

  final int maxSamples;
  final List<double> _values = <double>[];

  double? add(double? value) {
    if (value == null || !value.isFinite || value.isNaN) {
      return current;
    }
    _values.add(value);
    if (_values.length > maxSamples) {
      _values.removeAt(0);
    }
    return current;
  }

  double? get current {
    if (_values.isEmpty) {
      return null;
    }
    return _values.reduce((a, b) => a + b) / _values.length;
  }

  void reset() {
    _values.clear();
  }
}

class DurationTracker {
  DateTime? _startedAt;

  Duration update({required bool active, required DateTime timestamp}) {
    if (!active) {
      _startedAt = null;
      return Duration.zero;
    }
    _startedAt ??= timestamp;
    return timestamp.difference(_startedAt!);
  }

  void reset() {
    _startedAt = null;
  }
}
