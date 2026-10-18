import 'dart:async';

import 'package:driveawake/app/app_theme.dart';
import 'package:driveawake/screens/trip_preparation_screen.dart';
import 'package:driveawake/services/trip_permission_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('preparation asks for camera and optional microphone only', (
    tester,
  ) async {
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
    final order = <String>[];
    final permissions = _Permissions(order)..cameraGate.complete(true);
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.dark(),
        home: TripPreparationScreen(permissions: permissions),
      ),
    );
    expect(find.text('Sin permiso de ubicación'), findsOneWidget);
    await tester.tap(find.text('Autorizar y preparar'));
    await tester.pumpAndSettle();
    expect(order, ['camera', 'microphone']);
    expect(find.text('Iniciar viaje'), findsOneWidget);
  });

  testWidgets('camera denial never enables trip entry', (tester) async {
    final order = <String>[];
    final permissions = _Permissions(order)..cameraGate.complete(false);
    await tester.pumpWidget(
      MaterialApp(home: TripPreparationScreen(permissions: permissions)),
    );
    await tester.tap(find.text('Autorizar y preparar'));
    await tester.pumpAndSettle();
    expect(order, ['camera']);
    expect(find.text('Iniciar viaje'), findsNothing);
    expect(find.text('Abrir ajustes de permisos'), findsOneWidget);
  });
}

class _Permissions extends TripPermissionService {
  _Permissions(this.order);

  final List<String> order;
  final cameraGate = Completer<bool>();

  @override
  Future<bool> camera() {
    order.add('camera');
    return cameraGate.future;
  }

  @override
  Future<bool> microphone() async {
    order.add('microphone');
    return false;
  }
}
