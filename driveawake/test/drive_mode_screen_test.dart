import 'package:driveawake/features/drive/application/drive_session_controller.dart';
import 'package:driveawake/app/app_theme.dart';
import 'package:driveawake/features/drive/application/drive_state.dart';
import 'package:driveawake/features/drive/application/monitoring_watchdog.dart';
import 'package:driveawake/models/trip_session_draft.dart';
import 'package:driveawake/models/trip_session_summary.dart';
import 'package:driveawake/screens/drive_mode_screen.dart';
import 'package:driveawake/screens/navigation_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets(
    'returning from Google Maps handoff stays paused until explicit resume',
    (tester) async {
      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
      final resources = _WidgetResources();
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.dark(),
          home: DriveModeScreen(sessionResources: resources),
        ),
      );
      await tester.pump();
      await tester.tap(find.byTooltip('Paradas'));
      await tester.pump();
      expect(resources.pauseCalls, 0);
      await tester.tap(find.text('Estoy detenido'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));
      expect(find.byType(NavigationScreen), findsOneWidget);
      await tester.pageBack();
      await tester.pump(const Duration(milliseconds: 400));
      expect(resources.startCalls, 1);
      // Multiple safety surfaces report the paused state. Hit testing their
      // text depends on the test viewport, not on whether monitoring resumed.
      expect(find.text('MONITOREO PAUSADO'), findsWidgets);
      expect(find.text('Monitoreo pausado'), findsOneWidget);
      await tester.ensureVisible(find.text('Google Maps'));
      await tester.tap(find.text('Google Maps'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));
      await tester.pageBack();
      await tester.pump(const Duration(milliseconds: 400));
      expect(resources.startCalls, 1);
      expect(find.text('REANUDAR'), findsOneWidget);
      expect(find.text('Monitoreo pausado'), findsOneWidget);
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox());
    },
  );
  testWidgets('cancelling stop confirmation keeps monitoring active', (
    tester,
  ) async {
    final resources = _WidgetResources();
    await tester.pumpWidget(
      MaterialApp(home: DriveModeScreen(sessionResources: resources)),
    );
    await tester.pump();
    await tester.tap(find.byTooltip('Paradas'));
    await tester.pump();
    await tester.tap(find.text('Seguir monitoreando'));
    await tester.pump();
    expect(resources.pauseCalls, 0);
    expect(find.byType(NavigationScreen), findsNothing);
  });
  for (final size in [const Size(390, 844), const Size(740, 360)]) {
    testWidgets('pause controls work with production theme at $size', (
      tester,
    ) async {
      tester.view.physicalSize = size;
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      final resources = _WidgetResources();
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.dark(),
          home: DriveModeScreen(sessionResources: resources),
        ),
      );
      await tester.pump();
      await tester.ensureVisible(find.byTooltip('Pausar'));
      await tester.tap(find.byTooltip('Pausar'));
      await tester.pump();
      expect(tester.takeException(), isNull);
      await tester.ensureVisible(find.text('REANUDAR'));
      await tester.tap(find.text('REANUDAR'));
      await tester.pump();
      await tester.pump(const Duration(seconds: 1));
      await tester.pump(const Duration(seconds: 1));
      await tester.pump(const Duration(seconds: 1));
      expect(resources.startCalls, 2);
      expect(find.text('MONITOREO PAUSADO'), findsNothing);
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox());
    });
  }
  testWidgets('la pantalla observa estado y envia pausa al controlador', (
    tester,
  ) async {
    final resources = _WidgetResources();
    await tester.pumpWidget(
      MaterialApp(home: DriveModeScreen(sessionResources: resources)),
    );
    await tester.pump();
    expect(find.text('DriverAwaken'), findsOneWidget);
    expect(find.byTooltip('Pausar'), findsOneWidget);

    await tester.tap(find.byTooltip('Pausar'));
    await tester.pump();
    expect(resources.pauseCalls, 1);
    expect(find.text('MONITOREO PAUSADO'), findsOneWidget);
    await tester.pumpWidget(const SizedBox());
  });

  testWidgets('estado NORMAL is prohibited when monitoring is unavailable', (
    tester,
  ) async {
    final resources = _WidgetResources();
    await tester.pumpWidget(
      MaterialApp(home: DriveModeScreen(sessionResources: resources)),
    );
    await tester.pump();
    resources.emitUnavailable();
    await tester.pump();

    expect(find.text('MONITOREO NO DISPONIBLE'), findsOneWidget);
    expect(find.text('NORMAL'), findsNothing);
    await tester.pumpWidget(const SizedBox());
  });

  testWidgets('finish requires confirmation and cancel retains the trip', (
    tester,
  ) async {
    final resources = _WidgetResources();
    await tester.pumpWidget(
      MaterialApp(home: DriveModeScreen(sessionResources: resources)),
    );
    await tester.pump();
    await tester.tap(find.byTooltip('Finalizar'));
    await tester.pump(const Duration(milliseconds: 400));
    expect(find.text('Finalizar viaje'), findsOneWidget);
    expect(resources.finishCalls, 0);
    await tester.tap(find.text('CONTINUAR'));
    await tester.pump(const Duration(milliseconds: 400));
    expect(resources.finishCalls, 0);
    await tester.pumpWidget(const SizedBox());
  });

  testWidgets(
    'compact landscape layout keeps primary controls visible without overflow',
    (tester) async {
      tester.view.physicalSize = const Size(740, 360);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      await tester.pumpWidget(
        MaterialApp(
          home: DriveModeScreen(sessionResources: _WidgetResources()),
        ),
      );
      await tester.pump();
      expect(tester.takeException(), isNull);
      expect(find.byTooltip('Finalizar').hitTestable(), findsOneWidget);
      await tester.pumpWidget(const SizedBox());
    },
  );
}

class _WidgetResources extends ChangeNotifier implements DriveSessionResources {
  DriveState _state = DriveState.idle();
  int pauseCalls = 0;
  int finishCalls = 0;
  int startCalls = 0;

  @override
  DriveState get resourceState => _state;

  @override
  Future<void> prepare({TripSessionDraft? recoveredDraft}) async {}

  @override
  Future<void> startMonitoring() async {
    startCalls += 1;
    _state = _state.copyWith(
      streamStatus: DriveStreamStatus.streaming,
      monitoringHealth: MonitoringHealth.healthy,
    );
    notifyListeners();
  }

  @override
  Future<void> pauseMonitoring() async {
    pauseCalls += 1;
    _state = _state.copyWith(
      streamStatus: DriveStreamStatus.stopped,
      alarmStatus: DriveAlarmStatus.silent,
    );
    notifyListeners();
  }

  void emitUnavailable() {
    _state = _state.copyWith(
      monitoringHealth: MonitoringHealth.unavailable,
      technicalReason: 'No se reciben frames válidos.',
    );
    notifyListeners();
  }

  @override
  Future<void> acknowledgeDanger() async {}
  @override
  Future<void> discardMonitoring() async {}
  @override
  Future<void> disposeResources() async {}
  @override
  Future<void> startCalibration() async {}

  @override
  Future<TripSessionSummary> finishMonitoring() {
    finishCalls += 1;
    throw UnimplementedError();
  }
}
