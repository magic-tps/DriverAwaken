import 'package:driveawake/models/drowsiness_state.dart';
import 'package:driveawake/utils/adaptive_frame_scheduler.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('uses 4-5 FPS during normal monitoring', () {
    final scheduler = AdaptiveFrameScheduler();
    expect(
      scheduler.intervalFor(
        riskLevel: DrowsinessLevel.normal,
        calibrationInProgress: false,
      ),
      const Duration(milliseconds: 220),
    );
  });

  test('raises sampling while suspicious and throttles on heat', () {
    final scheduler = AdaptiveFrameScheduler();
    expect(
      scheduler.intervalFor(
        riskLevel: DrowsinessLevel.warning,
        calibrationInProgress: false,
      ),
      const Duration(milliseconds: 110),
    );
    scheduler.updateTelemetry(
      batteryTemperatureC: 41,
      batteryPercent: 80,
      charging: false,
    );
    expect(scheduler.thermalLoad, ThermalLoad.elevated);
    expect(
      scheduler.intervalFor(
        riskLevel: DrowsinessLevel.danger,
        calibrationInProgress: true,
      ),
      const Duration(milliseconds: 400),
    );
  });

  test('uses hysteresis before leaving critical thermal load', () {
    final scheduler = AdaptiveFrameScheduler();
    scheduler.updateTelemetry(
      batteryTemperatureC: 45,
      batteryPercent: 80,
      charging: false,
    );
    scheduler.updateTelemetry(
      batteryTemperatureC: 43,
      batteryPercent: 80,
      charging: false,
    );
    expect(scheduler.thermalLoad, ThermalLoad.critical);
    scheduler.updateTelemetry(
      batteryTemperatureC: 41,
      batteryPercent: 80,
      charging: false,
    );
    expect(scheduler.thermalLoad, ThermalLoad.elevated);
  });

  test('reduces FPS on low battery when not charging', () {
    final scheduler = AdaptiveFrameScheduler();
    scheduler.updateTelemetry(
      batteryTemperatureC: null,
      batteryPercent: 10,
      charging: false,
    );
    expect(
      scheduler.intervalFor(
        riskLevel: DrowsinessLevel.normal,
        calibrationInProgress: false,
      ),
      const Duration(milliseconds: 300),
    );
  });
}
