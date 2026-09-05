import 'dart:io';
import 'dart:math' as math;
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:share_plus/share_plus.dart';

import '../models/drowsiness_event.dart';
import '../models/drowsiness_state.dart';

class HistoryExportService {
  Future<void> shareDayAsPdf({
    required DateTime day,
    required List<DrowsinessEvent> events,
  }) async {
    final bytes = await _buildPdf(day: day, events: events);
    await _shareBytes(
      bytes: bytes,
      filename: '${_fileStem(day)}.pdf',
      mimeType: 'application/pdf',
      text: 'Historial DriverAwake ${_formatDay(day)}',
    );
  }

  Future<void> shareDayAsPng({
    required DateTime day,
    required List<DrowsinessEvent> events,
  }) async {
    final bytes = await _buildPng(day: day, events: events);
    await _shareBytes(
      bytes: bytes,
      filename: '${_fileStem(day)}.png',
      mimeType: 'image/png',
      text: 'Historial DriverAwake ${_formatDay(day)}',
    );
  }

  Future<void> _shareBytes({
    required Uint8List bytes,
    required String filename,
    required String mimeType,
    required String text,
  }) async {
    final directory = await getTemporaryDirectory();
    final file = File('${directory.path}${Platform.pathSeparator}$filename');
    await file.writeAsBytes(bytes, flush: true);
    try {
      await SharePlus.instance.share(
        ShareParams(
          text: text,
          files: <XFile>[XFile(file.path, mimeType: mimeType, name: filename)],
        ),
      );
    } finally {
      if (await file.exists()) {
        await file.delete();
      }
    }
  }

  Future<Uint8List> _buildPdf({
    required DateTime day,
    required List<DrowsinessEvent> events,
  }) async {
    final sorted = _sorted(events);
    final summary = _DailySummary.fromEvents(sorted);
    final document = pw.Document();

    document.addPage(
      pw.MultiPage(
        pageTheme: const pw.PageTheme(
          margin: pw.EdgeInsets.all(28),
          pageFormat: PdfPageFormat.a4,
        ),
        build: (context) {
          return <pw.Widget>[
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: <pw.Widget>[
                pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: <pw.Widget>[
                    pw.Text(
                      'DriverAwake',
                      style: pw.TextStyle(
                        fontSize: 26,
                        fontWeight: pw.FontWeight.bold,
                        color: PdfColor.fromHex('#0B8DFF'),
                      ),
                    ),
                    pw.SizedBox(height: 4),
                    pw.Text(
                      'Reporte diario de somnolencia',
                      style: const pw.TextStyle(fontSize: 12),
                    ),
                  ],
                ),
                pw.Text(
                  _formatDay(day),
                  style: pw.TextStyle(
                    fontSize: 16,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
              ],
            ),
            pw.SizedBox(height: 20),
            pw.Wrap(
              spacing: 8,
              runSpacing: 8,
              children: <pw.Widget>[
                _pdfMetric('Eventos', '${summary.total}'),
                _pdfMetric('Precaucion', '${summary.warningCount}'),
                _pdfMetric('Peligro', '${summary.dangerCount}'),
                _pdfMetric('Riesgo max.', summary.maxRisk.toStringAsFixed(0)),
                _pdfMetric(
                  'Riesgo prom.',
                  summary.averageRisk.toStringAsFixed(0),
                ),
                _pdfMetric('Bostezos', '${summary.yawnCount}'),
              ],
            ),
            pw.SizedBox(height: 18),
            pw.TableHelper.fromTextArray(
              border: pw.TableBorder.all(
                color: PdfColor.fromHex('#D8E5F0'),
                width: 0.5,
              ),
              headerDecoration: pw.BoxDecoration(
                color: PdfColor.fromHex('#081B2F'),
              ),
              headerStyle: pw.TextStyle(
                color: PdfColors.white,
                fontWeight: pw.FontWeight.bold,
                fontSize: 9,
              ),
              cellStyle: const pw.TextStyle(fontSize: 8),
              cellPadding: const pw.EdgeInsets.all(5),
              headers: const <String>[
                'Hora',
                'Nivel',
                'Evento',
                'Riesgo',
                'PERCLOS',
                'Duracion',
                'Nota',
              ],
              data: sorted.map((event) {
                return <String>[
                  _formatTime(event.dateTime),
                  event.level.label,
                  _eventTitle(event.eventType),
                  event.riskScore.toStringAsFixed(0),
                  event.perclos.toStringAsFixed(2),
                  '${event.durationSeconds.toStringAsFixed(1)} s',
                  event.notes,
                ];
              }).toList(),
            ),
            pw.SizedBox(height: 14),
            pw.Text(
              'Reporte generado localmente. No contiene imagenes ni video.',
              style: pw.TextStyle(
                fontSize: 9,
                color: PdfColor.fromHex('#6B7680'),
              ),
            ),
          ];
        },
      ),
    );

    return document.save();
  }

  pw.Widget _pdfMetric(String label, String value) {
    return pw.Container(
      width: 82,
      padding: const pw.EdgeInsets.all(8),
      decoration: pw.BoxDecoration(
        borderRadius: pw.BorderRadius.circular(5),
        border: pw.Border.all(color: PdfColor.fromHex('#B9D7EC')),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: <pw.Widget>[
          pw.Text(
            label,
            style: pw.TextStyle(
              fontSize: 8,
              color: PdfColor.fromHex('#66717C'),
            ),
          ),
          pw.SizedBox(height: 4),
          pw.Text(
            value,
            style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Future<Uint8List> _buildPng({
    required DateTime day,
    required List<DrowsinessEvent> events,
  }) async {
    final sorted = _sorted(events);
    final visible = sorted.take(48).toList();
    final summary = _DailySummary.fromEvents(sorted);
    const width = 1080.0;
    final height = math.max(1200.0, 520.0 + visible.length * 78.0);
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);

    final background = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: <Color>[
          Color(0xFF020711),
          Color(0xFF08213A),
          Color(0xFF020509),
        ],
      ).createShader(const Rect.fromLTWH(0, 0, width, 1800));
    canvas.drawRect(Rect.fromLTWH(0, 0, width, height), background);

    _drawText(
      canvas,
      'DriverAwake',
      const Offset(56, 54),
      size: 54,
      weight: FontWeight.w900,
      color: Colors.white,
      maxWidth: width - 112,
    );
    _drawText(
      canvas,
      'Reporte diario - ${_formatDay(day)}',
      const Offset(56, 126),
      size: 26,
      weight: FontWeight.w700,
      color: const Color(0xFF8EDFFF),
      maxWidth: width - 112,
    );

    _drawSummaryCard(canvas, summary);

    var y = 430.0;
    _drawText(
      canvas,
      'Eventos del dia',
      Offset(56, y),
      size: 30,
      weight: FontWeight.w900,
      color: Colors.white,
      maxWidth: width - 112,
    );
    y += 56;

    for (final event in visible) {
      _drawEventRow(canvas, event, Offset(56, y), width - 112);
      y += 78;
    }

    if (sorted.length > visible.length) {
      _drawText(
        canvas,
        'PNG: ${visible.length} eventos recientes. El PDF incluye los ${sorted.length} eventos.',
        Offset(56, y + 18),
        size: 22,
        weight: FontWeight.w700,
        color: const Color(0xFFFFC14A),
        maxWidth: width - 112,
      );
    }

    _drawText(
      canvas,
      'Generado localmente. No contiene imagenes ni video.',
      Offset(56, height - 70),
      size: 20,
      weight: FontWeight.w600,
      color: Colors.white.withValues(alpha: 0.55),
      maxWidth: width - 112,
    );

    final picture = recorder.endRecording();
    final image = await picture.toImage(width.toInt(), height.toInt());
    final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
    return byteData!.buffer.asUint8List();
  }

  void _drawSummaryCard(Canvas canvas, _DailySummary summary) {
    final rect = RRect.fromRectAndRadius(
      const Rect.fromLTWH(56, 192, 968, 190),
      const Radius.circular(18),
    );
    canvas.drawRRect(
      rect,
      Paint()..color = const Color(0xFF061326).withValues(alpha: 0.94),
    );
    canvas.drawRRect(
      rect,
      Paint()
        ..color = const Color(0xFF1DA9FF).withValues(alpha: 0.42)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2,
    );

    final metrics = <_MetricSummary>[
      _MetricSummary('Eventos', '${summary.total}', const Color(0xFF8EDFFF)),
      _MetricSummary(
        'Precaucion',
        '${summary.warningCount}',
        const Color(0xFFFFC14A),
      ),
      _MetricSummary(
        'Peligro',
        '${summary.dangerCount}',
        const Color(0xFFFF5A4D),
      ),
      _MetricSummary(
        'Riesgo max.',
        summary.maxRisk.toStringAsFixed(0),
        const Color(0xFF32E65F),
      ),
      _MetricSummary(
        'Promedio',
        summary.averageRisk.toStringAsFixed(0),
        const Color(0xFF8EDFFF),
      ),
      _MetricSummary(
        'Bostezos',
        '${summary.yawnCount}',
        const Color(0xFF32E65F),
      ),
    ];

    for (var i = 0; i < metrics.length; i++) {
      final metric = metrics[i];
      final x = 88.0 + (i % 3) * 310.0;
      final y = 224.0 + (i ~/ 3) * 76.0;
      _drawText(
        canvas,
        metric.label.toUpperCase(),
        Offset(x, y),
        size: 18,
        weight: FontWeight.w800,
        color: Colors.white.withValues(alpha: 0.55),
        maxWidth: 260,
      );
      _drawText(
        canvas,
        metric.value,
        Offset(x, y + 25),
        size: 34,
        weight: FontWeight.w900,
        color: metric.color,
        maxWidth: 260,
      );
    }
  }

  void _drawEventRow(
    Canvas canvas,
    DrowsinessEvent event,
    Offset offset,
    double width,
  ) {
    final color = switch (event.level) {
      DrowsinessLevel.normal => const Color(0xFF32E65F),
      DrowsinessLevel.warning => const Color(0xFFFFC14A),
      DrowsinessLevel.danger => const Color(0xFFFF5A4D),
    };
    final rect = RRect.fromRectAndRadius(
      Rect.fromLTWH(offset.dx, offset.dy, width, 64),
      const Radius.circular(14),
    );
    canvas.drawRRect(
      rect,
      Paint()..color = const Color(0xFF061326).withValues(alpha: 0.82),
    );
    canvas.drawRRect(
      rect,
      Paint()
        ..color = color.withValues(alpha: 0.45)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.4,
    );
    canvas.drawCircle(
      Offset(offset.dx + 28, offset.dy + 32),
      9,
      Paint()..color = color,
    );
    _drawText(
      canvas,
      _formatTime(event.dateTime),
      Offset(offset.dx + 54, offset.dy + 13),
      size: 22,
      weight: FontWeight.w900,
      color: Colors.white,
      maxWidth: 95,
    );
    _drawText(
      canvas,
      _eventTitle(event.eventType),
      Offset(offset.dx + 160, offset.dy + 11),
      size: 23,
      weight: FontWeight.w900,
      color: Colors.white,
      maxWidth: 520,
    );
    _drawText(
      canvas,
      '${event.level.label}  Riesgo ${event.riskScore.toStringAsFixed(0)}',
      Offset(offset.dx + 160, offset.dy + 38),
      size: 17,
      weight: FontWeight.w700,
      color: Colors.white.withValues(alpha: 0.62),
      maxWidth: 520,
    );
    _drawText(
      canvas,
      'PERCLOS ${event.perclos.toStringAsFixed(2)}',
      Offset(offset.dx + width - 190, offset.dy + 21),
      size: 19,
      weight: FontWeight.w900,
      color: color,
      maxWidth: 160,
      align: TextAlign.right,
    );
  }

  void _drawText(
    Canvas canvas,
    String text,
    Offset offset, {
    required double size,
    required FontWeight weight,
    required Color color,
    required double maxWidth,
    TextAlign align = TextAlign.left,
  }) {
    final painter = TextPainter(
      text: TextSpan(
        text: text,
        style: TextStyle(
          color: color,
          fontSize: size,
          fontWeight: weight,
          height: 1.1,
        ),
      ),
      maxLines: 2,
      ellipsis: '...',
      textAlign: align,
      textDirection: TextDirection.ltr,
    )..layout(maxWidth: maxWidth);
    painter.paint(canvas, offset);
  }

  List<DrowsinessEvent> _sorted(List<DrowsinessEvent> events) {
    return events.toList()..sort((a, b) => a.dateTime.compareTo(b.dateTime));
  }

  String _fileStem(DateTime day) {
    final local = day.toLocal();
    return 'driveawake_${local.year}_${local.month.toString().padLeft(2, '0')}_${local.day.toString().padLeft(2, '0')}';
  }
}

class _DailySummary {
  const _DailySummary({
    required this.total,
    required this.warningCount,
    required this.dangerCount,
    required this.yawnCount,
    required this.maxRisk,
    required this.averageRisk,
  });

  final int total;
  final int warningCount;
  final int dangerCount;
  final int yawnCount;
  final double maxRisk;
  final double averageRisk;

  factory _DailySummary.fromEvents(List<DrowsinessEvent> events) {
    final total = events.length;
    final warningCount = events
        .where((event) => event.level == DrowsinessLevel.warning)
        .length;
    final dangerCount = events
        .where((event) => event.level == DrowsinessLevel.danger)
        .length;
    final yawnCount = events
        .where((event) => event.eventType == 'bostezo')
        .length;
    final maxRisk = events.fold<double>(
      0,
      (maxRisk, event) => math.max(maxRisk, event.riskScore),
    );
    final averageRisk = total == 0
        ? 0.0
        : events.fold<double>(0, (sum, event) => sum + event.riskScore) / total;

    return _DailySummary(
      total: total,
      warningCount: warningCount,
      dangerCount: dangerCount,
      yawnCount: yawnCount,
      maxRisk: maxRisk,
      averageRisk: averageRisk,
    );
  }
}

class _MetricSummary {
  const _MetricSummary(this.label, this.value, this.color);

  final String label;
  final String value;
  final Color color;
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

String _formatDay(DateTime dateTime) {
  final local = dateTime.toLocal();
  final day = local.day.toString().padLeft(2, '0');
  final month = local.month.toString().padLeft(2, '0');
  return '$day/$month/${local.year}';
}

String _formatTime(DateTime dateTime) {
  final local = dateTime.toLocal();
  final hour = local.hour.toString().padLeft(2, '0');
  final minute = local.minute.toString().padLeft(2, '0');
  return '$hour:$minute';
}
