import 'dart:async';

import 'package:camera/camera.dart';
import 'package:drift/native.dart';
import 'package:driveawake/data/database/database_provider.dart';
import 'package:driveawake/data/database/driver_awake_database.dart';
import 'package:driveawake/screens/home_screen.dart';
import 'package:driveawake/services/camera_service.dart';
import 'package:driveawake/services/drowsiness_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    final database = DriverAwakeDatabase(NativeDatabase.memory());
    DatabaseProvider.overrideForTesting(database);
    await database.customSelect('SELECT 1').get();
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
          const MethodChannel('google_mlkit_face_detector'),
          (_) async => null,
        );
  });
  tearDown(DatabaseProvider.reset);

  Future<void> openHome(WidgetTester tester, _Camera camera) async {
    await tester.pumpWidget(
      MaterialApp(
        home: HomeScreen(
          cameraService: camera,
          drowsinessService: _Drowsiness(),
        ),
      ),
    );
    // SQLite uses asynchronous platform work outside the widget fake clock.
    await tester.runAsync(() async {
      for (var i = 0; i < 100 && camera.opens == 0; i++) {
        await Future<void>.delayed(const Duration(milliseconds: 10));
      }
    });
    await tester.pump();
  }

  testWidgets('abre cámara al inicio y continúa después de 25 segundos', (
    tester,
  ) async {
    final camera = _Camera();
    await openHome(tester, camera);
    expect(camera.opens, 1);
    expect(camera.streams, 1);
    await tester.pump(const Duration(seconds: 30));
    expect(camera.closes, 0);
    await tester.pumpWidget(const SizedBox());
    await tester.pump();
    expect(camera.closes, 1);
  });

  testWidgets('pausa en segundo plano y reinicia al volver', (tester) async {
    final camera = _Camera();
    await openHome(tester, camera);
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.paused);
    await tester.pump();
    await tester.pump();
    expect(camera.closes, 1);
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
    await tester.pump();
    expect(camera.opens, 2);
    expect(camera.streams, 2);
    await tester.pumpWidget(const SizedBox());
    await tester.pump();
  });

  testWidgets('diálogo de permiso no duplica inicialización pendiente', (
    tester,
  ) async {
    final camera = _Camera()..permission = Completer<void>();
    await openHome(tester, camera);
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.inactive);
    await tester.pump();
    camera.permission!.complete();
    await tester.pump();
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
    await tester.pump();
    expect(camera.opens, 1);
    expect(camera.streams, 1);
    await tester.pumpWidget(const SizedBox());
    await tester.pump();
  });
  testWidgets('permission denial shows retry without a zero risk reading', (
    tester,
  ) async {
    final camera = _Camera()..deny = true;
    await openHome(tester, camera);
    expect(
      find.text('Activa el permiso de camara para usar el escaneo.'),
      findsOneWidget,
    );
    expect(find.text('0/100'), findsNothing);
    camera.deny = false;
    await tester.ensureVisible(find.text('Reintentar'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Reintentar'));
    await tester.pump();
    expect(camera.opens, 2);
    expect(camera.streams, 1);
    await tester.pumpWidget(const SizedBox());
    await tester.pump();
  });

  testWidgets(
    'background during opening cancels stream and resume opens once',
    (tester) async {
      final camera = _Camera()..permission = Completer<void>();
      await openHome(tester, camera);
      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.paused);
      camera.permission!.complete();
      await tester.pump();
      expect(camera.streams, 0);
      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
      await tester.pump();
      expect(camera.opens, 2);
      expect(camera.streams, 1);
      await tester.pumpWidget(const SizedBox());
      await tester.pump();
    },
  );
}

class _Camera extends CameraService {
  int opens = 0;
  int streams = 0;
  int closes = 0;
  bool initialized = false;
  bool deny = false;
  Completer<void>? permission;

  @override
  bool get isInitialized => initialized;
  @override
  Future<void> initializeFrontCamera({
    ResolutionPreset resolutionPreset = ResolutionPreset.medium,
  }) async {
    opens++;
    if (deny) throw CameraException('CameraAccessDenied', 'Permission denied');
    await permission?.future;
    initialized = true;
  }

  @override
  Future<void> startImageStream(void Function(CameraImage) onImage) async {
    streams++;
  }

  @override
  Future<void> dispose() async {
    closes++;
    initialized = false;
  }
}

class _Drowsiness extends DrowsinessService {
  @override
  Future<void> initialize() async {}
  @override
  Future<void> close() async {}
}
