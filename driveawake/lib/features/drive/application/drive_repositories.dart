import 'package:camera/camera.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';

import '../../../models/device_telemetry_snapshot.dart';
import '../../../models/drowsiness_state.dart';
import '../../../models/trip_session_draft.dart';
import '../../../models/trip_session_summary.dart';

abstract interface class CameraRepository {
  CameraController? get controller;
  CameraDescription? get camera;
  bool get isInitialized;
  Future<void> initialize();
  Future<void> startStream(void Function(CameraImage image) onImage);
  Future<void> stopAndDispose();
}

abstract interface class FaceDetectionRepository {
  Future<List<Face>> detect(InputImage image);
  Future<void> close();
}

abstract interface class DrowsinessAnalyzer {
  Future<void> initialize();
  Future<DrowsinessState> analyze({
    required List<Face> faces,
    required DateTime timestamp,
    required double? imageBrightness,
    required int imageWidth,
    required int imageHeight,
    required double fps,
  });
  Future<void> startCalibration();
  void resetTemporalState();
  Future<void> close();
}

abstract interface class RiskEngine {
  DrowsinessState get latestState;
}

abstract interface class AlarmController {
  Future<void> handle(DrowsinessState state);
  Future<void> stop();
  Future<void> close();
}

abstract interface class TripRepository {
  void start();
  void restore(TripSessionDraft draft);
  void pause();
  void resume();
  Future<void> observe(DrowsinessState state, DateTime timestamp);
  void recordTelemetry(DeviceTelemetrySnapshot snapshot);
  Future<TripSessionSummary> finish();
  Future<void> discard();
}

abstract interface class SessionDraftRepository {
  Future<TripSessionDraft?> load();
}

abstract interface class TelemetryRepository {
  Future<DeviceTelemetrySnapshot?> read();
  Future<void> keepScreenAwake(bool enabled);
}
