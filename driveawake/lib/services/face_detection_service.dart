import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';

class FaceDetectionService {
  FaceDetectionService()
    : _detector = FaceDetector(
        options: FaceDetectorOptions(
          enableContours: true,
          enableClassification: true,
          enableLandmarks: true,
          enableTracking: true,
          performanceMode: FaceDetectorMode.fast,
        ),
      );

  final FaceDetector _detector;

  Future<List<Face>> detectFaces(InputImage inputImage) {
    return _detector.processImage(inputImage);
  }

  Future<void> close() {
    return _detector.close();
  }
}
