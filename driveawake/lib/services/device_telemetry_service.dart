import 'package:flutter/services.dart';

import '../models/device_telemetry_snapshot.dart';

class DeviceTelemetryService {
  static const MethodChannel _channel = MethodChannel(
    'com.magicdrive.alert/device',
  );

  Future<bool> openDialer({String? number}) async {
    try {
      return await _channel.invokeMethod<bool>('openDialer', {
            'number':
                number != null && RegExp(r'^\+?[0-9]{6,15}$').hasMatch(number)
                ? number
                : null,
          }) ??
          false;
    } catch (_) {
      return false;
    }
  }

  Future<Map<String, dynamic>> cameraCapabilities() async {
    try {
      return await _channel.invokeMapMethod<String, dynamic>(
            'cameraCapabilities',
          ) ??
          {};
    } catch (_) {
      return {};
    }
  }

  Future<DeviceTelemetrySnapshot?> getBatteryThermalSnapshot() async {
    try {
      final result = await _channel.invokeMapMethod<dynamic, dynamic>(
        'getBatteryThermal',
      );
      if (result == null) {
        return null;
      }
      return DeviceTelemetrySnapshot.fromMap(result);
    } catch (_) {
      return null;
    }
  }

  Future<void> playAlarm({int repeat = 1}) async {
    try {
      await _channel.invokeMethod<void>('playAlarm', <String, int>{
        'repeat': repeat.clamp(1, 4).toInt(),
      });
    } catch (_) {
      await SystemSound.play(SystemSoundType.alert);
    }
  }

  Future<void> stopAlarm() async {
    try {
      await _channel.invokeMethod<void>('stopAlarm');
    } catch (_) {
      // No-op: native audio is best effort.
    }
  }

  Future<void> setKeepScreenAwake(bool enabled) async {
    try {
      await _channel.invokeMethod<void>('setKeepScreenAwake', <String, bool>{
        'enabled': enabled,
      });
    } catch (_) {
      // No-op on platforms without the native device channel.
    }
  }
}
