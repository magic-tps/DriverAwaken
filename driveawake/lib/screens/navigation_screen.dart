import 'dart:async';

import 'package:flutter/material.dart';

import '../navigation/navigation_contracts.dart';
import '../navigation/rest_recommendation_engine.dart';
import '../navigation/smart_navigation.dart';

/// A lightweight hand-off screen. It never embeds a map or queries place APIs.
class NavigationScreen extends StatefulWidget {
  const NavigationScreen({super.key, this.navigation});

  final SmartNavigation? navigation;

  @override
  State<NavigationScreen> createState() => _NavigationScreenState();
}

class _NavigationScreenState extends State<NavigationScreen> {
  final _destination = TextEditingController();
  late final SmartNavigation nav;
  bool _stationaryConfirmed = false;

  @override
  void initState() {
    super.initState();
    nav = widget.navigation ?? SmartNavigation.instance;
    unawaited(nav.load());
    _destination.addListener(_refreshDestinationAction);
  }

  void _refreshDestinationAction() => setState(() {});

  @override
  void dispose() {
    _destination
      ..removeListener(_refreshDestinationAction)
      ..dispose();
    super.dispose();
  }

  Future<void> _open(Future<bool> Function() action) async {
    if (!_stationaryConfirmed) return;
    final agreed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Abrir Google Maps'),
        content: const Text(
          'Al abrir Google Maps, el monitoreo de DriverAwaken se pausará. '
          'Al regresar seguirá pausado hasta que pulses Reanudar.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Continuar'),
          ),
        ],
      ),
    );
    if (agreed != true) return;
    final opened = await action();
    if (!opened && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(nav.error ?? 'No se pudo abrir Google Maps.')),
      );
    }
  }

  Future<void> _recordRest() async {
    try {
      if (nav.openRest == null) {
        await nav.startRest();
      } else {
        await nav.endRest();
      }
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(error.toString())));
      }
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: const Color(0xFF080D18),
    appBar: AppBar(title: const Text('Paradas en Google Maps')),
    body: ListenableBuilder(
      listenable: nav,
      builder: (context, _) => ListView(
        padding: const EdgeInsets.all(18),
        children: [
          const _PausedNotice(),
          const SizedBox(height: 14),
          CheckboxListTile(
            value: _stationaryConfirmed,
            onChanged: (value) =>
                setState(() => _stationaryConfirmed = value ?? false),
            title: const Text('Confirmo que el vehículo está detenido'),
            subtitle: const Text(
              'Las búsquedas solo se habilitan con confirmación voluntaria.',
            ),
            controlAffinity: ListTileControlAffinity.leading,
          ),
          if (nav.recommendation != null) ...[
            const SizedBox(height: 8),
            _RestRecommendationCard(recommendation: nav.recommendation!),
          ],
          const SizedBox(height: 18),
          const Text(
            'Buscar una parada',
            style: TextStyle(fontSize: 21, fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 10),
          GridView.count(
            crossAxisCount: MediaQuery.sizeOf(context).width > 600 ? 3 : 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            childAspectRatio: 2.3,
            crossAxisSpacing: 8,
            mainAxisSpacing: 8,
            children: MapsSearchCategory.values
                .map(
                  (category) => OutlinedButton(
                    onPressed: _stationaryConfirmed && !nav.openingExternalMap
                        ? () => _open(() => nav.searchCategory(category))
                        : null,
                    child: Text(category.label, textAlign: TextAlign.center),
                  ),
                )
                .toList(),
          ),
          const SizedBox(height: 22),
          const Text(
            'Navegar a un destino',
            style: TextStyle(fontSize: 21, fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _destination,
            enabled: _stationaryConfirmed && !nav.openingExternalMap,
            maxLength: 160,
            textInputAction: TextInputAction.search,
            decoration: const InputDecoration(
              labelText: 'Dirección o nombre del destino',
              helperText: 'Google Maps resolverá el lugar y calculará la ruta.',
            ),
          ),
          FilledButton.icon(
            onPressed:
                _stationaryConfirmed &&
                    !nav.openingExternalMap &&
                    _destination.text.trim().isNotEmpty
                ? () => _open(() => nav.navigate(_destination.text))
                : null,
            icon: const Icon(Icons.open_in_new),
            label: const Text('Abrir navegación externa'),
          ),
          const SizedBox(height: 8),
          const Text(
            'DriverAwaken no consulta lugares, distancias, horarios ni '
            'disponibilidad. Google Maps se abre sin clave API.',
            style: TextStyle(color: Colors.white60, fontSize: 12),
          ),
          const Divider(height: 34),
          FilledButton.tonalIcon(
            onPressed: _stationaryConfirmed ? _recordRest : null,
            icon: Icon(nav.openRest == null ? Icons.coffee : Icons.check),
            label: Text(
              nav.openRest == null
                  ? 'Registrar inicio de descanso'
                  : 'Registrar fin de descanso',
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Registrar un descanso no reanuda la cámara automáticamente.',
            style: TextStyle(color: Colors.white60, fontSize: 12),
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<int>(
            initialValue: nav.drivingLimit.inMinutes,
            decoration: const InputDecoration(
              labelText: 'Recordatorio de pausa',
            ),
            items: [15, 30, 60, 90, 120, 180, 240]
                .map(
                  (minutes) => DropdownMenuItem(
                    value: minutes,
                    child: Text('$minutes minutos'),
                  ),
                )
                .toList(),
            onChanged: _stationaryConfirmed
                ? (value) {
                    if (value != null) unawaited(nav.setInterval(value));
                  }
                : null,
          ),
        ],
      ),
    ),
  );
}

class _PausedNotice extends StatelessWidget {
  const _PausedNotice();

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(
      color: const Color(0x22F2B35D),
      border: Border.all(color: const Color(0x99F2B35D)),
      borderRadius: BorderRadius.circular(16),
    ),
    child: const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'MONITOREO PAUSADO',
          style: TextStyle(
            color: Color(0xFFF2B35D),
            fontWeight: FontWeight.w900,
          ),
        ),
        SizedBox(height: 4),
        Text('Al volver a DriverAwaken, reanuda el monitoreo explícitamente.'),
      ],
    ),
  );
}

class _RestRecommendationCard extends StatelessWidget {
  const _RestRecommendationCard({required this.recommendation});

  final RestRecommendation recommendation;

  @override
  Widget build(BuildContext context) => Card(
    color: recommendation.critical
        ? const Color(0xFF39131B)
        : const Color(0xFF2B2412),
    child: Padding(
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            recommendation.critical ? 'RIESGO CRÍTICO' : 'SMART REST',
            style: TextStyle(
              color: recommendation.critical
                  ? const Color(0xFFFF6875)
                  : const Color(0xFFFFC857),
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 6),
          Text(recommendation.message),
        ],
      ),
    ),
  );
}
