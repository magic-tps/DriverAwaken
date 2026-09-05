import 'package:driveawake/services/alert_service.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('cooldown evita disparos repetidos', () {
    final gate = AlertCooldownGate(cooldown: const Duration(seconds: 5));
    final start = DateTime(2026);

    expect(gate.canFire(start), isTrue);
    expect(gate.canFire(start.add(const Duration(seconds: 2))), isFalse);
    expect(gate.canFire(start.add(const Duration(seconds: 6))), isTrue);
  });
}
