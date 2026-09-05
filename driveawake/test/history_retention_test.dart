import 'dart:convert';

import 'package:driveawake/models/app_settings.dart';
import 'package:driveawake/models/drowsiness_event.dart';
import 'package:driveawake/models/drowsiness_state.dart';
import 'package:driveawake/services/local_history_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('retention removes expired events from persistent storage', () async {
    final now = DateTime.now();
    DrowsinessEvent event(String id, DateTime date) => DrowsinessEvent(
      id: id,
      dateTime: date,
      level: DrowsinessLevel.warning,
      eventType: 'test',
      durationSeconds: 1,
      notes: '',
    );
    SharedPreferences.setMockInitialValues(<String, Object>{
      'driverawake_app_settings_v1': jsonEncode(
        AppSettings.defaults()
            .copyWith(historyRetention: HistoryRetention.sevenDays)
            .toMap(),
      ),
      'driverawake_event_history_v1': jsonEncode(<Map<String, Object?>>[
        event('old', now.subtract(const Duration(days: 8))).toMap(),
        event('recent', now.subtract(const Duration(days: 1))).toMap(),
      ]),
    });

    await LocalHistoryService.instance.enforceRetentionPolicy();
    final events = await LocalHistoryService.instance.loadEvents();
    final prefs = await SharedPreferences.getInstance();
    final persisted =
        jsonDecode(prefs.getString('driverawake_event_history_v1')!)
            as List<dynamic>;

    expect(events.map((event) => event.id), <String>['recent']);
    expect(persisted, hasLength(1));
  });
}
