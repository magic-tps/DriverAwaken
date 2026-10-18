import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:driveawake/app/app_theme.dart';
import 'package:driveawake/widgets/copilot_panel.dart';
import 'package:driveawake/navigation/conversation_engine.dart';
import 'package:driveawake/models/drowsiness_state.dart';

void main() {
  for (final size in [const Size(390, 844), const Size(740, 360)]) {
    testWidgets('copilot panel is scrollable without overflow at $size', (
      tester,
    ) async {
      tester.view.physicalSize = size;
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.dark(),
          home: Scaffold(
            body: CopilotPanel(
              contextProvider: () => ConversationContext(
                monitoring: DrowsinessState.initial(),
                paused: true,
                reliable: false,
                driving: Duration.zero,
              ),
              onAction: (_) async {},
            ),
          ),
        ),
      );
      expect(find.text('Tu copiloto'), findsOneWidget);
      await tester.ensureVisible(find.text('Conversa conmigo'));
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox());
      await tester.pump();
      expect(tester.takeException(), isNull);
    });
  }
}
