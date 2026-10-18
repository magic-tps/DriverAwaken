import 'package:driveawake/models/drowsiness_state.dart';
import 'package:driveawake/widgets/status_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets(
    'unreliable observation is not presented as normal; reliable critical warning remains',
    (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(body: StatusCard(state: DrowsinessState.initial())),
        ),
      );
      expect(find.text('Señal insuficiente'), findsOneWidget);
      expect(find.text('NORMAL'), findsNothing);
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: StatusCard(
              state: DrowsinessState.initial().copyWith(
                faceDetected: true,
                signalQuality: .9,
                level: DrowsinessLevel.danger,
                riskScore: 96,
                message: 'Se detectó cierre ocular prolongado',
              ),
            ),
          ),
        ),
      );
      expect(find.text('PELIGRO'), findsOneWidget);
      expect(find.text('Se detectó cierre ocular prolongado'), findsOneWidget);
    },
  );
}
