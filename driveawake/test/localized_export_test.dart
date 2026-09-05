import 'dart:convert';
import 'dart:io';

import 'package:driveawake/l10n/app_strings.dart';
import 'package:driveawake/models/drowsiness_event.dart';
import 'package:driveawake/models/drowsiness_state.dart';
import 'package:driveawake/services/history_export_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  for (final language in ['es', 'en']) {
    test(
      'PDF contains $language labels and translates existing stored notes',
      () async {
        await initializeDateFormatting(language);
        final date = DateTime(2026, 9, 5, 10, 30);
        final event = DrowsinessEvent(
          id: 'test-event',
          dateTime: date,
          level: DrowsinessLevel.danger,
          eventType: 'bostezo',
          durationSeconds: 3,
          notes: 'Ojos cerrados y cabeza caida',
          riskScore: 90,
        );
        final before = event.toMap();
        final bytes = await HistoryExportService(
          strings: AppStrings(language),
        ).buildDayAsPdf(day: date, events: [event]);
        final pdf = latin1.decode(bytes);
        expect(pdf.startsWith('%PDF-'), isTrue);
        final streams = StringBuffer();
        for (final match in RegExp(
          r'stream\r?\n([\s\S]*?)\r?\nendstream',
        ).allMatches(pdf)) {
          final data = latin1.encode(match[1]!);
          try {
            streams.writeln(latin1.decode(zlib.decode(data)));
          } on FormatException {
            streams.writeln(match[1]);
          }
        }
        // The PDF writer positions words separately; collect its text operands.
        final content = RegExp(
          r'\(([^()]*)\)',
        ).allMatches(streams.toString()).map((match) => match[1]!).join(' ');
        expect(
          content,
          contains(
            language == 'en'
                ? 'Daily drowsiness report'
                : 'Reporte diario de somnolencia',
          ),
        );
        expect(content, contains(language == 'en' ? 'DANGER' : 'PELIGRO'));
        expect(content, contains(language == 'en' ? 'Yawn' : 'Bostezo'));
        expect(
          content,
          contains(
            language == 'en'
                ? 'Eyes closed and head drooping'
                : 'Ojos cerrados y cabeza caida',
          ),
        );
        expect(event.toMap(), before);
      },
    );
  }
}
