import 'dart:math';

import '../models/drowsiness_frame_metrics.dart';

class FeatureWindowService {
  static const Duration windowDuration = Duration(seconds: 10);
  static const List<int> _rollingWindows = <int>[3, 6, 12];
  static const List<String> _rollingMeanColumns = <String>[
    'face_ratio',
    'no_face_ratio',
    'ear_mean',
    'ear_min',
    'ear_std',
    'mar_mean',
    'mar_max',
    'perclos',
    'max_eye_closed_duration',
    'yawn_ratio',
    'yaw_proxy_max_abs',
    'pitch_proxy_max',
  ];
  static const List<String> _rollingSumColumns = <String>[
    'blink_count',
    'yawn_count',
  ];
  static const List<String> _diffColumns = <String>[
    'ear_mean',
    'ear_min',
    'mar_mean',
    'mar_max',
    'perclos',
    'yaw_proxy_mean',
    'pitch_proxy_mean',
  ];

  final List<DrowsinessFrameMetrics> _currentSamples =
      <DrowsinessFrameMetrics>[];
  final List<Map<String, double>> _completedWindows = <Map<String, double>>[];
  DateTime? _currentWindowStart;

  Map<String, double>? addSample(DrowsinessFrameMetrics sample) {
    _currentWindowStart ??= sample.timestamp;
    _rollWindowIfNeeded(sample.timestamp);
    _currentSamples.add(sample);

    if (_currentSamples.length < 8) {
      return null;
    }

    final current = _summarize(_currentSamples);
    return _enhance(current);
  }

  void reset() {
    _currentSamples.clear();
    _completedWindows.clear();
    _currentWindowStart = null;
  }

  void _rollWindowIfNeeded(DateTime timestamp) {
    final start = _currentWindowStart;
    if (start == null || timestamp.difference(start) < windowDuration) {
      return;
    }

    if (_currentSamples.isNotEmpty) {
      _completedWindows.add(_summarize(_currentSamples));
      if (_completedWindows.length > 12) {
        _completedWindows.removeAt(0);
      }
      _currentSamples.clear();
    }

    _currentWindowStart = timestamp;
  }

  Map<String, double> _enhance(Map<String, double> current) {
    final features = Map<String, double>.from(current);
    _addStaticFeatures(features);

    final windows = <Map<String, double>>[..._completedWindows, features];
    final previous = _completedWindows.isEmpty ? null : _completedWindows.last;

    for (final column in _diffColumns) {
      final value = features[column] ?? 0;
      final previousValue = previous?[column] ?? value;
      final diff = value - previousValue;
      features['${column}_diff1'] = diff;
      features['${column}_abs_diff1'] = diff.abs();
    }

    for (final windowSize in _rollingWindows) {
      final recent = windows.length <= windowSize
          ? windows
          : windows.sublist(windows.length - windowSize);

      for (final column in _rollingMeanColumns) {
        final values = _valuesFor(recent, column);
        features['${column}_roll${windowSize}_mean'] = _mean(values);
        features['${column}_roll${windowSize}_max'] = _max(values);
        features['${column}_roll${windowSize}_min'] = _min(values);
      }

      for (final column in _rollingSumColumns) {
        final values = _valuesFor(recent, column);
        features['${column}_roll${windowSize}_sum'] = _sum(values);
      }
    }

    features['perclos_minus_roll3'] =
        (features['perclos'] ?? 0) - (features['perclos_roll3_mean'] ?? 0);
    features['perclos_minus_roll6'] =
        (features['perclos'] ?? 0) - (features['perclos_roll6_mean'] ?? 0);
    features['ear_mean_minus_roll3'] =
        (features['ear_mean'] ?? 0) - (features['ear_mean_roll3_mean'] ?? 0);
    features['mar_max_minus_roll3'] =
        (features['mar_max'] ?? 0) - (features['mar_max_roll3_mean'] ?? 0);
    features['fatigue_accumulation_3'] =
        (features['perclos_roll3_mean'] ?? 0) +
        (features['closed_duration_ratio'] ?? 0) +
        (features['yawn_ratio_roll3_mean'] ?? 0);
    features['fatigue_accumulation_6'] =
        (features['perclos_roll6_mean'] ?? 0) +
        ((features['max_eye_closed_duration_roll6_max'] ?? 0) / 10) +
        ((features['yawn_count_roll6_sum'] ?? 0) / 6);

    return features;
  }

  Map<String, double> _summarize(List<DrowsinessFrameMetrics> records) {
    final totalCount = records.length;
    final valid = records.where((record) => record.faceDetected).toList();
    final validCount = valid.length;
    final safeTotal = max(1, totalCount);
    final safeValid = max(1, validCount);

    final ears = _finiteValues(valid.map((record) => record.ear));
    final mars = _finiteValues(valid.map((record) => record.mar));
    final yawValues = _finiteValues(valid.map((record) => record.yawProxy));
    final pitchValues = _finiteValues(valid.map((record) => record.pitchProxy));
    final closedFlags = valid.map((record) => record.eyesClosed).toList();
    final yawnFlags = valid.map((record) => record.yawning).toList();

    final closedCount = closedFlags.where((value) => value).length;
    final yawnCount = yawnFlags.where((value) => value).length;

    return <String, double>{
      'face_ratio': validCount / safeTotal,
      'no_face_ratio': 1 - (validCount / safeTotal),
      'ear_mean': _mean(ears),
      'ear_min': _min(ears),
      'ear_max': _max(ears),
      'ear_std': _std(ears),
      'mar_mean': _mean(mars),
      'mar_max': _max(mars),
      'mar_std': _std(mars),
      'perclos': validCount == 0 ? 0 : closedCount / safeValid,
      'blink_count': _countTrueRuns(closedFlags).toDouble(),
      'max_eye_closed_duration': _maxTrueRunDuration(valid, closedFlags),
      'yawn_count': _countTrueRuns(yawnFlags).toDouble(),
      'yawn_ratio': validCount == 0 ? 0 : yawnCount / safeValid,
      'yaw_proxy_mean': _mean(yawValues),
      'yaw_proxy_max_abs': _maxAbs(yawValues),
      'pitch_proxy_mean': _mean(pitchValues),
      'pitch_proxy_max': _max(pitchValues),
      'valid_frame_count': validCount.toDouble(),
      'total_frame_count': totalCount.toDouble(),
    };
  }

  void _addStaticFeatures(Map<String, double> features) {
    const eps = 1e-6;
    const earThreshold = 0.16;
    const marThreshold = 0.55;
    const windowSeconds = 10.0;

    final valid = max(1.0, features['valid_frame_count'] ?? 0);
    final total = max(1.0, features['total_frame_count'] ?? 0);
    final earMean = features['ear_mean'] ?? 0;
    final earMin = features['ear_min'] ?? 0;
    final earMax = features['ear_max'] ?? 0;
    final earStd = features['ear_std'] ?? 0;
    final marMean = features['mar_mean'] ?? 0;
    final marMax = features['mar_max'] ?? 0;
    final marStd = features['mar_std'] ?? 0;
    final perclos = features['perclos'] ?? 0;
    final yawnRatio = features['yawn_ratio'] ?? 0;
    final yawnCount = features['yawn_count'] ?? 0;
    final blinkCount = features['blink_count'] ?? 0;
    final maxClosedDuration = features['max_eye_closed_duration'] ?? 0;
    final yawAbs = (features['yaw_proxy_max_abs'] ?? 0).abs();
    final pitchMax = (features['pitch_proxy_max'] ?? 0).abs();

    features['valid_frame_ratio'] = valid / total;
    features['invalid_frame_count'] = total - valid;
    features['ear_range'] = earMax - earMin;
    features['ear_mean_to_min_gap'] = earMean - earMin;
    features['ear_closed_intensity_mean'] = max(0, earThreshold - earMean);
    features['ear_closed_intensity_min'] = max(0, earThreshold - earMin);
    features['ear_stability_ratio'] = earStd / (earMean.abs() + eps);
    features['mar_open_intensity_mean'] = max(0, marMean - marThreshold);
    features['mar_open_intensity_max'] = max(0, marMax - marThreshold);
    features['mar_activity_ratio'] = marStd / (marMean.abs() + eps);
    features['blink_rate'] = blinkCount / windowSeconds;
    features['yawn_rate'] = yawnCount / windowSeconds;
    features['closed_duration_ratio'] = maxClosedDuration / windowSeconds;
    features['closed_frames_estimated'] = perclos * valid;
    features['head_yaw_abs_mean_proxy'] = (features['yaw_proxy_mean'] ?? 0)
        .abs();
    features['head_pitch_abs_mean_proxy'] = (features['pitch_proxy_mean'] ?? 0)
        .abs();
    features['head_pose_intensity'] = yawAbs + pitchMax;
    features['fatigue_eye_score'] =
        0.55 * perclos +
        0.30 * (features['closed_duration_ratio'] ?? 0) +
        0.15 * (features['ear_closed_intensity_min'] ?? 0);
    features['fatigue_mouth_score'] =
        0.70 * yawnRatio +
        0.20 * (features['mar_open_intensity_max'] ?? 0) +
        0.10 * (features['yawn_rate'] ?? 0);
    features['fatigue_pose_score'] =
        0.60 * (features['head_pose_intensity'] ?? 0) +
        0.40 * (features['no_face_ratio'] ?? 0);
    features['fatigue_combined_score'] =
        0.55 * (features['fatigue_eye_score'] ?? 0) +
        0.25 * (features['fatigue_mouth_score'] ?? 0) +
        0.20 * (features['fatigue_pose_score'] ?? 0);
    features['perclos_x_yawn_ratio'] = perclos * yawnRatio;
    features['perclos_x_closed_duration'] = perclos * maxClosedDuration;
    features['perclos_x_head_pose'] =
        perclos * (features['head_pose_intensity'] ?? 0);
    features['mar_x_head_pose'] =
        marMax * (features['head_pose_intensity'] ?? 0);
    features['blink_per_valid_frame'] = blinkCount / valid;
    features['yawn_per_valid_frame'] = yawnCount / valid;
  }

  List<double> _finiteValues(Iterable<double?> values) {
    return values
        .whereType<double>()
        .where((value) => value.isFinite && !value.isNaN)
        .toList(growable: false);
  }

  List<double> _valuesFor(List<Map<String, double>> windows, String column) {
    return windows
        .map((window) => window[column])
        .whereType<double>()
        .where((value) => value.isFinite && !value.isNaN)
        .toList(growable: false);
  }

  double _mean(List<double> values) {
    if (values.isEmpty) {
      return 0;
    }
    return _sum(values) / values.length;
  }

  double _sum(List<double> values) {
    return values.fold<double>(0, (total, value) => total + value);
  }

  double _min(List<double> values) {
    if (values.isEmpty) {
      return 0;
    }
    return values.reduce(min);
  }

  double _max(List<double> values) {
    if (values.isEmpty) {
      return 0;
    }
    return values.reduce(max);
  }

  double _maxAbs(List<double> values) {
    if (values.isEmpty) {
      return 0;
    }
    return values.map((value) => value.abs()).reduce(max);
  }

  double _std(List<double> values) {
    if (values.length < 2) {
      return 0;
    }
    final average = _mean(values);
    final variance =
        values.fold<double>(
          0,
          (total, value) => total + pow(value - average, 2).toDouble(),
        ) /
        values.length;
    return sqrt(variance);
  }

  int _countTrueRuns(List<bool> flags) {
    var count = 0;
    var previous = false;
    for (final flag in flags) {
      if (flag && !previous) {
        count += 1;
      }
      previous = flag;
    }
    return count;
  }

  double _maxTrueRunDuration(
    List<DrowsinessFrameMetrics> valid,
    List<bool> flags,
  ) {
    if (valid.isEmpty || flags.isEmpty) {
      return 0;
    }

    final secondsPerSample = _secondsPerSample(valid);
    var maxRun = 0;
    var currentRun = 0;
    for (final flag in flags) {
      if (flag) {
        currentRun += 1;
        maxRun = max(maxRun, currentRun);
      } else {
        currentRun = 0;
      }
    }
    return maxRun * secondsPerSample;
  }

  double _secondsPerSample(List<DrowsinessFrameMetrics> records) {
    if (records.length < 2) {
      return 0.2;
    }
    final elapsed = records.last.timestamp
        .difference(records.first.timestamp)
        .inMilliseconds;
    if (elapsed <= 0) {
      return 0.2;
    }
    return (elapsed / 1000) / max(1, records.length - 1);
  }
}
