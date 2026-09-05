import 'dart:convert';

import 'package:driveawake/features/drive/application/performance_monitor.dart';
import 'package:driveawake/models/technical_session_report.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('technical report exports sanitized JSON without sensitive data', () {
    final monitor = PerformanceMonitor()
      ..frameReceived()
      ..frameDroppedBusy()
      ..recordLatencyMicros(ProcessingStage.total, 12000);
    final report = TechnicalSessionReport(
      anonymousSessionId: 'a1b2c3d4-1234',
      deviceManufacturer: 'Example',
      deviceModel: 'Safe Model',
      androidVersion: '15',
      appVersion: '1.0.0+1',
      duration: const Duration(minutes: 30),
      performance: monitor.snapshot(),
      cameraRestarts: 1,
      successfulRecoveries: 1,
      failedRecoveries: 0,
      initialBattery: 90,
      finalBattery: 80,
      initialTemperatureC: 31,
      maximumTemperatureC: 39,
      elevatedThermalTime: Duration.zero,
      criticalThermalTime: Duration.zero,
      initialMemoryBytes: null,
      finalMemoryBytes: null,
      maximumMemoryBytes: null,
      pauseCount: 1,
      normalCompletion: true,
    );

    final json = report.toJson();
    final decoded = jsonDecode(json) as Map<String, dynamic>;

    expect(decoded['anonymousSessionId'], 'a1b2c3d4-1234');
    expect(json.toLowerCase(), isNot(contains('email')));
    expect(json.toLowerCase(), isNot(contains('latitude')));
    expect(json.toLowerCase(), isNot(contains('"image":')));
    expect(json.toLowerCase(), isNot(contains('landmark')));
    expect((decoded['frames'] as Map<String, dynamic>)['dropped'], 1);
  });
}
