import 'dart:convert';
import 'dart:math';

import 'package:shared_preferences/shared_preferences.dart';

class PersonalCalibrationService {
  static const String _storageKey = 'magicdrive_personal_calibration_v1';
  static const int _minimumSamples = 45;
  static const Duration _minimumDuration = Duration(seconds: 10);

  final List<_CalibrationSample> _samples = <_CalibrationSample>[];
  DateTime? _startedAt;
  bool _ready = false;
  double? _earOpenBaseline;
  double? _headXBaseline;
  double? _headYBaseline;

  bool get isReady => _ready;
  double? get earOpenBaseline => _earOpenBaseline;
  double? get headXBaseline => _headXBaseline;
  double? get headYBaseline => _headYBaseline;

  double get calibratedEarClosedThreshold {
    final baseline = _earOpenBaseline;
    if (baseline == null) {
      return 0.16;
    }
    return (baseline * 0.70).clamp(0.10, 0.20).toDouble();
  }

  double get calibratedHeadDownAngle {
    final baseline = _headXBaseline;
    if (baseline == null) {
      return 18;
    }
    return max(18, baseline.abs() + 16).toDouble();
  }

  double get calibratedDistractionAngle {
    final baseline = _headYBaseline;
    if (baseline == null) {
      return 25;
    }
    return max(25, baseline.abs() + 22).toDouble();
  }

  String get statusText {
    if (_ready) {
      return 'Calibracion activa';
    }

    if (_samples.isEmpty) {
      return 'Calibrando rostro frontal';
    }

    final progress = (_samples.length / _minimumSamples).clamp(0, 1);
    return 'Calibrando ${(progress * 100).round()}%';
  }

  Future<void> initialize() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_storageKey);
    if (raw == null) {
      return;
    }

    try {
      final data = jsonDecode(raw) as Map<String, dynamic>;
      _earOpenBaseline = (data['earOpenBaseline'] as num?)?.toDouble();
      _headXBaseline = (data['headXBaseline'] as num?)?.toDouble();
      _headYBaseline = (data['headYBaseline'] as num?)?.toDouble();
      _ready = _earOpenBaseline != null;
    } catch (_) {
      await prefs.remove(_storageKey);
    }
  }

  Future<void> observe({
    required DateTime timestamp,
    required bool faceDetected,
    required bool eyesClosed,
    required double? ear,
    required double? eyeOpenScore,
    required double? headX,
    required double? headY,
  }) async {
    if (_ready || !faceDetected || eyesClosed || ear == null || !ear.isFinite) {
      return;
    }

    if (eyeOpenScore != null && eyeOpenScore < 0.60) {
      return;
    }

    _startedAt ??= timestamp;
    _samples.add(
      _CalibrationSample(ear: ear, headX: headX ?? 0, headY: headY ?? 0),
    );

    final enoughSamples = _samples.length >= _minimumSamples;
    final enoughTime = timestamp.difference(_startedAt!) >= _minimumDuration;
    if (!enoughSamples || !enoughTime) {
      return;
    }

    _earOpenBaseline = _median(_samples.map((sample) => sample.ear).toList());
    _headXBaseline = _median(_samples.map((sample) => sample.headX).toList());
    _headYBaseline = _median(_samples.map((sample) => sample.headY).toList());
    _ready = true;
    await _save();
  }

  Future<void> reset() async {
    _samples.clear();
    _startedAt = null;
    _ready = false;
    _earOpenBaseline = null;
    _headXBaseline = null;
    _headYBaseline = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_storageKey);
  }

  Future<void> _save() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _storageKey,
      jsonEncode(<String, double?>{
        'earOpenBaseline': _earOpenBaseline,
        'headXBaseline': _headXBaseline,
        'headYBaseline': _headYBaseline,
      }),
    );
  }

  double _median(List<double> values) {
    final filtered =
        values.where((value) => value.isFinite && !value.isNaN).toList()
          ..sort();
    if (filtered.isEmpty) {
      return 0;
    }
    final middle = filtered.length ~/ 2;
    if (filtered.length.isOdd) {
      return filtered[middle];
    }
    return (filtered[middle - 1] + filtered[middle]) / 2;
  }
}

class _CalibrationSample {
  const _CalibrationSample({
    required this.ear,
    required this.headX,
    required this.headY,
  });

  final double ear;
  final double headX;
  final double headY;
}
