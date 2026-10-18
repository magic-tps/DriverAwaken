import 'package:shared_preferences/shared_preferences.dart';

import '../models/drowsiness_event.dart';
import '../models/drowsiness_state.dart';
import 'local_history_service.dart';

class EmergencyService {
  static const contactKey = 'guardian_emergency_contact_v1';
  Future<String> contact() async =>
      (await SharedPreferences.getInstance()).getString(contactKey) ?? '';

  Future<void> saveContact(String value) async {
    if (value.isNotEmpty && !RegExp(r'^\+?[0-9]{6,15}$').hasMatch(value)) {
      throw const FormatException('Usa de 6 a 15 dígitos, con + opcional.');
    }
    final prefs = await SharedPreferences.getInstance();
    if (value.isEmpty) {
      await prefs.remove(contactKey);
    } else {
      await prefs.setString(contactKey, value);
    }
  }

  Future<void> recordManualIncident({String? tripId}) {
    final now = DateTime.now();
    return LocalHistoryService.instance.addEvent(
      DrowsinessEvent(
        id: 'manual_sos_${now.microsecondsSinceEpoch}',
        dateTime: now,
        level: DrowsinessLevel.normal,
        eventType: 'sos_manual',
        durationSeconds: 0,
        notes:
            'Solicitud manual de asistencia. No es una detección de fatiga ni una llamada realizada.',
        tripId: tripId,
      ),
    );
  }
}
