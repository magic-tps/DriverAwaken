import '../models/drowsiness_state.dart';

enum ThermalLoad { normal, elevated, critical }

class AdaptiveFrameScheduler {
  AdaptiveFrameScheduler({
    this.elevatedTemperatureC = 40,
    this.criticalTemperatureC = 44,
    this.temperatureHysteresisC = 2,
    this.lowBatteryPercent = 15,
  });

  final double elevatedTemperatureC;
  final double criticalTemperatureC;
  final double temperatureHysteresisC;
  final double lowBatteryPercent;

  ThermalLoad _thermalLoad = ThermalLoad.normal;
  double? _batteryPercent;
  bool _charging = false;

  ThermalLoad get thermalLoad => _thermalLoad;

  void updateTelemetry({
    double? batteryPercent,
    double? batteryTemperatureC,
    required bool charging,
  }) {
    _batteryPercent = batteryPercent;
    _charging = charging;
    final temperature = batteryTemperatureC;
    if (temperature == null) return;

    if (_thermalLoad == ThermalLoad.critical) {
      if (temperature < criticalTemperatureC - temperatureHysteresisC) {
        _thermalLoad = temperature >= elevatedTemperatureC
            ? ThermalLoad.elevated
            : ThermalLoad.normal;
      }
      return;
    }
    if (temperature >= criticalTemperatureC) {
      _thermalLoad = ThermalLoad.critical;
    } else if (temperature >= elevatedTemperatureC) {
      _thermalLoad = ThermalLoad.elevated;
    } else if (temperature < elevatedTemperatureC - temperatureHysteresisC) {
      _thermalLoad = ThermalLoad.normal;
    }
  }

  Duration intervalFor({
    required DrowsinessLevel riskLevel,
    required bool calibrationInProgress,
  }) {
    if (_thermalLoad == ThermalLoad.critical) {
      return const Duration(milliseconds: 500);
    }
    if (_thermalLoad == ThermalLoad.elevated) {
      return const Duration(milliseconds: 400);
    }
    if (!_charging && (_batteryPercent ?? 100) <= lowBatteryPercent) {
      return const Duration(milliseconds: 300);
    }
    if (calibrationInProgress || riskLevel != DrowsinessLevel.normal) {
      return const Duration(milliseconds: 110);
    }
    return const Duration(milliseconds: 220);
  }

  double requestedFpsFor({
    required DrowsinessLevel riskLevel,
    required bool calibrationInProgress,
  }) =>
      1000 /
      intervalFor(
        riskLevel: riskLevel,
        calibrationInProgress: calibrationInProgress,
      ).inMilliseconds;
}
