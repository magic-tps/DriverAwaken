import '../l10n/app_strings.dart';
import '../l10n/localized_text.dart';
import 'dart:async';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';

import '../features/drive/application/drive_session_controller.dart';
import '../features/drive/application/drive_state.dart';
import '../features/drive/application/monitoring_watchdog.dart';
import '../features/drive/infrastructure/flutter_drive_session_resources.dart';
import '../models/drowsiness_state.dart';
import '../models/trip_session_draft.dart';
import '../widgets/alert_overlay.dart';
import '../widgets/debug_metrics_panel.dart';
import '../widgets/status_card.dart';
import 'trip_summary_screen.dart';

class DriveModeScreen extends StatefulWidget {
  const DriveModeScreen({
    super.key,
    this.recoveredDraft,
    this.sessionResources,
  });

  final TripSessionDraft? recoveredDraft;
  final DriveSessionResources? sessionResources;

  @override
  State<DriveModeScreen> createState() => _DriveModeScreenState();
}

class _DriveModeScreenState extends State<DriveModeScreen>
    with WidgetsBindingObserver {
  late final DriveSessionResources _resources;
  late final DriveSessionController _controller;
  bool _completionHandled = false;

  DriveState get _driveState => _controller.state;
  DrowsinessState get _monitoring => _driveState.monitoring;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _resources = widget.sessionResources ?? FlutterDriveSessionResources();
    _controller = DriveSessionController(resources: _resources)
      ..addListener(_onControllerChanged);
    unawaited(_controller.start(recoveredDraft: widget.recoveredDraft));
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.inactive ||
        state == AppLifecycleState.paused) {
      unawaited(_controller.appMovedToBackground());
    }
  }

  void _onControllerChanged() {
    if (!mounted) return;
    setState(() {});
    if (_driveState.phase == DriveSessionPhase.completed &&
        !_completionHandled) {
      _completionHandled = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        final summary = _driveState.summary;
        if (summary == null) {
          Navigator.of(context).pop();
        } else {
          unawaited(
            Navigator.of(context).pushReplacement(
              MaterialPageRoute<void>(
                builder: (_) => TripSummaryScreen(
                  summary: summary,
                  technicalReport: _driveState.technicalReport,
                ),
              ),
            ),
          );
        }
      });
    }
  }

  Future<void> _togglePause() async {
    if (_driveState.paused ||
        _driveState.phase == DriveSessionPhase.recoverableError) {
      await _controller.resume();
    } else {
      await _controller.pause();
    }
  }

  Future<void> _startCalibration() async {
    await _controller.startCalibration();
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: LocalizedText('Calibracion guiada iniciada')),
    );
  }

  Future<void> _showMetrics() async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _MetricsSheet(driveState: _driveState),
    );
  }

  Future<void> _confirmExit() async {
    final action = await showDialog<_ExitAction>(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const LocalizedText('Finalizar viaje'),
        content: const LocalizedText(
          'El monitoreo sigue activo. Puedes continuar, guardar el viaje o descartarlo.',
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () =>
                Navigator.of(context).pop(_ExitAction.continueTrip),
            child: const LocalizedText('CONTINUAR'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(_ExitAction.discard),
            child: const LocalizedText('DESCARTAR'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(_ExitAction.finish),
            child: const LocalizedText('GUARDAR'),
          ),
        ],
      ),
    );
    if (!mounted || action == null || action == _ExitAction.continueTrip) {
      return;
    }
    if (action == _ExitAction.discard) {
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const LocalizedText('Descartar definitivamente'),
          content: const LocalizedText(
            'Se eliminaran el borrador y todos los eventos asociados a este viaje.',
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const LocalizedText('CANCELAR'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const LocalizedText('DESCARTAR'),
            ),
          ],
        ),
      );
      if (confirmed == true) await _controller.finish(discard: true);
      return;
    }
    await _controller.finish(discard: false);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _controller
      ..removeListener(_onControllerChanged)
      ..dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = _driveState;
    final controller = state.cameraController;
    final cameraReady = state.cameraReady && controller != null;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) unawaited(_confirmExit());
      },
      child: Scaffold(
        backgroundColor: const Color(0xFF050708),
        body: Stack(
          fit: StackFit.expand,
          children: <Widget>[
            const _DriveBackdrop(),
            SafeArea(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(14, 10, 14, 14),
                child: state.phase == DriveSessionPhase.fatalError
                    ? _ErrorView(
                        message: state.fatalError ?? 'Error fatal de sesion',
                        onBack: () => Navigator.of(context).pop(),
                      )
                    : Column(
                        children: <Widget>[
                          _DriveTopBar(
                            paused: state.paused,
                            onShowMetrics: () => unawaited(_showMetrics()),
                          ),
                          const SizedBox(height: 10),
                          if (state.monitoringHealth !=
                                  MonitoringHealth.unavailable &&
                              state.monitoringHealth !=
                                  MonitoringHealth.recovering)
                            StatusCard(state: _monitoring),
                          const SizedBox(height: 8),
                          _MonitoringHealthBar(state: state),
                          const SizedBox(height: 12),
                          Expanded(
                            child: cameraReady
                                ? _CameraViewfinder(
                                    controller: controller,
                                    state: _monitoring,
                                  )
                                : _LoadingPanel(
                                    message: state.recoverableError,
                                  ),
                          ),
                          const SizedBox(height: 10),
                          _ActionBar(
                            paused: state.paused,
                            busy: state.transitionInProgress,
                            onCalibrate: () => unawaited(_startCalibration()),
                            onPauseResume: () => unawaited(_togglePause()),
                            onFinish: () =>
                                unawaited(_controller.finish(discard: false)),
                          ),
                        ],
                      ),
              ),
            ),
            if (_monitoring.calibrationInProgress)
              _CalibrationOverlay(state: _monitoring),
            if (state.paused || state.phase == DriveSessionPhase.resuming)
              _PausedOverlay(
                countdown: state.resumeCountdown,
                onResume: () => unawaited(_controller.resume()),
                onFinish: () => unawaited(_controller.finish(discard: false)),
              ),
            AlertOverlay(
              visible:
                  state.phase == DriveSessionPhase.active &&
                  state.monitoringHealth != MonitoringHealth.unavailable &&
                  state.monitoringHealth != MonitoringHealth.recovering &&
                  _monitoring.level == DrowsinessLevel.danger &&
                  state.alarmStatus != DriveAlarmStatus.acknowledged,
              tier: _monitoring.alertTier,
              onAcknowledge: () => unawaited(_controller.acknowledgeDanger()),
            ),
            if (state.phase == DriveSessionPhase.active &&
                state.monitoringHealth == MonitoringHealth.unavailable)
              _UnavailableOverlay(
                onFinish: () => unawaited(_controller.finish(discard: false)),
              ),
          ],
        ),
      ),
    );
  }
}

enum _ExitAction { continueTrip, finish, discard }

class _DriveBackdrop extends StatelessWidget {
  const _DriveBackdrop();
  @override
  Widget build(BuildContext context) => const DecoratedBox(
    decoration: BoxDecoration(
      gradient: LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: <Color>[
          Color(0xFF081114),
          Color(0xFF050708),
          Color(0xFF0C0E11),
        ],
      ),
    ),
  );
}

class _DriveTopBar extends StatelessWidget {
  const _DriveTopBar({required this.paused, required this.onShowMetrics});
  final bool paused;
  final VoidCallback onShowMetrics;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.fromLTRB(12, 8, 8, 8),
    decoration: BoxDecoration(
      color: Colors.black.withValues(alpha: 0.44),
      borderRadius: BorderRadius.circular(8),
      border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
    ),
    child: Row(
      children: <Widget>[
        const Icon(Icons.health_and_safety_rounded, color: Color(0xFF24D17E)),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              const LocalizedText(
                'Modo conduccion',
                style: TextStyle(fontWeight: FontWeight.w900, fontSize: 15),
              ),
              LocalizedText(
                paused ? 'Viaje pausado' : 'Camara frontal - IA local',
                style: const TextStyle(color: Colors.white54, fontSize: 12),
              ),
            ],
          ),
        ),
        IconButton.filledTonal(
          tooltip: context.tr('Ver metricas'),
          onPressed: onShowMetrics,
          icon: const Icon(Icons.monitor_heart_outlined),
        ),
      ],
    ),
  );
}

class _CameraViewfinder extends StatelessWidget {
  const _CameraViewfinder({required this.controller, required this.state});
  final CameraController controller;
  final DrowsinessState state;

  @override
  Widget build(BuildContext context) {
    final color = switch (state.level) {
      DrowsinessLevel.normal => const Color(0xFF24D17E),
      DrowsinessLevel.warning => const Color(0xFFFFA726),
      DrowsinessLevel.danger => const Color(0xFFFF3B30),
    };
    return Container(
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.8), width: 1.6),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(7),
        child: Stack(
          fit: StackFit.expand,
          children: <Widget>[
            _CameraPreviewCover(controller: controller),
            Center(
              child: Container(
                width: 190,
                height: 240,
                decoration: BoxDecoration(
                  border: Border.all(color: color, width: 2),
                  borderRadius: BorderRadius.circular(100),
                ),
              ),
            ),
            Positioned(
              left: 12,
              top: 12,
              child: _Chip(label: 'Frontal', color: Colors.white),
            ),
            Positioned(
              right: 12,
              top: 12,
              child: _Chip(
                label: state.faceDetected ? 'Rostro OK' : 'Sin rostro',
                color: state.faceDetected ? color : const Color(0xFFFFA726),
              ),
            ),
            Positioned(
              left: 12,
              right: 12,
              bottom: 12,
              child: Container(
                padding: const EdgeInsets.all(10),
                color: Colors.black.withValues(alpha: 0.68),
                child: LocalizedText(
                  state.faceDetected
                      ? state.message
                      : 'Alinea tu rostro dentro del marco',
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontWeight: FontWeight.w800),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CameraPreviewCover extends StatelessWidget {
  const _CameraPreviewCover({required this.controller});
  final CameraController controller;
  @override
  Widget build(BuildContext context) {
    final size = controller.value.previewSize;
    if (size == null) return const ColoredBox(color: Colors.black);
    final portrait = MediaQuery.orientationOf(context) == Orientation.portrait;
    return ClipRect(
      child: FittedBox(
        fit: BoxFit.cover,
        child: SizedBox(
          width: portrait ? size.height : size.width,
          height: portrait ? size.width : size.height,
          child: Transform(
            alignment: Alignment.center,
            transform: Matrix4.diagonal3Values(-1, 1, 1),
            child: CameraPreview(controller),
          ),
        ),
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  const _Chip({required this.label, required this.color});
  final String label;
  final Color color;
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
    decoration: BoxDecoration(
      color: Colors.black.withValues(alpha: 0.7),
      borderRadius: BorderRadius.circular(8),
      border: Border.all(color: color.withValues(alpha: 0.4)),
    ),
    child: LocalizedText(
      label,
      style: TextStyle(color: color, fontWeight: FontWeight.w800),
    ),
  );
}

class _MonitoringHealthBar extends StatelessWidget {
  const _MonitoringHealthBar({required this.state});
  final DriveState state;
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(10),
    decoration: BoxDecoration(
      color: Colors.black.withValues(alpha: 0.52),
      borderRadius: BorderRadius.circular(8),
    ),
    child: Row(
      children: <Widget>[
        Icon(_icon, color: _color),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              LocalizedText(
                _label,
                style: const TextStyle(fontWeight: FontWeight.w900),
              ),
              if (state.technicalReason != null)
                LocalizedText(
                  state.technicalReason!,
                  style: const TextStyle(color: Colors.white70, fontSize: 12),
                ),
            ],
          ),
        ),
      ],
    ),
  );

  String get _label => switch (state.monitoringHealth) {
    MonitoringHealth.healthy => 'Monitoreo disponible',
    MonitoringHealth.degraded => 'Precisión posiblemente reducida',
    MonitoringHealth.recovering => 'Recuperando monitoreo',
    MonitoringHealth.unavailable => 'Monitoreo no disponible',
  };
  IconData get _icon => switch (state.monitoringHealth) {
    MonitoringHealth.healthy => Icons.check_circle,
    MonitoringHealth.degraded => Icons.warning_amber_rounded,
    MonitoringHealth.recovering => Icons.sync,
    MonitoringHealth.unavailable => Icons.videocam_off,
  };
  Color get _color => switch (state.monitoringHealth) {
    MonitoringHealth.healthy => const Color(0xFF24D17E),
    MonitoringHealth.degraded => const Color(0xFFFFA726),
    MonitoringHealth.recovering => const Color(0xFF42A5F5),
    MonitoringHealth.unavailable => const Color(0xFFFF3B30),
  };
}

class _ActionBar extends StatelessWidget {
  const _ActionBar({
    required this.paused,
    required this.busy,
    required this.onCalibrate,
    required this.onPauseResume,
    required this.onFinish,
  });
  final bool paused;
  final bool busy;
  final VoidCallback onCalibrate;
  final VoidCallback onPauseResume;
  final VoidCallback onFinish;
  @override
  Widget build(BuildContext context) => Row(
    children: <Widget>[
      Expanded(
        child: OutlinedButton.icon(
          onPressed: busy ? null : onCalibrate,
          icon: const Icon(Icons.tune),
          label: const LocalizedText('Calibrar'),
        ),
      ),
      const SizedBox(width: 8),
      Expanded(
        child: OutlinedButton.icon(
          onPressed: busy ? null : onPauseResume,
          icon: Icon(paused ? Icons.play_arrow : Icons.pause),
          label: LocalizedText(paused ? 'Reanudar' : 'Pausar'),
        ),
      ),
      const SizedBox(width: 8),
      Expanded(
        child: FilledButton.icon(
          onPressed: busy ? null : onFinish,
          icon: const Icon(Icons.stop),
          label: const LocalizedText('Finalizar'),
        ),
      ),
    ],
  );
}

class _LoadingPanel extends StatelessWidget {
  const _LoadingPanel({this.message});
  final String? message;
  @override
  Widget build(BuildContext context) => Center(
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        if (message == null)
          const CircularProgressIndicator()
        else
          const Icon(Icons.videocam_off, size: 48, color: Color(0xFFFFA726)),
        const SizedBox(height: 12),
        LocalizedText(
          message ?? 'Iniciando monitoreo',
          textAlign: TextAlign.center,
        ),
      ],
    ),
  );
}

class _PausedOverlay extends StatelessWidget {
  const _PausedOverlay({
    required this.countdown,
    required this.onResume,
    required this.onFinish,
  });
  final int? countdown;
  final VoidCallback onResume;
  final VoidCallback onFinish;
  @override
  Widget build(BuildContext context) => Positioned.fill(
    child: ColoredBox(
      color: const Color(0xEB050708),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Icon(
              countdown == null ? Icons.pause_circle : Icons.timer,
              size: 72,
            ),
            const SizedBox(height: 18),
            LocalizedText(
              countdown == null
                  ? 'MONITOREO PAUSADO'
                  : 'REANUDANDO EN $countdown',
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 22),
            if (countdown == null)
              Row(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  FilledButton.icon(
                    onPressed: onResume,
                    icon: const Icon(Icons.play_arrow),
                    label: const LocalizedText('REANUDAR'),
                  ),
                  const SizedBox(width: 10),
                  OutlinedButton.icon(
                    onPressed: onFinish,
                    icon: const Icon(Icons.stop),
                    label: const LocalizedText('FINALIZAR'),
                  ),
                ],
              ),
          ],
        ),
      ),
    ),
  );
}

class _UnavailableOverlay extends StatelessWidget {
  const _UnavailableOverlay({required this.onFinish});
  final VoidCallback onFinish;

  @override
  Widget build(BuildContext context) => Positioned.fill(
    child: ColoredBox(
      color: const Color(0xF2050708),
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              const Icon(
                Icons.videocam_off,
                size: 72,
                color: Color(0xFFFF3B30),
              ),
              const SizedBox(height: 18),
              const LocalizedText(
                'MONITOREO NO DISPONIBLE',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900),
              ),
              const SizedBox(height: 12),
              const LocalizedText(
                'No se están recibiendo datos confiables.\nDetente en un lugar seguro y revisa la cámara.',
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              FilledButton.icon(
                onPressed: onFinish,
                icon: const Icon(Icons.stop),
                label: const LocalizedText('FINALIZAR VIAJE'),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}

class _CalibrationOverlay extends StatelessWidget {
  const _CalibrationOverlay({required this.state});
  final DrowsinessState state;
  @override
  Widget build(BuildContext context) => Positioned.fill(
    child: ColoredBox(
      color: Colors.black87,
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              const Icon(
                Icons.center_focus_strong,
                size: 64,
                color: Color(0xFF24D17E),
              ),
              const SizedBox(height: 18),
              LocalizedText(
                state.calibrationInstruction,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 18),
              LinearProgressIndicator(value: state.calibrationProgress),
            ],
          ),
        ),
      ),
    ),
  );
}

class _MetricsSheet extends StatelessWidget {
  const _MetricsSheet({required this.driveState});
  final DriveState driveState;
  @override
  Widget build(BuildContext context) => Container(
    height: MediaQuery.sizeOf(context).height * 0.72,
    padding: const EdgeInsets.fromLTRB(14, 12, 14, 18),
    decoration: const BoxDecoration(
      color: Color(0xFF101416),
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    child: Column(
      children: <Widget>[
        Row(
          children: <Widget>[
            const Expanded(
              child: LocalizedText(
                'Metricas tecnicas',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900),
              ),
            ),
            IconButton(
              onPressed: () => Navigator.of(context).pop(),
              icon: const Icon(Icons.close),
            ),
          ],
        ),
        Expanded(
          child: SingleChildScrollView(
            child: Column(
              children: <Widget>[
                DebugMetricsPanel(state: driveState.monitoring),
                const SizedBox(height: 12),
                _TechnicalPerformance(state: driveState),
              ],
            ),
          ),
        ),
      ],
    ),
  );
}

class _TechnicalPerformance extends StatelessWidget {
  const _TechnicalPerformance({required this.state});
  final DriveState state;

  @override
  Widget build(BuildContext context) => Card(
    child: Padding(
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          const LocalizedText(
            'Observabilidad',
            style: TextStyle(fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 8),
          LocalizedText('Salud: ${state.monitoringHealth.name}'),
          LocalizedText('FPS real: ${state.actualFps.toStringAsFixed(1)}'),
          LocalizedText('Frames descartados: ${state.framesDropped}'),
          LocalizedText('P95 total: ${state.totalP95Ms.toStringAsFixed(1)} ms'),
          LocalizedText('Intentos de recuperación: ${state.recoveryAttempts}'),
        ],
      ),
    ),
  );
}

class _ErrorView extends StatelessWidget {
  const _ErrorView({required this.message, required this.onBack});
  final String message;
  final VoidCallback onBack;
  @override
  Widget build(BuildContext context) => Center(
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        const Icon(Icons.error_outline, color: Color(0xFFFF3B30), size: 56),
        const SizedBox(height: 16),
        LocalizedText(message, textAlign: TextAlign.center),
        const SizedBox(height: 20),
        FilledButton(onPressed: onBack, child: const LocalizedText('VOLVER')),
      ],
    ),
  );
}
