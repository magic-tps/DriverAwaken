import 'package:driveawake/utils/perclos_tracker.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  PerclosTracker tracker({
    Duration window = const Duration(seconds: 30),
    Duration minimumObserved = Duration.zero,
    double minimumCoverage = 0,
  }) {
    return PerclosTracker(
      window: window,
      minimumValidObservedDuration: minimumObserved,
      minimumValidCoverage: minimumCoverage,
    );
  }

  void addRange(
    PerclosTracker target,
    DateTime start, {
    required int count,
    required bool eyesClosed,
    bool valid = true,
    Duration step = const Duration(milliseconds: 500),
  }) {
    for (var index = 0; index < count; index += 1) {
      target.addSample(
        timestamp: start.add(step * index),
        eyesClosed: eyesClosed,
        valid: valid,
      );
    }
  }

  test('calcula ojos cerrados continuos', () {
    final start = DateTime(2026);
    final target = tracker();
    addRange(target, start, count: 21, eyesClosed: true);

    final snapshot = target.snapshotAt(start.add(const Duration(seconds: 10)));

    expect(snapshot.perclos, 1);
    expect(snapshot.validCoverage, 1);
    expect(snapshot.validObservedDuration, const Duration(seconds: 10));
  });

  test('calcula ojos abiertos continuos', () {
    final start = DateTime(2026);
    final target = tracker();
    addRange(target, start, count: 21, eyesClosed: false);

    expect(target.valueAt(start.add(const Duration(seconds: 10))), 0);
  });

  test('calcula cambio abierto a cerrado ponderado por tiempo', () {
    final start = DateTime(2026);
    final target = tracker();
    addRange(target, start, count: 10, eyesClosed: false);
    addRange(
      target,
      start.add(const Duration(seconds: 5)),
      count: 11,
      eyesClosed: true,
    );

    expect(
      target.valueAt(start.add(const Duration(seconds: 10))),
      closeTo(0.5, 0.01),
    );
  });

  test('rostro ausente rompe el segmento entre muestras validas', () {
    final start = DateTime(2026);
    final target = tracker(window: const Duration(seconds: 30));
    target.addSample(timestamp: start, eyesClosed: true, valid: true);
    for (var second = 1; second < 20; second += 1) {
      target.addSample(
        timestamp: start.add(Duration(seconds: second)),
        eyesClosed: false,
        valid: false,
      );
    }
    target.addSample(
      timestamp: start.add(const Duration(seconds: 20)),
      eyesClosed: false,
      valid: true,
    );

    final snapshot = target.snapshotAt(start.add(const Duration(seconds: 20)));

    expect(snapshot.perclos, 0);
    expect(snapshot.validObservedDuration, Duration.zero);
  });

  test('intervalo superior a 600 ms no se integra', () {
    final start = DateTime(2026);
    final target = tracker();
    target.addSample(timestamp: start, eyesClosed: true, valid: true);
    target.addSample(
      timestamp: start.add(const Duration(milliseconds: 601)),
      eyesClosed: true,
      valid: true,
    );

    expect(target.valueAt(start.add(const Duration(milliseconds: 601))), 0);
    expect(target.validObservedDuration, Duration.zero);
  });

  test('timestamps duplicados o fuera de orden se ignoran', () {
    final start = DateTime(2026);
    final target = tracker();
    target.addSample(timestamp: start, eyesClosed: false, valid: true);
    target.addSample(timestamp: start, eyesClosed: true, valid: true);
    target.addSample(
      timestamp: start.subtract(const Duration(milliseconds: 100)),
      eyesClosed: true,
      valid: true,
    );

    expect(target.sampleCount, 1);
    expect(target.valueAt(start), 0);
  });

  test('tracker vacio devuelve snapshot determinista', () {
    final target = tracker();

    expect(target.snapshotAt(DateTime(2026)), PerclosSnapshot.empty);
    expect(target.isReady, isFalse);
  });

  test('cobertura insuficiente no habilita PERCLOS', () {
    final start = DateTime(2026);
    final target = tracker(
      minimumObserved: const Duration(seconds: 5),
      minimumCoverage: 0.8,
    );
    addRange(target, start, count: 5, eyesClosed: false);
    target.addSample(
      timestamp: start.add(const Duration(seconds: 10)),
      eyesClosed: false,
      valid: false,
    );

    final snapshot = target.snapshotAt(start.add(const Duration(seconds: 10)));

    expect(snapshot.validCoverage, lessThan(0.8));
    expect(snapshot.hasSufficientSignal, isFalse);
    expect(snapshot.validCoverage, inInclusiveRange(0, 1));
  });

  test('reset elimina muestras y estado de suficiencia', () {
    final start = DateTime(2026);
    final target = tracker();
    addRange(target, start, count: 10, eyesClosed: true);
    target.snapshotAt(start.add(const Duration(milliseconds: 4500)));

    target.reset();

    expect(target.sampleCount, 0);
    expect(target.perclos, 0);
    expect(target.validCoverage, 0);
    expect(target.validObservedDuration, Duration.zero);
    expect(target.isReady, isFalse);
  });

  test('pausa y reanudacion pueden reiniciar el tracker', () {
    final start = DateTime(2026);
    final target = tracker();
    addRange(target, start, count: 10, eyesClosed: true);
    target.reset();
    addRange(
      target,
      start.add(const Duration(seconds: 20)),
      count: 10,
      eyesClosed: false,
    );

    expect(target.valueAt(start.add(const Duration(milliseconds: 24500))), 0);
  });
}
