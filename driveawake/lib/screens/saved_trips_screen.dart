import 'package:flutter/material.dart';

import '../models/trip_session_summary.dart';
import '../services/local_history_service.dart';
import 'trip_summary_screen.dart';
import 'cloud_reports_screen.dart';

class SavedTripsScreen extends StatefulWidget {
  const SavedTripsScreen({super.key});

  @override
  State<SavedTripsScreen> createState() => _SavedTripsScreenState();
}

class _SavedTripsScreenState extends State<SavedTripsScreen> {
  late Future<List<TripSessionSummary>> _trips;

  @override
  void initState() {
    super.initState();
    _trips = LocalHistoryService.instance.loadTrips();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: const Text('Informes de viajes'),
      actions: [
        IconButton(
          tooltip: 'Mis copias en la nube',
          icon: const Icon(Icons.cloud_outlined),
          onPressed: () => Navigator.of(context).push(
            MaterialPageRoute<void>(builder: (_) => const CloudReportsScreen()),
          ),
        ),
      ],
    ),
    body: FutureBuilder<List<TripSessionSummary>>(
      future: _trips,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('No se pudieron cargar los informes.'),
                TextButton(
                  onPressed: () => setState(() {
                    _trips = LocalHistoryService.instance.loadTrips();
                  }),
                  child: const Text('Reintentar'),
                ),
              ],
            ),
          );
        }
        final trips = snapshot.data ?? const <TripSessionSummary>[];
        if (trips.isEmpty) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(24),
              child: Text(
                'Todavía no hay informes. Al finalizar un viaje, su resumen se guarda aquí, incluso sin internet.',
                textAlign: TextAlign.center,
              ),
            ),
          );
        }
        return ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: trips.length,
          separatorBuilder: (_, index) => const Divider(),
          itemBuilder: (context, index) {
            final trip = trips[index];
            final date = trip.startedAt.toLocal();
            final label = MaterialLocalizations.of(
              context,
            ).formatMediumDate(date);
            final time = MaterialLocalizations.of(
              context,
            ).formatTimeOfDay(TimeOfDay.fromDateTime(date));
            return ListTile(
              leading: const Icon(Icons.route_rounded),
              title: Text('$label · $time'),
              subtitle: Text(
                '${trip.drivingDuration.inMinutes} min · ${trip.warningAlerts + trip.dangerAlerts} alertas\n${trip.resultTitle}',
              ),
              isThreeLine: true,
              trailing: const Icon(Icons.chevron_right),
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) => TripSummaryScreen(summary: trip),
                ),
              ),
            );
          },
        );
      },
    ),
  );
}
