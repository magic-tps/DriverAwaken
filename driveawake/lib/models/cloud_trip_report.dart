import 'dart:convert';

import 'package:crypto/crypto.dart';

import 'drowsiness_state.dart';
import 'trip_session_summary.dart';

class CloudTripReport {
  const CloudTripReport({required this.id, required this.summary});

  final String id;
  final TripSessionSummary summary;

  static String documentId(TripSessionSummary trip) => sha256
      .convert(
        utf8.encode(
          '${trip.tripId}|${trip.startedAt.toUtc().toIso8601String()}',
        ),
      )
      .toString();

  static Map<String, dynamic> encode(TripSessionSummary trip) => {
    'schemaVersion': 1,
    'tripId': trip.tripId,
    'startedAtMs': trip.startedAt.millisecondsSinceEpoch,
    'endedAtMs': trip.endedAt.millisecondsSinceEpoch,
    'drivingDurationMs': trip.drivingDuration.inMilliseconds,
    'warningAlerts': trip.warningAlerts,
    'dangerAlerts': trip.dangerAlerts,
    'yawnCount': trip.yawnCount,
    'closedEyeDurationMs': trip.closedEyeDuration.inMilliseconds,
    'noFaceEvents': trip.noFaceEvents,
    'averageRisk': trip.averageRisk,
    'maxRisk': trip.maxRisk,
    'dominantLevel': trip.dominantLevel.name,
    'startBatteryLevel': trip.startBatteryLevel,
    'endBatteryLevel': trip.endBatteryLevel,
    'startTemperatureC': trip.startTemperatureC,
    'endTemperatureC': trip.endTemperatureC,
    'maxTemperatureC': trip.maxTemperatureC,
    'isCharging': trip.isCharging,
  };

  factory CloudTripReport.decode(String id, Map<String, dynamic> data) {
    if (data['schemaVersion'] != 1) {
      throw const FormatException('Versión de informe no compatible.');
    }
    return CloudTripReport(
      id: id,
      summary: TripSessionSummary(
        tripId: data['tripId'] as String,
        startedAt: DateTime.fromMillisecondsSinceEpoch(
          data['startedAtMs'] as int,
        ),
        endedAt: DateTime.fromMillisecondsSinceEpoch(data['endedAtMs'] as int),
        drivingDuration: Duration(
          milliseconds: data['drivingDurationMs'] as int,
        ),
        warningAlerts: data['warningAlerts'] as int,
        dangerAlerts: data['dangerAlerts'] as int,
        yawnCount: data['yawnCount'] as int,
        closedEyeDuration: Duration(
          milliseconds: data['closedEyeDurationMs'] as int,
        ),
        noFaceEvents: data['noFaceEvents'] as int,
        averageRisk: (data['averageRisk'] as num).toDouble(),
        maxRisk: (data['maxRisk'] as num).toDouble(),
        dominantLevel: DrowsinessLevel.values.byName(
          data['dominantLevel'] as String,
        ),
        startBatteryLevel: (data['startBatteryLevel'] as num?)?.toDouble(),
        endBatteryLevel: (data['endBatteryLevel'] as num?)?.toDouble(),
        startTemperatureC: (data['startTemperatureC'] as num?)?.toDouble(),
        endTemperatureC: (data['endTemperatureC'] as num?)?.toDouble(),
        maxTemperatureC: (data['maxTemperatureC'] as num?)?.toDouble(),
        isCharging: data['isCharging'] as bool,
      ),
    );
  }
}
