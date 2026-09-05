import 'package:flutter/material.dart';

import '../models/cloud_trip_report.dart';
import '../services/cloud_report_service.dart';
import '../services/local_history_service.dart';
import 'trip_summary_screen.dart';
import 'login_screen.dart';
import '../models/trip_session_summary.dart';

class CloudReportsScreen extends StatefulWidget {
  const CloudReportsScreen({super.key, this.reportToUpload});
  final TripSessionSummary? reportToUpload;

  @override
  State<CloudReportsScreen> createState() => _CloudReportsScreenState();
}

class _CloudReportsScreenState extends State<CloudReportsScreen> {
  final _service = CloudReportService.instance;
  final _password = TextEditingController();
  List<CloudTripReport> _reports = [];
  bool _busy = false;
  bool _ready = false;
  String? _message;
  DateTime? _lastChecked;
  bool _uploading = false;

  @override
  void initState() {
    super.initState();
    _run(() async {
      await _service.initialize();
      _ready = true;
      if (_service.user != null) await _refresh();
    });
  }

  Future<void> _refresh() async {
    final reports = await _service.load();
    _reports = reports;
    _lastChecked = DateTime.now();
  }

  Future<void> _run(Future<void> Function() action) async {
    if (_busy) return;
    setState(() {
      _busy = true;
      _message = null;
    });
    try {
      await action();
    } catch (error) {
      _message = CloudReportService.friendlyError(error);
    } finally {
      if (mounted) {
        setState(() {
          _busy = false;
        });
      }
    }
  }

  Future<bool> _confirm(String title, String message) async =>
      await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: Text(title),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancelar'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Confirmar'),
            ),
          ],
        ),
      ) ??
      false;

  Future<void> _backup() async {
    final confirmed = await _confirm(
      'Guardar una copia en la nube',
      '${widget.reportToUpload == null ? 'Se subirán los informes guardados en este teléfono' : 'Se subirá este informe'} a ${_service.user?.email}. Incluyen fechas, alertas, riesgo y telemetría, sin imágenes ni videos. Borrar el historial local no borra estas copias.',
    );
    if (!confirmed || !mounted) return;
    await _run(() async {
      _uploading = true;
      try {
        final selected = widget.reportToUpload;
        final trips = selected == null
            ? await LocalHistoryService.instance.loadTrips()
            : [selected];
        final count = await _service.backup(trips);
        _message = count == 0
            ? 'Primero finaliza un viaje para tener un informe que subir.'
            : 'Subida confirmada: $count informes guardados en tu cuenta.';
        try {
          await _refresh();
        } catch (_) {
          _message =
              '$count informes subidos. No se pudo actualizar la lista; toca Comprobar nube para volver a consultarla.';
        }
      } finally {
        _uploading = false;
      }
    });
  }

  Future<void> _deleteAccount() async {
    _password.clear();
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Eliminar cuenta y copias'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Se eliminarán tu cuenta y todos sus informes en la nube. Los informes locales se conservan. Introduce tu contraseña para confirmar.',
            ),
            TextField(
              controller: _password,
              obscureText: true,
              autocorrect: false,
              decoration: const InputDecoration(labelText: 'Contraseña'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) {
      _password.clear();
      return;
    }
    final password = _password.text;
    _password.clear();
    await _run(() async {
      await _service.deleteAccount(password);
      _reports = [];
      _lastChecked = null;
      _message = 'Cuenta y copias eliminadas.';
    });
  }

  @override
  void dispose() {
    _password.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final user = _service.user;
    if (_ready && user == null) {
      return LoginScreen(onAuthenticated: () => _run(_refresh));
    }
    return PopScope(
      canPop: !_busy,
      child: Scaffold(
        appBar: AppBar(title: const Text('Mis copias en la nube')),
        body: SafeArea(
          child: ListView(
            padding: const EdgeInsets.all(20),
            children: [
              const Text(
                'Tus informes, también en tu cuenta',
                style: TextStyle(fontSize: 23, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              const Text(
                'La cámara y los viajes funcionan sin iniciar sesión. Aquí puedes guardar copias y consultarlas desde otro teléfono con la misma cuenta.',
              ),
              const SizedBox(height: 16),
              if (_busy) const LinearProgressIndicator(),
              if (_message != null)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  child: Text(_message!, key: const ValueKey('cloud-message')),
                ),
              if (!_ready && !_busy)
                FilledButton(
                  onPressed: () => _run(() async {
                    await _service.initialize();
                    _ready = true;
                    if (_service.user != null) await _refresh();
                  }),
                  child: const Text('Reintentar conexión'),
                ),
              if (_ready && user != null) ...[
                const SizedBox(height: 12),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Row(
                          children: [
                            Icon(
                              Icons.verified_user_outlined,
                              color: Color(0xFF24D17E),
                            ),
                            SizedBox(width: 8),
                            Text('Sesión iniciada'),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          user.email ?? '',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        const Divider(),
                        Text(
                          _lastChecked == null
                              ? 'Aún no se ha confirmado el contenido de la nube.'
                              : '${_reports.length} informes encontrados en la nube',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        if (_lastChecked != null)
                          Text(
                            'Última consulta al servidor: ${MaterialLocalizations.of(context).formatTimeOfDay(TimeOfDay.fromDateTime(_lastChecked!))}',
                          ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                FilledButton.icon(
                  onPressed: _busy ? null : _backup,
                  icon: const Icon(Icons.cloud_upload_outlined),
                  label: Text(
                    _uploading
                        ? 'Subiendo informes…'
                        : widget.reportToUpload == null
                        ? 'Subir informes a la nube'
                        : 'Subir este informe',
                  ),
                ),
                OutlinedButton.icon(
                  onPressed: _busy
                      ? null
                      : () => _run(() async {
                          await _refresh();
                        }),
                  icon: const Icon(Icons.refresh),
                  label: const Text('Comprobar nube'),
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 12),
                  child: Text(
                    'Últimos 100 informes. Las copias se conservan hasta que las elimines aquí; la retención local no las borra.',
                  ),
                ),
                if (_lastChecked != null && _reports.isEmpty && !_busy)
                  const Text('Aún no hay copias en esta cuenta.'),
                for (final report in _reports)
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text(
                      MaterialLocalizations.of(
                        context,
                      ).formatMediumDate(report.summary.startedAt.toLocal()),
                    ),
                    subtitle: Text(
                      '${report.summary.drivingDuration.inMinutes} min · ${report.summary.warningAlerts + report.summary.dangerAlerts} alertas',
                    ),
                    onTap: _busy
                        ? null
                        : () => Navigator.of(context).push(
                            MaterialPageRoute<void>(
                              builder: (_) => TripSummaryScreen(
                                summary: report.summary,
                                isCloudCopy: true,
                              ),
                            ),
                          ),
                    trailing: IconButton(
                      tooltip: 'Eliminar copia',
                      icon: const Icon(Icons.delete_outline),
                      onPressed: _busy
                          ? null
                          : () async {
                              if (await _confirm(
                                    'Eliminar copia',
                                    'Se borrará este informe de tu cuenta. Su copia local se conserva.',
                                  ) &&
                                  mounted) {
                                await _run(() async {
                                  await _service.deleteReport(report.id);
                                  await _refresh();
                                });
                              }
                            },
                    ),
                  ),
                const Divider(),
                TextButton(
                  onPressed: _busy
                      ? null
                      : () => _run(() async {
                          await _service.signOut();
                          _reports = [];
                          _lastChecked = null;
                          _password.clear();
                        }),
                  child: const Text('Cerrar sesión'),
                ),
                TextButton(
                  onPressed: _busy ? null : _deleteAccount,
                  child: const Text('Eliminar cuenta y copias'),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
