import 'dart:convert';
import 'package:drift/native.dart';
import 'package:driveawake/data/database/database_provider.dart';
import 'package:driveawake/data/database/driver_awake_database.dart'
    hide AppSettings;
import 'package:driveawake/models/app_settings.dart';
import 'package:driveawake/models/drowsiness_event.dart';
import 'package:driveawake/models/drowsiness_state.dart';
import 'package:driveawake/services/local_history_service.dart';
import 'package:driveawake/services/settings_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  test(
    'async SQLite read error reaches legacy history fallback with no retention query',
    () async {
      final source = DrowsinessEvent(
        id: 'legacy-safe',
        dateTime: DateTime(2026, 10, 17),
        level: DrowsinessLevel.warning,
        eventType: 'bostezo',
        durationSeconds: 1,
        notes: 'local',
      );
      SharedPreferences.setMockInitialValues({
        'driverawake_event_history_v1': jsonEncode([source.toMap()]),
      });
      final database = DriverAwakeDatabase(NativeDatabase.memory());
      DatabaseProvider.overrideForTesting(database);
      await SettingsService.instance.update(
        AppSettings.defaults().copyWith(
          historyRetention: HistoryRetention.forever,
        ),
      );
      await database
          .close(); // Forces only the asynchronous repository read to fail.
      final events = await LocalHistoryService.instance.loadEvents();
      expect(events.single.id, 'legacy-safe');
    },
  );
}
