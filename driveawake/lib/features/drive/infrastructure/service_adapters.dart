import 'package:camera/camera.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';

import '../../../models/device_telemetry_snapshot.dart';
import '../../../models/drowsiness_state.dart';
import '../../../models/trip_session_draft.dart';
import '../../../models/trip_session_summary.dart';
import '../../../services/alert_service.dart';
import '../../../services/camera_service.dart';
import '../../../services/device_telemetry_service.dart';
import '../../../services/drowsiness_service.dart';
import '../../../services/face_detection_service.dart';
import '../../../services/trip_session_draft_service.dart';
import '../../../services/trip_session_service.dart';
import '../application/drive_repositories.dart';
import '../application/performance_monitor.dart';

class CameraServiceAdapter implements CameraRepository {
  CameraServiceAdapter([CameraService? service])
    : _service = service ?? CameraService(requestPermissions: false);
  final CameraService _service;

  @override
  CameraDescription? get camera => _service.camera;
  @override
  CameraController? get controller => _service.controller;
  @override
  bool get isInitialized => _service.isInitialized;
  @override
  Future<void> initialize() => _service.initializeFrontCamera();
  @override
  Future<void> startStream(void Function(CameraImage image) onImage) =>
      _service.startImageStream(onImage);
  @override
  Future<void> stopAndDispose() => _service.dispose();
}

class FaceDetectionServiceAdapter implements FaceDetectionRepository {
  FaceDetectionServiceAdapter([FaceDetectionService? service])
    : _service = service ?? FaceDetectionService();
  final FaceDetectionService _service;
  @override
  Future<void> close() => _service.close();
  @override
  Future<List<Face>> detect(InputImage image) => _service.detectFaces(image);
}

class DrowsinessServiceAdapter implements DrowsinessAnalyzer, RiskEngine {
  DrowsinessServiceAdapter({
    DrowsinessService? service,
    PerformanceMonitor? performanceMonitor,
  }) : _service =
           service ?? DrowsinessService(performanceMonitor: performanceMonitor);
  final DrowsinessService _service;
  DrowsinessState _latestState = DrowsinessState.initial();
  @override
  DrowsinessState get latestState => _latestState;
  @override
  Future<void> initialize() => _service.initialize();
  @override
  Future<DrowsinessState> analyze({
    required List<Face> faces,
    required DateTime timestamp,
    required double? imageBrightness,
    required int imageWidth,
    required int imageHeight,
    required double fps,
  }) async {
    _latestState = await _service.analyze(
      faces: faces,
      timestamp: timestamp,
      imageBrightness: imageBrightness,
      imageWidth: imageWidth,
      imageHeight: imageHeight,
      fps: fps,
    );
    return _latestState;
  }

  @override
  Future<void> startCalibration() => _service.startGuidedCalibration();
  @override
  void resetTemporalState() => _service.resetTemporalState();
  @override
  Future<void> close() => _service.close();
}

class AlertServiceAdapter implements AlarmController {
  AlertServiceAdapter([AlertService? service])
    : _service = service ?? AlertService();
  final AlertService _service;
  @override
  Future<void> close() => _service.dispose();
  @override
  Future<void> handle(DrowsinessState state) => _service.handleState(state);
  @override
  Future<void> stop() => _service.stopAllAlerts();
}

class TripSessionServiceAdapter implements TripRepository {
  TripSessionServiceAdapter([TripSessionService? service])
    : _service = service ?? TripSessionService();
  final TripSessionService _service;
  @override
  Future<void> discard() => _service.discard();
  @override
  Future<TripSessionSummary> finish() => _service.finish();
  @override
  Future<void> observe(DrowsinessState state, DateTime timestamp) =>
      _service.observe(state, timestamp);
  @override
  void pause() => _service.pause();
  @override
  void recordTelemetry(DeviceTelemetrySnapshot snapshot) =>
      _service.recordDeviceTelemetry(snapshot);
  @override
  void restore(TripSessionDraft draft) => _service.restore(draft);
  @override
  void resume() => _service.resume();
  @override
  void start() => _service.start();
}

class TripDraftServiceAdapter implements SessionDraftRepository {
  const TripDraftServiceAdapter();
  @override
  Future<TripSessionDraft?> load() => TripSessionDraftService.instance.load();
}

class DeviceTelemetryServiceAdapter implements TelemetryRepository {
  DeviceTelemetryServiceAdapter([DeviceTelemetryService? service])
    : _service = service ?? DeviceTelemetryService();
  final DeviceTelemetryService _service;
  @override
  Future<void> keepScreenAwake(bool enabled) =>
      _service.setKeepScreenAwake(enabled);
  @override
  Future<DeviceTelemetrySnapshot?> read() =>
      _service.getBatteryThermalSnapshot();
}
