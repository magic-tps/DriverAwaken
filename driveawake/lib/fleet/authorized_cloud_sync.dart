import 'dart:async';
import '../data/database/driver_awake_database.dart';
import 'local_outbox.dart';

typedef FleetSender = Future<void> Function(FleetOutboxData row);

/// A single worker; FIFO keeps terminal trip status behind incident delivery.
class AuthorizedCloudSync {
  AuthorizedCloudSync({
    required this.outbox,
    required this.send,
    required this.authorized,
    DateTime Function()? clock,
  }) : clock = clock ?? DateTime.now;
  final LocalOutbox outbox;
  final FleetSender send;
  final Future<bool> Function(FleetOutboxData) authorized;
  final DateTime Function() clock;
  bool _busy = false;

  Future<void> flush(String ownerId) async {
    if (_busy) return;
    _busy = true;
    try {
      final rows = await outbox.pending(ownerId);
      for (final row in rows.take(10)) {
        if (row.nextAttemptAt.isAfter(clock())) break;
        if (!await authorized(row)) break;
        if (!await outbox.stillPending(row.id)) continue;
        await outbox.mark(row.id, 'SYNCING', clock());
        try {
          await send(row).timeout(const Duration(seconds: 15));
          await outbox.mark(row.id, 'SYNCED', clock());
        } catch (error) {
          await outbox.failed(
            row,
            clock(),
            error is TimeoutException ? 'TIMEOUT' : 'DELIVERY_FAILED',
          );
          break;
        }
      }
    } finally {
      _busy = false;
    }
  }
}
