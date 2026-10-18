import 'dart:io';

import 'package:camera/camera.dart';
import 'package:permission_handler/permission_handler.dart';

class CameraService {
  CameraService({this.requestPermissions = true});
  final bool requestPermissions;
  CameraController? _controller;
  CameraDescription? _camera;
  String? _lastError;

  CameraController? get controller => _controller;
  CameraDescription? get camera => _camera;
  String? get lastError => _lastError;
  bool get isInitialized => _controller?.value.isInitialized ?? false;

  Future<void> initializeFrontCamera({
    ResolutionPreset resolutionPreset = ResolutionPreset.medium,
  }) async {
    _lastError = null;

    // A previous failed CameraController can remain allocated even when it was
    // never fully initialized. Release it before every fresh attempt so Retry
    // is a real retry and does not reuse a broken Android camera session.
    await dispose();

    final status = requestPermissions
        ? await Permission.camera.request()
        : await Permission.camera.status;
    if (!status.isGranted) {
      _lastError = status.isPermanentlyDenied
          ? 'Permiso de camara denegado permanentemente.'
          : 'Permiso de camara denegado.';
      throw CameraException('cameraPermission', _lastError);
    }

    final cameras = await availableCameras();
    if (cameras.isEmpty) {
      _lastError = 'No se encontraron camaras disponibles.';
      throw CameraException('noCamera', _lastError);
    }

    final frontCameras = cameras.where(
      (camera) => camera.lensDirection == CameraLensDirection.front,
    );
    if (frontCameras.isEmpty) {
      _lastError =
          'No hay cámara frontal disponible para monitorear al conductor.';
      throw CameraException('noFrontCamera', _lastError);
    }
    final selectedCamera = frontCameras.first;

    final imageFormatGroup = Platform.isAndroid
        ? ImageFormatGroup.yuv420
        : Platform.isIOS
        ? ImageFormatGroup.bgra8888
        : ImageFormatGroup.unknown;

    final controller = CameraController(
      selectedCamera,
      resolutionPreset,
      enableAudio: false,
      imageFormatGroup: imageFormatGroup,
    );

    try {
      await controller.initialize();
      try {
        // Some front-camera implementations report no flash mode at all.
        // Failing to force it off must not invalidate an otherwise usable
        // camera session.
        await controller.setFlashMode(FlashMode.off);
      } on CameraException {
        // The app never requests flash, so continuing is safe.
      }
      _camera = selectedCamera;
      _controller = controller;
    } catch (error) {
      _lastError = error.toString();
      await controller.dispose();
      rethrow;
    }
  }

  Future<void> startImageStream(
    void Function(CameraImage image) onImage,
  ) async {
    final controller = _controller;
    if (controller == null || !controller.value.isInitialized) {
      throw CameraException(
        'notInitialized',
        'La camara no esta inicializada.',
      );
    }

    if (controller.value.isStreamingImages) {
      return;
    }

    await controller.startImageStream(onImage);
  }

  Future<void> stopImageStream() async {
    final controller = _controller;
    if (controller == null || !controller.value.isInitialized) {
      return;
    }

    if (controller.value.isStreamingImages) {
      await controller.stopImageStream();
    }
  }

  Future<void> dispose() async {
    final controller = _controller;
    _controller = null;
    _camera = null;

    if (controller == null) {
      return;
    }

    try {
      if (controller.value.isInitialized &&
          controller.value.isStreamingImages) {
        await controller.stopImageStream();
      }
    } finally {
      await controller.dispose();
    }
  }
}
