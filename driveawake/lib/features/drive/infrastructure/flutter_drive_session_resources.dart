import 'dart:async';
import 'dart:convert';

import 'package:camera/camera.dart';
import 'package:crypto/crypto.dart';
import 'package:flutter/foundation.dart';

import '../../../app/app_config.dart';
import '../../../models/device_telemetry_snapshot.dart';
import '../../../models/drowsiness_state.dart';
import '../../../models/trip_session_draft.dart';
import '../../../models/trip_session_summary.dart';
import '../../../models/technical_session_report.dart';
import '../../../utils/adaptive_frame_scheduler.dart';
import '../../../utils/input_image_converter.dart';
import '../application/drive_ports.dart';
import '../application/controlled_recovery.dart';
import '../application/drive_repositories.dart';
import '../application/drive_session_controller.dart';
import '../application/drive_state.dart';
import '../application/monitoring_watchdog.dart';
import '../application/performance_monitor.dart';
import 'service_adapters.dart';

class FlutterDriveSessionResources extends ChangeNotifier
    implements DriveSessionResources {
  FlutterDriveSessionResources({
    CameraRepository? camera,
    FaceDetectionRepository? faceDetection,
    DrowsinessAnalyzer? analyzer,
    AlarmController? alarm,
    TripRepository? trip,
    TelemetryRepository? telemetry,
    Clock clock = const SystemClock(),
    Logger logger = const DebugLogger(),
    AdaptiveFrameScheduler? scheduler,
    PerformanceMonitor? performanceMonitor,
    MonitoringWatchdog? watchdog,
    DriveDelay delay = Future<void>.delayed,
    Duration watchdogInterval = const Duration(seconds: 1),
  }) : _camera = camera ?? CameraServiceAdapter(),
       _faceDetection = faceDetection ?? FaceDetectionServiceAdapter(),
       _alarm = alarm ?? AlertServiceAdapter(),
       _trip = trip ?? TripSessionServiceAdapter(),
       _telemetry = telemetry ?? DeviceTelemetryServiceAdapter(),
       _clock = clock,
       _logger = logger,
       _scheduler = scheduler ?? AdaptiveFrameScheduler(),
       _watchdog = watchdog ?? const MonitoringWatchdog(),
       _delay = delay,
       _watchdogInterval = watchdogInterval {
    _performance = performanceMonitor ?? PerformanceMonitor();
    _analyzer =
        analyzer ?? DrowsinessServiceAdapter(performanceMonitor: _performance);
  }

  final CameraRepository _camera;
  final FaceDetectionRepository _faceDetection;
  late final DrowsinessAnalyzer _analyzer;
  final AlarmController _alarm;
  final TripRepository _trip;
  final TelemetryRepository _telemetry;
  final Clock _clock;
  final Logger _logger;
  final AdaptiveFrameScheduler _scheduler;
  late final PerformanceMonitor _performance;
  final MonitoringWatchdog _watchdog;
  final DriveDelay _delay;
  final Duration _watchdogInterval;
  final List<DateTime> _processedFrameTimes = <DateTime>[];

  DriveState _state = DriveState.idle();
  DateTime _lastFrameAt = DateTime.fromMillisecondsSinceEpoch(0);
  Timer? _telemetryTimer;
  Timer? _watchdogTimer;
  Future<void>? _pauseOperation;
  bool _prepared = false;
  bool _paused = false;
  bool _processing = false;
  bool _disposed = false;
  int _consecutiveProcessingErrors = 0;
  int _persistentDriftErrors = 0;
  int _recoveryGeneration = 0;
  int _recoveryAttempts = 0;
  bool _recoveryExhausted = false;
  bool _recovering = false;
  bool _lifecycleActive = true;
  int? _monitoringStartedMicros;
  Completer<bool>? _validFrameDuringRecovery;
  DeviceTelemetrySnapshot? _initialTelemetry;
  double? _maximumTemperatureC;
  int? _maximumMemoryBytes;
  int _successfulRecoveries = 0;
  int _failedRecoveries = 0;
  int _cameraRestarts = 0;
  int _pauseCount = 0;
  int? _lastThermalSampleMicros;
  DriveThermalStatus _lastThermalStatus = DriveThermalStatus.unknown;
  Duration _elevatedThermalTime = Duration.zero;
  Duration _criticalThermalTime = Duration.zero;
  DateTime? _dangerAcknowledgedAt;

  @override
  DriveState get resourceState => _state;

  @override
  Future<void> prepare({TripSessionDraft? recoveredDraft}) async {
    if (_prepared) return;
    _performance.reset();
    await _analyzer.initialize();
    if (recoveredDraft == null) {
      _trip.start();
      _paused = false;
    } else {
      _trip.restore(recoveredDraft);
      _paused = true;
    }
    _prepared = true;
    _emit(
      _state.copyWith(
        draft: recoveredDraft,
        processingStatus: DriveProcessingStatus.idle,
      ),
    );
    await _pollTelemetry();
  }

  @override
  Future<void> startMonitoring() async {
    if (!_prepared) throw StateError('La sesion no fue preparada');
    if (_state.streamActive) return;
    _lifecycleActive = true;
    _performance.beginMonitoringEpisode();
    _recoveryAttempts = 0;
    _recoveryExhausted = false;
    _emit(
      _state.copyWith(
        cameraStatus: DriveCameraStatus.initializing,
        streamStatus: DriveStreamStatus.starting,
        clearRecoverableError: true,
      ),
    );
    if (!_camera.isInitialized) await _camera.initialize();
    _analyzer.resetTemporalState();
    _lastFrameAt = DateTime.fromMillisecondsSinceEpoch(0);
    _processedFrameTimes.clear();
    await _camera.startStream(_processFrame);
    if (_paused) _trip.resume();
    _paused = false;
    _startTelemetryTimer();
    _startWatchdogTimer();
    _monitoringStartedMicros = _performance.nowMicros();
    await _telemetry.keepScreenAwake(true);
    _emit(
      _state.copyWith(
        cameraStatus: DriveCameraStatus.ready,
        streamStatus: DriveStreamStatus.streaming,
        processingStatus: DriveProcessingStatus.idle,
        cameraController: _camera.controller,
        clearRecoverableError: true,
      ),
    );
  }

  @override
  Future<void> pauseMonitoring() => _pauseOperation ??= _pauseOnce();

  Future<void> _pauseOnce() async {
    try {
      _lifecycleActive = false;
      _recoveryGeneration += 1;
      _recovering = false;
      _validFrameDuringRecovery?.complete(false);
      _validFrameDuringRecovery = null;
      _emit(
        _state.copyWith(
          streamStatus: DriveStreamStatus.stopping,
          processingStatus: DriveProcessingStatus.idle,
        ),
      );
      _telemetryTimer?.cancel();
      _telemetryTimer = null;
      _watchdogTimer?.cancel();
      _watchdogTimer = null;
      await _camera.stopAndDispose();
      await _alarm.stop();
      await _telemetry.keepScreenAwake(false);
      if (_prepared && !_paused) _trip.pause();
      if (_prepared && !_paused) _pauseCount += 1;
      _paused = true;
      _processing = false;
      _consecutiveProcessingErrors = 0;
      _persistentDriftErrors = 0;
      _analyzer.resetTemporalState();
      _processedFrameTimes.clear();
      _emit(
        _state.copyWith(
          cameraStatus: DriveCameraStatus.off,
          streamStatus: DriveStreamStatus.stopped,
          processingStatus: DriveProcessingStatus.idle,
          alarmStatus: DriveAlarmStatus.silent,
          monitoringHealth: MonitoringHealth.unavailable,
          technicalReason: 'El monitoreo está pausado.',
          clearCameraController: true,
        ),
      );
    } finally {
      _pauseOperation = null;
    }
  }

  @override
  Future<TripSessionSummary> finishMonitoring() async {
    await pauseMonitoring();
    final summary = await _trip.finish();
    if (AppConfig.technicalFeaturesEnabled) {
      _accumulateThermalTime(_performance.nowMicros());
      final anonymousId = sha256
          .convert(utf8.encode(summary.tripId))
          .toString()
          .substring(0, 32);
      _emit(
        _state.copyWith(
          technicalReport: TechnicalSessionReport(
            anonymousSessionId: anonymousId,
            deviceManufacturer: _initialTelemetry?.deviceManufacturer,
            deviceModel: _initialTelemetry?.deviceModel,
            androidVersion: _initialTelemetry?.androidVersion,
            appVersion: AppConfig.appVersion,
            duration: summary.drivingDuration,
            performance: _performance.snapshot(),
            cameraRestarts: _cameraRestarts,
            successfulRecoveries: _successfulRecoveries,
            failedRecoveries: _failedRecoveries,
            initialBattery: _initialTelemetry?.batteryLevel,
            finalBattery: _state.telemetry?.batteryLevel,
            initialTemperatureC: _initialTelemetry?.temperatureC,
            maximumTemperatureC: _maximumTemperatureC,
            elevatedThermalTime: _elevatedThermalTime,
            criticalThermalTime: _criticalThermalTime,
            initialMemoryBytes: _initialTelemetry?.memoryBytes,
            finalMemoryBytes: _state.telemetry?.memoryBytes,
            maximumMemoryBytes: _maximumMemoryBytes,
            pauseCount: _pauseCount,
            normalCompletion: true,
          ),
        ),
      );
    }
    return summary;
  }

  @override
  Future<void> discardMonitoring() async {
    await pauseMonitoring();
    await _trip.discard();
  }

  @override
  Future<void> startCalibration() => _analyzer.startCalibration();

  @override
  Future<void> acknowledgeDanger() async {
    await _alarm.stop();
    _dangerAcknowledgedAt = _clock.now();
    _emit(_state.copyWith(alarmStatus: DriveAlarmStatus.acknowledged));
  }

  Future<void> _processFrame(CameraImage image) async {
    _performance.frameReceived();
    final now = _clock.now();
    final interval = _scheduler.intervalFor(
      riskLevel: _state.monitoring.level,
      calibrationInProgress: _state.monitoring.calibrationInProgress,
    );
    if (_paused) {
      _performance.frameDroppedScheduler();
      return;
    }
    if (now.difference(_lastFrameAt) < interval) {
      _performance.frameDroppedScheduler();
      return;
    }
    if (_processing) {
      _performance.frameDroppedBusy();
      return;
    }
    final controller = _camera.controller;
    final camera = _camera.camera;
    if (controller == null || camera == null) return;
    _processing = true;
    _lastFrameAt = now;
    _performance.frameAccepted(
      requestedFps: _scheduler.requestedFpsFor(
        riskLevel: _state.monitoring.level,
        calibrationInProgress: _state.monitoring.calibrationInProgress,
      ),
    );
    final totalStarted = _performance.nowMicros();
    try {
      final input = _performance.measureSync(
        ProcessingStage.imageConversion,
        () => InputImageConverter.fromCameraImage(
          image,
          camera,
          controller.value.deviceOrientation,
        ),
      );
      if (input == null) {
        _performance.frameFailed(ProcessingStage.imageConversion);
        return;
      }
      final faces = await _performance.measure(
        ProcessingStage.faceDetection,
        () => _faceDetection.detect(input),
      );
      final next = await _performance.measure(
        ProcessingStage.featureExtraction,
        () => _analyzer.analyze(
          faces: faces,
          timestamp: now,
          imageBrightness: _estimateBrightness(image),
          imageWidth: image.width,
          imageHeight: image.height,
          fps: _trackFps(now),
        ),
      );
      try {
        await _performance.measure(
          ProcessingStage.persistence,
          () => _trip.observe(next, now),
        );
        _persistentDriftErrors = 0;
      } catch (_) {
        _persistentDriftErrors += 1;
        rethrow;
      }
      final alarmStatus = _alarmStatus(next);
      if (alarmStatus != DriveAlarmStatus.acknowledged) {
        await _alarm.handle(next);
      }
      _consecutiveProcessingErrors = 0;
      _performance.frameProcessed(hasFace: faces.isNotEmpty);
      if (faces.isNotEmpty) {
        _validFrameDuringRecovery?.complete(true);
        _validFrameDuringRecovery = null;
      }
      _performance.measureSync(
        ProcessingStage.stateUpdate,
        () => _emitTechnicalState(
          _state.copyWith(
            monitoring: next,
            processingStatus: DriveProcessingStatus.idle,
            alarmStatus: alarmStatus,
            lastValidFrame: now,
            clearRecoverableError: true,
          ),
        ),
      );
    } catch (error, stackTrace) {
      _performance.frameFailed();
      _consecutiveProcessingErrors += 1;
      _logger.warning('Fallo al procesar frame', error, stackTrace);
      if (_consecutiveProcessingErrors >= 3) {
        _emit(
          _state.copyWith(
            phase: DriveSessionPhase.recoverableError,
            processingStatus: DriveProcessingStatus.error,
            recoverableError:
                'El analisis fallo repetidamente. Pausa y reintenta.',
          ),
        );
      }
    } finally {
      _performance.recordLatencyMicros(
        ProcessingStage.total,
        _performance.nowMicros() - totalStarted,
      );
      _processing = false;
    }
  }

  void _startWatchdogTimer() {
    _watchdogTimer?.cancel();
    _watchdogTimer = Timer.periodic(
      _watchdogInterval,
      (_) => unawaited(_evaluateWatchdog()),
    );
  }

  Future<void> _evaluateWatchdog() async {
    if (_paused || _disposed || !_lifecycleActive) return;
    final nowMicros = _performance.nowMicros();
    final started = _monitoringStartedMicros;
    final snapshot = _performance.snapshot();
    if (snapshot.lastValidFrameMicros == null &&
        started != null &&
        nowMicros - started <
            _watchdog.config.criticalFrameAfter.inMicroseconds) {
      return;
    }
    final assessment = _watchdog.evaluate(
      performance: snapshot,
      nowMicros: nowMicros,
      streamStatus: _state.streamStatus,
      cameraStatus: _state.cameraStatus,
      lifecycleActive: _lifecycleActive,
      thermalStatus: _state.thermalStatus,
      telemetryAvailable: _state.telemetry != null,
      consecutiveFailures: _consecutiveProcessingErrors,
      persistentDriftErrors: _persistentDriftErrors,
      recovering: _recovering,
      recoveryExhausted: _recoveryExhausted,
    );
    _emitTechnicalState(
      _state.copyWith(
        monitoringHealth: assessment.health,
        technicalReason: assessment.reason,
      ),
    );
    if (assessment.health == MonitoringHealth.unavailable &&
        _state.streamActive &&
        !_recovering &&
        !_recoveryExhausted) {
      await _recoverMonitoring();
    }
  }

  Future<void> _recoverMonitoring() async {
    if (_recovering || _paused || _disposed) return;
    final generation = ++_recoveryGeneration;
    _recovering = true;
    _recoveryExhausted = false;
    await _alarm.stop();
    _analyzer.resetTemporalState();
    _emitTechnicalState(
      _state.copyWith(
        monitoringHealth: MonitoringHealth.recovering,
        technicalReason: 'Reiniciando la fuente de monitoreo.',
        alarmStatus: DriveAlarmStatus.silent,
        processingStatus: DriveProcessingStatus.idle,
      ),
    );

    final recovery = ControlledRecovery(
      maximumAttempts: _watchdog.config.maximumRecoveryAttempts,
      initialBackoff: _watchdog.config.recoveryBackoff,
    );
    final outcome = await recovery.run(
      isCancelled: () =>
          generation != _recoveryGeneration || _paused || _disposed,
      attempt: (attempt, backoff) async {
        _recoveryAttempts = attempt;
        _emitTechnicalState(
          _state.copyWith(recoveryAttempts: _recoveryAttempts),
        );
        try {
          await _camera.stopAndDispose();
          await _delay(backoff);
          if (generation != _recoveryGeneration || _paused || _disposed) {
            return false;
          }
          await _camera.initialize();
          _cameraRestarts += 1;
          _validFrameDuringRecovery = Completer<bool>();
          await _camera.startStream(_processFrame);
          _monitoringStartedMicros = _performance.nowMicros();
          _emit(
            _state.copyWith(
              cameraStatus: DriveCameraStatus.ready,
              streamStatus: DriveStreamStatus.streaming,
              cameraController: _camera.controller,
            ),
          );
          final recovered = await _validFrameDuringRecovery!.future.timeout(
            _watchdog.config.criticalFrameAfter,
            onTimeout: () => false,
          );
          _validFrameDuringRecovery = null;
          return recovered;
        } catch (error, stackTrace) {
          _logger.warning(
            'Intento de recuperación $attempt falló',
            error,
            stackTrace,
          );
          return false;
        }
      },
    );
    if (outcome == RecoveryOutcome.cancelled) return;
    if (outcome == RecoveryOutcome.recovered) {
      _successfulRecoveries += 1;
      _recoveryExhausted = false;
      _recovering = false;
      _emitTechnicalState(
        _state.copyWith(
          monitoringHealth: MonitoringHealth.healthy,
          clearTechnicalReason: true,
        ),
      );
      return;
    }
    _recovering = false;
    _failedRecoveries += 1;
    _recoveryExhausted = true;
    await _alarm.stop();
    _emitTechnicalState(
      _state.copyWith(
        monitoringHealth: MonitoringHealth.unavailable,
        technicalReason: 'La cámara no pudo recuperarse.',
        cameraStatus: DriveCameraStatus.error,
        streamStatus: DriveStreamStatus.error,
        alarmStatus: DriveAlarmStatus.silent,
      ),
    );
  }

  void _emitTechnicalState(DriveState base) {
    final snapshot = _performance.snapshot();
    _emit(
      base.copyWith(
        performance: snapshot,
        actualFps: snapshot.actualFps,
        framesDropped: snapshot.framesDropped,
        totalP95Ms: snapshot.totalP95Ms,
      ),
    );
  }

  DriveAlarmStatus _alarmStatus(DrowsinessState state) {
    if (state.level == DrowsinessLevel.danger) {
      final acknowledgedAt = _dangerAcknowledgedAt;
      if (acknowledgedAt != null &&
          _clock.now().difference(acknowledgedAt) <
              const Duration(seconds: 30)) {
        return DriveAlarmStatus.acknowledged;
      }
      return DriveAlarmStatus.danger;
    }
    _dangerAcknowledgedAt = null;
    if (state.alertTier >= 2) return DriveAlarmStatus.warning;
    return DriveAlarmStatus.silent;
  }

  void _startTelemetryTimer() {
    _telemetryTimer?.cancel();
    _telemetryTimer = Timer.periodic(
      const Duration(seconds: 12),
      (_) => unawaited(_pollTelemetry()),
    );
  }

  Future<void> _pollTelemetry() async {
    try {
      final snapshot = await _telemetry.read();
      if (snapshot == null) return;
      _initialTelemetry ??= snapshot;
      final temperature = snapshot.temperatureC;
      if (temperature != null &&
          (_maximumTemperatureC == null ||
              temperature > _maximumTemperatureC!)) {
        _maximumTemperatureC = temperature;
      }
      final memoryBytes = snapshot.memoryBytes;
      if (memoryBytes != null &&
          (_maximumMemoryBytes == null || memoryBytes > _maximumMemoryBytes!)) {
        _maximumMemoryBytes = memoryBytes;
      }
      final nextThermalStatus = _thermalStatus(snapshot);
      _accumulateThermalTime(_performance.nowMicros());
      _lastThermalStatus = nextThermalStatus;
      _trip.recordTelemetry(snapshot);
      _scheduler.updateTelemetry(
        batteryPercent: snapshot.batteryLevel,
        batteryTemperatureC: snapshot.temperatureC,
        charging: snapshot.isCharging,
      );
      _emit(
        _state.copyWith(telemetry: snapshot, thermalStatus: nextThermalStatus),
      );
    } catch (error, stackTrace) {
      _logger.warning('No se pudo leer telemetria', error, stackTrace);
    }
  }

  DriveThermalStatus _thermalStatus(DeviceTelemetrySnapshot snapshot) {
    final value = snapshot.temperatureC;
    if (value == null) return DriveThermalStatus.unknown;
    if (value >= 44) return DriveThermalStatus.critical;
    if (value >= 40) return DriveThermalStatus.elevated;
    return DriveThermalStatus.normal;
  }

  void _accumulateThermalTime(int nowMicros) {
    final previous = _lastThermalSampleMicros;
    _lastThermalSampleMicros = nowMicros;
    if (previous == null || nowMicros <= previous) return;
    final elapsed = Duration(microseconds: nowMicros - previous);
    if (_lastThermalStatus == DriveThermalStatus.elevated) {
      _elevatedThermalTime += elapsed;
    } else if (_lastThermalStatus == DriveThermalStatus.critical) {
      _criticalThermalTime += elapsed;
    }
  }

  double? _estimateBrightness(CameraImage image) {
    if (image.planes.isEmpty) return null;
    final bytes = image.planes.first.bytes;
    if (bytes.isEmpty) return null;
    // Sample roughly 800 luminance bytes regardless of camera resolution.
    final step = (bytes.length ~/ 800).clamp(1, 10000);
    var total = 0.0;
    var count = 0;
    for (var index = 0; index < bytes.length; index += step) {
      total += bytes[index];
      count += 1;
    }
    return count == 0 ? null : total / count;
  }

  double _trackFps(DateTime timestamp) {
    _processedFrameTimes.add(timestamp);
    final cutoff = timestamp.subtract(const Duration(seconds: 2));
    _processedFrameTimes.removeWhere((time) => time.isBefore(cutoff));
    if (_processedFrameTimes.length < 2) return 0;
    final elapsed = _processedFrameTimes.last
        .difference(_processedFrameTimes.first)
        .inMilliseconds;
    return elapsed <= 0
        ? 0
        : (_processedFrameTimes.length - 1) * 1000 / elapsed;
  }

  void _emit(DriveState state) {
    if (_disposed) return;
    _state = state;
    notifyListeners();
  }

  @override
  Future<void> disposeResources() async {
    if (_disposed) return;
    _disposed = true;
    _telemetryTimer?.cancel();
    _watchdogTimer?.cancel();
    _recoveryGeneration += 1;
    _validFrameDuringRecovery?.complete(false);
    await _camera.stopAndDispose();
    await _alarm.close();
    await _faceDetection.close();
    await _analyzer.close();
    await _telemetry.keepScreenAwake(false);
  }
}
