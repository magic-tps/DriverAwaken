import 'package:permission_handler/permission_handler.dart';

class TripPermissionService {
  Future<bool> camera() async => (await Permission.camera.request()).isGranted;
  Future<bool> microphone() async =>
      (await Permission.microphone.request()).isGranted;
}
