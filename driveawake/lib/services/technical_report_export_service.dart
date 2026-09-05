import 'dart:io';

import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import '../app/app_config.dart';
import '../models/technical_session_report.dart';

typedef ShareConfirmation = Future<bool> Function();

class TechnicalReportExportService {
  const TechnicalReportExportService();

  Future<bool> confirmAndShare({
    required TechnicalSessionReport report,
    required ShareConfirmation confirm,
  }) async {
    if (!AppConfig.technicalFeaturesEnabled || !await confirm()) return false;
    final directory = await getTemporaryDirectory();
    final file = File(
      '${directory.path}${Platform.pathSeparator}'
      'driverawake-technical-${report.anonymousSessionId}.json',
    );
    await file.writeAsString(report.toJson(), flush: true);
    try {
      await SharePlus.instance.share(
        ShareParams(
          text: 'Reporte técnico anónimo DriverAwake',
          files: <XFile>[
            XFile(
              file.path,
              mimeType: 'application/json',
              name: file.uri.pathSegments.last,
            ),
          ],
        ),
      );
      return true;
    } finally {
      if (await file.exists()) await file.delete();
    }
  }
}
