import 'dart:io';
import 'dart:math' as math;

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';

class FaceLandmarkOverlayData {
  const FaceLandmarkOverlayData({
    required this.faces,
    required this.imageSize,
    required this.rotation,
    required this.lensDirection,
  });

  final List<Face> faces;
  final Size imageSize;
  final InputImageRotation rotation;
  final CameraLensDirection lensDirection;

  bool get hasFaces => faces.isNotEmpty;
}

class FaceLandmarkOverlayPainter extends CustomPainter {
  const FaceLandmarkOverlayPainter({
    required this.data,
    required this.color,
    this.drawScanFrame = true,
  });

  final FaceLandmarkOverlayData? data;
  final Color color;
  final bool drawScanFrame;

  @override
  void paint(Canvas canvas, Size size) {
    if (drawScanFrame) {
      _drawScanFrame(canvas, size);
    }

    final overlayData = data;
    if (overlayData == null || overlayData.faces.isEmpty) {
      return;
    }

    for (final face in overlayData.faces.take(1)) {
      _drawContours(canvas, size, overlayData, face);
    }
  }

  void _drawScanFrame(Canvas canvas, Size size) {
    final framePaint = Paint()
      ..color = color.withValues(alpha: 0.72)
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 1.8;
    const pad = 24.0;
    final len = math.min(size.width, size.height) * 0.12;

    canvas.drawLine(const Offset(pad, pad), Offset(pad + len, pad), framePaint);
    canvas.drawLine(const Offset(pad, pad), Offset(pad, pad + len), framePaint);
    canvas.drawLine(
      Offset(size.width - pad, pad),
      Offset(size.width - pad - len, pad),
      framePaint,
    );
    canvas.drawLine(
      Offset(size.width - pad, pad),
      Offset(size.width - pad, pad + len),
      framePaint,
    );
    canvas.drawLine(
      Offset(pad, size.height - pad),
      Offset(pad + len, size.height - pad),
      framePaint,
    );
    canvas.drawLine(
      Offset(pad, size.height - pad),
      Offset(pad, size.height - pad - len),
      framePaint,
    );
    canvas.drawLine(
      Offset(size.width - pad, size.height - pad),
      Offset(size.width - pad - len, size.height - pad),
      framePaint,
    );
    canvas.drawLine(
      Offset(size.width - pad, size.height - pad),
      Offset(size.width - pad, size.height - pad - len),
      framePaint,
    );
  }

  void _drawContours(
    Canvas canvas,
    Size canvasSize,
    FaceLandmarkOverlayData data,
    Face face,
  ) {
    final linePaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.86)
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..strokeWidth = 1.05;
    final glowPaint = Paint()
      ..color = color.withValues(alpha: 0.12)
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..strokeWidth = 3;
    final nodePaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.9)
      ..style = PaintingStyle.fill;
    final nodeGlowPaint = Paint()
      ..color = color.withValues(alpha: 0.18)
      ..style = PaintingStyle.fill;

    final contourTypes = <FaceContourType>[
      FaceContourType.face,
      FaceContourType.leftEyebrowTop,
      FaceContourType.leftEyebrowBottom,
      FaceContourType.rightEyebrowTop,
      FaceContourType.rightEyebrowBottom,
      FaceContourType.leftEye,
      FaceContourType.rightEye,
      FaceContourType.noseBridge,
      FaceContourType.noseBottom,
      FaceContourType.upperLipTop,
      FaceContourType.upperLipBottom,
      FaceContourType.lowerLipTop,
      FaceContourType.lowerLipBottom,
      FaceContourType.leftCheek,
      FaceContourType.rightCheek,
    ];

    final contourOffsets = <FaceContourType, List<Offset>>{};
    for (final type in contourTypes) {
      final offsets = _contourOffsets(face, type, canvasSize, data);
      if (offsets.length < 2) {
        continue;
      }
      contourOffsets[type] = offsets;
      _drawPath(canvas, offsets, glowPaint, _closedContour(type));
      _drawPath(canvas, offsets, linePaint, _closedContour(type));
    }

    _drawMeshLinks(canvas, contourOffsets, linePaint, glowPaint);

    for (final offsets in contourOffsets.values) {
      final step = offsets.length > 18 ? 2 : 1;
      for (var i = 0; i < offsets.length; i += step) {
        canvas.drawCircle(offsets[i], 2.8, nodeGlowPaint);
        canvas.drawCircle(offsets[i], 1.55, nodePaint);
      }
    }
  }

  void _drawPath(Canvas canvas, List<Offset> points, Paint paint, bool close) {
    if (points.length < 2) {
      return;
    }
    final path = Path()..moveTo(points.first.dx, points.first.dy);
    for (final point in points.skip(1)) {
      path.lineTo(point.dx, point.dy);
    }
    if (close) {
      path.close();
    }
    canvas.drawPath(path, paint);
  }

  void _drawMeshLinks(
    Canvas canvas,
    Map<FaceContourType, List<Offset>> contours,
    Paint linePaint,
    Paint glowPaint,
  ) {
    final face = contours[FaceContourType.face];
    final leftEye = contours[FaceContourType.leftEye];
    final rightEye = contours[FaceContourType.rightEye];
    final noseBridge = contours[FaceContourType.noseBridge];
    final noseBottom = contours[FaceContourType.noseBottom];
    final upperLip = contours[FaceContourType.upperLipTop];
    final lowerLip = contours[FaceContourType.lowerLipBottom];
    final leftBrow = contours[FaceContourType.leftEyebrowTop];
    final rightBrow = contours[FaceContourType.rightEyebrowTop];

    void link(Offset? a, Offset? b) {
      if (a == null || b == null) {
        return;
      }
      canvas.drawLine(a, b, glowPaint);
      canvas.drawLine(a, b, linePaint);
    }

    link(_at(face, 4), _middle(leftBrow));
    link(_at(face, 14), _middle(rightBrow));
    link(_at(face, 8), _middle(leftEye));
    link(_at(face, 28), _middle(rightEye));
    link(_middle(leftEye), _first(noseBridge));
    link(_middle(rightEye), _first(noseBridge));
    link(_last(noseBridge), _middle(noseBottom));
    link(_middle(noseBottom), _middle(upperLip));
    link(_middle(upperLip), _middle(lowerLip));
    link(_at(face, 8), _middle(upperLip));
    link(_at(face, 28), _middle(upperLip));
    link(_at(face, 18), _middle(lowerLip));
    link(_at(face, 0), _at(face, 18));
    link(_at(face, 35), _at(face, 18));
  }

  List<Offset> _contourOffsets(
    Face face,
    FaceContourType type,
    Size canvasSize,
    FaceLandmarkOverlayData data,
  ) {
    final points = face.contours[type]?.points;
    if (points == null || points.isEmpty) {
      return const <Offset>[];
    }
    return points
        .map((point) => _translatePoint(point, canvasSize, data))
        .toList(growable: false);
  }

  Offset _translatePoint(
    math.Point<int> point,
    Size canvasSize,
    FaceLandmarkOverlayData data,
  ) {
    final x = point.x.toDouble();
    final y = point.y.toDouble();
    final imageSize = data.imageSize;
    final lens = data.lensDirection;
    final rotation = data.rotation;

    final translatedX = switch (rotation) {
      InputImageRotation.rotation90deg =>
        lens == CameraLensDirection.front
            ? canvasSize.width -
                  x *
                      canvasSize.width /
                      (Platform.isIOS ? imageSize.width : imageSize.height)
            : x *
                  canvasSize.width /
                  (Platform.isIOS ? imageSize.width : imageSize.height),
      InputImageRotation.rotation270deg =>
        lens == CameraLensDirection.front
            ? x *
                  canvasSize.width /
                  (Platform.isIOS ? imageSize.width : imageSize.height)
            : canvasSize.width -
                  x *
                      canvasSize.width /
                      (Platform.isIOS ? imageSize.width : imageSize.height),
      InputImageRotation.rotation0deg || InputImageRotation.rotation180deg =>
        lens == CameraLensDirection.front
            ? canvasSize.width - x * canvasSize.width / imageSize.width
            : x * canvasSize.width / imageSize.width,
    };

    final translatedY = switch (rotation) {
      InputImageRotation.rotation90deg || InputImageRotation.rotation270deg =>
        y *
            canvasSize.height /
            (Platform.isIOS ? imageSize.height : imageSize.width),
      InputImageRotation.rotation0deg || InputImageRotation.rotation180deg =>
        y * canvasSize.height / imageSize.height,
    };

    return Offset(translatedX, translatedY);
  }

  bool _closedContour(FaceContourType type) {
    return switch (type) {
      FaceContourType.face ||
      FaceContourType.leftEye ||
      FaceContourType.rightEye ||
      FaceContourType.upperLipTop ||
      FaceContourType.upperLipBottom ||
      FaceContourType.lowerLipTop ||
      FaceContourType.lowerLipBottom ||
      FaceContourType.noseBottom => true,
      _ => false,
    };
  }

  Offset? _first(List<Offset>? points) {
    if (points == null || points.isEmpty) {
      return null;
    }
    return points.first;
  }

  Offset? _last(List<Offset>? points) {
    if (points == null || points.isEmpty) {
      return null;
    }
    return points.last;
  }

  Offset? _middle(List<Offset>? points) {
    if (points == null || points.isEmpty) {
      return null;
    }
    return points[points.length ~/ 2];
  }

  Offset? _at(List<Offset>? points, int index) {
    if (points == null || points.isEmpty) {
      return null;
    }
    return points[index.clamp(0, points.length - 1)];
  }

  @override
  bool shouldRepaint(covariant FaceLandmarkOverlayPainter oldDelegate) {
    return oldDelegate.data != data ||
        oldDelegate.color != color ||
        oldDelegate.drawScanFrame != drawScanFrame;
  }
}
