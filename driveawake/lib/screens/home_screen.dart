import '../l10n/app_strings.dart';
import '../l10n/localized_text.dart';
// ignore_for_file: unused_element

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:camera/camera.dart';

import '../models/device_telemetry_snapshot.dart';
import '../models/drowsiness_state.dart';
import '../models/trip_session_draft.dart';
import '../services/camera_service.dart';
import '../services/cloud_report_service.dart';
import '../services/device_telemetry_service.dart';
import '../services/drowsiness_service.dart';
import '../services/face_detection_service.dart';
import '../services/local_history_service.dart';
import '../services/trip_session_draft_service.dart';
import '../utils/drowsiness_thresholds.dart';
import '../utils/input_image_converter.dart';
import '../widgets/face_landmark_overlay.dart';
import '../widgets/account_card.dart';
import 'drive_mode_screen.dart';
import 'history_screen.dart';
import 'privacy_policy_screen.dart';
import 'settings_screen.dart';
import 'cloud_reports_screen.dart';
import 'login_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key, this.cameraService, this.drowsinessService});

  final CameraService? cameraService;
  final DrowsinessService? drowsinessService;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final DeviceTelemetryService _deviceTelemetryService =
      DeviceTelemetryService();
  final GlobalKey<_LiveMonitoringPanelState> _liveMonitorKey =
      GlobalKey<_LiveMonitoringPanelState>();
  late final Future<DeviceTelemetrySnapshot?> _telemetryFuture;
  bool _routeOpen = false;

  @override
  void initState() {
    super.initState();
    _telemetryFuture = _deviceTelemetryService.getBatteryThermalSnapshot();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      unawaited(_initializeDashboard());
    });
  }

  Future<void> _initializeDashboard() async {
    try {
      await _offerIncompleteTripRecovery();
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: LocalizedText('No se pudo recuperar el viaje anterior.'),
          ),
        );
      }
    }
    if (mounted && !_routeOpen) {
      await _liveMonitorKey.currentState?.start();
    }
  }

  Future<void> _offerIncompleteTripRecovery() async {
    final draft = await TripSessionDraftService.instance.load();
    if (!mounted || draft == null) {
      return;
    }
    final recover = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const LocalizedText('Viaje incompleto encontrado'),
        content: LocalizedText(
          'Se encontró un viaje iniciado el ${_formatDraftDate(draft)}. '
          'La cámara y las alarmas permanecerán apagadas hasta que decidas reanudar.',
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const LocalizedText('Descartar'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const LocalizedText('Recuperar'),
          ),
        ],
      ),
    );
    if (!mounted) {
      return;
    }
    if (recover == true) {
      await _openRoute(
        MaterialPageRoute<void>(
          builder: (_) => DriveModeScreen(recoveredDraft: draft),
        ),
      );
    } else if (recover == false) {
      await LocalHistoryService.instance.deleteEventsForTrip(draft.tripId);
      await TripSessionDraftService.instance.clear();
    }
  }

  String _formatDraftDate(TripSessionDraft draft) {
    final value = draft.startedAt.toLocal();
    String two(int number) => number.toString().padLeft(2, '0');
    return '${two(value.day)}/${two(value.month)}/${value.year} '
        '${two(value.hour)}:${two(value.minute)}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: <Widget>[
          const _DashboardBackdrop(),
          SafeArea(
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 560),
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(18, 12, 18, 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: <Widget>[
                      _DashboardTopBar(
                        onPrivacy: () {
                          unawaited(
                            _openRoute(
                              MaterialPageRoute<void>(
                                builder: (_) => const PrivacyPolicyScreen(),
                              ),
                            ),
                          );
                        },
                        onSettings: () {
                          unawaited(
                            _openRoute(
                              MaterialPageRoute<void>(
                                builder: (_) => const SettingsScreen(),
                              ),
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 14),
                      AccountCard(
                        email: CloudReportService.instance.user?.email,
                        onLogin: () => unawaited(
                          _openRoute(
                            MaterialPageRoute<void>(
                              builder: (routeContext) => LoginScreen(
                                onAuthenticated: () =>
                                    Navigator.of(routeContext).pop(),
                              ),
                            ),
                          ),
                        ),
                        onCloud: () => unawaited(
                          _openRoute(
                            MaterialPageRoute<void>(
                              builder: (_) => const CloudReportsScreen(),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 14),
                      _LiveMonitoringPanel(
                        key: _liveMonitorKey,
                        cameraService: widget.cameraService,
                        drowsinessService: widget.drowsinessService,
                      ),
                      const SizedBox(height: 12),
                      const _BreakCard(),
                      const SizedBox(height: 14),
                      _StartTripButton(
                        onPressed: () {
                          unawaited(_openDriveMode(context));
                        },
                      ),
                      const SizedBox(height: 12),
                      _SecondaryActions(
                        onHistory: () {
                          unawaited(
                            _openRoute(
                              MaterialPageRoute<void>(
                                builder: (_) => const HistoryScreen(),
                              ),
                            ),
                          );
                        },
                        onSettings: () {
                          unawaited(
                            _openRoute(
                              MaterialPageRoute<void>(
                                builder: (_) => const SettingsScreen(),
                              ),
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 12),
                      FutureBuilder<DeviceTelemetrySnapshot?>(
                        future: _telemetryFuture,
                        builder: (context, snapshot) {
                          return _TelemetryDock(snapshot: snapshot.data);
                        },
                      ),
                      const SizedBox(height: 12),
                      _PrivacyStrip(onExplain: () => _showExplanation(context)),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _openDriveMode(BuildContext context) async {
    await _openRoute(
      MaterialPageRoute<void>(builder: (_) => const DriveModeScreen()),
    );
  }

  Future<void> _openRoute(Route<void> route) async {
    if (!mounted) {
      return;
    }
    if (_routeOpen) return;
    _routeOpen = true;
    try {
      await _liveMonitorKey.currentState?.stop();
      if (!mounted) return;
      await Navigator.of(context).push(route);
    } finally {
      _routeOpen = false;
      if (mounted) setState(() {});
      if (mounted) unawaited(_liveMonitorKey.currentState?.start());
    }
  }

  void _showExplanation(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      backgroundColor: const Color(0xFF08131F),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                const LocalizedText(
                  'Como funciona',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900),
                ),
                const SizedBox(height: 12),
                LocalizedText(
                  'DriverAwake usa la camara frontal, Google ML Kit, reglas criticas y un modelo TensorFlow Lite local. No graba video ni guarda imagenes: solo calcula senales de riesgo en tiempo real.',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.74),
                    height: 1.35,
                  ),
                ),
                const SizedBox(height: 18),
                FilledButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const LocalizedText('Entendido'),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _DashboardBackdrop extends StatelessWidget {
  const _DashboardBackdrop();

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _DashboardBackdropPainter(),
      child: const DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: <Color>[
              Color(0xFF020711),
              Color(0xFF07172A),
              Color(0xFF020509),
            ],
          ),
        ),
      ),
    );
  }
}

class _DashboardBackdropPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final glowPaint = Paint()
      ..shader =
          RadialGradient(
            colors: <Color>[
              const Color(0xFF1DA9FF).withValues(alpha: 0.34),
              Colors.transparent,
            ],
          ).createShader(
            Rect.fromCircle(
              center: Offset(size.width * 0.8, size.height * 0.2),
              radius: size.width * 0.78,
            ),
          );
    canvas.drawRect(Offset.zero & size, glowPaint);

    final roadTop = size.height * 0.58;
    final roadBottom = size.height;
    final centerX = size.width * 0.5;

    final roadPaint = Paint()
      ..color = const Color(0xFF06101B).withValues(alpha: 0.74)
      ..style = PaintingStyle.fill;
    final road = Path()
      ..moveTo(centerX - 20, roadTop)
      ..quadraticBezierTo(size.width * 0.1, size.height * 0.8, -20, roadBottom)
      ..lineTo(size.width + 20, roadBottom)
      ..quadraticBezierTo(
        size.width * 0.9,
        size.height * 0.8,
        centerX + 20,
        roadTop,
      )
      ..close();
    canvas.drawPath(road, roadPaint);

    final lanePaint = Paint()
      ..color = const Color(0xFF1DA9FF).withValues(alpha: 0.42)
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 2.4;
    final leftLane = Path()
      ..moveTo(centerX - 28, roadTop + 10)
      ..quadraticBezierTo(
        size.width * 0.22,
        size.height * 0.82,
        10,
        roadBottom,
      );
    final rightLane = Path()
      ..moveTo(centerX + 28, roadTop + 10)
      ..quadraticBezierTo(
        size.width * 0.78,
        size.height * 0.82,
        size.width - 10,
        roadBottom,
      );
    canvas.drawPath(leftLane, lanePaint);
    canvas.drawPath(rightLane, lanePaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _DashboardTopBar extends StatelessWidget {
  const _DashboardTopBar({required this.onPrivacy, required this.onSettings});

  final VoidCallback onPrivacy;
  final VoidCallback onSettings;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 48,
      child: Row(
        children: <Widget>[
          _GlassIconButton(
            icon: Icons.menu_rounded,
            tooltip: context.tr('Privacidad'),
            onPressed: onPrivacy,
          ),
          const Expanded(child: Center(child: _GradientTitle())),
          Stack(
            clipBehavior: Clip.none,
            children: <Widget>[
              _GlassIconButton(
                icon: Icons.notifications_none_rounded,
                tooltip: context.tr('Ajustes'),
                onPressed: onSettings,
              ),
              Positioned(
                right: 8,
                top: 7,
                child: Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: const Color(0xFF28C9FF),
                    borderRadius: BorderRadius.circular(999),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _GradientTitle extends StatelessWidget {
  const _GradientTitle();

  @override
  Widget build(BuildContext context) {
    return FittedBox(
      fit: BoxFit.scaleDown,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.asset(
              'assets/logo.png',
              width: 34,
              height: 34,
              fit: BoxFit.cover,
            ),
          ),
          const SizedBox(width: 8),
          RichText(
            text: const TextSpan(
              style: TextStyle(
                color: Colors.white,
                fontSize: 25,
                fontWeight: FontWeight.w900,
                letterSpacing: 0,
              ),
              children: <TextSpan>[
                TextSpan(text: 'Driver'),
                TextSpan(
                  text: 'Awake',
                  style: TextStyle(color: Color(0xFF22BFFF)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _GlassIconButton extends StatelessWidget {
  const _GlassIconButton({
    required this.icon,
    required this.tooltip,
    required this.onPressed,
  });

  final IconData icon;
  final String tooltip;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: IconButton(
        onPressed: onPressed,
        icon: Icon(icon),
        color: Colors.white,
        style: IconButton.styleFrom(
          backgroundColor: Colors.white.withValues(alpha: 0.05),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      ),
    );
  }
}

class _IntroMonitoringPanel extends StatelessWidget {
  const _IntroMonitoringPanel();

  @override
  Widget build(BuildContext context) {
    return _GlassPanel(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: <Widget>[
          Row(
            children: <Widget>[
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: const Color(0xFF32E65F),
                  borderRadius: BorderRadius.circular(999),
                ),
              ),
              const SizedBox(width: 9),
              const Expanded(
                child: LocalizedText(
                  'MONITOREO LISTO',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 0,
                  ),
                ),
              ),
              LocalizedText(
                'Camara al iniciar viaje',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.68),
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          AspectRatio(
            aspectRatio: 16 / 9,
            child: Container(
              decoration: BoxDecoration(
                color: const Color(0xFF020711),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: const Color(0xFF28C9FF).withValues(alpha: 0.36),
                ),
              ),
              child: Stack(
                fit: StackFit.expand,
                children: <Widget>[
                  Center(
                    child: Image.asset(
                      'assets/logo.png',
                      width: 138,
                      height: 138,
                      fit: BoxFit.contain,
                    ),
                  ),
                  Positioned.fill(
                    child: CustomPaint(painter: _ReadyScanFramePainter()),
                  ),
                  Positioned(
                    left: 12,
                    right: 12,
                    bottom: 12,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.58),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: const Color(
                            0xFF28C9FF,
                          ).withValues(alpha: 0.32),
                        ),
                      ),
                      child: const Row(
                        children: <Widget>[
                          Icon(
                            Icons.verified_user_rounded,
                            color: Color(0xFF32E65F),
                            size: 18,
                          ),
                          SizedBox(width: 8),
                          Expanded(
                            child: LocalizedText(
                              'El escaneo real empieza en modo viaje',
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 13,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          const Row(
            children: <Widget>[
              Expanded(
                child: _ReadinessMetric(
                  icon: Icons.visibility_rounded,
                  label: 'Ojos',
                  value: 'Listo',
                ),
              ),
              SizedBox(width: 8),
              Expanded(
                child: _ReadinessMetric(
                  icon: Icons.person_rounded,
                  label: 'Cabeza',
                  value: 'Listo',
                ),
              ),
              SizedBox(width: 8),
              Expanded(
                child: _ReadinessMetric(
                  icon: Icons.notifications_active_rounded,
                  label: 'Alertas',
                  value: 'Activas',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ReadyScanFramePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF28C9FF).withValues(alpha: 0.78)
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 2;
    const pad = 24.0;
    final len = size.shortestSide * 0.18;

    canvas.drawLine(const Offset(pad, pad), Offset(pad + len, pad), paint);
    canvas.drawLine(const Offset(pad, pad), Offset(pad, pad + len), paint);
    canvas.drawLine(
      Offset(size.width - pad, pad),
      Offset(size.width - pad - len, pad),
      paint,
    );
    canvas.drawLine(
      Offset(size.width - pad, pad),
      Offset(size.width - pad, pad + len),
      paint,
    );
    canvas.drawLine(
      Offset(pad, size.height - pad),
      Offset(pad + len, size.height - pad),
      paint,
    );
    canvas.drawLine(
      Offset(pad, size.height - pad),
      Offset(pad, size.height - pad - len),
      paint,
    );
    canvas.drawLine(
      Offset(size.width - pad, size.height - pad),
      Offset(size.width - pad - len, size.height - pad),
      paint,
    );
    canvas.drawLine(
      Offset(size.width - pad, size.height - pad),
      Offset(size.width - pad, size.height - pad - len),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _ReadinessMetric extends StatelessWidget {
  const _ReadinessMetric({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.045),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: const Color(0xFF28C9FF).withValues(alpha: 0.2),
        ),
      ),
      child: Column(
        children: <Widget>[
          Icon(icon, color: const Color(0xFF28C9FF), size: 22),
          const SizedBox(height: 6),
          LocalizedText(
            label.toUpperCase(),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.52),
              fontSize: 10,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 3),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: LocalizedText(
              value,
              style: const TextStyle(
                color: Color(0xFF32E65F),
                fontSize: 14,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _LiveMonitoringPanel extends StatefulWidget {
  const _LiveMonitoringPanel({
    super.key,
    this.cameraService,
    this.drowsinessService,
  });

  final CameraService? cameraService;
  final DrowsinessService? drowsinessService;

  @override
  State<_LiveMonitoringPanel> createState() => _LiveMonitoringPanelState();
}

class _LiveMonitoringPanelState extends State<_LiveMonitoringPanel>
    with WidgetsBindingObserver {
  late final CameraService _cameraService =
      widget.cameraService ?? CameraService();
  final FaceDetectionService _faceDetectionService = FaceDetectionService();
  late final DrowsinessService _drowsinessService =
      widget.drowsinessService ?? DrowsinessService();
  final List<DateTime> _processedFrameTimes = <DateTime>[];

  DrowsinessState _state = DrowsinessState.initial();
  FaceLandmarkOverlayData? _overlayData;
  DateTime _lastFrameAt = DateTime.fromMillisecondsSinceEpoch(0);
  bool _initializing = false;
  bool _isBusy = false;
  bool _starting = false;
  bool _previewVisible = false;
  bool _enabled = false;
  bool _foreground = true;
  Future<void> _operation = Future<void>.value();
  Future<void>? _frameTask;
  int _startToken = 0;
  String? _errorMessage;

  bool get isActive => _starting || _previewVisible;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // Android permission dialogs temporarily make the app inactive. Let the
    // pending permission request finish instead of launching a second one.
    if (state == AppLifecycleState.inactive && _starting) return;
    final foreground = state == AppLifecycleState.resumed;
    if (_foreground == foreground) return;
    _foreground = foreground;
    unawaited(_reconcile());
  }

  Future<void> start() {
    _enabled = true;
    return _reconcile();
  }

  Future<void> stop() {
    _enabled = false;
    return _reconcile();
  }

  Future<void> _reconcile() {
    final token = ++_startToken;
    _operation = _operation.then((_) => _updateCamera(token));
    return _operation;
  }

  Future<void> _updateCamera(int token) async {
    if (!mounted || token != _startToken) return;
    try {
      if (!_enabled || !_foreground) {
        setState(() {
          _initializing = false;
          _previewVisible = false;
          _overlayData = null;
          _state = DrowsinessState.initial();
        });
        // Background apps do not receive frames; waiting for one would block
        // camera release and every subsequent resume.
        if (_foreground) await WidgetsBinding.instance.endOfFrame;
        await _cameraService.dispose();
        await _frameTask;
        _processedFrameTimes.clear();
        _drowsinessService.resetTemporalState();
        return;
      }
      if (_previewVisible && _cameraService.isInitialized) return;
      _starting = true;
      setState(() {
        _initializing = true;
        _previewVisible = false;
        _errorMessage = null;
      });
      await _drowsinessService.initialize();
      if (!mounted || token != _startToken) return;
      await _cameraService.initializeFrontCamera(
        resolutionPreset: ResolutionPreset.medium,
      );
      if (!mounted || token != _startToken) {
        await _cameraService.dispose();
        return;
      }
      await _cameraService.startImageStream((image) {
        if (!_isBusy) _frameTask = _processCameraImage(image);
      });
      if (!mounted || token != _startToken) {
        await _cameraService.dispose();
        return;
      }
      setState(() {
        _initializing = false;
        _previewVisible = true;
      });
    } on CameraException catch (error) {
      if (mounted && token == _startToken) {
        await _setError(
          _friendlyCameraError('${error.code} ${error.description}'),
        );
      }
    } catch (error) {
      if (mounted && token == _startToken) {
        await _setError(_friendlyCameraError(error.toString()));
      }
    } finally {
      _starting = false;
    }
  }

  Future<void> _processCameraImage(CameraImage image) async {
    final token = _startToken;
    final now = DateTime.now();
    if (!_enabled ||
        !_foreground ||
        _isBusy ||
        now.difference(_lastFrameAt) < DrowsinessThresholds.frameInterval) {
      return;
    }

    final controller = _cameraService.controller;
    final camera = _cameraService.camera;
    if (controller == null || camera == null) {
      return;
    }

    _isBusy = true;
    _lastFrameAt = now;

    try {
      final inputImage = InputImageConverter.fromCameraImage(
        image,
        camera,
        controller.value.deviceOrientation,
      );
      if (inputImage == null) {
        return;
      }

      final faces = await _faceDetectionService.detectFaces(inputImage);
      if (!mounted || token != _startToken) return;
      final nextState = await _drowsinessService.analyze(
        faces: faces,
        timestamp: DateTime.now(),
        imageBrightness: _estimateBrightness(image),
        imageWidth: image.width,
        imageHeight: image.height,
        fps: _trackFps(now),
      );
      if (!mounted || token != _startToken) {
        return;
      }
      setState(() {
        _state = nextState;
        _overlayData = FaceLandmarkOverlayData(
          faces: faces,
          imageSize: inputImage.metadata!.size,
          rotation: inputImage.metadata!.rotation,
          lensDirection: camera.lensDirection,
        );
      });
    } catch (_) {
      // Un frame fallido no debe apagar la vista previa.
    } finally {
      _isBusy = false;
    }
  }

  Future<void> _setError(String message) async {
    try {
      await _cameraService.dispose();
    } catch (_) {
      // Keep Retry usable even if the native camera already disconnected.
    }
    if (!mounted) {
      return;
    }
    setState(() {
      _initializing = false;
      _previewVisible = false;
      _errorMessage = message;
    });
  }

  String _friendlyCameraError(String raw) {
    final normalized = raw.toLowerCase();
    if (normalized.contains('no supported surface combination') ||
        normalized.contains('too many use cases') ||
        normalized.contains('cameraexception')) {
      return 'Tu celular no pudo abrir vista previa y escaneo a la vez. Toca Reintentar o inicia el viaje.';
    }
    if (normalized.contains('permission') ||
        normalized.contains('permiso') ||
        normalized.contains('accessdenied')) {
      return 'Activa el permiso de camara para usar el escaneo.';
    }
    return 'No se pudo iniciar la camara. Toca Reintentar.';
  }

  double? _estimateBrightness(CameraImage image) {
    try {
      if (image.planes.isEmpty) {
        return null;
      }
      final bytes = image.planes.first.bytes;
      if (bytes.isEmpty) {
        return null;
      }
      final step = (bytes.length ~/ 800).clamp(1, 80).toInt();
      var total = 0.0;
      var count = 0;
      for (var i = 0; i < bytes.length; i += step) {
        total += bytes[i];
        count += 1;
      }
      return count == 0 ? null : total / count;
    } catch (_) {
      return null;
    }
  }

  double _trackFps(DateTime timestamp) {
    _processedFrameTimes.add(timestamp);
    final cutoff = timestamp.subtract(const Duration(seconds: 2));
    _processedFrameTimes.removeWhere((time) => time.isBefore(cutoff));
    if (_processedFrameTimes.length < 2) {
      return 0;
    }
    final elapsed = _processedFrameTimes.last
        .difference(_processedFrameTimes.first)
        .inMilliseconds;
    if (elapsed <= 0) {
      return 0;
    }
    return (_processedFrameTimes.length - 1) * 1000 / elapsed;
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _enabled = false;
    _startToken++;
    unawaited(
      _operation.whenComplete(() async {
        await _cameraService.dispose();
        await _frameTask;
        await _faceDetectionService.close();
        await _drowsinessService.close();
      }),
    );
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller = _cameraService.controller;
    final cameraReady =
        _previewVisible &&
        controller != null &&
        controller.value.isInitialized &&
        !_initializing;
    final statusText = _errorMessage != null
        ? 'Camara no disponible'
        : cameraReady
        ? 'Camara activa'
        : _initializing
        ? 'Iniciando camara'
        : 'Camara apagada';

    return _GlassPanel(
      padding: const EdgeInsets.all(14),
      child: Column(
        children: <Widget>[
          Row(
            children: <Widget>[
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: _errorMessage != null
                      ? const Color(0xFFFFA726)
                      : cameraReady
                      ? const Color(0xFF32E65F)
                      : Colors.white38,
                  borderRadius: BorderRadius.circular(999),
                ),
              ),
              const SizedBox(width: 9),
              const Expanded(
                child: LocalizedText(
                  'MONITOREO EN VIVO',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 0,
                  ),
                ),
              ),
              LocalizedText(
                statusText,
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.68),
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          _LiveCameraCard(
            controller: cameraReady ? controller : null,
            state: _state,
            overlayData: _overlayData,
            initializing: _initializing,
            errorMessage: _errorMessage,
            onRetry: () => unawaited(start()),
          ),
          const SizedBox(height: 12),
          _LiveInsightStrip(state: _state, available: cameraReady),
          const SizedBox(height: 12),
          _SignalStatusList(state: _state),
        ],
      ),
    );
  }
}

class _LiveCameraCard extends StatelessWidget {
  const _LiveCameraCard({
    required this.controller,
    required this.state,
    required this.overlayData,
    required this.initializing,
    required this.errorMessage,
    required this.onRetry,
  });

  final CameraController? controller;
  final DrowsinessState state;
  final FaceLandmarkOverlayData? overlayData;
  final bool initializing;
  final String? errorMessage;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final ready =
        controller != null && controller!.value.isInitialized && !initializing;
    final color = _levelColor(state.level);
    final alertMessage = _alertMessage(state);
    final aspectRatio = _previewAspectRatio(context, controller) ?? 3 / 4;

    return AspectRatio(
      aspectRatio: aspectRatio,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.black,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: color.withValues(alpha: 0.5), width: 1.4),
          boxShadow: <BoxShadow>[
            BoxShadow(
              color: color.withValues(alpha: 0.12),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(7),
          child: Stack(
            fit: StackFit.expand,
            children: <Widget>[
              const ColoredBox(color: Colors.black),
              if (ready)
                _HomeCameraPreviewSurface(controller: controller!)
              else
                _CameraPlaceholder(
                  initializing: initializing,
                  errorMessage: errorMessage,
                  onRetry: onRetry,
                ),
              Positioned.fill(
                child: IgnorePointer(
                  child: CustomPaint(
                    painter: FaceLandmarkOverlayPainter(
                      data: overlayData,
                      color: color,
                    ),
                  ),
                ),
              ),
              Positioned(
                left: 10,
                top: 10,
                child: _CameraChip(
                  icon: state.faceDetected
                      ? Icons.face_retouching_natural_rounded
                      : Icons.face_retouching_off_rounded,
                  label: !ready
                      ? 'Sin monitoreo'
                      : state.faceDetected
                      ? 'Rostro OK'
                      : 'Busca rostro',
                  color: state.faceDetected
                      ? const Color(0xFF32E65F)
                      : const Color(0xFFFFA726),
                ),
              ),
              const Positioned(
                right: 10,
                top: 10,
                child: _CameraChip(
                  icon: Icons.auto_awesome_rounded,
                  label: 'Landmarks',
                  color: Color(0xFF28C9FF),
                ),
              ),
              if (ready && alertMessage != null)
                Positioned(
                  left: 10,
                  right: 10,
                  bottom: 10,
                  child: _CameraAlertBanner(
                    message: alertMessage,
                    color: color,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  double? _previewAspectRatio(
    BuildContext context,
    CameraController? controller,
  ) {
    final previewSize = controller?.value.previewSize;
    if (previewSize == null) {
      return null;
    }
    final orientation = MediaQuery.orientationOf(context);
    final displayWidth = orientation == Orientation.portrait
        ? previewSize.height
        : previewSize.width;
    final displayHeight = orientation == Orientation.portrait
        ? previewSize.width
        : previewSize.height;
    if (displayHeight == 0) {
      return null;
    }
    return displayWidth / displayHeight;
  }

  Color _levelColor(DrowsinessLevel level) {
    switch (level) {
      case DrowsinessLevel.normal:
        return const Color(0xFF28C9FF);
      case DrowsinessLevel.warning:
        return const Color(0xFFFFA726);
      case DrowsinessLevel.danger:
        return const Color(0xFFFF3B30);
    }
  }

  String? _alertMessage(DrowsinessState state) {
    if (!state.faceDetected) {
      return 'Alinea tu rostro para iniciar el escaneo';
    }
    if (state.eyesClosed) {
      return 'Ojos cerrados detectados';
    }
    if (state.yawning) {
      return 'Bostezo detectado';
    }
    if (state.headDown) {
      return 'Cabeza baja';
    }
    if (state.distracted) {
      return 'Mirada fuera del camino';
    }
    if (state.lowLight) {
      return 'Poca luz: mejora la iluminacion';
    }
    return null;
  }
}

class _HomeCameraPreviewSurface extends StatelessWidget {
  const _HomeCameraPreviewSurface({required this.controller});

  final CameraController controller;

  @override
  Widget build(BuildContext context) {
    final previewSize = controller.value.previewSize;
    if (previewSize == null) {
      return const ColoredBox(color: Colors.black);
    }

    final orientation = MediaQuery.orientationOf(context);
    final displayWidth = orientation == Orientation.portrait
        ? previewSize.height
        : previewSize.width;
    final displayHeight = orientation == Orientation.portrait
        ? previewSize.width
        : previewSize.height;

    return ClipRect(
      child: FittedBox(
        fit: BoxFit.cover,
        alignment: Alignment.center,
        child: SizedBox(
          width: displayWidth,
          height: displayHeight,
          child: Transform(
            alignment: Alignment.center,
            transform: Matrix4.diagonal3Values(-1.0, 1.0, 1.0),
            child: CameraPreview(controller),
          ),
        ),
      ),
    );
  }
}

class _CameraPlaceholder extends StatelessWidget {
  const _CameraPlaceholder({
    required this.initializing,
    required this.errorMessage,
    required this.onRetry,
  });

  final bool initializing;
  final String? errorMessage;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    if (initializing) {
      return const Center(child: CircularProgressIndicator());
    }
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            const Icon(
              Icons.videocam_off_rounded,
              color: Color(0xFFFFA726),
              size: 42,
            ),
            const SizedBox(height: 10),
            LocalizedText(
              errorMessage ?? 'Camara detenida',
              textAlign: TextAlign.center,
              maxLines: 4,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh_rounded),
              label: LocalizedText(
                errorMessage == null ? 'Comprobar camara' : 'Reintentar',
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CameraChip extends StatelessWidget {
  const _CameraChip({
    required this.icon,
    required this.label,
    required this.color,
  });

  final IconData icon;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.58),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.34)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Icon(icon, color: color, size: 15),
          const SizedBox(width: 6),
          LocalizedText(
            label,
            style: TextStyle(
              color: color,
              fontSize: 11,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }
}

class _CameraAlertBanner extends StatelessWidget {
  const _CameraAlertBanner({required this.message, required this.color});

  final String message;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 9),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.68),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.55)),
      ),
      child: Row(
        children: <Widget>[
          Icon(Icons.warning_amber_rounded, color: color, size: 18),
          const SizedBox(width: 8),
          Expanded(
            child: LocalizedText(
              message,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.w900,
                height: 1.15,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _LiveInsightStrip extends StatelessWidget {
  const _LiveInsightStrip({required this.state, required this.available});

  final DrowsinessState state;
  final bool available;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        Expanded(
          child: _InsightPill(
            label: 'Riesgo',
            value: available && state.faceDetected
                ? '${state.riskScore.round()}/100'
                : '--',
            color: available && state.faceDetected
                ? _riskColor(state.level)
                : Colors.white54,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _InsightPill(
            label: 'Senal',
            value: available ? '${(state.signalQuality * 100).round()}%' : '--',
            color: const Color(0xFF28C9FF),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _InsightPill(
            label: 'FPS',
            value: !available || state.fps == null
                ? '--'
                : state.fps!.toStringAsFixed(1),
            color: const Color(0xFF8FE7FF),
          ),
        ),
      ],
    );
  }

  Color _riskColor(DrowsinessLevel level) {
    switch (level) {
      case DrowsinessLevel.normal:
        return const Color(0xFF32E65F);
      case DrowsinessLevel.warning:
        return const Color(0xFFFFA726);
      case DrowsinessLevel.danger:
        return const Color(0xFFFF3B30);
    }
  }
}

class _InsightPill extends StatelessWidget {
  const _InsightPill({
    required this.label,
    required this.value,
    required this.color,
  });

  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 9),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.045),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.22)),
      ),
      child: Column(
        children: <Widget>[
          LocalizedText(
            label.toUpperCase(),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.52),
              fontSize: 10,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 3),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: LocalizedText(
              value,
              style: TextStyle(
                color: color,
                fontSize: 15,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SignalStatusList extends StatelessWidget {
  const _SignalStatusList({required this.state});

  final DrowsinessState state;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        _SignalStatus(
          icon: Icons.visibility_rounded,
          label: 'Ojos',
          value: _eyesValue,
          alert: state.eyesClosed,
        ),
        const _SignalDivider(),
        _SignalStatus(
          icon: Icons.person_rounded,
          label: 'Cabeza',
          value: _headValue,
          alert: state.headDown || state.distracted,
        ),
        const _SignalDivider(),
        _SignalStatus(
          icon: Icons.gps_fixed_rounded,
          label: 'Atencion',
          value: _attentionValue,
          alert: state.level != DrowsinessLevel.normal || state.lowLight,
        ),
        const _SignalDivider(),
        _SignalStatus(
          icon: Icons.airline_seat_recline_extra_rounded,
          label: 'Fatiga',
          value: state.yawning
              ? 'Bostezo'
              : state.perclosReady
              ? 'PERCLOS ${state.perclos.toStringAsFixed(2)}'
              : 'Aprendiendo',
          alert: state.yawning || state.perclos >= 0.2,
        ),
      ],
    );
  }

  String get _eyesValue {
    if (!state.faceDetected) {
      return 'Sin rostro';
    }
    return state.eyesClosed ? 'Cerrados' : 'Abiertos';
  }

  String get _headValue {
    if (!state.faceDetected) {
      return '--';
    }
    if (state.headDown) {
      return 'Baja';
    }
    if (state.distracted) {
      return 'Girando';
    }
    return 'Centrada';
  }

  String get _attentionValue {
    if (state.lowLight) {
      return 'Poca luz';
    }
    if (!state.faceDetected) {
      return 'Busca rostro';
    }
    return state.level == DrowsinessLevel.normal ? 'Enfocada' : state.message;
  }
}

class _SignalStatus extends StatelessWidget {
  const _SignalStatus({
    required this.icon,
    required this.label,
    required this.value,
    required this.alert,
  });

  final IconData icon;
  final String label;
  final String value;
  final bool alert;

  @override
  Widget build(BuildContext context) {
    final color = alert ? const Color(0xFFFFA726) : const Color(0xFF28C9FF);

    return Row(
      children: <Widget>[
        Icon(icon, color: color, size: 30),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              LocalizedText(
                label.toUpperCase(),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.54),
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 3),
              LocalizedText(
                value,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: color,
                  fontSize: 15,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 0,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _SignalDivider extends StatelessWidget {
  const _SignalDivider();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Divider(height: 1, color: Colors.white.withValues(alpha: 0.08)),
    );
  }
}

class _BreakCard extends StatelessWidget {
  const _BreakCard();

  @override
  Widget build(BuildContext context) {
    return _GlassPanel(
      padding: const EdgeInsets.all(14),
      child: Row(
        children: <Widget>[
          Container(
            width: 55,
            height: 55,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(999),
              border: Border.all(
                color: const Color(0xFF28C9FF).withValues(alpha: 0.72),
                width: 1.6,
              ),
              color: const Color(0xFF081E31),
            ),
            child: const Icon(
              Icons.local_cafe_rounded,
              color: Color(0xFF6CEAFF),
              size: 29,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                const LocalizedText(
                  'Toma pausas regulares',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900),
                ),
                const SizedBox(height: 4),
                LocalizedText(
                  'Sistema listo para detectar fatiga en tiempo real.',
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.66),
                    height: 1.25,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Icon(
            Icons.close_rounded,
            color: Colors.white.withValues(alpha: 0.42),
          ),
        ],
      ),
    );
  }
}

class _StartTripButton extends StatelessWidget {
  const _StartTripButton({required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(8),
      child: Ink(
        height: 64,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          gradient: const LinearGradient(
            colors: <Color>[Color(0xFF20B8FF), Color(0xFF0877E8)],
          ),
          boxShadow: <BoxShadow>[
            BoxShadow(
              color: const Color(0xFF0B98FF).withValues(alpha: 0.34),
              blurRadius: 22,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(8),
          child: const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Icon(Icons.play_arrow_rounded, color: Colors.white, size: 30),
              SizedBox(width: 10),
              LocalizedText(
                'INICIAR VIAJE',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 0,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SecondaryActions extends StatelessWidget {
  const _SecondaryActions({required this.onHistory, required this.onSettings});

  final VoidCallback onHistory;
  final VoidCallback onSettings;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        Expanded(
          child: _SecondaryButton(
            icon: Icons.schedule_rounded,
            label: 'HISTORIAL',
            onPressed: onHistory,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _SecondaryButton(
            icon: Icons.settings_rounded,
            label: 'AJUSTES',
            onPressed: onSettings,
          ),
        ),
      ],
    );
  }
}

class _SecondaryButton extends StatelessWidget {
  const _SecondaryButton({
    required this.icon,
    required this.label,
    required this.onPressed,
  });

  final IconData icon;
  final String label;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return OutlinedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, color: const Color(0xFF93DFFF)),
      label: FittedBox(fit: BoxFit.scaleDown, child: LocalizedText(label)),
      style: OutlinedButton.styleFrom(
        minimumSize: const Size.fromHeight(60),
        foregroundColor: Colors.white,
        textStyle: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w900,
          letterSpacing: 0,
        ),
        backgroundColor: const Color(0xFF061528).withValues(alpha: 0.82),
        side: BorderSide(
          color: const Color(0xFF1DA9FF).withValues(alpha: 0.32),
        ),
      ),
    );
  }
}

class _TelemetryDock extends StatelessWidget {
  const _TelemetryDock({required this.snapshot});

  final DeviceTelemetrySnapshot? snapshot;

  @override
  Widget build(BuildContext context) {
    final battery = snapshot?.batteryLevel == null
        ? '--'
        : '${snapshot!.batteryLevel!.round()}%';
    final temp = snapshot?.temperatureC == null
        ? '--'
        : '${snapshot!.temperatureC!.round()} C';

    return _GlassPanel(
      padding: EdgeInsets.zero,
      child: Row(
        children: <Widget>[
          Expanded(
            child: _DockMetric(
              icon: Icons.battery_5_bar_rounded,
              label: 'BATERIA',
              value: battery,
              color: const Color(0xFF43EA63),
            ),
          ),
          const _DockDivider(),
          Expanded(
            child: _DockMetric(
              icon: Icons.device_thermostat_rounded,
              label: 'TEMP',
              value: temp,
              color: const Color(0xFF2CD0FF),
            ),
          ),
          const _DockDivider(),
          const Expanded(
            child: _DockMetric(
              icon: Icons.memory_rounded,
              label: 'MODELO',
              value: 'Activo',
              color: Color(0xFF43EA63),
            ),
          ),
          const _DockDivider(),
          const Expanded(
            child: _DockMetric(
              icon: Icons.center_focus_strong_rounded,
              label: 'CALIBR.',
              value: 'Lista',
              color: Color(0xFF43EA63),
            ),
          ),
        ],
      ),
    );
  }
}

class _DockMetric extends StatelessWidget {
  const _DockMetric({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  final IconData icon;
  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 104,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 12),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Icon(icon, color: Colors.white.withValues(alpha: 0.9), size: 27),
            const SizedBox(height: 8),
            LocalizedText(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.48),
                fontSize: 10,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 4),
            FittedBox(
              fit: BoxFit.scaleDown,
              child: LocalizedText(
                value,
                maxLines: 1,
                style: TextStyle(
                  color: color,
                  fontSize: 16,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 0,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DockDivider extends StatelessWidget {
  const _DockDivider();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 1,
      height: 66,
      color: Colors.white.withValues(alpha: 0.08),
    );
  }
}

class _PrivacyStrip extends StatelessWidget {
  const _PrivacyStrip({required this.onExplain});

  final VoidCallback onExplain;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: const Color(0xFF111309).withValues(alpha: 0.72),
      borderRadius: BorderRadius.circular(8),
      child: InkWell(
        onTap: onExplain,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: const Color(0xFFFFC14A).withValues(alpha: 0.24),
            ),
          ),
          child: Row(
            children: <Widget>[
              const Icon(
                Icons.lock_outline_rounded,
                color: Color(0xFFFFC14A),
                size: 22,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: LocalizedText(
                  'IA local. No se guardan imagenes ni video.',
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.74),
                    fontWeight: FontWeight.w700,
                    height: 1.25,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              const Icon(
                Icons.info_outline_rounded,
                color: Color(0xFFFFC14A),
                size: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _GlassPanel extends StatelessWidget {
  const _GlassPanel({required this.child, required this.padding});

  final Widget child;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: const Color(0xFF061326).withValues(alpha: 0.82),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: const Color(0xFF1DA9FF).withValues(alpha: 0.28),
        ),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.32),
            blurRadius: 24,
            offset: const Offset(0, 14),
          ),
        ],
      ),
      child: child,
    );
  }
}
