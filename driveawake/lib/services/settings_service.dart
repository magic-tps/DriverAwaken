import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../data/database/database_provider.dart';
import '../data/database/driver_awake_database.dart' hide AppSettings;
import '../models/app_settings.dart';

class SettingsService extends ChangeNotifier {
  SettingsService._();

  static final SettingsService instance = SettingsService._();
  static const String _storageKey = 'driverawake_app_settings_v1';
  static const String _legacyStorageKey = 'magicdrive_app_settings_v1';

  AppSettings _settings = AppSettings.defaults();
  bool _initialized = false;

  AppSettings get settings => _settings;
  bool get initialized => _initialized;

  Future<void> initialize() async {
    if (_initialized) return;
    final database = DatabaseProvider.database;
    try {
      final row = await (database.select(
        database.appSettings,
      )..where((table) => table.id.equals('current'))).getSingleOrNull();
      if (row != null) {
        _settings = AppSettings.fromMap(
          jsonDecode(row.payloadJson) as Map<String, dynamic>,
        );
        _initialized = true;
        return;
      }
    } catch (_) {
      // Legacy fallback below keeps settings available if SQLite cannot open.
    }

    final prefs = await SharedPreferences.getInstance();
    final currentRaw = prefs.getString(_storageKey);
    final legacyRaw = prefs.getString(_legacyStorageKey);
    final raw = currentRaw ?? legacyRaw;
    if (raw != null) {
      try {
        _settings = AppSettings.fromMap(
          jsonDecode(raw) as Map<String, dynamic>,
        );
        if (currentRaw == null && legacyRaw != null) {
          await prefs.setString(_storageKey, legacyRaw);
          await prefs.remove(_legacyStorageKey);
        }
      } catch (_) {
        _settings = AppSettings.defaults();
      }
    }
    _initialized = true;
  }

  Future<void> update(AppSettings settings) async {
    await initialize();
    _settings = settings;
    try {
      final database = DatabaseProvider.database;
      await database
          .into(database.appSettings)
          .insertOnConflictUpdate(
            AppSettingsCompanion.insert(
              id: 'current',
              payloadJson: jsonEncode(settings.toMap()),
              updatedAt: DateTime.now(),
            ),
          );
    } catch (_) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_storageKey, jsonEncode(settings.toMap()));
    }
    notifyListeners();
  }

  Future<void> resetDefaults() async {
    _settings = AppSettings.defaults();
    _initialized = true;
    try {
      final database = DatabaseProvider.database;
      await database.transaction(() async {
        await (database.delete(
          database.appSettings,
        )..where((table) => table.id.equals('current'))).go();
      });
    } catch (_) {}
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_storageKey);
    await prefs.remove(_legacyStorageKey);
    notifyListeners();
  }
}
