import 'package:driveawake/features/drive/application/drive_session_controller.dart';
import 'package:driveawake/features/drive/application/drive_state.dart';
import 'package:driveawake/features/drive/application/monitoring_watchdog.dart';
import 'package:driveawake/models/trip_session_draft.dart';
import 'package:driveawake/models/trip_session_summary.dart';
import 'package:driveawake/screens/drive_mode_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('la pantalla observa estado y envia pausa al controlador', (
    tester,
  ) async {
    final resources = _WidgetResources();
    await tester.pumpWidget(
      MaterialApp(home: DriveModeScreen(sessionResources: resources)),
    );
    await tester.pump();
    expect(find.text('Modo conduccion'), findsOneWidget);
    expect(find.text('Pausar'), findsOneWidget);

    await tester.tap(find.text('Pausar'));
    await tester.pump();
    expect(resources.pauseCalls, 1);
    expect(find.text('MONITOREO PAUSADO'), findsOneWidget);
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
  });
}

class _WidgetResources extends ChangeNotifier implements DriveSessionResources {
  DriveState _state = DriveState.idle();
  int pauseCalls = 0;

  @override
  DriveState get resourceState => _state;

  @override
  Future<void> prepare({TripSessionDraft? recoveredDraft}) async {}

  @override
  Future<void> startMonitoring() async {
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
    throw UnimplementedError();
  }
}
