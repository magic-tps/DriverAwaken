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
import '../navigation/rest_recommendation_engine.dart';
import '../navigation/smart_navigation.dart';
import '../services/device_telemetry_service.dart';
import 'navigation_screen.dart';
import 'settings_screen.dart';
import '../services/emergency_service.dart';
import '../services/voice_command_service.dart';
import '../navigation/conversation_engine.dart';
import '../widgets/copilot_panel.dart';

class DriveModeScreen extends StatefulWidget {
  const DriveModeScreen({
    super.key,
    this.recoveredDraft,
    this.sessionResources,
    this.resumeRecovered = false,
  });

  final TripSessionDraft? recoveredDraft;
  final DriveSessionResources? sessionResources;
  final bool resumeRecovered;

  @override
  State<DriveModeScreen> createState() => _DriveModeScreenState();
}

class _DriveModeScreenState extends State<DriveModeScreen>
    with WidgetsBindingObserver {
  late final DriveSessionResources _resources;
  late final DriveSessionController _controller;
  bool _completionHandled = false;
  final VoiceCommandService _commands = VoiceCommandService.instance;
  bool _openingNavigation = false;
  bool _backgroundedDuringStart = false;
  bool _voicePanelOpen = false;

  DriveState get _driveState => _controller.state;
  DrowsinessState get _monitoring => _driveState.monitoring;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _resources = widget.sessionResources ?? FlutterDriveSessionResources();
    _controller = DriveSessionController(resources: _resources)
      ..addListener(_onControllerChanged);
    unawaited(_startPreparedTrip());
  }

  Future<void> _startPreparedTrip() async {
    await _controller.start(recoveredDraft: widget.recoveredDraft);
    unawaited(SmartNavigation.instance.load());
    if (mounted &&
        widget.resumeRecovered &&
        !_backgroundedDuringStart &&
        _driveState.paused &&
        WidgetsBinding.instance.lifecycleState == AppLifecycleState.resumed) {
      await _controller.resume();
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused) {
      _backgroundedDuringStart = true;
      unawaited(_controller.appMovedToBackground());
      unawaited(_commands.stop());
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
      builder: (context) => _MetricsSheet(
        driveState: _driveState,
        onCalibrate: () {
          Navigator.pop(context);
          unawaited(_startCalibration());
        },
      ),
    );
  }

  Future<void> _openSettings() async {
    if (!_driveState.paused) await _controller.pause();
    if (!mounted) return;
    await Navigator.of(
      context,
    ).push(MaterialPageRoute<void>(builder: (_) => const SettingsScreen()));
  }

  Future<void> _voiceControls() async {
    if (_voicePanelOpen) return;
    _voicePanelOpen = true;
    final command = await showModalBottomSheet<VoiceCommand>(
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      builder: (sheetContext) => CopilotPanel(
        contextProvider: () => ConversationContext(
          monitoring: _monitoring,
          paused: _driveState.paused,
          reliable:
              _driveState.monitoringHealth == MonitoringHealth.healthy &&
              _monitoring.faceDetected &&
              _monitoring.signalQuality >= .32,
          driving: SmartNavigation.instance.driving,
        ),
        onAction: (action) async {
          switch (action) {
            case VoiceCommand.pause:
              await _controller.pause();
            case VoiceCommand.resume:
              await _controller.resume();
            case VoiceCommand.rest:
              SmartNavigation.instance.requestRest();
            case VoiceCommand.map:
            case VoiceCommand.sos:
              if (sheetContext.mounted) Navigator.pop(sheetContext, action);
            case VoiceCommand.silence:
            case VoiceCommand.repeat:
            case VoiceCommand.status:
              break;
          }
        },
      ),
    );
    _voicePanelOpen = false;
    await _commands.stop();
    if (!mounted) return;
    if (command == VoiceCommand.map) await _openNavigation();
    if (command == VoiceCommand.sos) await _sos();
  }

  Future<void> _openNavigation() async {
    if (_openingNavigation || _driveState.transitionInProgress) return;
    _openingNavigation = true;
    try {
      if (!_driveState.paused) {
        final stopped = await showDialog<bool>(
          context: context,
          builder: (dialogContext) => AlertDialog(
            title: const Text('¿Vehículo detenido?'),
            content: const Text(
              'Consulta paradas únicamente después de detenerte en un '
              'lugar seguro. DriverAwaken pausará el monitoreo al continuar.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(dialogContext, false),
                child: const Text('Seguir monitoreando'),
              ),
              FilledButton(
                onPressed: () => Navigator.pop(dialogContext, true),
                child: const Text('Estoy detenido'),
              ),
            ],
          ),
        );
        if (!mounted || stopped != true) return;
      }
      if (!_driveState.paused) await _controller.pause();
      if (!mounted) return;
      await Navigator.of(
        context,
      ).push(MaterialPageRoute<void>(builder: (_) => const NavigationScreen()));
    } finally {
      _openingNavigation = false;
    }
  }

  Future<void> _sos() async {
    final emergency = EmergencyService();
    final savedContact = await emergency.contact();
    if (!mounted) return;
    var phone = savedContact;
    var record = false;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, update) => AlertDialog(
          title: const Text('SOS · abrir teléfono'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Se abrirá el marcador para que elijas a quién llamar. No envía ubicación ni contacta automáticamente a emergencias. El monitoreo quedará pausado.',
                ),
                TextFormField(
                  initialValue: savedContact,
                  keyboardType: TextInputType.phone,
                  maxLength: 16,
                  onChanged: (value) => update(() => phone = value.trim()),
                  decoration: const InputDecoration(
                    labelText: 'Contacto de emergencia (opcional)',
                    helperText: 'Solo se guarda en este dispositivo.',
                  ),
                ),
                CheckboxListTile(
                  value: record,
                  onChanged: (value) => update(() => record = value ?? false),
                  title: const Text(
                    'Registrar solicitud manual en el historial local',
                  ),
                ),
                if (_driveState.draft != null)
                  Text('Viaje: ${_driveState.draft!.tripId}'),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancelar'),
            ),
            FilledButton(
              onPressed:
                  phone.isEmpty || RegExp(r'^\+?[0-9]{6,15}$').hasMatch(phone)
                  ? () => Navigator.pop(context, true)
                  : null,
              child: const Text('Abrir marcador'),
            ),
          ],
        ),
      ),
    );
    if (confirmed != true) return;
    await _controller.pause();
    try {
      await emergency.saveContact(phone);
      if (record) {
        await emergency.recordManualIncident(tripId: _driveState.draft?.tripId);
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('No se pudo guardar el contacto o registro local.'),
          ),
        );
      }
    }
    final opened = await DeviceTelemetryService().openDialer(number: phone);
    if (!opened && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'No se pudo abrir el marcador. Usa la función Teléfono del dispositivo.',
          ),
        ),
      );
    }
  }

  Future<void> _confirmExit() async {
    final action = await showDialog<_ExitAction>(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const LocalizedText('Finalizar viaje'),
        content: const LocalizedText(
          'Puedes continuar, guardar el viaje o descartarlo.',
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
    unawaited(_commands.stop());
    _controller
      ..removeListener(_onControllerChanged)
      ..dispose();
    super.dispose();
  }

  Widget _buildMonitoringMap(
    DriveState state,
    CameraController? camera,
    bool cameraReady,
  ) => LayoutBuilder(
    builder: (context, constraints) => Column(
      children: [
        if (constraints.maxHeight > 390)
          _MonitoringMetrics(state: _monitoring, driveState: state),
        const SizedBox(height: 8),
        Expanded(
          child: RepaintBoundary(
            child: Stack(
              fit: StackFit.expand,
              children: [
                if (cameraReady && camera != null)
                  _CameraViewfinder(controller: camera, state: _monitoring)
                else
                  _LoadingPanel(message: state.recoverableError),
                if (!state.paused &&
                    state.phase != DriveSessionPhase.resuming &&
                    state.monitoringHealth != MonitoringHealth.healthy)
                  Positioned(
                    top: 58,
                    left: 8,
                    right: 8,
                    child: _MonitoringHealthBar(state: state),
                  ),
                if (_monitoring.level != DrowsinessLevel.normal &&
                    constraints.maxHeight > 510 &&
                    state.monitoringHealth == MonitoringHealth.healthy &&
                    !state.paused)
                  Positioned(
                    top: 58,
                    left: 8,
                    right: 8,
                    child: StatusCard(state: _monitoring),
                  ),
                if (!state.paused &&
                    SmartNavigation.instance.recommendation != null &&
                    SmartNavigation.instance.recommendation!.reason !=
                        'SIGNAL_UNAVAILABLE')
                  Positioned(
                    left: 8,
                    right: 8,
                    bottom: 8,
                    child: _SmartRestCard(
                      recommendation: SmartNavigation.instance.recommendation!,
                      onOpen: () => unawaited(_openNavigation()),
                    ),
                  ),
                if (state.paused ||
                    state.phase == DriveSessionPhase.resuming ||
                    state.phase == DriveSessionPhase.recoverableError)
                  Positioned(
                    left: 8,
                    right: 8,
                    bottom: 8,
                    child: _PausedOverlay(
                      countdown: state.resumeCountdown,
                      onResume: () => unawaited(_controller.resume()),
                      onFinish: () => unawaited(_confirmExit()),
                      onNavigation: () => unawaited(_openNavigation()),
                      onVoice: () => unawaited(_voiceControls()),
                    ),
                  ),
                if (!state.paused &&
                    state.phase != DriveSessionPhase.resuming &&
                    state.phase != DriveSessionPhase.recoverableError)
                  Positioned(
                    right: 10,
                    top: 10,
                    child: IconButton.filledTonal(
                      tooltip: context.tr('Pausar'),
                      onPressed: state.transitionInProgress
                          ? null
                          : () => unawaited(_togglePause()),
                      icon: const Icon(Icons.pause),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ],
    ),
  );

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
                            onSettings: () => unawaited(_openSettings()),
                            onSos: () => unawaited(_sos()),
                          ),
                          const SizedBox(height: 10),
                          Expanded(
                            child: _buildMonitoringMap(
                              state,
                              controller,
                              cameraReady,
                            ),
                          ),
                          const SizedBox(height: 10),
                          _ActionBar(
                            paused: state.paused,
                            busy: state.transitionInProgress,
                            onMap: () => unawaited(_openNavigation()),
                            onVoice: () => unawaited(_voiceControls()),
                            onFinish: () => unawaited(_confirmExit()),
                          ),
                        ],
                      ),
              ),
            ),
            if (_monitoring.calibrationInProgress)
              _CalibrationOverlay(state: _monitoring),
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
          Color(0xFF0B1020),
          Color(0xFF050A16),
          Color(0xFF101D36),
        ],
      ),
    ),
  );
}

class _DriveTopBar extends StatelessWidget {
  const _DriveTopBar({
    required this.paused,
    required this.onShowMetrics,
    required this.onSettings,
    required this.onSos,
  });
  final bool paused;
  final VoidCallback onShowMetrics;
  final VoidCallback onSettings, onSos;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.fromLTRB(12, 8, 8, 8),
    decoration: BoxDecoration(
      color: Colors.black.withValues(alpha: 0.44),
      borderRadius: BorderRadius.circular(20),
      border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
    ),
    child: Row(
      children: <Widget>[
        Image.asset('assets/logo.png', width: 30, height: 30),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              const LocalizedText(
                'DriverAwaken',
                style: TextStyle(fontWeight: FontWeight.w900, fontSize: 15),
              ),
              LocalizedText(
                paused ? 'Monitoreo pausado' : 'Conduce seguro, llega siempre',
                style: const TextStyle(color: Colors.white54, fontSize: 12),
              ),
            ],
          ),
        ),
        TextButton(
          onPressed: onSos,
          child: const Text(
            'SOS',
            style: TextStyle(
              color: Color(0xFFF06A76),
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        IconButton(
          tooltip: 'Configuración y navegación',
          onPressed: onSettings,
          icon: const Icon(Icons.settings_outlined),
        ),
        IconButton.filledTonal(
          tooltip: context.tr('Ver metricas'),
          onPressed: onShowMetrics,
          icon: const Icon(Icons.more_vert),
        ),
      ],
    ),
  );
}

class _MonitoringMetrics extends StatelessWidget {
  const _MonitoringMetrics({required this.state, required this.driveState});

  final DrowsinessState state;
  final DriveState driveState;

  @override
  Widget build(BuildContext context) {
    final elapsed = SmartNavigation.instance.driving;
    final time =
        '${elapsed.inHours}:${(elapsed.inMinutes % 60).toString().padLeft(2, '0')}';
    return SizedBox(
      height: 68,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: [
          _item(
            'OJOS',
            state.faceDetected
                ? (state.eyesClosed ? 'Cerrados' : 'Abiertos')
                : 'Sin rostro',
          ),
          _item('BOSTEZOS', state.yawnCountWindow.toString()),
          _item(
            'PERCLOS',
            state.perclosReady
                ? '${(state.perclos * 100).round()}%'
                : 'Calibrando',
          ),
          _item(
            'CABEZA',
            state.headDown
                ? 'Inclinada'
                : state.distracted
                ? 'Desviada'
                : 'Alineada',
          ),
          _item('SEÑAL', '${(state.signalQuality * 100).round()}%'),
          _item(
            'RIESGO',
            state.faceDetected && state.signalQuality >= .32
                ? '${state.riskScore.round()}/100'
                : 'Sin señal',
          ),
          _item('TIEMPO', time),
        ],
      ),
    );
  }

  Widget _item(String label, String value) => Container(
    width: 94,
    margin: const EdgeInsets.only(right: 6),
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
    decoration: BoxDecoration(
      color: const Color(0xCC101A2B),
      borderRadius: BorderRadius.circular(14),
      border: Border.all(color: Colors.white12),
    ),
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          value,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 12),
        ),
        const SizedBox(height: 3),
        Text(label, style: const TextStyle(color: Colors.white54, fontSize: 9)),
      ],
    ),
  );
}

class _SmartRestCard extends StatelessWidget {
  const _SmartRestCard({required this.recommendation, required this.onOpen});

  final RestRecommendation recommendation;
  final VoidCallback onOpen;

  @override
  Widget build(BuildContext context) => Material(
    color: recommendation.critical
        ? const Color(0xF039131B)
        : const Color(0xF02B2412),
    borderRadius: BorderRadius.circular(16),
    child: Padding(
      padding: const EdgeInsets.all(12),
      child: Row(
        children: [
          Icon(
            recommendation.critical
                ? Icons.warning_rounded
                : Icons.hotel_rounded,
            color: recommendation.critical
                ? const Color(0xFFFF6875)
                : const Color(0xFFFFC857),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              recommendation.message,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
            ),
          ),
          if (!recommendation.critical)
            TextButton(onPressed: onOpen, child: const Text('BUSCAR PARADA')),
        ],
      ),
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
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.8), width: 1.6),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(19),
        child: Stack(
          fit: StackFit.expand,
          children: <Widget>[
            _CameraPreviewCover(controller: controller),
            Center(
              child: FractionallySizedBox(
                widthFactor: .65,
                heightFactor: .65,
                child: Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: color, width: 2),
                    borderRadius: BorderRadius.circular(28),
                  ),
                ),
              ),
            ),
            Positioned(
              left: 12,
              top: 12,
              child: _Chip(label: 'Cámara frontal', color: Colors.white),
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
                      ? '${state.eyesClosed ? 'Ojos cerrados' : 'Ojos abiertos'} · ${state.headDown
                            ? 'Cabeza inclinada'
                            : state.distracted
                            ? 'Desvío de cabeza'
                            : 'Cabeza alineada'}\nCalidad de señal: ${(state.signalQuality * 100).round()} / 100'
                      : 'Alinea tu rostro dentro del marco',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 10,
                  ),
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
      borderRadius: BorderRadius.circular(20),
      border: Border.all(color: color.withValues(alpha: 0.4)),
    ),
    child: LocalizedText(
      label,
      style: TextStyle(color: color, fontWeight: FontWeight.w800, fontSize: 10),
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
      borderRadius: BorderRadius.circular(20),
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
    MonitoringHealth.unavailable => 'MONITOREO NO DISPONIBLE',
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
    required this.onMap,
    required this.onVoice,
    required this.onFinish,
  });
  final bool paused, busy;
  final VoidCallback onMap, onVoice, onFinish;
  @override
  Widget build(BuildContext context) => Row(
    children: [
      _control(
        context,
        Icons.open_in_new,
        'Paradas',
        const Color(0xFF3478FF),
        onMap,
      ),
      _control(
        context,
        Icons.mic_none_rounded,
        'Copiloto',
        const Color(0xFF23D18B),
        onVoice,
      ),
      _control(
        context,
        Icons.stop_rounded,
        'Finalizar',
        const Color(0xFFFF455C),
        onFinish,
      ),
    ],
  );
  Widget _control(
    BuildContext context,
    IconData icon,
    String label,
    Color color,
    VoidCallback action,
  ) => Expanded(
    child: Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: 58,
            height: 58,
            child: IconButton(
              tooltip: context.tr(label),
              style: IconButton.styleFrom(
                foregroundColor: color,
                backgroundColor: color.withValues(alpha: .09),
                side: BorderSide(color: color.withValues(alpha: .55)),
              ),
              onPressed: busy ? null : action,
              icon: Icon(icon, size: 30),
            ),
          ),
          const SizedBox(height: 6),
          LocalizedText(
            label,
            style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 12),
          ),
        ],
      ),
    ),
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
          message ?? 'Iniciando monitoreo…',
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
    required this.onNavigation,
    required this.onVoice,
  });
  final int? countdown;
  final VoidCallback onResume, onFinish, onNavigation, onVoice;
  @override
  Widget build(BuildContext context) => Material(
    color: const Color(0xF5101A2B),
    borderRadius: BorderRadius.circular(16),
    child: SingleChildScrollView(
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          LocalizedText(
            countdown == null
                ? 'MONITOREO PAUSADO'
                : 'REANUDANDO EN $countdown',
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 12),
          if (countdown == null) ...[
            FilledButton.icon(
              onPressed: onResume,
              icon: const Icon(Icons.play_arrow),
              label: const LocalizedText('REANUDAR'),
            ),
            const SizedBox(height: 8),
            Wrap(
              alignment: WrapAlignment.center,
              spacing: 8,
              children: [
                TextButton.icon(
                  onPressed: onNavigation,
                  icon: const Icon(Icons.open_in_new),
                  label: const Text('Google Maps'),
                ),
                TextButton.icon(
                  onPressed: onVoice,
                  icon: const Icon(Icons.mic),
                  label: const LocalizedText('Copiloto'),
                ),
                TextButton.icon(
                  onPressed: onFinish,
                  icon: const Icon(Icons.stop),
                  label: const LocalizedText('FINALIZAR'),
                ),
              ],
            ),
          ] else
            const LinearProgressIndicator(),
        ],
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
  const _MetricsSheet({required this.driveState, required this.onCalibrate});
  final DriveState driveState;
  final VoidCallback onCalibrate;
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
                OutlinedButton.icon(
                  onPressed: onCalibrate,
                  icon: const Icon(Icons.tune),
                  label: const LocalizedText('Calibrar'),
                ),
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
          if (state.performance != null) ...[
            LocalizedText(
              'Por muestreo adaptativo: '
              '${state.performance!.framesDroppedScheduler}',
            ),
            LocalizedText(
              'Por procesamiento ocupado: '
              '${state.performance!.framesDroppedBusy}',
            ),
          ],
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
