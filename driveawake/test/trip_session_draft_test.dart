import 'package:driveawake/models/trip_session_draft.dart';
import 'package:driveawake/services/trip_session_draft_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  TripSessionDraft draft() {
    return TripSessionDraft(
      tripId: 'trip_test',
      startedAt: DateTime.utc(2026, 1, 1, 10),
      updatedAt: DateTime.utc(2026, 1, 1, 10, 5),
      drivingDuration: const Duration(minutes: 4),
      warningAlerts: 2,
      dangerAlerts: 1,
      yawnCount: 3,
      noFaceEvents: 1,
      normalSamples: 20,
      warningSamples: 8,
      dangerSamples: 2,
      sampleCount: 30,
      riskSum: 750,
      maxRisk: 91,
      closedEyeDuration: const Duration(seconds: 4),
      paused: true,
      incomplete: true,
    );
  }

  setUp(() {
    SharedPreferences.setMockInitialValues(<String, Object>{});
  });

  test('serializa y restaura todos los contadores del borrador', () {
    final original = draft();
    final restored = TripSessionDraft.fromMap(original.toMap());

    expect(restored.tripId, original.tripId);
    expect(restored.startedAt, original.startedAt);
    expect(restored.drivingDuration, original.drivingDuration);
    expect(restored.warningAlerts, 2);
    expect(restored.dangerAlerts, 1);
    expect(restored.sampleCount, 30);
    expect(restored.maxRisk, 91);
    expect(restored.paused, isTrue);
    expect(restored.incomplete, isTrue);
  });

  test('servicio guarda, carga y elimina un borrador', () async {
    final service = TripSessionDraftService.instance;

    await service.save(draft());
    final restored = await service.load();
    await service.clear();

    expect(restored?.tripId, 'trip_test');
    expect(await service.load(), isNull);
  });
}
