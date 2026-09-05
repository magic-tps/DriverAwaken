import 'dart:convert';

import 'package:driveawake/models/app_settings.dart';
import 'package:driveawake/services/settings_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('migrates legacy settings without losing values', () async {
    final legacy = AppSettings.defaults()
        .copyWith(
          sensitivity: SensitivityLevel.high,
          soundEnabled: false,
          historyRetention: HistoryRetention.sevenDays,
        )
        .toMap();
    SharedPreferences.setMockInitialValues(<String, Object>{
      'magicdrive_app_settings_v1': jsonEncode(legacy),
    });

    await SettingsService.instance.initialize();
    final prefs = await SharedPreferences.getInstance();

    expect(
      SettingsService.instance.settings.sensitivity,
      SensitivityLevel.high,
    );
    expect(SettingsService.instance.settings.soundEnabled, isFalse);
    expect(
      SettingsService.instance.settings.historyRetention,
      HistoryRetention.sevenDays,
    );
    expect(prefs.getString('driverawake_app_settings_v1'), isNotNull);
    expect(prefs.getString('magicdrive_app_settings_v1'), isNull);
  });

  test('old maps receive safe retention default', () {
    final restored = AppSettings.fromMap(<String, Object?>{});
    expect(restored.historyRetention, HistoryRetention.thirtyDays);
  });
}
