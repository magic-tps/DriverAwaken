import 'dart:convert';

import 'package:flutter/foundation.dart';

import '../features/drive/application/performance_monitor.dart';

@immutable
class TechnicalSessionReport {
  TechnicalSessionReport({
    required this.anonymousSessionId,
    required this.deviceManufacturer,
    required this.deviceModel,
    required this.androidVersion,
    required this.appVersion,
    required this.duration,
    required this.performance,
    required this.cameraRestarts,
    required this.successfulRecoveries,
    required this.failedRecoveries,
    required this.initialBattery,
    required this.finalBattery,
    required this.initialTemperatureC,
    required this.maximumTemperatureC,
    required this.elevatedThermalTime,
    required this.criticalThermalTime,
    required this.initialMemoryBytes,
    required this.finalMemoryBytes,
    required this.maximumMemoryBytes,
    required this.pauseCount,
    required this.normalCompletion,
  }) : assert(_anonymousId.hasMatch(anonymousSessionId));

  static final RegExp _anonymousId = RegExp(r'^[a-f0-9-]{8,64}$');
  static final RegExp _unsafeKey = RegExp(
    r'(email|name|route|location|latitude|longitude|image|video|landmark|vector|imei|androidId|serial)',
    caseSensitive: false,
  );

  final String anonymousSessionId;
  final String? deviceManufacturer;
  final String? deviceModel;
  final String? androidVersion;
  final String appVersion;
  final Duration duration;
  final PerformanceSnapshot performance;
  final int cameraRestarts;
  final int successfulRecoveries;
  final int failedRecoveries;
  final double? initialBattery;
  final double? finalBattery;
  final double? initialTemperatureC;
  final double? maximumTemperatureC;
  final Duration elevatedThermalTime;
  final Duration criticalThermalTime;
  final int? initialMemoryBytes;
  final int? finalMemoryBytes;
  final int? maximumMemoryBytes;
  final int pauseCount;
  final bool normalCompletion;

  Map<String, Object?> toSanitizedMap() {
    final stages = <String, Object?>{};
    for (final entry in performance.stageStats.entries) {
      stages[entry.key.name] = <String, Object?>{
        'samples': entry.value.sampleCount,
        'p50Ms': entry.value.p50Ms,
        'p95Ms': entry.value.p95Ms,
        'p99Ms': entry.value.p99Ms,
        'maxMs': entry.value.maxMs,
      };
    }
    final errors = <String, int>{
      for (final entry in performance.errorsByStage.entries)
        entry.key.name: entry.value,
    };
    final value = <String, Object?>{
      'schemaVersion': 1,
      'anonymousSessionId': anonymousSessionId,
      'device': <String, Object?>{
        'manufacturer': _safeText(deviceManufacturer),
        'model': _safeText(deviceModel),
        'androidVersion': _safeText(androidVersion),
      },
      'appVersion': _safeText(appVersion),
      'durationSeconds': duration.inMilliseconds / 1000,
      'frames': <String, int>{
        'received': performance.framesReceived,
        'processed': performance.framesProcessed,
        'dropped': performance.framesDropped,
        'failed': performance.framesFailed,
      },
      'errorsByStage': errors,
      'cameraRestarts': cameraRestarts,
      'successfulRecoveries': successfulRecoveries,
      'failedRecoveries': failedRecoveries,
      'requestedFpsAverage': performance.requestedFps,
      'actualFpsAverage': performance.actualFps,
      'stageLatency': stages,
      'battery': <String, double?>{
        'initial': initialBattery,
        'final': finalBattery,
      },
      'temperatureC': <String, double?>{
        'initial': initialTemperatureC,
        'maximum': maximumTemperatureC,
      },
      'thermalTimeSeconds': <String, double>{
        'elevated': elevatedThermalTime.inMilliseconds / 1000,
        'critical': criticalThermalTime.inMilliseconds / 1000,
      },
      'memoryBytes': <String, int?>{
        'initial': initialMemoryBytes,
        'final': finalMemoryBytes,
        'maximum': maximumMemoryBytes,
      },
      'pauseCount': pauseCount,
      'completion': normalCompletion ? 'normal' : 'abnormal',
    };
    _assertSanitized(value);
    return Map<String, Object?>.unmodifiable(value);
  }

  String toJson() =>
      const JsonEncoder.withIndent('  ').convert(toSanitizedMap());

  static String? _safeText(String? value) {
    if (value == null) return null;
    return value
        .replaceAll(RegExp(r'[\r\n\t]'), ' ')
        .trim()
        .substring(0, value.trim().length.clamp(0, 80));
  }

  static void _assertSanitized(Object? value) {
    if (value is Map) {
      for (final entry in value.entries) {
        final key = entry.key.toString();
        final processingStageName = ProcessingStage.values.any(
          (stage) => stage.name == key,
        );
        if (_unsafeKey.hasMatch(key) && !processingStageName) {
          throw StateError(
            'Campo sensible no permitido en reporte técnico: $key',
          );
        }
        _assertSanitized(entry.value);
      }
    } else if (value is Iterable) {
      for (final item in value) {
        _assertSanitized(item);
      }
    }
  }
}
