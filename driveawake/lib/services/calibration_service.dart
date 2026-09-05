import 'dart:convert';
import 'dart:math';

import 'package:drift/drift.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../data/database/database_provider.dart';
import '../data/database/driver_awake_database.dart';

class CalibrationService {
  static const String _storageKey = 'magicdrive_personal_calibration_v2';
  static const int _minimumAutoSamples = 45;
  static const Duration _minimumAutoDuration = Duration(seconds: 10);
  static const Duration _guidedDuration = Duration(seconds: 26);

  final List<CalibrationObservation> _autoSamples = <CalibrationObservation>[];
  final List<CalibrationObservation> _guidedSamples =
      <CalibrationObservation>[];

  DateTime? _autoStartedAt;
  DateTime? _guidedStartedAt;
  bool _ready = false;

  double? _earOpenBaseline;
  double? _earClosedBaseline;
  double? _marNormalBaseline;
  double? _marYawnBaseline;
  double? _headXBaseline;
  double? _headYBaseline;
  double? _faceSizeBaseline;

  bool get isReady => _ready;
  bool get isGuidedCalibrationActive => _guidedStartedAt != null;
  double? get earOpenBaseline => _earOpenBaseline;
  double? get earClosedBaseline => _earClosedBaseline;
  double? get marNormalBaseline => _marNormalBaseline;
  double? get marYawnBaseline => _marYawnBaseline;
  double? get headXBaseline => _headXBaseline;
  double? get headYBaseline => _headYBaseline;
  double? get faceSizeBaseline => _faceSizeBaseline;

  double get guidedProgress {
    final startedAt = _guidedStartedAt;
    if (startedAt == null) {
      return 0;
    }
    final elapsedMs = DateTime.now().difference(startedAt).inMilliseconds;
    return (elapsedMs / _guidedDuration.inMilliseconds).clamp(0, 1).toDouble();
  }

  String get currentInstruction {
    final startedAt = _guidedStartedAt;
    if (startedAt == null) {
      return _ready ? 'Calibracion activa' : 'Mira al frente';
    }

    final elapsed = DateTime.now().difference(startedAt);
    if (elapsed < const Duration(seconds: 5)) {
      return 'Mira al frente';
    }
    if (elapsed < const Duration(seconds: 10)) {
      return 'Manten los ojos abiertos';
    }
    if (elapsed < const Duration(seconds: 14)) {
      return 'Parpadea normalmente';
    }
    if (elapsed < const Duration(seconds: 18)) {
      return 'Cierra los ojos por 1 segundo';
    }
    if (elapsed < const Duration(seconds: 22)) {
      return 'Abre la boca una vez';
    }
    return 'Mueve ligeramente la cabeza';
  }

  String get statusText {
    if (_guidedStartedAt != null) {
      return 'Calibrando ${(guidedProgress * 100).round()}%';
    }
    if (_ready) {
      return 'Calibracion activa';
    }
    if (_autoSamples.isEmpty) {
      return 'Calibrando rostro frontal';
    }
    final progress = (_autoSamples.length / _minimumAutoSamples).clamp(0, 1);
    return 'Calibrando ${(progress * 100).round()}%';
  }

  double get calibratedEarClosedThreshold {
    if (_earClosedBaseline != null && _earOpenBaseline != null) {
      final midpoint = (_earClosedBaseline! + _earOpenBaseline!) / 2;
      return midpoint.clamp(0.10, 0.21).toDouble();
    }
    final baseline = _earOpenBaseline;
    if (baseline == null) {
      return 0.16;
    }
    return (baseline * 0.70).clamp(0.10, 0.20).toDouble();
  }

  double get calibratedYawnThreshold {
    if (_marYawnBaseline != null && _marNormalBaseline != null) {
      final threshold =
          _marNormalBaseline! +
          ((_marYawnBaseline! - _marNormalBaseline!) * 0.55);
      return threshold.clamp(0.45, 0.72).toDouble();
    }
    final normal = _marNormalBaseline;
    if (normal == null) {
      return 0.55;
    }
    return max(0.55, normal * 1.65).toDouble();
  }

  double get calibratedHeadDownAngle {
    final baseline = _headXBaseline;
    if (baseline == null) {
      return 22;
    }
    return max(22, baseline.abs() + 18).toDouble();
  }

  double get calibratedDistractionAngle {
    final baseline = _headYBaseline;
    if (baseline == null) {
      return 28;
    }
    return max(28, baseline.abs() + 24).toDouble();
  }

  Future<void> initialize() async {
    String? raw;
    try {
      final database = DatabaseProvider.database;
      final row = await (database.select(
        database.calibrations,
      )..where((table) => table.id.equals(_storageKey))).getSingleOrNull();
      raw = row?.payloadJson;
    } catch (_) {
      // Retained legacy fallback below.
    }
    final prefs = await SharedPreferences.getInstance();
    raw ??= prefs.getString(_storageKey);
    if (raw == null) {
      return;
    }

    try {
      final data = jsonDecode(raw) as Map<String, dynamic>;
      _earOpenBaseline = (data['earOpenBaseline'] as num?)?.toDouble();
      _earClosedBaseline = (data['earClosedBaseline'] as num?)?.toDouble();
      _marNormalBaseline = (data['marNormalBaseline'] as num?)?.toDouble();
      _marYawnBaseline = (data['marYawnBaseline'] as num?)?.toDouble();
      _headXBaseline = (data['headXBaseline'] as num?)?.toDouble();
      _headYBaseline = (data['headYBaseline'] as num?)?.toDouble();
      _faceSizeBaseline = (data['faceSizeBaseline'] as num?)?.toDouble();
      _ready = _earOpenBaseline != null;
    } catch (_) {}
  }

  void startGuidedCalibration() {
    _guidedSamples.clear();
    _guidedStartedAt = DateTime.now();
    _ready = false;
  }

  Future<void> cancelGuidedCalibration() async {
    _guidedSamples.clear();
    _guidedStartedAt = null;
    await initialize();
  }

  Future<void> observe(CalibrationObservation observation) async {
    if (!observation.faceDetected || !_valid(observation.ear)) {
      return;
    }

    final guidedStartedAt = _guidedStartedAt;
    if (guidedStartedAt != null) {
      _guidedSamples.add(observation);
      if (observation.timestamp.difference(guidedStartedAt) >=
          _guidedDuration) {
        await _completeGuided(guidedStartedAt);
      }
      return;
    }

    if (_ready || observation.eyesClosed) {
      return;
    }
    if (observation.eyeOpenScore != null && observation.eyeOpenScore! < 0.60) {
      return;
    }

    _autoStartedAt ??= observation.timestamp;
    _autoSamples.add(observation);
    final enoughSamples = _autoSamples.length >= _minimumAutoSamples;
    final enoughTime =
        observation.timestamp.difference(_autoStartedAt!) >=
        _minimumAutoDuration;
    if (!enoughSamples || !enoughTime) {
      return;
    }

    _earOpenBaseline = _median(
      _autoSamples.map((sample) => sample.ear).whereType<double>().toList(),
    );
    _marNormalBaseline = _median(
      _autoSamples.map((sample) => sample.mar).whereType<double>().toList(),
    );
    _headXBaseline = _median(
      _autoSamples.map((sample) => sample.headX).toList(),
    );
    _headYBaseline = _median(
      _autoSamples.map((sample) => sample.headY).toList(),
    );
    _faceSizeBaseline = _median(
      _autoSamples.map((sample) => sample.faceSizeRatio).toList(),
    );
    _ready = true;
    await _save();
  }

  Future<void> reset() async {
    _autoSamples.clear();
    _guidedSamples.clear();
    _autoStartedAt = null;
    _guidedStartedAt = null;
    _ready = false;
    _earOpenBaseline = null;
    _earClosedBaseline = null;
    _marNormalBaseline = null;
    _marYawnBaseline = null;
    _headXBaseline = null;
    _headYBaseline = null;
    _faceSizeBaseline = null;
    try {
      final database = DatabaseProvider.database;
      await (database.delete(
        database.calibrations,
      )..where((table) => table.id.equals(_storageKey))).go();
    } catch (_) {}
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_storageKey);
  }

  Future<void> _completeGuided(DateTime startedAt) async {
    final openSamples = _guidedSamples.where((sample) {
      final elapsed = sample.timestamp.difference(startedAt);
      return elapsed < const Duration(seconds: 12) &&
          !sample.eyesClosed &&
          sample.ear != null;
    }).toList();
    final closedSamples = _guidedSamples.where((sample) {
      final elapsed = sample.timestamp.difference(startedAt);
      return elapsed >= const Duration(seconds: 14) &&
          elapsed < const Duration(seconds: 18) &&
          sample.ear != null;
    }).toList();
    final mouthSamples = _guidedSamples.where((sample) {
      final elapsed = sample.timestamp.difference(startedAt);
      return elapsed < const Duration(seconds: 14) && sample.mar != null;
    }).toList();
    final yawnSamples = _guidedSamples.where((sample) {
      final elapsed = sample.timestamp.difference(startedAt);
      return elapsed >= const Duration(seconds: 18) &&
          elapsed < const Duration(seconds: 23) &&
          sample.mar != null;
    }).toList();

    _earOpenBaseline = _median(
      openSamples.map((sample) => sample.ear).whereType<double>().toList(),
    );
    final closedEar = _min(
      closedSamples.map((sample) => sample.ear).whereType<double>().toList(),
    );
    _earClosedBaseline = closedEar == 0
        ? (_earOpenBaseline == null ? null : _earOpenBaseline! * 0.45)
        : closedEar;
    _marNormalBaseline = _median(
      mouthSamples.map((sample) => sample.mar).whereType<double>().toList(),
    );
    final yawnMar = _max(
      yawnSamples.map((sample) => sample.mar).whereType<double>().toList(),
    );
    _marYawnBaseline = yawnMar == 0
        ? (_marNormalBaseline == null ? null : _marNormalBaseline! * 1.7)
        : yawnMar;
    _headXBaseline = _median(
      _guidedSamples.map((sample) => sample.headX).toList(),
    );
    _headYBaseline = _median(
      _guidedSamples.map((sample) => sample.headY).toList(),
    );
    _faceSizeBaseline = _median(
      _guidedSamples.map((sample) => sample.faceSizeRatio).toList(),
    );
    _guidedStartedAt = null;
    _guidedSamples.clear();
    _ready = _earOpenBaseline != null;
    if (_ready) {
      await _save();
    }
  }

  Future<void> _save() async {
    final payload = jsonEncode(<String, double?>{
      'earOpenBaseline': _earOpenBaseline,
      'earClosedBaseline': _earClosedBaseline,
      'marNormalBaseline': _marNormalBaseline,
      'marYawnBaseline': _marYawnBaseline,
      'headXBaseline': _headXBaseline,
      'headYBaseline': _headYBaseline,
      'faceSizeBaseline': _faceSizeBaseline,
    });
    try {
      final database = DatabaseProvider.database;
      await database
          .into(database.calibrations)
          .insertOnConflictUpdate(
            CalibrationsCompanion.insert(
              id: _storageKey,
              version: const Value(2),
              payloadJson: payload,
              updatedAt: DateTime.now(),
            ),
          );
    } catch (_) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_storageKey, payload);
    }
  }

  bool _valid(double? value) {
    return value != null && value.isFinite && !value.isNaN;
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

  double _min(List<double> values) {
    final filtered = values.where((value) => value.isFinite).toList();
    if (filtered.isEmpty) {
      return 0;
    }
    return filtered.reduce(min);
  }

  double _max(List<double> values) {
    final filtered = values.where((value) => value.isFinite).toList();
    if (filtered.isEmpty) {
      return 0;
    }
    return filtered.reduce(max);
  }
}

class CalibrationObservation {
  const CalibrationObservation({
    required this.timestamp,
    required this.faceDetected,
    required this.eyesClosed,
    required this.ear,
    required this.mar,
    required this.eyeOpenScore,
    required this.headX,
    required this.headY,
    required this.faceSizeRatio,
  });

  final DateTime timestamp;
  final bool faceDetected;
  final bool eyesClosed;
  final double? ear;
  final double? mar;
  final double? eyeOpenScore;
  final double headX;
  final double headY;
  final double faceSizeRatio;
}
