import 'package:flutter/material.dart';

import 'app/app.dart';
import 'data/migration/database_bootstrap.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await DatabaseBootstrap.initialize();
  runApp(const AppConductoresApp());
}
