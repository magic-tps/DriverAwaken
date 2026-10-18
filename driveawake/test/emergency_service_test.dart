import 'package:driveawake/services/emergency_service.dart';
import 'package:driveawake/services/device_telemetry_service.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUp(() => SharedPreferences.setMockInitialValues({}));
  test(
    'emergency contact remains local, validates digits and can be removed',
    () async {
      final service = EmergencyService();
      expect(await service.contact(), '');
      await service.saveContact('+51987654321');
      expect(await EmergencyService().contact(), '+51987654321');
      await expectLater(service.saveContact('123;bad'), throwsFormatException);
      expect(await service.contact(), '+51987654321');
      await service.saveContact('');
      expect(await service.contact(), '');
    },
  );
  test('dialer passes a validated contact or opens an empty dialer', () async {
    final calls = <MethodCall>[];
    const channel = MethodChannel('com.magicdrive.alert/device');
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (call) async {
          calls.add(call);
          return true;
        });
    addTearDown(
      () => TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(channel, null),
    );
    await DeviceTelemetryService().openDialer(number: '+51987654321');
    await DeviceTelemetryService().openDialer(number: '*unsafe#');
    expect(calls.first.arguments['number'], '+51987654321');
    expect(calls.last.arguments['number'], isNull);
    expect(calls.every((call) => call.method == 'openDialer'), isTrue);
  });
}
