import 'package:driveawake/services/voice_command_service.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('Spanish commands tolerate punctuation and accents', () {
    expect(parseVoiceCommand('¡Abrir mapa!'), VoiceCommand.map);
    expect(parseVoiceCommand('NAVEGACIÓN'), VoiceCommand.map);
    expect(parseVoiceCommand('  Reanudar  monitoreo '), VoiceCommand.resume);
    expect(parseVoiceCommand('pausar'), VoiceCommand.pause);
    expect(parseVoiceCommand('S.O.S.'), VoiceCommand.sos);
    expect(parseVoiceCommand('emergencia'), VoiceCommand.sos);
  });
  test('negations and incidental words never trigger commands', () {
    for (final phrase in [
      'no pausar',
      'no quiero emergencia',
      'no abrir mapa',
      'despausar',
      'creo que necesito una pausa',
      'no necesito descansar',
      'me dijo que pausara el viaje',
      '',
    ]) {
      expect(parseVoiceCommand(phrase), isNull, reason: phrase);
    }
  });
  test('natural short requests map to explicit, safe actions', () {
    expect(
      parseVoiceCommand('Por favor pausar el monitoreo'),
      VoiceCommand.pause,
    );
    expect(parseVoiceCommand('Retomar la cámara'), VoiceCommand.resume);
    expect(parseVoiceCommand('Abre Google Maps'), VoiceCommand.map);
    expect(parseVoiceCommand('Necesito descansar'), VoiceCommand.rest);
    expect(parseVoiceCommand('Estoy cansada'), VoiceCommand.rest);
    expect(parseVoiceCommand('Silencio'), VoiceCommand.silence);
    expect(parseVoiceCommand('Repite'), VoiceCommand.repeat);
    expect(parseVoiceCommand('¿Cómo voy?'), VoiceCommand.status);
  });
}
