import 'package:driveawake/models/app_settings.dart';
import 'package:driveawake/models/drowsiness_state.dart';
import 'package:driveawake/models/ml_prediction.dart';
import 'package:driveawake/services/drowsiness_engine.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  DrowsinessSignalSnapshot signal({
    required DateTime timestamp,
    bool eyesClosed = false,
    bool yawning = false,
    double perclos = 0,
    bool perclosReady = true,
    int yawnCountWindow = 0,
    Duration closedEyeDuration = Duration.zero,
    Duration noFaceDuration = Duration.zero,
    Duration headDownDuration = Duration.zero,
    Duration distractedDuration = Duration.zero,
    bool lowLight = false,
    double signalQuality = 0.9,
    MlPrediction? prediction,
  }) {
    return DrowsinessSignalSnapshot(
      timestamp: timestamp,
      settings: AppSettings.defaults(),
      modelEnabled: true,
      eyesClosed: eyesClosed,
      yawning: yawning,
      perclosReady: perclosReady,
      perclos: perclos,
      yawnCountWindow: yawnCountWindow,
      closedEyeDuration: closedEyeDuration,
      noFaceDuration: noFaceDuration,
      headDownDuration: headDownDuration,
      distractedDuration: distractedDuration,
      lowLight: lowLight,
      signalQuality: signalQuality,
      prediction: prediction,
    );
  }

  test('ojos cerrados mas de 3 segundos fuerza peligro', () {
    final engine = DrowsinessEngine();
    final decision = engine.evaluate(
      signal(
        timestamp: DateTime(2026),
        eyesClosed: true,
        closedEyeDuration: const Duration(milliseconds: 3200),
      ),
    );

    expect(decision.level, DrowsinessLevel.danger);
    expect(decision.totalRisk, greaterThanOrEqualTo(70));
    expect(decision.alertTier, 3);
  });

  test('modelo somnoliento con baja confianza no decide solo', () {
    final engine = DrowsinessEngine();
    final decision = engine.evaluate(
      signal(
        timestamp: DateTime(2026),
        prediction: const MlPrediction(
          predictedClass: 2,
          confidence: 0.45,
          awakeProbability: 0.30,
          fatigueProbability: 0.25,
          drowsyProbability: 0.45,
        ),
      ),
    );

    expect(decision.level, isNot(DrowsinessLevel.danger));
  });

  test('modelo con confianza alta suma riesgo sin saltar a peligro solo', () {
    final engine = DrowsinessEngine();
    var now = DateTime(2026);
    RiskDecision decision = engine.evaluate(
      signal(timestamp: now, prediction: null),
    );

    for (var i = 0; i < 6; i++) {
      now = now.add(const Duration(seconds: 1));
      decision = engine.evaluate(
        signal(
          timestamp: now,
          prediction: const MlPrediction(
            predictedClass: 2,
            confidence: 0.86,
            awakeProbability: 0.04,
            fatigueProbability: 0.10,
            drowsyProbability: 0.86,
          ),
        ),
      );
    }

    expect(decision.level, DrowsinessLevel.warning);
    expect(decision.totalRisk, lessThan(70));
  });

  test('mala iluminacion no genera peligro por si sola', () {
    final engine = DrowsinessEngine();
    final decision = engine.evaluate(
      signal(timestamp: DateTime(2026), lowLight: true, signalQuality: 0.2),
    );

    expect(decision.level, isNot(DrowsinessLevel.danger));
    expect(decision.message, contains('Iluminacion'));
  });
  test('sin rostro no infiere somnolencia incluso después de peligro', () {
    final engine = DrowsinessEngine();
    engine.evaluate(
      signal(
        timestamp: DateTime(2026),
        eyesClosed: true,
        closedEyeDuration: const Duration(seconds: 4),
      ),
    );
    final decision = engine.evaluate(
      signal(
        timestamp: DateTime(2026, 1, 1, 0, 0, 5),
        noFaceDuration: const Duration(seconds: 5),
        signalQuality: 0,
        perclos: .9,
      ),
    );
    expect(decision.level, DrowsinessLevel.normal);
    expect(decision.totalRisk, 0);
    expect(decision.alertTier, 0);
    expect(decision.reason, 'SIGNAL_UNAVAILABLE');
  });
}
