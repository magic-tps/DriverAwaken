import '../l10n/localized_text.dart';
import 'package:flutter/material.dart';

import '../app/app_config.dart';
import '../models/drowsiness_state.dart';
import '../models/technical_session_report.dart';
import '../models/trip_session_summary.dart';
import '../services/technical_report_export_service.dart';
import 'cloud_reports_screen.dart';

class TripSummaryScreen extends StatelessWidget {
  const TripSummaryScreen({
    required this.summary,
    this.technicalReport,
    this.isCloudCopy = false,
    super.key,
  });

  final TripSessionSummary summary;
  final TechnicalSessionReport? technicalReport;
  final bool isCloudCopy;

  @override
  Widget build(BuildContext context) {
    final color = switch (summary.dominantLevel) {
      DrowsinessLevel.normal => const Color(0xFF24D17E),
      DrowsinessLevel.warning => const Color(0xFFFFA726),
      DrowsinessLevel.danger => const Color(0xFFFF3B30),
    };

    return Scaffold(
      appBar: AppBar(title: const LocalizedText('Resumen del viaje')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.36),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: color.withValues(alpha: 0.36)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Icon(Icons.route_rounded, color: color, size: 34),
                    const SizedBox(height: 14),
                    LocalizedText(
                      summary.resultTitle,
                      style: const TextStyle(
                        fontSize: 25,
                        fontWeight: FontWeight.w900,
                        height: 1.05,
                      ),
                    ),
                    const SizedBox(height: 8),
                    LocalizedText(
                      summary.resultMessage,
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.7),
                        height: 1.35,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),
              if (isCloudCopy)
                const ListTile(
                  leading: Icon(
                    Icons.cloud_done_outlined,
                    color: Color(0xFF24D17E),
                  ),
                  title: LocalizedText('Informe consultado desde la nube'),
                )
              else ...[
                const LocalizedText(
                  'Guardado en este teléfono',
                  style: TextStyle(color: Colors.white70),
                ),
                const SizedBox(height: 8),
                FilledButton.icon(
                  onPressed: () => Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (_) =>
                          CloudReportsScreen(reportToUpload: summary),
                    ),
                  ),
                  icon: const Icon(Icons.cloud_upload_outlined),
                  label: const LocalizedText('Subir informe a la nube'),
                ),
              ],
              const SizedBox(height: 18),
              _SummaryGrid(summary: summary),
              const SizedBox(height: 18),
              LocalizedText(
                'Sistema preventivo de alerta temprana, no sustituye la responsabilidad del conductor ni una evaluacion medica.',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.58),
                  height: 1.35,
                  fontSize: 12,
                ),
              ),
              const SizedBox(height: 24),
              if (AppConfig.technicalFeaturesEnabled &&
                  technicalReport != null) ...<Widget>[
                OutlinedButton.icon(
                  onPressed: () => _shareTechnicalReport(context),
                  icon: const Icon(Icons.ios_share),
                  label: const LocalizedText('Compartir reporte técnico'),
                ),
                const SizedBox(height: 10),
              ],
              FilledButton.icon(
                onPressed: () =>
                    Navigator.of(context).popUntil((route) => route.isFirst),
                icon: const Icon(Icons.home_rounded),
                label: const LocalizedText('Volver al inicio'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _shareTechnicalReport(BuildContext context) async {
    final report = technicalReport;
    if (report == null) return;
    await const TechnicalReportExportService().confirmAndShare(
      report: report,
      confirm: () async =>
          (await showDialog<bool>(
            context: context,
            builder: (context) => AlertDialog(
              title: const LocalizedText('Compartir reporte técnico'),
              content: const LocalizedText(
                'El JSON contiene métricas anónimas del dispositivo y la sesión. '
                'Confirma que deseas compartirlo.',
              ),
              actions: <Widget>[
                TextButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  child: const LocalizedText('CANCELAR'),
                ),
                FilledButton(
                  onPressed: () => Navigator.of(context).pop(true),
                  child: const LocalizedText('COMPARTIR'),
                ),
              ],
            ),
          )) ??
          false,
    );
  }
}

class _SummaryGrid extends StatelessWidget {
  const _SummaryGrid({required this.summary});

  final TripSessionSummary summary;

  @override
  Widget build(BuildContext context) {
    final items = <_SummaryItem>[
      _SummaryItem('Tiempo', _formatDuration(summary.drivingDuration)),
      _SummaryItem('Alertas leves', '${summary.warningAlerts}'),
      _SummaryItem('Alertas graves', '${summary.dangerAlerts}'),
      _SummaryItem('Bostezos', '${summary.yawnCount}'),
      _SummaryItem('Ojos cerrados', _formatDuration(summary.closedEyeDuration)),
      _SummaryItem('Sin rostro', '${summary.noFaceEvents}'),
      _SummaryItem('Riesgo prom.', summary.averageRisk.toStringAsFixed(0)),
      _SummaryItem('Riesgo max.', summary.maxRisk.toStringAsFixed(0)),
      _SummaryItem('Bateria', _formatBattery(summary)),
      _SummaryItem('Temp. max.', _formatTemperature(summary.maxTemperatureC)),
      _SummaryItem('Temp. delta', _formatSigned(summary.temperatureDelta, 'C')),
      _SummaryItem('Carga', summary.isCharging ? 'Si' : 'No'),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        final columns = constraints.maxWidth >= 560 ? 4 : 2;
        final width = (constraints.maxWidth - ((columns - 1) * 10)) / columns;
        return Wrap(
          spacing: 10,
          runSpacing: 10,
          children: items
              .map(
                (item) => SizedBox(
                  width: width,
                  height: 78,
                  child: _SummaryTile(item: item),
                ),
              )
              .toList(),
        );
      },
    );
  }

  String _formatDuration(Duration duration) {
    final minutes = duration.inMinutes;
    final seconds = duration.inSeconds.remainder(60);
    return '${minutes}m ${seconds}s';
  }

  String _formatBattery(TripSessionSummary summary) {
    final start = summary.startBatteryLevel;
    final end = summary.endBatteryLevel;
    if (start == null || end == null) {
      return '--';
    }
    final delta = summary.batteryDelta ?? 0;
    return '${end.toStringAsFixed(0)}% (${delta.toStringAsFixed(0)}%)';
  }

  String _formatTemperature(double? value) {
    if (value == null) {
      return '--';
    }
    return '${value.toStringAsFixed(1)}C';
  }

  String _formatSigned(double? value, String unit) {
    if (value == null) {
      return '--';
    }
    final sign = value > 0 ? '+' : '';
    return '$sign${value.toStringAsFixed(1)}$unit';
  }
}

class _SummaryTile extends StatelessWidget {
  const _SummaryTile({required this.item});

  final _SummaryItem item;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF11171A),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          LocalizedText(
            item.label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.52),
              fontSize: 11,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          LocalizedText(
            item.value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }
}

class _SummaryItem {
  const _SummaryItem(this.label, this.value);

  final String label;
  final String value;
}
