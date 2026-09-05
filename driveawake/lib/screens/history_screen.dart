import 'package:flutter/material.dart';

import '../models/drowsiness_event.dart';
import '../models/drowsiness_state.dart';
import '../services/history_export_service.dart';
import '../services/local_history_service.dart';
import 'saved_trips_screen.dart';
import 'cloud_reports_screen.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  final LocalHistoryService _historyService = LocalHistoryService.instance;
  final HistoryExportService _exportService = HistoryExportService();
  DrowsinessLevel? _filter;
  late Future<List<DrowsinessEvent>> _eventsFuture;
  String? _exportingDayKey;

  @override
  void initState() {
    super.initState();
    _eventsFuture = _historyService.loadEvents();
  }

  void _load() {
    setState(() {
      _eventsFuture = _historyService.loadEvents(level: _filter);
    });
  }

  Future<void> _clearHistory() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Borrar historial'),
          content: const Text(
            'Se eliminaran los eventos y metricas locales. No hay imagenes ni videos guardados.',
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancelar'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Borrar'),
            ),
          ],
        );
      },
    );
    if (confirmed != true) {
      return;
    }
    await _historyService.clear();
    _load();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Historial'),
        actions: <Widget>[
          IconButton(
            onPressed: _clearHistory,
            icon: const Icon(Icons.delete_outline_rounded),
            tooltip: 'Borrar historial',
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: <Widget>[
            ListTile(
              leading: const Icon(Icons.cloud_upload_outlined),
              title: const Text('Subir y consultar informes en la nube'),
              subtitle: const Text('Tu cuenta y copias confirmadas'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) => const CloudReportsScreen(),
                ),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.summarize_outlined),
              title: const Text('Informes de viajes'),
              subtitle: const Text('Guardados en este dispositivo'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) => const SavedTripsScreen(),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
              child: _FilterBar(
                selected: _filter,
                onChanged: (level) {
                  _filter = level;
                  _load();
                },
              ),
            ),
            Expanded(
              child: FutureBuilder<List<DrowsinessEvent>>(
                future: _eventsFuture,
                builder: (context, snapshot) {
                  final events = snapshot.data ?? <DrowsinessEvent>[];
                  if (snapshot.connectionState != ConnectionState.done) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (events.isEmpty) {
                    return const _EmptyHistory();
                  }
                  final groups = _groupByDay(events);
                  return ListView.separated(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 20),
                    itemBuilder: (context, index) {
                      final group = groups[index];
                      return _DaySection(
                        group: group,
                        exporting: _exportingDayKey == group.key,
                        onExportPdf: () => _exportDay(group, _ExportFormat.pdf),
                        onExportPng: () => _exportDay(group, _ExportFormat.png),
                        onEventTap: _showEventDetail,
                      );
                    },
                    separatorBuilder: (_, __) => const SizedBox(height: 14),
                    itemCount: groups.length,
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showEventDetail(DrowsinessEvent event) {
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      backgroundColor: const Color(0xFF11171A),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  _eventTitle(event.eventType),
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 12),
                _DetailRow('Nivel', event.level.label),
                _DetailRow('Riesgo', event.riskScore.toStringAsFixed(0)),
                _DetailRow('PERCLOS', event.perclos.toStringAsFixed(2)),
                _DetailRow(
                  'Modelo',
                  event.modelPrediction == null
                      ? '--'
                      : '${event.modelPrediction} (${((event.modelConfidence ?? 0) * 100).toStringAsFixed(0)}%)',
                ),
                _DetailRow(
                  'Duracion',
                  '${event.durationSeconds.toStringAsFixed(1)} s',
                ),
                _DetailRow('Nota', event.notes),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _exportDay(_HistoryDayGroup group, _ExportFormat format) async {
    if (_exportingDayKey != null) {
      return;
    }
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Exportar ${format.label}'),
        content: const Text(
          'El reporte contiene datos del historial. Al compartirlo, una aplicacion externa o el destinatario podra conservarlo.',
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancelar'),
          ),
          FilledButton.icon(
            onPressed: () => Navigator.of(context).pop(true),
            icon: const Icon(Icons.ios_share_rounded),
            label: const Text('Continuar'),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;
    setState(() {
      _exportingDayKey = group.key;
    });

    try {
      if (format == _ExportFormat.pdf) {
        await _exportService.shareDayAsPdf(
          day: group.day,
          events: group.events,
        );
      } else {
        await _exportService.shareDayAsPng(
          day: group.day,
          events: group.events,
        );
      }
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Reporte ${format.label} listo para ${_formatDayHeader(group.day)}',
          ),
        ),
      );
    } catch (error) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No se pudo exportar el reporte')),
      );
    } finally {
      if (mounted) {
        setState(() {
          _exportingDayKey = null;
        });
      }
    }
  }

  List<_HistoryDayGroup> _groupByDay(List<DrowsinessEvent> events) {
    final groups = <String, _HistoryDayGroup>{};
    for (final event in events) {
      final local = event.dateTime.toLocal();
      final day = DateTime(local.year, local.month, local.day);
      final key = _dayKey(day);
      groups.putIfAbsent(
        key,
        () => _HistoryDayGroup(day: day, events: <DrowsinessEvent>[]),
      );
      groups[key]!.events.add(event);
    }
    final result = groups.values.toList()
      ..sort((a, b) => b.day.compareTo(a.day));
    for (final group in result) {
      group.events.sort((a, b) => b.dateTime.compareTo(a.dateTime));
    }
    return result;
  }
}

enum _ExportFormat {
  pdf('PDF'),
  png('PNG');

  const _ExportFormat(this.label);

  final String label;
}

class _HistoryDayGroup {
  _HistoryDayGroup({required this.day, required this.events});

  final DateTime day;
  final List<DrowsinessEvent> events;

  String get key => _dayKey(day);

  int get warningCount =>
      events.where((event) => event.level == DrowsinessLevel.warning).length;
  int get dangerCount =>
      events.where((event) => event.level == DrowsinessLevel.danger).length;
  double get maxRisk => events.fold<double>(
    0,
    (value, event) => event.riskScore > value ? event.riskScore : value,
  );
}

class _FilterBar extends StatelessWidget {
  const _FilterBar({required this.selected, required this.onChanged});

  final DrowsinessLevel? selected;
  final ValueChanged<DrowsinessLevel?> onChanged;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: <Widget>[
          FilterChip(
            selected: selected == null,
            label: const Text('Todos'),
            onSelected: (_) => onChanged(null),
          ),
          const SizedBox(width: 8),
          for (final level in DrowsinessLevel.values) ...<Widget>[
            FilterChip(
              selected: selected == level,
              label: Text(level.label),
              onSelected: (_) => onChanged(level),
            ),
            const SizedBox(width: 8),
          ],
        ],
      ),
    );
  }
}

class _DaySection extends StatelessWidget {
  const _DaySection({
    required this.group,
    required this.exporting,
    required this.onExportPdf,
    required this.onExportPng,
    required this.onEventTap,
  });

  final _HistoryDayGroup group;
  final bool exporting;
  final VoidCallback onExportPdf;
  final VoidCallback onExportPng;
  final ValueChanged<DrowsinessEvent> onEventTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF0B1218),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
      ),
      child: Column(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 12, 10, 10),
            child: Row(
              children: <Widget>[
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        _formatDayHeader(group.day),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        '${group.events.length} eventos - Precaucion ${group.warningCount} - Peligro ${group.dangerCount} - Max ${group.maxRisk.toStringAsFixed(0)}',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.58),
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
                if (exporting)
                  const SizedBox(
                    width: 40,
                    height: 40,
                    child: Padding(
                      padding: EdgeInsets.all(10),
                      child: CircularProgressIndicator(strokeWidth: 2.4),
                    ),
                  )
                else ...<Widget>[
                  Tooltip(
                    message: 'Exportar PDF',
                    child: IconButton(
                      onPressed: onExportPdf,
                      icon: const Icon(Icons.picture_as_pdf_rounded),
                      color: const Color(0xFFFF5A4D),
                    ),
                  ),
                  Tooltip(
                    message: 'Exportar PNG',
                    child: IconButton(
                      onPressed: onExportPng,
                      icon: const Icon(Icons.image_rounded),
                      color: const Color(0xFF28C9FF),
                    ),
                  ),
                ],
              ],
            ),
          ),
          Divider(height: 1, color: Colors.white.withValues(alpha: 0.08)),
          for (var i = 0; i < group.events.length; i++) ...<Widget>[
            Padding(
              padding: EdgeInsets.fromLTRB(
                10,
                i == 0 ? 10 : 0,
                10,
                i == group.events.length - 1 ? 10 : 0,
              ),
              child: _EventTile(
                event: group.events[i],
                onTap: () => onEventTap(group.events[i]),
              ),
            ),
            if (i != group.events.length - 1) const SizedBox(height: 10),
          ],
        ],
      ),
    );
  }
}

class _EventTile extends StatelessWidget {
  const _EventTile({required this.event, required this.onTap});

  final DrowsinessEvent event;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = switch (event.level) {
      DrowsinessLevel.normal => const Color(0xFF24D17E),
      DrowsinessLevel.warning => const Color(0xFFFFA726),
      DrowsinessLevel.danger => const Color(0xFFFF3B30),
    };

    return Material(
      color: const Color(0xFF11171A),
      borderRadius: BorderRadius.circular(8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: color.withValues(alpha: 0.22)),
          ),
          child: Row(
            children: <Widget>[
              Icon(Icons.event_note_rounded, color: color, size: 26),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      _eventTitle(event.eventType),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      '${_formatDate(event.dateTime)} - Riesgo ${event.riskScore.toStringAsFixed(0)}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.58),
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right_rounded),
            ],
          ),
        ),
      ),
    );
  }
}

class _EmptyHistory extends StatelessWidget {
  const _EmptyHistory();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Text(
          'Aun no hay eventos guardados. El historial solo almacena metricas y alertas, nunca imagenes ni video.',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.66),
            height: 1.35,
          ),
        ),
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow(this.label, this.value);

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          SizedBox(
            width: 92,
            child: Text(
              label,
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.52),
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontWeight: FontWeight.w800),
            ),
          ),
        ],
      ),
    );
  }
}

String _eventTitle(String type) {
  switch (type) {
    case 'ojos_cerrados_prolongados':
      return 'Ojos cerrados prolongados';
    case 'bostezo':
      return 'Bostezo';
    case 'cabeza_caida':
      return 'Cabeza caida';
    case 'distraccion':
      return 'Distraccion';
    case 'rostro_ausente':
      return 'Rostro ausente';
    case 'perclos_alto':
      return 'PERCLOS alto';
    case 'modelo_somnolencia':
      return 'Modelo detecto somnolencia';
    case 'alarma_critica':
      return 'Alarma critica';
    case 'alerta_precaucion':
      return 'Alerta de precaucion';
    default:
      return type;
  }
}

String _formatDate(DateTime dateTime) {
  final local = dateTime.toLocal();
  final day = local.day.toString().padLeft(2, '0');
  final month = local.month.toString().padLeft(2, '0');
  final hour = local.hour.toString().padLeft(2, '0');
  final minute = local.minute.toString().padLeft(2, '0');
  return '$day/$month $hour:$minute';
}

String _formatDayHeader(DateTime dateTime) {
  final local = dateTime.toLocal();
  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);
  final day = DateTime(local.year, local.month, local.day);
  final dateText =
      '${local.day.toString().padLeft(2, '0')}/${local.month.toString().padLeft(2, '0')}/${local.year}';
  if (day == today) {
    return 'Hoy - $dateText';
  }
  if (day == today.subtract(const Duration(days: 1))) {
    return 'Ayer - $dateText';
  }
  return dateText;
}

String _dayKey(DateTime dateTime) {
  final local = dateTime.toLocal();
  return '${local.year}-${local.month.toString().padLeft(2, '0')}-${local.day.toString().padLeft(2, '0')}';
}
