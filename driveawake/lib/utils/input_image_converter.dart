import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/services.dart';
import 'package:google_mlkit_commons/google_mlkit_commons.dart';

class InputImageConverter {
  const InputImageConverter._();

  static InputImage? fromCameraImage(
    CameraImage image,
    CameraDescription camera,
    DeviceOrientation deviceOrientation,
  ) {
    try {
      final rotation = _rotationForCamera(camera, deviceOrientation);
      if (rotation == null) {
        return null;
      }

      final conversion = _bytesAndFormat(image);
      if (conversion == null) {
        return null;
      }

      final metadata = InputImageMetadata(
        size: Size(image.width.toDouble(), image.height.toDouble()),
        rotation: rotation,
        format: conversion.format,
        bytesPerRow: image.planes.isNotEmpty
            ? image.planes.first.bytesPerRow
            : 0,
      );

      return InputImage.fromBytes(bytes: conversion.bytes, metadata: metadata);
    } catch (_) {
      return null;
    }
  }

  static _ImageBytes? _bytesAndFormat(CameraImage image) {
    if (Platform.isAndroid) {
      if (image.format.group == ImageFormatGroup.nv21) {
        return _ImageBytes(
          bytes: _concatenatePlanes(image.planes),
          format: InputImageFormat.nv21,
        );
      }

      if (image.format.group == ImageFormatGroup.yuv420 &&
          image.planes.length == 3) {
        return _ImageBytes(
          bytes: _yuv420ToNv21(image),
          format: InputImageFormat.nv21,
        );
      }
    }

    if (Platform.isIOS && image.format.group == ImageFormatGroup.bgra8888) {
      if (image.planes.length != 1) {
        return null;
      }

      return _ImageBytes(
        bytes: image.planes.first.bytes,
        format: InputImageFormat.bgra8888,
      );
    }

    return null;
  }

  static Uint8List _concatenatePlanes(List<Plane> planes) {
    final allBytes = WriteBuffer();
    for (final plane in planes) {
      allBytes.putUint8List(plane.bytes);
    }
    return allBytes.done().buffer.asUint8List();
  }

  static Uint8List _yuv420ToNv21(CameraImage image) {
    final width = image.width;
    final height = image.height;
    final yPlane = image.planes[0];
    final uPlane = image.planes[1];
    final vPlane = image.planes[2];
    final ySize = width * height;
    final nv21 = Uint8List(ySize + (width * height ~/ 2));

    var outputIndex = 0;
    for (var row = 0; row < height; row++) {
      final rowStart = row * yPlane.bytesPerRow;
      final rowEnd = rowStart + width;
      nv21.setRange(outputIndex, outputIndex + width, yPlane.bytes, rowStart);
      outputIndex += rowEnd - rowStart;
    }

    final chromaHeight = height ~/ 2;
    final chromaWidth = width ~/ 2;
    final uPixelStride = uPlane.bytesPerPixel ?? 1;
    final vPixelStride = vPlane.bytesPerPixel ?? 1;

    for (var row = 0; row < chromaHeight; row++) {
      for (var col = 0; col < chromaWidth; col++) {
        final uvIndex = ySize + row * width + col * 2;
        final uIndex = row * uPlane.bytesPerRow + col * uPixelStride;
        final vIndex = row * vPlane.bytesPerRow + col * vPixelStride;

        if (uvIndex + 1 < nv21.length &&
            uIndex < uPlane.bytes.length &&
            vIndex < vPlane.bytes.length) {
          nv21[uvIndex] = vPlane.bytes[vIndex];
          nv21[uvIndex + 1] = uPlane.bytes[uIndex];
        }
      }
    }

    return nv21;
  }

  static InputImageRotation? _rotationForCamera(
    CameraDescription camera,
    DeviceOrientation deviceOrientation,
  ) {
    if (Platform.isIOS) {
      return InputImageRotationValue.fromRawValue(camera.sensorOrientation);
    }

    if (!Platform.isAndroid) {
      return null;
    }

    final orientationDegrees = <DeviceOrientation, int>{
      DeviceOrientation.portraitUp: 0,
      DeviceOrientation.landscapeLeft: 90,
      DeviceOrientation.portraitDown: 180,
      DeviceOrientation.landscapeRight: 270,
    };

    final deviceDegrees = orientationDegrees[deviceOrientation];
    if (deviceDegrees == null) {
      return null;
    }

    final rotationCompensation =
        camera.lensDirection == CameraLensDirection.front
        ? (camera.sensorOrientation + deviceDegrees) % 360
        : (camera.sensorOrientation - deviceDegrees + 360) % 360;

    return InputImageRotationValue.fromRawValue(rotationCompensation);
  }
}

class _ImageBytes {
  const _ImageBytes({required this.bytes, required this.format});

  final Uint8List bytes;
  final InputImageFormat format;
}
