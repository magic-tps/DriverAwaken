class DeviceTelemetrySnapshot {
  const DeviceTelemetrySnapshot({
    required this.timestamp,
    required this.batteryLevel,
    required this.temperatureC,
    required this.voltageMv,
    required this.status,
    required this.plugged,
    this.deviceManufacturer,
    this.deviceModel,
    this.androidVersion,
    this.memoryBytes,
  });

  final DateTime timestamp;
  final double? batteryLevel;
  final double? temperatureC;
  final int? voltageMv;
  final int? status;
  final int? plugged;
  final String? deviceManufacturer;
  final String? deviceModel;
  final String? androidVersion;
  final int? memoryBytes;

  bool get isCharging => plugged != null && plugged != 0;

  factory DeviceTelemetrySnapshot.fromMap(Map<dynamic, dynamic> map) {
    final timestampMs = (map['timestampMs'] as num?)?.toInt();
    return DeviceTelemetrySnapshot(
      timestamp: timestampMs == null
          ? DateTime.now()
          : DateTime.fromMillisecondsSinceEpoch(timestampMs),
      batteryLevel: (map['batteryLevel'] as num?)?.toDouble(),
      temperatureC: (map['temperatureC'] as num?)?.toDouble(),
      voltageMv: (map['voltageMv'] as num?)?.toInt(),
      status: (map['status'] as num?)?.toInt(),
      plugged: (map['plugged'] as num?)?.toInt(),
      deviceManufacturer: map['deviceManufacturer'] as String?,
      deviceModel: map['deviceModel'] as String?,
      androidVersion: map['androidVersion'] as String?,
      memoryBytes: (map['memoryBytes'] as num?)?.toInt(),
    );
  }
}
