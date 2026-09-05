import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';

import '../../../models/device_telemetry_snapshot.dart';
import '../../../models/drowsiness_state.dart';
import '../../../models/trip_session_draft.dart';
import '../../../models/trip_session_summary.dart';
import '../../../models/technical_session_report.dart';
import 'monitoring_watchdog.dart';
import 'performance_monitor.dart';

enum DriveSessionPhase {
  idle,
  starting,
  active,
  paused,
  resuming,
  finishing,
  completed,
  recoverableError,
  fatalError,
}

enum DriveCameraStatus { off, requestingPermission, initializing, ready, error }

enum DriveStreamStatus { stopped, starting, streaming, stopping, error }

enum DriveProcessingStatus { idle, processing, throttled, error }

enum DriveAlarmStatus { silent, warning, danger, acknowledged }

enum DriveThermalStatus { unknown, normal, elevated, critical }

@immutable
class DriveState {
  DriveState({
    required this.phase,
    this.cameraStatus = DriveCameraStatus.off,
    this.streamStatus = DriveStreamStatus.stopped,
    this.processingStatus = DriveProcessingStatus.idle,
    DrowsinessState? monitoring,
    this.alarmStatus = DriveAlarmStatus.silent,
    this.thermalStatus = DriveThermalStatus.unknown,
    this.monitoringHealth = MonitoringHealth.unavailable,
    this.technicalReason,
    this.lastValidFrame,
    this.recoveryAttempts = 0,
    this.actualFps = 0,
    this.framesDropped = 0,
    this.totalP95Ms = 0,
    this.performance,
    this.technicalReport,
    this.cameraController,
    this.telemetry,
    this.draft,
    this.summary,
    this.resumeCountdown,
    this.recoverableError,
    this.fatalError,
  }) : monitoring = monitoring ?? DrowsinessState.initial();

  DriveState.idle() : this(phase: DriveSessionPhase.idle);

  final DriveSessionPhase phase;
  final DriveCameraStatus cameraStatus;
  final DriveStreamStatus streamStatus;
  final DriveProcessingStatus processingStatus;
  final DrowsinessState monitoring;
  final DriveAlarmStatus alarmStatus;
  final DriveThermalStatus thermalStatus;
  final MonitoringHealth monitoringHealth;
  final String? technicalReason;
  final DateTime? lastValidFrame;
  final int recoveryAttempts;
  final double actualFps;
  final int framesDropped;
  final double totalP95Ms;
  final PerformanceSnapshot? performance;
  final TechnicalSessionReport? technicalReport;
  final CameraController? cameraController;
  final DeviceTelemetrySnapshot? telemetry;
  final TripSessionDraft? draft;
  final TripSessionSummary? summary;
  final int? resumeCountdown;
  final String? recoverableError;
  final String? fatalError;

  bool get monitoringActive => phase == DriveSessionPhase.active;
  bool get paused => phase == DriveSessionPhase.paused;
  bool get cameraReady =>
      cameraStatus == DriveCameraStatus.ready && cameraController != null;
  bool get streamActive => streamStatus == DriveStreamStatus.streaming;
  bool get transitionInProgress =>
      phase == DriveSessionPhase.starting ||
      phase == DriveSessionPhase.resuming ||
      phase == DriveSessionPhase.finishing;
  String? get errorMessage => fatalError ?? recoverableError;

  DriveState copyWith({
    DriveSessionPhase? phase,
    DriveCameraStatus? cameraStatus,
    DriveStreamStatus? streamStatus,
    DriveProcessingStatus? processingStatus,
    DrowsinessState? monitoring,
    DriveAlarmStatus? alarmStatus,
    DriveThermalStatus? thermalStatus,
    MonitoringHealth? monitoringHealth,
    String? technicalReason,
    bool clearTechnicalReason = false,
    DateTime? lastValidFrame,
    int? recoveryAttempts,
    double? actualFps,
    int? framesDropped,
    double? totalP95Ms,
    PerformanceSnapshot? performance,
    TechnicalSessionReport? technicalReport,
    CameraController? cameraController,
    bool clearCameraController = false,
    DeviceTelemetrySnapshot? telemetry,
    TripSessionDraft? draft,
    TripSessionSummary? summary,
    int? resumeCountdown,
    bool clearCountdown = false,
    String? recoverableError,
    bool clearRecoverableError = false,
    String? fatalError,
    bool clearFatalError = false,
  }) => DriveState(
    phase: phase ?? this.phase,
    cameraStatus: cameraStatus ?? this.cameraStatus,
    streamStatus: streamStatus ?? this.streamStatus,
    processingStatus: processingStatus ?? this.processingStatus,
    monitoring: monitoring ?? this.monitoring,
    alarmStatus: alarmStatus ?? this.alarmStatus,
    thermalStatus: thermalStatus ?? this.thermalStatus,
    monitoringHealth: monitoringHealth ?? this.monitoringHealth,
    technicalReason: clearTechnicalReason
        ? null
        : technicalReason ?? this.technicalReason,
    lastValidFrame: lastValidFrame ?? this.lastValidFrame,
    recoveryAttempts: recoveryAttempts ?? this.recoveryAttempts,
    actualFps: actualFps ?? this.actualFps,
    framesDropped: framesDropped ?? this.framesDropped,
    totalP95Ms: totalP95Ms ?? this.totalP95Ms,
    performance: performance ?? this.performance,
    technicalReport: technicalReport ?? this.technicalReport,
    cameraController: clearCameraController
        ? null
        : cameraController ?? this.cameraController,
    telemetry: telemetry ?? this.telemetry,
    draft: draft ?? this.draft,
    summary: summary ?? this.summary,
    resumeCountdown: clearCountdown
        ? null
        : resumeCountdown ?? this.resumeCountdown,
    recoverableError: clearRecoverableError
        ? null
        : recoverableError ?? this.recoverableError,
    fatalError: clearFatalError ? null : fatalError ?? this.fatalError,
  );
}
