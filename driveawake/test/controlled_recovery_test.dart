import 'dart:async';

import 'package:driveawake/features/drive/application/controlled_recovery.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const recovery = ControlledRecovery(
    maximumAttempts: 3,
    initialBackoff: Duration(milliseconds: 100),
  );

  test('successful recovery stops after first valid attempt', () async {
    final attempts = <int>[];
    final outcome = await recovery.run(
      isCancelled: () => false,
      attempt: (number, _) async {
        attempts.add(number);
        return number == 2;
      },
    );

    expect(outcome, RecoveryOutcome.recovered);
    expect(attempts, <int>[1, 2]);
  });

  test('exhausted recovery is limited and uses growing backoff', () async {
    final backoffs = <Duration>[];
    final outcome = await recovery.run(
      isCancelled: () => false,
      attempt: (_, backoff) async {
        backoffs.add(backoff);
        return false;
      },
    );

    expect(outcome, RecoveryOutcome.exhausted);
    expect(backoffs, const <Duration>[
      Duration(milliseconds: 100),
      Duration(milliseconds: 200),
      Duration(milliseconds: 300),
    ]);
  });

  test('pause during recovery invalidates the pending generation', () async {
    var cancelled = false;
    final attemptStarted = Completer<void>();
    final releaseAttempt = Completer<void>();
    final operation = recovery.run(
      isCancelled: () => cancelled,
      attempt: (_, _) async {
        attemptStarted.complete();
        await releaseAttempt.future;
        return true;
      },
    );
    await attemptStarted.future;
    cancelled = true;
    releaseAttempt.complete();

    expect(await operation, RecoveryOutcome.cancelled);
  });

  test('background before recovery prevents camera attempt', () async {
    var attempts = 0;
    final outcome = await recovery.run(
      isCancelled: () => true,
      attempt: (_, _) async {
        attempts++;
        return true;
      },
    );

    expect(outcome, RecoveryOutcome.cancelled);
    expect(attempts, 0);
  });

  test('finish during recovery prevents further attempts', () async {
    var finished = false;
    var attempts = 0;
    final outcome = await recovery.run(
      isCancelled: () => finished,
      attempt: (_, _) async {
        attempts++;
        finished = true;
        return false;
      },
    );

    expect(outcome, RecoveryOutcome.cancelled);
    expect(attempts, 1);
  });
}
