import 'dart:math';

import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';

import '../models/drowsiness_frame_metrics.dart';
import '../models/drowsiness_state.dart';
import '../models/ml_prediction.dart';
import '../utils/drowsiness_thresholds.dart';
import '../utils/perclos_tracker.dart';
import '../features/drive/application/performance_monitor.dart';
import 'calibration_service.dart';
import 'drowsiness_engine.dart';
import 'drowsiness_model_service.dart';
import 'feature_window_service.dart';
import 'settings_service.dart';

class DrowsinessService {
  DrowsinessService({PerformanceMonitor? performanceMonitor})
    : _performance = performanceMonitor;

  final PerformanceMonitor? _performance;
  final SettingsService _settingsService = SettingsService.instance;
  final DrowsinessModelService _modelService = DrowsinessModelService();
  final FeatureWindowService _featureWindowService = FeatureWindowService();
  final CalibrationService _calibrationService = CalibrationService();
  final DrowsinessEngine _engine = DrowsinessEngine();
  final PerclosTracker _perclosTracker = PerclosTracker(
    window: DrowsinessThresholds.perclosWindow,
  );

  final RollingValueSmoother _earSmoother = RollingValueSmoother(maxSamples: 5);
  final RollingValueSmoother _marSmoother = RollingValueSmoother(maxSamples: 5);
  final RollingValueSmoother _headXSmoother = RollingValueSmoother(
    maxSamples: 5,
  );
  final RollingValueSmoother _headYSmoother = RollingValueSmoother(
    maxSamples: 5,
  );
  final RollingValueSmoother _eyeScoreSmoother = RollingValueSmoother(
    maxSamples: 4,
  );
  final DurationTracker _eyeClosedTracker = DurationTracker();
  final DurationTracker _noFaceTracker = DurationTracker();
  final DurationTracker _headDownTracker = DurationTracker();
  final DurationTracker _distractedTracker = DurationTracker();

  DateTime? _lastPredictionAt;
  MlPrediction? _lastPrediction;
  bool _wasYawning = false;
  final List<DateTime> _yawnEvents = <DateTime>[];

  Future<void> initialize() async {
    await Future.wait(<Future<void>>[
      _settingsService.initialize(),
      _modelService.initialize(),
      _calibrationService.initialize(),
    ]);
    _modelService.setDebugLogging(
      _settingsService.settings.technicalPanelEnabled,
    );
  }

  Future<void> startGuidedCalibration() async {
    _resetRuntimeState(keepCalibration: true);
    _calibrationService.startGuidedCalibration();
  }

  Future<void> resetCalibration() async {
    await _calibrationService.reset();
    _resetRuntimeState(keepCalibration: false);
  }

  Future<void> cancelGuidedCalibration() async {
    await _calibrationService.cancelGuidedCalibration();
  }

  void resetTemporalState() {
    _resetRuntimeState(keepCalibration: true);
  }

  Future<DrowsinessState> analyze({
    required List<Face> faces,
    required DateTime timestamp,
    double? imageBrightness,
    int? imageWidth,
    int? imageHeight,
    double? fps,
  }) async {
    await _settingsService.initialize();
    _modelService.setDebugLogging(
      _settingsService.settings.technicalPanelEnabled,
    );
    _perclosTracker.window = _settingsService.settings.perclosWindow;
    _purgeOldYawns(timestamp);

    final lowLight = _isLowLight(imageBrightness);
    if (faces.isEmpty) {
      return _analyzeNoFace(
        timestamp: timestamp,
        imageBrightness: imageBrightness,
        lowLight: lowLight,
        fps: fps,
      );
    }

    final noFaceDuration = _noFaceTracker.update(
      active: false,
      timestamp: timestamp,
    );
    final face = _measureSync(
      ProcessingStage.faceSelection,
      () => _largestFace(faces),
    );
    final rawEyeOpenScore = _eyeOpenScore(face);
    final rawEar = _averageEar(face);
    final rawMar = _mouthAspectRatio(face);
    final rawHeadX = face.headEulerAngleX;
    final rawHeadY = face.headEulerAngleY;
    final faceSizeRatio = _faceSizeRatio(face, imageWidth, imageHeight);
    final signalQuality = _signalQuality(
      ear: rawEar,
      mar: rawMar,
      eyeOpenScore: rawEyeOpenScore,
      brightness: imageBrightness,
      faceSizeRatio: faceSizeRatio,
    );
    final reliableLandmarks = signalQuality >= 0.36 && !lowLight;

    final eyeOpenScore = _eyeScoreSmoother.add(rawEyeOpenScore);
    final ear = _earSmoother.add(rawEar);
    final mar = _marSmoother.add(rawMar);
    final headX = _headXSmoother.add(rawHeadX);
    final headY = _headYSmoother.add(rawHeadY);

    final eyesClosedByScore =
        reliableLandmarks &&
        eyeOpenScore != null &&
        eyeOpenScore < DrowsinessThresholds.eyeOpenScoreClosed;
    final eyesClosedByEar =
        reliableLandmarks &&
        ear != null &&
        ear < _calibrationService.calibratedEarClosedThreshold;
    final eyesClosed = eyesClosedByScore || eyesClosedByEar;

    await _calibrationService.observe(
      CalibrationObservation(
        timestamp: timestamp,
        faceDetected: true,
        eyesClosed: eyesClosed,
        ear: rawEar,
        mar: rawMar,
        eyeOpenScore: rawEyeOpenScore,
        headX: rawHeadX ?? 0,
        headY: rawHeadY ?? 0,
        faceSizeRatio: faceSizeRatio,
      ),
    );

    final closedDuration = _eyeClosedTracker.update(
      active: eyesClosed,
      timestamp: timestamp,
    );
    final prolongedBlink =
        closedDuration >= DrowsinessThresholds.prolongedBlinkWarning;

    final yawning =
        reliableLandmarks &&
        mar != null &&
        mar > _calibrationService.calibratedYawnThreshold;
    _registerYawnIfNeeded(timestamp, yawning);

    final headDown =
        reliableLandmarks &&
        headX != null &&
        headX.abs() >= _calibrationService.calibratedHeadDownAngle;
    final distracted =
        reliableLandmarks &&
        headY != null &&
        headY.abs() >= _calibrationService.calibratedDistractionAngle;
    final headDownDuration = _headDownTracker.update(
      active: headDown,
      timestamp: timestamp,
    );
    final distractedDuration = _distractedTracker.update(
      active: distracted,
      timestamp: timestamp,
    );

    final perclos = _measureSync(ProcessingStage.perclos, () {
      _perclosTracker.addSample(
        timestamp: timestamp,
        eyesClosed: eyesClosed,
        valid: reliableLandmarks,
      );
      return _perclosTracker.valueAt(timestamp);
    });
    final perclosReady =
        _perclosTracker.isReady && reliableLandmarks && !lowLight;

    final metrics = DrowsinessFrameMetrics(
      timestamp: timestamp,
      faceDetected: true,
      eyesClosed: eyesClosed,
      yawning: yawning,
      perclos: perclos,
      ear: ear,
      mar: mar,
      headX: headX,
      headY: headY,
      eyeClosedDurationSeconds: closedDuration.inMilliseconds / 1000,
      faceMissingDurationSeconds: 0,
      headDownDurationSeconds: headDownDuration.inMilliseconds / 1000,
      signalQuality: signalQuality,
      lowLight: lowLight,
    );
    final prediction = _measureSync(
      ProcessingStage.modelInference,
      () => _predictIfReady(metrics, timestamp),
    );
    final decision = _measureSync(
      ProcessingStage.riskEngine,
      () => _engine.evaluate(
        DrowsinessSignalSnapshot(
          timestamp: timestamp,
          settings: _settingsService.settings,
          modelEnabled: _settingsService.settings.modelEnabled,
          eyesClosed: eyesClosed,
          yawning: yawning,
          perclosReady: perclosReady,
          perclos: perclos,
          yawnCountWindow: _yawnEvents.length,
          closedEyeDuration: closedDuration,
          noFaceDuration: noFaceDuration,
          headDownDuration: headDownDuration,
          distractedDuration: distractedDuration,
          lowLight: lowLight,
          signalQuality: signalQuality,
          prediction: prediction,
        ),
      ),
    );

    return _buildState(
      decision: decision,
      faceDetected: true,
      eyesClosed: eyesClosed,
      prolongedBlink: prolongedBlink,
      yawning: yawning,
      headDown:
          headDownDuration >= DrowsinessThresholds.sustainedHeadDownWarning,
      distracted:
          distractedDuration >=
          DrowsinessThresholds.sustainedDistractionWarning,
      noFaceTooLong: false,
      eyeOpenScore: eyeOpenScore,
      ear: ear,
      mar: mar,
      perclos: perclos,
      perclosReady: perclosReady,
      headX: headX,
      headY: headY,
      closedDuration: closedDuration,
      noFaceDuration: Duration.zero,
      headDownDuration: headDownDuration,
      distractedDuration: distractedDuration,
      imageBrightness: imageBrightness,
      lowLight: lowLight,
      signalQuality: signalQuality,
      fps: fps,
      prediction: prediction,
    );
  }

  Future<void> close() async {
    _modelService.close();
  }

  T _measureSync<T>(ProcessingStage stage, T Function() operation) {
    final performance = _performance;
    return performance == null
        ? operation()
        : performance.measureSync(stage, operation);
  }

  DrowsinessState _analyzeNoFace({
    required DateTime timestamp,
    required double? imageBrightness,
    required bool lowLight,
    required double? fps,
  }) {
    _eyeClosedTracker.reset();
    _headDownTracker.reset();
    _distractedTracker.reset();
    _wasYawning = false;

    final noFaceDuration = _noFaceTracker.update(
      active: true,
      timestamp: timestamp,
    );
    _perclosTracker.addSample(
      timestamp: timestamp,
      eyesClosed: false,
      valid: false,
    );
    final perclos = _perclosTracker.valueAt(timestamp);
    final metrics = DrowsinessFrameMetrics(
      timestamp: timestamp,
      faceDetected: false,
      eyesClosed: false,
      yawning: false,
      perclos: perclos,
      ear: null,
      mar: null,
      headX: null,
      headY: null,
      eyeClosedDurationSeconds: 0,
      faceMissingDurationSeconds: noFaceDuration.inMilliseconds / 1000,
      headDownDurationSeconds: 0,
      signalQuality: 0,
      lowLight: lowLight,
    );
    final prediction = _predictIfReady(metrics, timestamp);
    final decision = _engine.evaluate(
      DrowsinessSignalSnapshot(
        timestamp: timestamp,
        settings: _settingsService.settings,
        modelEnabled: _settingsService.settings.modelEnabled,
        eyesClosed: false,
        yawning: false,
        perclosReady: false,
        perclos: perclos,
        yawnCountWindow: _yawnEvents.length,
        closedEyeDuration: Duration.zero,
        noFaceDuration: noFaceDuration == Duration.zero
            ? const Duration(microseconds: 1)
            : noFaceDuration,
        headDownDuration: Duration.zero,
        distractedDuration: Duration.zero,
        lowLight: lowLight,
        signalQuality: 0,
        prediction: prediction,
      ),
    );

    return _buildState(
      decision: decision,
      faceDetected: false,
      eyesClosed: false,
      prolongedBlink: false,
      yawning: false,
      headDown: false,
      distracted: false,
      noFaceTooLong: noFaceDuration >= DrowsinessThresholds.noFaceDanger,
      eyeOpenScore: null,
      ear: null,
      mar: null,
      perclos: perclos,
      perclosReady: false,
      headX: null,
      headY: null,
      closedDuration: Duration.zero,
      noFaceDuration: noFaceDuration,
      headDownDuration: Duration.zero,
      distractedDuration: Duration.zero,
      imageBrightness: imageBrightness,
      lowLight: lowLight,
      signalQuality: 0,
      fps: fps,
      prediction: prediction,
    );
  }

  DrowsinessState _buildState({
    required RiskDecision decision,
    required bool faceDetected,
    required bool eyesClosed,
    required bool prolongedBlink,
    required bool yawning,
    required bool headDown,
    required bool distracted,
    required bool noFaceTooLong,
    required double? eyeOpenScore,
    required double? ear,
    required double? mar,
    required double perclos,
    required bool perclosReady,
    required double? headX,
    required double? headY,
    required Duration closedDuration,
    required Duration noFaceDuration,
    required Duration headDownDuration,
    required Duration distractedDuration,
    required double? imageBrightness,
    required bool lowLight,
    required double signalQuality,
    required double? fps,
    required MlPrediction? prediction,
  }) {
    return DrowsinessState(
      level: decision.level,
      faceDetected: faceDetected,
      eyesClosed: eyesClosed,
      prolongedBlink: prolongedBlink,
      yawning: yawning,
      headDown: headDown,
      distracted: distracted,
      noFaceTooLong: noFaceTooLong,
      eyeOpenScore: eyeOpenScore,
      ear: ear,
      mar: mar,
      perclos: perclos,
      perclosReady: perclosReady,
      headX: headX,
      headY: headY,
      eyeClosedDurationSeconds: closedDuration.inMilliseconds / 1000,
      noFaceDurationSeconds: noFaceDuration.inMilliseconds / 1000,
      headDownDurationSeconds: headDownDuration.inMilliseconds / 1000,
      distractedDurationSeconds: distractedDuration.inMilliseconds / 1000,
      yawnCountWindow: _yawnEvents.length,
      riskScore: decision.totalRisk,
      ruleRiskScore: decision.ruleRisk,
      modelRiskScore: decision.modelRisk,
      riskReason: decision.reason,
      alertTier: decision.alertTier,
      sustainedDangerDurationSeconds:
          decision.sustainedDangerDuration.inMilliseconds / 1000,
      lowLight: lowLight,
      imageBrightness: imageBrightness,
      signalQuality: signalQuality,
      fps: fps,
      modelAvailable: _modelService.isAvailable,
      modelLabel: prediction?.label,
      modelConfidence: prediction?.confidence,
      modelAwakeProbability: prediction?.awakeProbability,
      modelFatigueProbability: prediction?.fatigueProbability,
      modelDrowsyProbability: prediction?.drowsyProbability,
      calibrationReady: _calibrationService.isReady,
      calibrationStatus: _calibrationService.statusText,
      calibrationInProgress: _calibrationService.isGuidedCalibrationActive,
      calibrationProgress: _calibrationService.guidedProgress,
      calibrationInstruction: _calibrationService.currentInstruction,
      message: decision.message,
    );
  }

  MlPrediction? _predictIfReady(
    DrowsinessFrameMetrics metrics,
    DateTime timestamp,
  ) {
    final features = _featureWindowService.addSample(metrics);
    if (features == null ||
        !_modelService.isAvailable ||
        !_settingsService.settings.modelEnabled) {
      return _lastPrediction;
    }

    if (_lastPredictionAt != null &&
        timestamp.difference(_lastPredictionAt!) <
            DrowsinessThresholds.modelInferenceInterval) {
      return _lastPrediction;
    }

    _lastPredictionAt = timestamp;
    _lastPrediction = _modelService.predict(features) ?? _lastPrediction;
    return _lastPrediction;
  }

  void _resetRuntimeState({required bool keepCalibration}) {
    _featureWindowService.reset();
    _engine.reset();
    _perclosTracker.reset();
    _earSmoother.reset();
    _marSmoother.reset();
    _headXSmoother.reset();
    _headYSmoother.reset();
    _eyeScoreSmoother.reset();
    _eyeClosedTracker.reset();
    _noFaceTracker.reset();
    _headDownTracker.reset();
    _distractedTracker.reset();
    _lastPrediction = null;
    _lastPredictionAt = null;
    _wasYawning = false;
    _yawnEvents.clear();
  }

  bool _isLowLight(double? brightness) {
    return brightness != null &&
        brightness < DrowsinessThresholds.poorBrightness;
  }

  double _signalQuality({
    required double? ear,
    required double? mar,
    required double? eyeOpenScore,
    required double? brightness,
    required double faceSizeRatio,
  }) {
    var quality = 0.22;
    if (ear != null && ear.isFinite) {
      quality += 0.24;
    }
    if (mar != null && mar.isFinite) {
      quality += 0.16;
    }
    if (eyeOpenScore != null && eyeOpenScore.isFinite) {
      quality += 0.18;
    }
    quality += (faceSizeRatio * 2.4).clamp(0, 0.22).toDouble();
    if (brightness != null) {
      if (brightness < DrowsinessThresholds.poorBrightness) {
        quality *= 0.45;
      } else if (brightness < DrowsinessThresholds.weakBrightness) {
        quality *= 0.72;
      }
    }
    return quality.clamp(0, 1).toDouble();
  }

  double _faceSizeRatio(Face face, int? imageWidth, int? imageHeight) {
    final width = imageWidth;
    final height = imageHeight;
    if (width == null || height == null || width <= 0 || height <= 0) {
      return 0.12;
    }
    final area = face.boundingBox.width * face.boundingBox.height;
    return (area / (width * height)).clamp(0, 1).toDouble();
  }

  Face _largestFace(List<Face> faces) {
    return faces.reduce((current, next) {
      final currentArea =
          current.boundingBox.width * current.boundingBox.height;
      final nextArea = next.boundingBox.width * next.boundingBox.height;
      return nextArea > currentArea ? next : current;
    });
  }

  double? _eyeOpenScore(Face face) {
    final left = face.leftEyeOpenProbability;
    final right = face.rightEyeOpenProbability;

    if (left != null && right != null) {
      return (left + right) / 2;
    }

    return left ?? right;
  }

  double? _averageEar(Face face) {
    final leftEar = _aspectRatioForContour(
      face.contours[FaceContourType.leftEye],
    );
    final rightEar = _aspectRatioForContour(
      face.contours[FaceContourType.rightEye],
    );

    if (leftEar != null && rightEar != null) {
      return (leftEar + rightEar) / 2;
    }

    return leftEar ?? rightEar;
  }

  double? _mouthAspectRatio(Face face) {
    final points = <Point<int>>[
      ...?face.contours[FaceContourType.upperLipTop]?.points,
      ...?face.contours[FaceContourType.upperLipBottom]?.points,
      ...?face.contours[FaceContourType.lowerLipTop]?.points,
      ...?face.contours[FaceContourType.lowerLipBottom]?.points,
    ];

    return _aspectRatioForPoints(points);
  }

  double? _aspectRatioForContour(FaceContour? contour) {
    final points = contour?.points;
    if (points == null || points.length < 4) {
      return null;
    }

    return _aspectRatioForPoints(points);
  }

  double? _aspectRatioForPoints(List<Point<int>> points) {
    if (points.length < 4) {
      return null;
    }

    var minX = points.first.x;
    var maxX = points.first.x;
    var minY = points.first.y;
    var maxY = points.first.y;

    for (final point in points.skip(1)) {
      minX = min(minX, point.x);
      maxX = max(maxX, point.x);
      minY = min(minY, point.y);
      maxY = max(maxY, point.y);
    }

    final width = (maxX - minX).abs();
    final height = (maxY - minY).abs();
    if (width == 0) {
      return null;
    }

    return height / width;
  }

  void _registerYawnIfNeeded(DateTime timestamp, bool yawning) {
    if (yawning && !_wasYawning) {
      _yawnEvents.add(timestamp);
    }

    _wasYawning = yawning;
  }

  void _purgeOldYawns(DateTime timestamp) {
    final cutoff = timestamp.subtract(DrowsinessThresholds.yawnWindow);
    _yawnEvents.removeWhere((eventTime) => eventTime.isBefore(cutoff));
  }
}
