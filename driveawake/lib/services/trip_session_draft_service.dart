import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../data/database/database_provider.dart';
import '../data/repositories/drift_trip_repository.dart';
import '../models/trip_session_draft.dart';

class TripSessionDraftService {
  TripSessionDraftService._();

  static final TripSessionDraftService instance = TripSessionDraftService._();
  static const String _storageKey = 'driverawake_incomplete_trip_v1';

  DriftTripRepository get _repository =>
      DriftTripRepository(DatabaseProvider.database);

  Future<TripSessionDraft?> load() async {
    try {
      final draft = await _repository.loadDraft();
      if (draft != null) return draft;
    } catch (_) {
      // Fall through to the retained legacy value if SQLite is unavailable.
    }
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_storageKey);
    if (raw == null || raw.isEmpty) return null;
    try {
      final draft = TripSessionDraft.fromMap(
        jsonDecode(raw) as Map<String, dynamic>,
      );
      return draft.incomplete ? draft : null;
    } catch (_) {
      return null;
    }
  }

  Future<void> save(TripSessionDraft draft) async {
    try {
      await _repository.saveDraft(draft);
    } catch (_) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_storageKey, jsonEncode(draft.toMap()));
    }
  }

  Future<void> clear() async {
    try {
      await _repository.clearDraft();
    } catch (_) {
      // The retained fallback is removed below as well.
    }
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_storageKey);
  }
}
