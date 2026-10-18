import 'package:flutter/foundation.dart';

import 'drive_state.dart';
import 'performance_monitor.dart';

enum MonitoringHealth { healthy, degraded, recovering, unavailable }

@immutable
class MonitoringWatchdogConfig {
  const MonitoringWatchdogConfig({
    this.staleFrameAfter = const Duration(seconds: 3),
    this.criticalFrameAfter = const Duration(seconds: 8),
    this.minimumActualFps = 2,
    this.maximumDropRatio = 0.55,
    this.maximumTotalP95Ms = 700,
    this.maximumConsecutiveFailures = 3,
    this.maximumRecoveryAttempts = 3,
    this.recoveryBackoff = const Duration(milliseconds: 500),
  });

  final Duration staleFrameAfter;
  final Duration criticalFrameAfter;
  final double minimumActualFps;
  final double maximumDropRatio;
  final double maximumTotalP95Ms;
  final int maximumConsecutiveFailures;
  final int maximumRecoveryAttempts;
  final Duration recoveryBackoff;

  Duration backoffForAttempt(int attempt) => Duration(
    microseconds: recoveryBackoff.inMicroseconds * attempt.clamp(1, 8),
  );
}

@immutable
class MonitoringAssessment {
  const MonitoringAssessment(this.health, this.reason);

  final MonitoringHealth health;
  final String? reason;
}

class MonitoringWatchdog {
  const MonitoringWatchdog({this.config = const MonitoringWatchdogConfig()});

  final MonitoringWatchdogConfig config;

  MonitoringAssessment evaluate({
    required PerformanceSnapshot performance,
    required int nowMicros,
    required DriveStreamStatus streamStatus,
    required DriveCameraStatus cameraStatus,
    required bool lifecycleActive,
    required DriveThermalStatus thermalStatus,
    required bool telemetryAvailable,
    required int consecutiveFailures,
    required int persistentDriftErrors,
    required bool recovering,
    required bool recoveryExhausted,
  }) {
    if (recovering) {
      return const MonitoringAssessment(
        MonitoringHealth.recovering,
        'Reiniciando la fuente de monitoreo.',
      );
    }
    if (!lifecycleActive) {
      return const MonitoringAssessment(
        MonitoringHealth.unavailable,
        'La aplicación no está activa.',
      );
    }
    if (recoveryExhausted || cameraStatus == DriveCameraStatus.error) {
      return const MonitoringAssessment(
        MonitoringHealth.unavailable,
        'La cámara no pudo recuperarse.',
      );
    }
    final lastValid = performance.lastValidFrameMicros;
    final validAge = lastValid == null ? null : nowMicros - lastValid;
    if (streamStatus == DriveStreamStatus.streaming &&
        (lastValid == null ||
            validAge! >= config.criticalFrameAfter.inMicroseconds)) {
      return const MonitoringAssessment(
        MonitoringHealth.unavailable,
        'No se reciben frames válidos.',
      );
    }
    if (streamStatus != DriveStreamStatus.streaming) {
      return const MonitoringAssessment(
        MonitoringHealth.unavailable,
        'El stream de cámara está detenido.',
      );
    }
    if (consecutiveFailures >= config.maximumConsecutiveFailures ||
        persistentDriftErrors >= config.maximumConsecutiveFailures) {
      return const MonitoringAssessment(
        MonitoringHealth.unavailable,
        'El pipeline presenta fallos persistentes.',
      );
    }
    if (validAge != null && validAge >= config.staleFrameAfter.inMicroseconds) {
      return const MonitoringAssessment(
        MonitoringHealth.degraded,
        'Los frames válidos llegan con retraso.',
      );
    }
    if (performance.framesProcessed >= 3 &&
        performance.actualFps < config.minimumActualFps) {
      return const MonitoringAssessment(
        MonitoringHealth.degraded,
        'La tasa real de procesamiento es baja.',
      );
    }
    if (performance.framesAccepted + performance.framesDroppedBusy >= 5 &&
        performance.busyDropRatio > config.maximumDropRatio) {
      return const MonitoringAssessment(
        MonitoringHealth.degraded,
        'La cámara no alcanza el ritmo de análisis. Revisa el teléfono al detenerte.',
      );
    }
    if (performance.totalP95Ms > config.maximumTotalP95Ms) {
      return const MonitoringAssessment(
        MonitoringHealth.degraded,
        'La latencia de procesamiento es elevada.',
      );
    }
    if (thermalStatus == DriveThermalStatus.elevated ||
        thermalStatus == DriveThermalStatus.critical) {
      return const MonitoringAssessment(
        MonitoringHealth.degraded,
        'La temperatura del dispositivo limita el monitoreo.',
      );
    }
    if (!telemetryAvailable) {
      return const MonitoringAssessment(
        MonitoringHealth.degraded,
        'La telemetría del dispositivo no está disponible.',
      );
    }
    return const MonitoringAssessment(MonitoringHealth.healthy, null);
  }
}
