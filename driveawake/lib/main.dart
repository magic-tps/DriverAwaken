import 'package:flutter/material.dart';

import 'app/app.dart';
import 'data/migration/database_bootstrap.dart';
import 'l10n/locale_controller.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await DatabaseBootstrap.initialize();
  await LocaleController.instance.initialize();
  runApp(const AppConductoresApp());
}
