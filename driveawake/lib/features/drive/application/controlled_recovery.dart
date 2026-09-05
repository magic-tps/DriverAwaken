import 'dart:async';

enum RecoveryOutcome { recovered, exhausted, cancelled }

typedef RecoveryAttempt = Future<bool> Function(int attempt, Duration backoff);

class ControlledRecovery {
  const ControlledRecovery({
    required this.maximumAttempts,
    required this.initialBackoff,
  }) : assert(maximumAttempts > 0);

  final int maximumAttempts;
  final Duration initialBackoff;

  Future<RecoveryOutcome> run({
    required bool Function() isCancelled,
    required RecoveryAttempt attempt,
  }) async {
    for (var number = 1; number <= maximumAttempts; number++) {
      if (isCancelled()) return RecoveryOutcome.cancelled;
      final recovered = await attempt(
        number,
        Duration(
          microseconds: initialBackoff.inMicroseconds * number.clamp(1, 8),
        ),
      );
      if (isCancelled()) return RecoveryOutcome.cancelled;
      if (recovered) return RecoveryOutcome.recovered;
    }
    return isCancelled()
        ? RecoveryOutcome.cancelled
        : RecoveryOutcome.exhausted;
  }
}
