import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

import '../services/trip_permission_service.dart';

/// Requests only permissions required by the monitoring experience.
class TripPreparationScreen extends StatefulWidget {
  const TripPreparationScreen({super.key, this.permissions});

  final TripPermissionService? permissions;

  @override
  State<TripPreparationScreen> createState() => _TripPreparationScreenState();
}

class _TripPreparationScreenState extends State<TripPreparationScreen>
    with WidgetsBindingObserver {
  late final permissions = widget.permissions ?? TripPermissionService();
  bool _busy = false;
  bool _camera = false;
  bool _microphone = false;
  bool _checked = false;
  bool _foreground = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed ||
        state == AppLifecycleState.paused) {
      setState(() => _foreground = state == AppLifecycleState.resumed);
    }
  }

  Future<void> _prepare() async {
    if (_busy) return;
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      final camera = await permissions.camera();
      if (!mounted) return;
      _camera = camera;
      if (camera) _microphone = await permissions.microphone();
      if (mounted) setState(() => _checked = true);
    } catch (_) {
      if (mounted) {
        setState(() => _error = 'No se pudieron preparar los permisos.');
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Antes de conducir')),
    bottomNavigationBar: SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 8, 24, 16),
        child: FilledButton.icon(
          onPressed: _busy || !_foreground
              ? null
              : _checked && _camera
              ? () => Navigator.pop(context, true)
              : _prepare,
          icon: Icon(
            _busy
                ? Icons.hourglass_top
                : _checked && _camera
                ? Icons.play_arrow
                : Icons.verified_user_outlined,
          ),
          label: Text(
            _busy
                ? 'Preparando permisos…'
                : _checked && _camera
                ? 'Iniciar viaje'
                : 'Autorizar y preparar',
          ),
        ),
      ),
    ),
    body: SafeArea(
      child: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          const Icon(
            Icons.visibility_rounded,
            size: 64,
            color: Color(0xFF38BDF8),
          ),
          const SizedBox(height: 20),
          const Text(
            'Monitoreo enfocado en ti',
            style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          const Text(
            'DriverAwaken usa la cámara frontal para detectar señales de '
            'somnolencia. No necesita ubicación ni carga mapas.',
          ),
          const SizedBox(height: 20),
          ListTile(
            leading: const Icon(Icons.videocam_outlined),
            title: const Text('Cámara frontal'),
            subtitle: Text(
              _camera
                  ? 'Lista para monitorear'
                  : 'Necesaria para detectar fatiga',
            ),
          ),
          ListTile(
            leading: const Icon(Icons.mic_none),
            title: const Text('Copiloto y alertas habladas'),
            subtitle: Text(
              _microphone
                  ? 'Micrófono autorizado · conversación al iniciarla'
                  : 'Opcional: puedes continuar sin micrófono',
            ),
          ),
          const ListTile(
            leading: Icon(Icons.location_off_outlined),
            title: Text('Sin permiso de ubicación'),
            subtitle: Text('Las búsquedas y rutas se delegan a Google Maps.'),
          ),
          if (_error != null)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Text(_error!),
            ),
          if (_checked && !_camera)
            TextButton(
              onPressed: openAppSettings,
              child: const Text('Abrir ajustes de permisos'),
            ),
        ],
      ),
    ),
  );
}
