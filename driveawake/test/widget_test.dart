import 'package:driveawake/app/app.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('shows DriverAwake dashboard home screen', (tester) async {
    await tester.pumpWidget(const AppConductoresApp());

    expect(find.text('MONITOREO EN VIVO'), findsOneWidget);
    expect(find.text('INICIAR VIAJE'), findsOneWidget);
    expect(find.text('HISTORIAL'), findsOneWidget);
    expect(find.text('AJUSTES'), findsOneWidget);
  });
}
