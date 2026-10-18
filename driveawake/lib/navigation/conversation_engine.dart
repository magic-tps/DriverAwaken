import '../models/drowsiness_state.dart';
import '../services/voice_command_service.dart';
import 'conversation_topics.dart';

class ConversationContext {
  const ConversationContext({
    required this.monitoring,
    required this.paused,
    required this.reliable,
    required this.driving,
  });
  final DrowsinessState monitoring;
  final bool paused;
  final bool reliable;
  final Duration driving;
  bool get critical => monitoring.level == DrowsinessLevel.danger;
  bool get tired => monitoring.level == DrowsinessLevel.warning;
}

class ConversationReply {
  const ConversationReply(this.text, {this.action, this.end = false});
  final String text;
  final VoiceCommand? action;
  final bool end;
}

String normalizeConversation(String words) {
  var text = words.toLowerCase();
  const accented = 'áàäéèëíìïóòöúùü';
  const plain = 'aaaeeeiiiooouuu';
  for (var i = 0; i < accented.length; i++) {
    text = text.replaceAll(accented[i], plain[i]);
  }
  return text
      .replaceAll(RegExp(r'[^a-zñ\s]'), ' ')
      .replaceAll(RegExp(r'\s+'), ' ')
      .trim();
}

/// Local dialogue with immediate context, not an unrestricted language model.
/// It never changes detector scores, acknowledges alarms, or claims a stop.
class ConversationEngine {
  ConversationTopic topic = ConversationTopic.everyday;
  final _positions = <ConversationTopic, int>{};
  String? _lastQuestion;
  String? _lastFact;
  bool _offeredFact = false;
  int _factIndex = 0;
  int _followups = 0;
  String? _lastDriverDetail;
  bool _supporting = false;
  int _supportTurns = 0;
  final _followupPositions = <ConversationTopic, int>{};

  ConversationReply respond(
    String words,
    ConversationContext context, {
    String language = 'es',
    String? lastUtterance,
  }) {
    String t(String es, String en) => language == 'en' ? en : es;
    final text = normalizeConversation(words);
    bool has(String pattern) => RegExp(pattern).hasMatch(text);
    final command = parseVoiceCommand(words);
    if (command == VoiceCommand.silence ||
        has(
          r'^(adios|hasta luego|terminar conversacion|dejar de conversar|stop conversation|goodbye|no|ahora no|no gracias|prefiero silencio|no thanks|not now)$',
        )) {
      return ConversationReply(
        t(
          'De acuerdo. Te dejo en silencio; las alertas de seguridad siguen activas.',
          'All right. I will be quiet; safety alerts stay active.',
        ),
        end: true,
      );
    }
    if (command == VoiceCommand.pause) {
      return ConversationReply(
        t(
          'Voy a pausar el monitoreo. Tendrás que reanudarlo cuando estés listo.',
          'I will pause monitoring. You will need to resume when ready.',
        ),
        action: command,
      );
    }
    if (command == VoiceCommand.resume) {
      return ConversationReply(
        t(
          'Voy a intentar reanudar el monitoreo. La pantalla confirmará su estado.',
          'I will try to resume monitoring. The screen will confirm its state.',
        ),
        action: command,
      );
    }
    if (command == VoiceCommand.sos) {
      return ConversationReply(
        t(
          'Voy a abrir el panel de emergencia para que confirmes la acción.',
          'I will open the emergency panel so you can confirm the action.',
        ),
        action: command,
      );
    }
    if (command == VoiceCommand.repeat) {
      if (context.critical || context.tired) {
        return ConversationReply(_status(context, language));
      }
      return ConversationReply(
        lastUtterance ??
            t(
              'Todavía no tengo un mensaje que repetir. ¿Cómo te sientes?',
              'There is no previous message yet. How do you feel?',
            ),
      );
    }
    if (has(
      r'\b(voy a parar|voy a detenerme|me voy a detener|i will stop|i am going to stop)\b',
    )) {
      return ConversationReply(
        t(
          'Gracias por avisarme. Detente en un lugar seguro. Seguiré mostrando las señales; tu respuesta no confirma que ya estés detenido.',
          'Thank you for telling me. Stop in a safe place. I will keep showing the signals; your response does not confirm you have stopped.',
        ),
      );
    }
    final fatigue =
        !has(
          r'\b(no tengo sueno|no estoy cansad[oa]|no me siento cansad[oa]|no estoy agotad[oa]|no me estoy durmiendo|no me estoy quedando dormid[oa]|not tired|not sleepy)\b',
        ) &&
        has(
          r'\b(tengo sueno|me da sueno|me estoy durmiendo|me estoy quedando dormid[oa]|no puedo mantener los ojos abiertos|estoy agotad[oa]|estoy cansad[oa]|me siento cansad[oa]|necesito descansar|quiero descansar|necesito un descanso|sleepy|i am tired|i need a break|falling asleep|can t keep my eyes open)\b',
        );
    if (fatigue || command == VoiceCommand.rest) {
      return ConversationReply(
        t(
          'Gracias por decírmelo. Lo más seguro es detenerte y descansar. Te preparo la recomendación; busca paradas solo cuando estés detenido.',
          'Thank you for telling me. The safest choice is to stop and rest. I will prepare the recommendation; search for stops only once parked.',
        ),
        action: VoiceCommand.rest,
      );
    }
    if (command == VoiceCommand.map) {
      return ConversationReply(
        t(
          'Puedo mostrarte las opciones de paradas. Primero confirma en pantalla que el vehículo está detenido.',
          'I can show stop options. First confirm on screen that the vehicle is parked.',
        ),
        action: command,
      );
    }
    if (has(
      r'\b(cuanto tiempo|cuantos minutos|tiempo de conduccion|how long)\b',
    )) {
      final minutes = context.driving.inMinutes;
      return ConversationReply(
        t(
          'Llevas $minutes minutos de conducción registrados. Ese tiempo no mide si estás descansado.',
          'You have $minutes recorded driving minutes. That duration does not measure how rested you are.',
        ),
      );
    }
    if (command == VoiceCommand.status ||
        has(
          r'\b(por que.*(alerta|alarma|avis)|que detectas|que pasa|why.*(alert|alarm)|what do you detect)\b',
        )) {
      return ConversationReply(_status(context, language));
    }
    if (context.critical || context.tired) {
      _offeredFact = false;
      return ConversationReply(
        t(
          context.critical
              ? 'Ahora estoy detectando señales fuertes de somnolencia. Dejemos la charla para después. Detente en un lugar seguro y descansa.'
              : 'Hay señales de cansancio. Prefiero ayudarte a preparar un descanso. ¿Cómo te sientes?',
          context.critical
              ? 'I am detecting strong signs of drowsiness. Let us chat later. Stop safely and rest.'
              : 'There are signs of tiredness. Let us focus on a rest break. How do you feel?',
        ),
      );
    }
    if (has(
      r'\b(recuerdas lo que|que te dije|de que hablabamos|what did i say|what were we talking about)\b',
    )) {
      return ConversationReply(
        _lastDriverDetail == null
            ? t(
                'Aún no me has contado mucho. ¿De qué te gustaría hablar?',
                'You have not told me much yet. What would you like to talk about?',
              )
            : t(
                'Me habías contado: «$_lastDriverDetail». ¿Seguimos por ahí?',
                'You told me: "$_lastDriverDetail". Shall we pick up there?',
              ),
      );
    }
    if (has(
      r'\b(estoy triste|estoy preocupad[oa]|estoy estresad[oa]|mal dia|dia dificil|dia pesado|dia complicado|sad|worried|stressed|bad day|difficult day)\b',
    )) {
      _remember(words);
      _offeredFact = false;
      _supporting = true;
      _supportTurns = 0;
      return ConversationReply(
        t(
          'Suena a un día difícil. Te escucho. ¿Quieres contarme qué pasó? Si te cuesta concentrarte, busca un lugar seguro para parar.',
          'That sounds like a difficult day. I am listening. Would you like to tell me what happened? If concentrating is hard, find a safe place to stop.',
        ),
      );
    }
    if (has(
      r'\b(pon musica|pausa la musica|siguiente cancion|play music|next song)\b',
    )) {
      return ConversationReply(
        t(
          'Puedo conversar sobre música. Para reproducirla, usa tu reproductor cuando estés detenido.',
          'We can talk about music. To play it, use your player while parked.',
        ),
      );
    }
    if (has(r'\b(como te llamas|quien eres|who are you|your name)\b')) {
      _lastQuestion = t('¿Cómo te sientes?', 'How do you feel?');
      return ConversationReply(
        t(
          'Soy el copiloto de DriverAwaken. Puedo acompañarte con una charla breve y explicarte las señales del viaje. ¿Cómo te sientes?',
          'I am your DriverAwaken copilot. I can keep you company with a short chat and explain trip signals. How do you feel?',
        ),
      );
    }
    if (has(
      r'^(hola|buenos dias|buenas tardes|buenas noches|hello|hi|hey)( .*|)$',
    )) {
      _lastQuestion = t('¿Cómo te sientes hoy?', 'How are you feeling today?');
      return ConversationReply(
        t(
          'Hola, me alegra acompañarte. ¿Cómo te sientes hoy?',
          'Hello, glad to be here with you. How are you feeling today?',
        ),
      );
    }
    if (has(r'^(como estas|como te va|how are you)( .*|)$')) {
      _lastQuestion = t('¿Cómo va tu día?', 'How is your day going?');
      return ConversationReply(
        t(
          'Aquí, listo para escucharte. ¿Cómo va tu día?',
          'Here and ready to listen. How is your day going?',
        ),
      );
    }
    if (has(r'\b(gracias|thank you|thanks)\b')) {
      return ConversationReply(
        t(
          _supporting
              ? 'Gracias a ti por contármelo. Podemos seguir hablando o dejarlo aquí, como prefieras.'
              : 'Con gusto. ¿Seguimos con este tema o prefieres otro?',
          _supporting
              ? 'Thank you for sharing that. We can keep talking or leave it here, whichever you prefer.'
              : 'You are welcome. Shall we keep this topic or choose another?',
        ),
      );
    }
    if (has(
      r'^(no se|no se que decir|ni idea|i do not know|i don t know|not sure)$',
    )) {
      _offeredFact = true;
      return ConversationReply(
        t(
          'No pasa nada, no hace falta tener una respuesta. ¿Te cuento una curiosidad o prefieres un rato de silencio?',
          'That is okay, you do not need an answer. Would you like a fact or a little quiet?',
        ),
      );
    }
    if (has(
          r'\b(cuentame algo|dato curioso|algo interesante|otra curiosidad|tell me something|interesting fact)\b',
        ) ||
        (_offeredFact &&
            has(r'^(si|claro|otro|otra|dale|yes|sure|another)( .*|)$'))) {
      if (_factIndex >= conversationFacts.length) {
        _offeredFact = false;
        topic = ConversationTopic.science;
        return ConversationReply(
          t(
            'Ya te conté esas curiosidades. ${_question(language)}',
            'We have covered those facts. What science topic would you like to talk about?',
          ),
        );
      }
      _supporting = false;
      final fact = conversationFacts[_factIndex++];
      _lastFact = language == 'en' ? fact.$2 : fact.$1;
      _lastQuestion = null;
      _offeredFact = true;
      return ConversationReply(
        '$_lastFact ${t('¿Quieres otro dato o prefieres cambiar de tema?', 'Would you like another fact or a different topic?')}',
      );
    }
    if (_lastFact != null &&
        has(
          r'\b(no sabia|que interesante|increible|did not know|interesting|amazing)\b',
        )) {
      _offeredFact = true;
      return ConversationReply(
        t(
          'Es curioso, ¿verdad? Podemos seguir con otra curiosidad o hablar de algo que te guste.',
          'Quite curious, right? We can try another fact or talk about something you enjoy.',
        ),
      );
    }
    if (has(r'\b(ayuda|que puedes hacer|help|what can you do)\b')) {
      return ConversationReply(
        t(
          'Puedes hablarme de tu día, pedir una curiosidad, música o viajes. También puedes decir cómo voy, necesito descansar, pausar o SOS.',
          'Tell me about your day, or ask for a fact, music or travel. You can also say status, I need a break, pause or emergency.',
        ),
      );
    }
    const keywords = <ConversationTopic, String>{
      ConversationTopic.music: r'\b(musica|cancion|cantar|music|song|sing)\b',
      ConversationTopic.travel:
          r'\b(viajes|viajar|playa|sierra|travel|beach|mountain)\b',
      ConversationTopic.peru: r'\b(peru|peruano|peruana|mi tierra|caral)\b',
      ConversationTopic.nature:
          r'\b(naturaleza|animales|bosque|nature|animals|forest)\b',
      ConversationTopic.science:
          r'\b(ciencia|espacio|planetas|science|space|planets)\b',
      ConversationTopic.technology:
          r'\b(tecnologia|inventos|celular|technology|phone)\b',
      ConversationTopic.culture:
          r'\b(cultura|pelicula|libro|culture|film|book)\b',
      ConversationTopic.questions:
          r'\b(pregunta|preguntas|question|questions)\b',
      ConversationTopic.wellbeing:
          r'\b(bienestar|tiempo libre|wellbeing|free time)\b',
    };
    final selected = keywords.entries
        .where((entry) => has(entry.value))
        .firstOrNull
        ?.key;
    final changingTopic = has(
      r'\b(hablemos|hablar de|conversemos|otro tema|cambia.*tema|cambiar.*tema|lets talk|let s talk|talk about|different topic|change.*topic)\b',
    );
    if ((selected != null && selected != topic && !_supporting) ||
        changingTopic) {
      topic =
          selected ??
          ConversationTopic.values[(topic.index + 1) %
              ConversationTopic.values.length];
      _lastQuestion = null;
      _offeredFact = false;
      _followups = 0;
      _supporting = false;
      // An explicit topic request starts with a question. Mentioning a topic
      // in an answer must not discard what the driver just told us.
      if (changingTopic) {
        return ConversationReply(_question(language));
      }
    }
    if (has(
      r'\b(estoy bien|me siento bien|todo bien|bien gracias|i feel good|i am fine|doing well)\b',
    )) {
      _supporting = false;
      final question = _question(language);
      return ConversationReply(
        t(
          'Me alegra que te sientas bien. Sigamos atentos a las señales. $question',
          'Glad you feel well. Let us stay aware of the signals. $question',
        ),
      );
    }
    if (_supporting) {
      _remember(words);
      final first = _supportTurns++ == 0;
      return ConversationReply(
        t(
          first
              ? 'Gracias por contármelo. ¿Qué parte de eso te preocupa más?'
              : 'Te sigo escuchando. ¿Prefieres seguir con esto o hablar de algo más ligero?',
          first
              ? 'Thank you for telling me. Which part worries you most?'
              : 'I am still listening. Would you rather keep talking about this or try something lighter?',
        ),
      );
    }
    if (has(
      r'\b(recuerda|recuerdo|recuerdos|juventud|infancia|reminds me|memories|childhood)\b',
    )) {
      _remember(words);
      return ConversationReply(
        t(
          'Hay cosas que nos llevan de vuelta a otra época. ¿Qué recuerdo te viene a la mente?',
          'Some things take us back to another time. What memory comes to mind?',
        ),
      );
    }
    if (has(
      r'^(por que|como funciona|que es|quien|cuando|donde|why|how does|what is|who|when|where)\b',
    )) {
      return ConversationReply(
        t(
          'No tengo una respuesta fiable para esa pregunta. Podemos seguir hablando del tema o probar con una curiosidad.',
          'I do not have a reliable answer to that question. We can keep talking about the topic or try a fact.',
        ),
      );
    }
    if (_lastQuestion != null || selected != null) {
      _remember(words);
      if (_followups++ < 3) {
        final detail = RegExp(
          r'^(?:me gusta(?:n)?|me encanta(?:n)?|prefiero|i like|i love|i prefer)\s+(.+)$',
          caseSensitive: false,
        ).firstMatch(_lastDriverDetail!);
        final acknowledgement = detail == null || _followups > 1
            ? ''
            : t('Te gusta ${detail[1]}. ', 'You enjoy ${detail[1]}. ');
        return ConversationReply('$acknowledgement${_followup(language)}');
      }
      _followups = 0;
      return ConversationReply(
        t(
          'Gracias por compartirlo. ¿Seguimos con esto o cambiamos de tema?',
          'Thank you for sharing that. Shall we stay with this or change topics?',
        ),
      );
    }
    return ConversationReply(_question(language));
  }

  void _remember(String words) {
    final detail = words.trim().replaceAll(RegExp(r'[\r\n]+'), ' ');
    _lastDriverDetail = detail.length <= 120
        ? detail
        : '${detail.substring(0, 120)}…';
  }

  String _followup(String language) {
    final list = conversationFollowups[topic]!;
    final index = _followupPositions[topic] ?? 0;
    _followupPositions[topic] = index + 1;
    final pair = list[index % list.length];
    return _lastQuestion = language == 'en' ? pair.$2 : pair.$1;
  }

  String _question(String language) {
    final list = conversationPrompts[topic]!;
    final index = _positions[topic] ?? 0;
    _positions[topic] = index + 1;
    final pair = list[index % list.length];
    return _lastQuestion = language == 'en' ? pair.$2 : pair.$1;
  }

  String _status(ConversationContext context, String language) {
    if (language == 'en') {
      if (context.paused) {
        return 'Monitoring is paused. Resume explicitly when ready.';
      }
      if (context.critical) {
        return 'Strong signs of drowsiness detected. Stop safely and rest.';
      }
      if (!context.reliable) {
        return 'The signal is insufficient. Check the camera when parked; I cannot assess fatigue reliably.';
      }
      if (context.tired) {
        return 'Signs of tiredness detected. Plan a safe stop to rest.';
      }
      return 'Monitoring is active. No significant signs of fatigue in the latest reading. Stay attentive to how you feel.';
    }
    if (context.paused) {
      return 'El monitoreo está pausado. Reanúdalo explícitamente cuando estés listo.';
    }
    if (context.critical) {
      return 'Hay señales fuertes de somnolencia. Detente en un lugar seguro y descansa.';
    }
    if (!context.reliable) {
      return 'La señal es insuficiente. Revisa la cámara al detenerte; ahora no puedo evaluar la fatiga de forma fiable.';
    }
    if (context.tired) {
      return 'Hay señales de cansancio. Prepara una parada segura para descansar.';
    }
    return 'El monitoreo está activo. La última lectura no muestra señales importantes de fatiga. Sigue atento a cómo te sientes.';
  }
}
