import 'package:driveawake/services/alert_service.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test(
    'stopAllAlerts detiene audio y vibracion de forma idempotente',
    () async {
      final actuator = _FakeAlertActuator();
      final service = AlertService(actuator: actuator);

      await service.stopAllAlerts();
      await service.stopAllAlerts();

      expect(actuator.stopAlarmCalls, 2);
      expect(actuator.cancelVibrationCalls, 2);
      expect(service.alarmActive, isFalse);
    },
  );

  test('dispose detiene alertas y libera el actuador', () async {
    final actuator = _FakeAlertActuator();
    final service = AlertService(actuator: actuator);

    await service.dispose();

    expect(actuator.stopAlarmCalls, 1);
    expect(actuator.cancelVibrationCalls, 1);
    expect(actuator.disposeCalls, 1);
  });
}

class _FakeAlertActuator implements AlertActuator {
  int stopAlarmCalls = 0;
  int cancelVibrationCalls = 0;
  int disposeCalls = 0;

  @override
  Future<void> cancelVibration() async {
    cancelVibrationCalls += 1;
  }

  @override
  Future<void> dispose() async {
    disposeCalls += 1;
  }

  @override
  Future<void> playAlarm({required int repeat}) async {}

  @override
  Future<void> stopAlarm() async {
    stopAlarmCalls += 1;
  }

  @override
  Future<void> vibrateShort() async {}

  @override
  Future<void> vibrateStrongly(int tier) async {}
}
