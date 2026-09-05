import 'driver_awake_database.dart';

class DatabaseProvider {
  DatabaseProvider._();

  static DriverAwakeDatabase? _database;

  static DriverAwakeDatabase get database =>
      _database ??= DriverAwakeDatabase();

  static void overrideForTesting(DriverAwakeDatabase database) {
    _database = database;
  }

  static Future<void> reset() async {
    final database = _database;
    _database = null;
    await database?.close();
  }
}
