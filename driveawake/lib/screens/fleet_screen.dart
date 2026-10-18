import 'package:flutter/material.dart';
import '../fleet/fleet_service.dart';

class FleetScreen extends StatefulWidget {
  const FleetScreen({super.key});
  @override
  State<FleetScreen> createState() => _FleetScreenState();
}

class _FleetScreenState extends State<FleetScreen> {
  final _org = TextEditingController();
  List<AssignedFleetTrip> _trips = [];
  String? _error;
  bool _busy = false;
  bool _consent = false;
  bool _shareRest = false;
  @override
  void dispose() {
    _org.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      final trips = await FleetService.instance.loadAssigned(_org.text.trim());
      if (mounted) setState(() => _trips = trips);
      await FleetService.instance.refresh();
    } catch (error) {
      if (mounted) {
        setState(
          () => _error =
              'No se pudieron consultar los viajes. Comprueba tu sesión, código de flota y conexión.',
        );
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Guardian · Mi flota')),
    body: ListenableBuilder(
      listenable: FleetService.instance,
      builder: (context, _) {
        final fleet = FleetService.instance;
        return ListView(
          padding: const EdgeInsets.all(20),
          children: [
            const Text(
              'Configura con el vehículo estacionado',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
            ),
            const SizedBox(height: 12),
            const Text(
              'El modo personal sigue funcionando sin una flota. Para compartir, inicia sesión y usa el código proporcionado por tu administrador. No se envían imágenes ni vectores faciales.',
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _org,
              maxLength: 100,
              decoration: const InputDecoration(
                labelText: 'Código de organización',
              ),
            ),
            FilledButton(
              onPressed: _busy ? null : _load,
              child: Text(
                _busy ? 'Consultando…' : 'Consultar viajes asignados',
              ),
            ),
            if (_error != null)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: Text(
                  _error!,
                  style: TextStyle(color: Theme.of(context).colorScheme.error),
                ),
              ),
            CheckboxListTile(
              value: _consent,
              onChanged: (value) => setState(() => _consent = value ?? false),
              title: const Text(
                'Autorizo compartir incidentes de este viaje con mi flota',
              ),
              subtitle: const Text(
                'Fechas, tipo, severidad, score heurístico y salud del monitoreo. La central conserva lo ya recibido. Desvincular borra la cola local y detiene futuros envíos; una transacción ya enviada puede completarse. La eliminación remota se solicita al responsable de la flota.',
              ),
            ),
            CheckboxListTile(
              value: _shareRest,
              onChanged: (value) => setState(() => _shareRest = value ?? false),
              title: const Text('Compartir también descansos declarados'),
              subtitle: const Text(
                'Opcional. Solo fechas, duración y motivo; sin ubicación. No demuestra recuperación fisiológica.',
              ),
            ),
            if (!_busy && _trips.isEmpty)
              const Padding(
                padding: EdgeInsets.all(12),
                child: Text(
                  'Sin viajes cargados. Consulta tu organización para verificar asignaciones.',
                ),
              ),
            ..._trips.map(
              (trip) => Card(
                child: ListTile(
                  leading: const Icon(Icons.directions_bus_outlined),
                  title: Text('${trip.origin} → ${trip.destination}'),
                  subtitle: Text('Vehículo: ${trip.vehicleId} · ${trip.id}'),
                  trailing: FilledButton(
                    onPressed: !_consent || _busy
                        ? null
                        : () async {
                            try {
                              await fleet.consent(trip, shareRest: _shareRest);
                              if (context.mounted) Navigator.pop(context);
                            } catch (_) {
                              if (mounted) {
                                setState(
                                  () => _error =
                                      'No se pudo vincular. Finaliza el monitoreo o desvincula la flota anterior.',
                                );
                              }
                            }
                          },
                    child: const Text('Elegir'),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(fleet.status),
            Text(
              '${fleet.pendingCount} mensajes pendientes · ${fleet.sessionIncidents} incidentes de sesión',
            ),
            OutlinedButton.icon(
              onPressed: () async {
                await fleet.refresh();
              },
              icon: const Icon(Icons.sync),
              label: const Text('Comprobar sincronización'),
            ),
            TextButton(
              onPressed: () async {
                final accepted = await showDialog<bool>(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('Volver a modo personal'),
                    content: const Text(
                      'Se borra la cola de flota del dispositivo y se detienen futuros envíos. Los registros recibidos por la central no se borran. Una operación ya enviada puede completarse.',
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context, false),
                        child: const Text('Cancelar'),
                      ),
                      FilledButton(
                        onPressed: () => Navigator.pop(context, true),
                        child: const Text('Desvincular y borrar cola'),
                      ),
                    ],
                  ),
                );
                if (accepted == true) {
                  await fleet.revoke();
                  if (mounted) {
                    setState(() {
                      _trips = [];
                      _consent = false;
                    });
                  }
                }
              },
              child: const Text('Desvincular flota y borrar cola'),
            ),
          ],
        );
      },
    ),
  );
}
