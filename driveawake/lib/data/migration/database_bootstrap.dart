import 'package:shared_preferences/shared_preferences.dart';

import '../database/database_provider.dart';
import 'legacy_preferences_migrator.dart';

class DatabaseBootstrap {
  const DatabaseBootstrap._();

  static Future<bool> initialize() async {
    final preferences = await SharedPreferences.getInstance();
    return LegacyPreferencesMigrator(
      database: DatabaseProvider.database,
      preferences: preferences,
    ).run();
  }
}
