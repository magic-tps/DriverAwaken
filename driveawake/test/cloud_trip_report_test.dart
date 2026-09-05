import 'dart:async';

import 'package:driveawake/models/cloud_trip_report.dart';
import 'package:driveawake/models/drowsiness_state.dart';
import 'package:driveawake/models/trip_session_summary.dart';
import 'package:driveawake/services/cloud_report_service.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final trip = TripSessionSummary(
    tripId: 'trip_123',
    startedAt: DateTime.utc(2026, 9, 5, 10),
    endedAt: DateTime.utc(2026, 9, 5, 10, 10),
    drivingDuration: const Duration(minutes: 10),
    warningAlerts: 2,
    dangerAlerts: 1,
    yawnCount: 3,
    closedEyeDuration: const Duration(seconds: 4),
    noFaceEvents: 1,
    averageRisk: 23.5,
    maxRisk: 85,
    dominantLevel: DrowsinessLevel.warning,
    startBatteryLevel: 90,
    endBatteryLevel: 85,
    maxTemperatureC: 38.5,
  );

  test(
    'report round trip preserves timing, risk, counts and optional telemetry',
    () {
      final encoded = CloudTripReport.encode(trip);
      final restored = CloudTripReport.decode('id', encoded).summary;
      expect(CloudTripReport.encode(restored), encoded);
      expect(restored.drivingDuration, const Duration(minutes: 10));
      expect(restored.startTemperatureC, isNull);
      expect(restored.batteryDelta, -5);
      expect(restored.averageRisk, 23.5);
    },
  );

  test(
    'cloud payload has an explicit schema without frames, location or credentials',
    () {
      expect(CloudTripReport.encode(trip).keys.toSet(), {
        'schemaVersion',
        'tripId',
        'startedAtMs',
        'endedAtMs',
        'drivingDurationMs',
        'warningAlerts',
        'dangerAlerts',
        'yawnCount',
        'closedEyeDurationMs',
        'noFaceEvents',
        'averageRisk',
        'maxRisk',
        'dominantLevel',
        'startBatteryLevel',
        'endBatteryLevel',
        'startTemperatureC',
        'endTemperatureC',
        'maxTemperatureC',
        'isCharging',
      });
    },
  );

  test('repeated backup uses the same ID after decoding persisted data', () {
    final restored = CloudTripReport.decode(
      'id',
      CloudTripReport.encode(trip),
    ).summary;
    expect(
      CloudTripReport.documentId(restored),
      CloudTripReport.documentId(trip),
    );
    expect(
      CloudTripReport.documentId(trip),
      matches(RegExp(r'^[a-f0-9]{64}$')),
    );
  });

  test('unknown report versions are rejected', () {
    expect(
      () => CloudTripReport.decode('id', {
        ...CloudTripReport.encode(trip),
        'schemaVersion': 2,
      }),
      throwsFormatException,
    );
  });

  test('timeout message does not claim a queued cloud write was cancelled', () {
    expect(
      CloudReportService.friendlyError(TimeoutException('test')),
      contains('puede completarse'),
    );
  });
}
