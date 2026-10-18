import 'package:flutter/foundation.dart';

import '../../../models/trip_session_draft.dart';
import '../../../models/trip_session_summary.dart';
import 'drive_ports.dart';
import 'drive_state.dart';

abstract interface class DriveSessionResources implements Listenable {
  DriveState get resourceState;
  Future<void> prepare({TripSessionDraft? recoveredDraft});
  Future<void> startMonitoring();
  Future<void> pauseMonitoring();
  Future<TripSessionSummary> finishMonitoring();
  Future<void> discardMonitoring();
  Future<void> startCalibration();
  Future<void> acknowledgeDanger();
  Future<void> disposeResources();
}

typedef DriveDelay = Future<void> Function(Duration duration);

class DriveSessionController extends ChangeNotifier
    implements LifecycleController {
  DriveSessionController({
    required DriveSessionResources resources,
    DriveDelay delay = Future<void>.delayed,
    Clock clock = const SystemClock(),
    Logger logger = const DebugLogger(),
  }) : _resources = resources,
       _delay = delay,
       _clock = clock,
       _logger = logger {
    _resources.addListener(_synchronizeResourceState);
  }

  final DriveSessionResources _resources;
  final DriveDelay _delay;
  final Clock _clock;
  final Logger _logger;
  DriveState _state = DriveState.idle();
  int _operationGeneration = 0;
  bool _disposed = false;
  Future<void>? _pauseOperation;
  Future<void>? _finishOperation;
  Future<void>? _resumeOperation;
  Future<void>? _startOperation;
  Future<void>? _monitoringStart;

  DriveState get state => _state;

  Future<void> start({TripSessionDraft? recoveredDraft}) =>
      _startOperation ??= _startOnce(
        recoveredDraft: recoveredDraft,
      ).whenComplete(() => _startOperation = null);

  Future<void> _startOnce({TripSessionDraft? recoveredDraft}) async {
    if (_state.phase != DriveSessionPhase.idle) return;
    final generation = ++_operationGeneration;
    _emit(_state.copyWith(phase: DriveSessionPhase.starting));
    try {
      await _resources.prepare(recoveredDraft: recoveredDraft);
      if (_disposed || generation != _operationGeneration) return;
      if (recoveredDraft != null) {
        await _resources.pauseMonitoring();
        _emit(
          _resources.resourceState.copyWith(phase: DriveSessionPhase.paused),
        );
        return;
      }
      await _beginMonitoring();
      if (!_disposed && generation == _operationGeneration) {
        _emit(
          _resources.resourceState.copyWith(phase: DriveSessionPhase.active),
        );
      }
    } catch (error, stackTrace) {
      if (_disposed || generation != _operationGeneration) return;
      _logger.error('Fallo al iniciar sesion', error, stackTrace);
      await _safePause();
      _emit(
        _resources.resourceState.copyWith(
          phase: DriveSessionPhase.recoverableError,
          recoverableError: error.toString(),
        ),
      );
    }
  }

  Future<void> pause() => _pauseOperation ??= _pauseOnce().whenComplete(
    () => _pauseOperation = null,
  );

  Future<void> _pauseOnce() async {
    try {
      if (_state.phase == DriveSessionPhase.paused ||
          _state.phase == DriveSessionPhase.completed ||
          _state.phase == DriveSessionPhase.finishing) {
        return;
      }
      _operationGeneration += 1;
      _emit(
        _state.copyWith(phase: DriveSessionPhase.paused, clearCountdown: true),
      );
      await _settleStartup();
      await _resources.pauseMonitoring();
      _emit(
        _resources.resourceState.copyWith(
          phase: DriveSessionPhase.paused,
          clearCountdown: true,
        ),
      );
    } finally {
      _pauseOperation = null;
    }
  }

  Future<void> resume() {
    final pendingPause = _pauseOperation;
    return _resumeOperation ??=
        (pendingPause == null
                ? _resumeOnce()
                : pendingPause.then((_) => _resumeOnce()))
            .whenComplete(() => _resumeOperation = null);
  }

  Future<void> _resumeOnce() async {
    try {
      if (_state.phase != DriveSessionPhase.paused &&
          _state.phase != DriveSessionPhase.recoverableError) {
        return;
      }
      final generation = ++_operationGeneration;
      for (var value = 3; value >= 1; value -= 1) {
        if (generation != _operationGeneration) return;
        _emit(
          _state.copyWith(
            phase: DriveSessionPhase.resuming,
            resumeCountdown: value,
            clearRecoverableError: true,
          ),
        );
        await _delay(const Duration(seconds: 1));
      }
      if (generation != _operationGeneration) return;
      try {
        await _beginMonitoring();
        if (generation == _operationGeneration) {
          _emit(
            _resources.resourceState.copyWith(
              phase: DriveSessionPhase.active,
              clearCountdown: true,
              clearRecoverableError: true,
            ),
          );
        }
      } catch (error, stackTrace) {
        if (_disposed || generation != _operationGeneration) return;
        _logger.error('Fallo al reanudar sesion', error, stackTrace);
        await _safePause();
        _emit(
          _resources.resourceState.copyWith(
            phase: DriveSessionPhase.recoverableError,
            recoverableError: error.toString(),
            clearCountdown: true,
          ),
        );
      }
    } finally {
      _resumeOperation = null;
    }
  }

  Future<void> appMovedToBackground() => movedToBackground();

  Future<void> _beginMonitoring() => _monitoringStart ??= _resources
      .startMonitoring()
      .whenComplete(() => _monitoringStart = null);

  Future<void> _settleStartup() async {
    try {
      await _startOperation;
      await _monitoringStart;
    } catch (_) {
      // The owning start/resume operation reports the error. Cleanup still runs.
    }
  }

  @override
  Future<void> movedToBackground() => pause();

  @override
  void movedToForeground() {}

  Future<void> startCalibration() => _resources.startCalibration();

  Future<void> acknowledgeDanger() => _resources.acknowledgeDanger();

  Future<void> finish({required bool discard}) =>
      _finishOperation ??= _finishOnce(discard: discard);

  Future<void> _finishOnce({required bool discard}) async {
    try {
      if (_state.phase == DriveSessionPhase.finishing ||
          _state.phase == DriveSessionPhase.completed) {
        return;
      }
      _operationGeneration += 1;
      _emit(_state.copyWith(phase: DriveSessionPhase.finishing));
      await _settleStartup();
      if (discard) {
        await _resources.discardMonitoring();
        _emit(
          _resources.resourceState.copyWith(
            phase: DriveSessionPhase.completed,
            clearCountdown: true,
          ),
        );
      } else {
        final summary = await _resources.finishMonitoring();
        _emit(
          _resources.resourceState.copyWith(
            phase: DriveSessionPhase.completed,
            summary: summary,
            clearCountdown: true,
          ),
        );
      }
      _logger.info('Sesion completada ${_clock.now().toIso8601String()}');
    } catch (error, stackTrace) {
      _logger.error('Fallo fatal al finalizar sesion', error, stackTrace);
      _emit(
        _resources.resourceState.copyWith(
          phase: DriveSessionPhase.fatalError,
          fatalError: error.toString(),
        ),
      );
    } finally {
      _finishOperation = null;
    }
  }

  Future<void> _safePause() async {
    try {
      await _resources.pauseMonitoring();
    } catch (error, stackTrace) {
      _logger.warning('Fallo secundario al pausar recursos', error, stackTrace);
    }
  }

  void _synchronizeResourceState() {
    if (_disposed) return;
    final resourceState = _resources.resourceState;
    final phase =
        resourceState.phase == DriveSessionPhase.recoverableError ||
            resourceState.phase == DriveSessionPhase.fatalError
        ? resourceState.phase
        : _state.phase;
    _emit(
      resourceState.copyWith(
        phase: phase,
        resumeCountdown: phase == DriveSessionPhase.resuming
            ? _state.resumeCountdown
            : null,
        clearCountdown: phase != DriveSessionPhase.resuming,
      ),
    );
  }

  void _emit(DriveState value) {
    if (_disposed) return;
    _state = value;
    notifyListeners();
  }

  @override
  void dispose() {
    _operationGeneration += 1;
    _disposed = true;
    _resources.removeListener(_synchronizeResourceState);
    _resources.disposeResources();
    super.dispose();
  }
}
