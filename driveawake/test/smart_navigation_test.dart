import 'package:drift/native.dart';
import 'package:driveawake/data/database/driver_awake_database.dart';
import 'package:driveawake/models/drowsiness_state.dart';
import 'package:driveawake/navigation/navigation_contracts.dart';
import 'package:driveawake/navigation/rest_recommendation_engine.dart';
import 'package:driveawake/navigation/rest_repository.dart';
import 'package:driveawake/navigation/smart_navigation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:url_launcher/url_launcher.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('official Maps URLs safely encode search and directions', () {
    final search = mapsSearchUri('café & estacionamiento');
    expect(search.host, 'www.google.com');
    expect(search.path, '/maps/search/');
    expect(search.queryParameters['api'], '1');
    expect(search.queryParameters['query'], 'café & estacionamiento');

    final directions = mapsDirectionsUri('Av. Perú 123, Lima');
    expect(directions.path, '/maps/dir/');
    expect(directions.queryParameters['destination'], 'Av. Perú 123, Lima');
    expect(directions.queryParameters['travelmode'], 'driving');
    expect(directions.queryParameters['dir_action'], 'navigate');
    expect(() => mapsSearchUri('  '), throwsArgumentError);
  });

  test(
    'uses externalApplication first and browser fallback when unavailable',
    () async {
      final modes = <LaunchMode>[];
      final nav = SmartNavigation(
        launcher: (uri, mode) async {
          modes.add(mode);
          return mode == LaunchMode.platformDefault;
        },
      );
      expect(await nav.searchCategory(MapsSearchCategory.restAreas), isTrue);
      expect(modes, [
        LaunchMode.externalApplication,
        LaunchMode.platformDefault,
      ]);
      expect(nav.error, isNull);
    },
  );

  test(
    'reports absence of both Google Maps and a compatible browser',
    () async {
      final nav = SmartNavigation(launcher: (_, _) async => false);
      expect(await nav.navigate('Arequipa'), isFalse);
      expect(nav.error, contains('navegador compatible'));
    },
  );

  test('tries browser fallback when the external resolver throws', () async {
    final modes = <LaunchMode>[];
    final nav = SmartNavigation(
      launcher: (_, mode) async {
        modes.add(mode);
        if (mode == LaunchMode.externalApplication) throw StateError('missing');
        return true;
      },
    );
    expect(await nav.searchCategory(MapsSearchCategory.parking), isTrue);
    expect(modes, [LaunchMode.externalApplication, LaunchMode.platformDefault]);
  });

  final now = DateTime.utc(2026, 10, 17);

  test('critical recommendation is immediate and never advises coffee', () {
    final state = DrowsinessState.initial().copyWith(
      faceDetected: true,
      signalQuality: .9,
      level: DrowsinessLevel.danger,
    );
    final result = RestRecommendationEngine().evaluate(
      state,
      now,
      Duration.zero,
    );
    expect(result?.critical, isTrue);
    expect(result?.reason, 'CRITICAL_SIGNAL');
    expect(result?.message.toLowerCase(), contains('no continúes'));
  });

  test('warning requires a sustained window and duration triggers a rest', () {
    final engine = RestRecommendationEngine();
    final warning = DrowsinessState.initial().copyWith(
      faceDetected: true,
      signalQuality: .9,
      level: DrowsinessLevel.warning,
    );
    expect(engine.evaluate(warning, now, Duration.zero), isNull);
    expect(
      engine
          .evaluate(
            warning,
            now.add(const Duration(seconds: 21)),
            Duration.zero,
          )
          ?.reason,
      'SUSTAINED_WARNING',
    );
    engine.reset();
    expect(
      engine
          .evaluate(
            warning.copyWith(level: DrowsinessLevel.normal),
            now,
            const Duration(minutes: 31),
            drivingLimit: const Duration(minutes: 30),
          )
          ?.reason,
      'DRIVING_DURATION',
    );
  });

  test(
    'spoken rest request persists without a detector alert and cannot replace critical fatigue',
    () {
      final nav = SmartNavigation(launcher: (_, _) async => false);
      nav.startTrip('voice-trip');
      final normal = DrowsinessState.initial().copyWith(
        faceDetected: true,
        signalQuality: .9,
        level: DrowsinessLevel.normal,
      );
      nav.requestRest();
      expect(nav.recommendation?.reason, 'MANUAL');
      nav.observe(normal, now, Duration.zero);
      expect(nav.recommendation?.reason, 'MANUAL');
      nav.observe(
        normal.copyWith(level: DrowsinessLevel.danger),
        now,
        Duration.zero,
      );
      expect(nav.recommendation?.reason, 'CRITICAL_SIGNAL');
      nav.requestRest();
      expect(nav.recommendation?.reason, 'CRITICAL_SIGNAL');
    },
  );

  test('declared rest persists and closes idempotently', () async {
    final db = DriverAwakeDatabase(NativeDatabase.memory());
    await db
        .into(db.trips)
        .insert(
          TripsCompanion.insert(
            id: 'local-trip',
            startedAt: now,
            createdAt: now,
            updatedAt: now,
          ),
        );
    final repository = RestRepository(db);
    final started = await repository.start('local-trip', now, 'MANUAL');
    expect(started.endedAt, isNull);
    await expectLater(
      repository.start('local-trip', now, 'MANUAL'),
      throwsStateError,
    );
    final completed = await repository.finish(
      'local-trip',
      now.add(const Duration(minutes: 15)),
    );
    expect(completed?.durationMs, 900000);
    expect(
      await repository.finish(
        'local-trip',
        now.add(const Duration(minutes: 20)),
      ),
      isNull,
    );
    await db.close();
  });
}
