import '../models/drowsiness_state.dart';

class SpokenSafetyAlert {
  const SpokenSafetyAlert(this.reason, this.lines, {this.critical = false});

  final String reason;
  final List<(String, String)> lines;
  final bool critical;

  String message(String language, int delivery) {
    final line = lines[delivery % lines.length];
    return language == 'en' ? line.$2 : line.$1;
  }
}

/// Brief explanations and a concrete action. Variants share a cooldown so
/// changing the wording never increases the frequency of spoken warnings.
SpokenSafetyAlert? spokenSafetyAlert(DrowsinessState state) {
  if (state.level == DrowsinessLevel.danger) {
    return SpokenSafetyAlert('spoken_danger', [
      state.eyesClosed
          ? (
              'Atención. Detecto un cierre prolongado de ojos. Detente en un lugar seguro y descansa.',
              'Attention. I am detecting prolonged eye closure. Stop in a safe place and rest.',
            )
          : (
              'Atención. Detecto señales fuertes de somnolencia. Detente en un lugar seguro y descansa.',
              'Attention. I am detecting strong signs of drowsiness. Stop in a safe place and rest.',
            ),
      (
        'La alerta de somnolencia continúa. Detente en un lugar seguro tan pronto como sea posible. Necesitas descansar.',
        'The drowsiness alert is continuing. Stop in a safe place as soon as possible. You need to rest.',
      ),
    ], critical: true);
  }
  if (state.noFaceTooLong) {
    return const SpokenSafetyAlert('spoken_signal', [
      (
        'No consigo ver bien tu rostro. Cuando estés detenido, revisa la posición de la cámara.',
        'I cannot see your face clearly. Once parked, check the camera position.',
      ),
      (
        'Sigo sin ver bien tu rostro. Ahora no puedo evaluar el cansancio. Revisa la cámara al detenerte.',
        'I still cannot see your face clearly. I cannot assess tiredness right now. Check the camera once parked.',
      ),
    ]);
  }
  if (state.level != DrowsinessLevel.warning) return null;
  if (state.yawning || state.yawnCountWindow >= 3) {
    return const SpokenSafetyAlert('spoken_warning', [
      (
        'He notado bostezos. ¿Cómo te sientes? Busca un lugar seguro para parar y descansar.',
        'I have noticed yawning. How are you feeling? Find a safe place to stop and rest.',
      ),
      (
        'Siguen apareciendo señales de cansancio. Hagamos una pausa: busca un lugar seguro para descansar.',
        'Signs of tiredness are continuing. Time for a break: find a safe place to rest.',
      ),
    ]);
  }
  if (state.headDown || state.distracted) {
    return const SpokenSafetyAlert('spoken_warning', [
      (
        'He notado que apartas la cabeza del camino. Mantén la atención al frente. Si estás cansado, detente en un lugar seguro.',
        'I have noticed your head turning away from the road. Keep your attention ahead. If you are tired, stop safely.',
      ),
      (
        'Vuelvo a detectar la cabeza fuera de posición. Atiende al camino y busca una parada segura si necesitas descansar.',
        'I am detecting your head out of position again. Focus on the road and find a safe stop if you need rest.',
      ),
    ]);
  }
  return const SpokenSafetyAlert('spoken_warning', [
    (
      'Estoy notando señales de cansancio. ¿Cómo te encuentras? Lo más seguro es buscar un lugar para parar y descansar.',
      'I am noticing signs of tiredness. How are you feeling? The safest choice is to find a place to stop and rest.',
    ),
    (
      'Las señales de cansancio continúan. Dejemos la charla para después y prepara una parada segura para descansar.',
      'Signs of tiredness are continuing. Let us chat later and plan a safe stop to rest.',
    ),
  ]);
}
