import 'package:flutter_test/flutter_test.dart';
import 'package:driveawake/navigation/conversation_engine.dart';
import 'package:driveawake/navigation/conversation_topics.dart';
import 'package:driveawake/models/drowsiness_state.dart';
import 'package:driveawake/services/voice_command_service.dart';

ConversationContext context({
  DrowsinessLevel level = DrowsinessLevel.normal,
  bool reliable = true,
  bool paused = false,
}) => ConversationContext(
  monitoring: DrowsinessState.initial().copyWith(
    level: level,
    faceDetected: reliable,
    signalQuality: reliable ? .9 : .1,
  ),
  paused: paused,
  reliable: reliable,
  driving: const Duration(minutes: 37),
);

void main() {
  test('a free answer to the greeting is remembered and followed up', () {
    final engine = ConversationEngine();
    engine.respond('Hola', context());
    expect(
      engine.respond('Pasé el día trabajando', context()).text,
      contains('sentir'),
    );
    expect(
      engine.respond('¿Qué te dije?', context()).text,
      contains('Pasé el día trabajando'),
    );
  });
  test('music answers stay on topic across turns and can be recalled', () {
    final engine = ConversationEngine();
    engine.respond('Hablemos de música', context());
    final preference = engine.respond(
      'Me gusta el rock de los ochenta',
      context(),
    );
    expect(preference.text, contains('rock de los ochenta'));
    expect(preference.text, contains('banda'));
    final memory = engine.respond('Me recuerda mi juventud', context());
    expect(memory.text, contains('recuerdo'));
    final recall = engine.respond('¿Qué te dije?', context());
    expect(recall.text, contains('Me recuerda mi juventud'));
    expect(engine.topic, ConversationTopic.music);
    expect(
      ConversationEngine().respond('¿Qué te dije?', context()).text,
      isNot(contains('juventud')),
    );
  });
  test('distress followups listen instead of asking what the driver likes', () {
    final engine = ConversationEngine();
    expect(
      engine.respond('Tuve un día difícil', context()).text,
      contains('qué pasó'),
    );
    final detail = engine.respond('Discutí con alguien del trabajo', context());
    expect(detail.text, contains('preocupa'));
    expect(detail.text, isNot(contains('gusta')));
    engine.respond('Hablemos de viajes', context());
    expect(
      engine.respond('Me gusta ir a la costa', context()).text,
      contains('lugar'),
    );
  });
  test(
    'uncertainty and unsupported questions do not produce random answers',
    () {
      final engine = ConversationEngine();
      engine.respond('Hola', context());
      expect(engine.respond('No sé', context()).text, contains('No pasa nada'));
      expect(engine.respond('Sí', context()).text, contains('pulpo'));
      expect(
        engine.respond('¿Por qué el cielo es azul?', context()).text,
        contains('respuesta fiable'),
      );
      expect(engine.respond('No gracias', context()).end, isTrue);
    },
  );
  test('natural fatigue phrases trigger rest but negations do not', () {
    for (final words in [
      'Me estoy quedando dormida',
      'No puedo mantener los ojos abiertos',
      'Estoy agotado',
      "I can't keep my eyes open",
    ]) {
      expect(
        ConversationEngine().respond(words, context()).action,
        VoiceCommand.rest,
        reason: words,
      );
    }
    for (final words in ['No estoy agotado', 'No me estoy quedando dormida']) {
      expect(
        ConversationEngine().respond(words, context()).action,
        isNull,
        reason: words,
      );
    }
    expect(
      ConversationEngine()
          .respond('Oye copiloto pausa el monitoreo', context())
          .action,
      VoiceCommand.pause,
    );
  });
  test('English emotional followups retain the driver context', () {
    final engine = ConversationEngine();
    expect(
      engine.respond('I had a difficult day', context(), language: 'en').text,
      contains('difficult day'),
    );
    expect(
      engine.respond('Trouble at work', context(), language: 'en').text,
      contains('worries you'),
    );
    expect(
      engine.respond('What did I say', context(), language: 'en').text,
      contains('Trouble at work'),
    );
  });
  test('a curiosity, surprise and yes retain immediate context', () {
    final engine = ConversationEngine();
    final first = engine.respond('Cuéntame algo interesante', context());
    expect(first.text, contains('pulpo'));
    final followup = engine.respond('No sabía eso', context());
    expect(followup.text, contains('otra curiosidad'));
    final next = engine.respond('Sí, claro', context());
    expect(next.text, contains('Venus'));
    expect(next.text, isNot(first.text));
  });
  test('topic change and free answers have contextual followups', () {
    final engine = ConversationEngine();
    expect(
      engine.respond('Hablemos de música', context()).text,
      contains('música'),
    );
    expect(engine.topic, ConversationTopic.music);
    expect(
      engine.respond('Me gusta el rock de los ochenta', context()).text,
      contains('rock de los ochenta'),
    );
    expect(
      engine.respond('Me recuerda mi juventud', context()).text,
      isNot(contains('Me cuentas')),
    );
    engine.respond('Cambia de tema', context());
    expect(engine.topic, isNot(ConversationTopic.music));
  });
  test('100 editable bilingual prompts are unique', () {
    final all = conversationPrompts.values.expand((value) => value).toList();
    expect(all.length, 100);
    expect(all.map((value) => value.$1).toSet().length, 100);
    expect(all.every((value) => value.$2.isNotEmpty), isTrue);
  });
  test(
    'reported fatigue requests rest without changing detector or claiming upload',
    () {
      final state = context();
      final reply = ConversationEngine().respond('Me estoy durmiendo', state);
      expect(reply.action, VoiceCommand.rest);
      expect(state.monitoring.level, DrowsinessLevel.normal);
      expect(reply.text, isNot(contains('enviado')));
      expect(
        ConversationEngine().respond('No tengo sueño', state).action,
        isNull,
      );
    },
  );
  test(
    'critical fatigue blocks recreational replies including after pausing',
    () {
      final engine = ConversationEngine();
      for (final paused in [false, true]) {
        final state = context(level: DrowsinessLevel.danger, paused: paused);
        final reply = engine.respond('Cuéntame algo interesante', state);
        expect(reply.text, contains('Detente'));
        expect(reply.text, isNot(contains('pulpo')));
        expect(reply.action, isNull);
        expect(engine.respond('Estoy bien', state).text, contains('Detente'));
        expect(
          engine
              .respond(
                'Repite',
                state,
                lastUtterance: 'Un pulpo tiene tres corazones',
              )
              .text,
          isNot(contains('pulpo')),
        );
        expect(
          engine.respond('Voy a parar', state).text,
          contains('no confirma'),
        );
      }
    },
  );
  test(
    'warning suppresses entertainment and silence never disables alerts',
    () {
      final engine = ConversationEngine();
      expect(
        engine
            .respond('Otra curiosidad', context(level: DrowsinessLevel.warning))
            .text,
        contains('descanso'),
      );
      final silence = engine.respond('Deja de hablar', context());
      expect(silence.end, isTrue);
      expect(silence.action, isNull);
      expect(
        engine
            .respond('No gracias', context(level: DrowsinessLevel.danger))
            .end,
        isTrue,
      );
    },
  );
  test('status is based on actual signal, pause and recorded time', () {
    final engine = ConversationEngine();
    expect(
      engine.respond('Cómo voy', context(reliable: false)).text,
      contains('insuficiente'),
    );
    expect(
      engine.respond('Cómo voy', context(paused: true)).text,
      contains('pausado'),
    );
    expect(
      engine.respond('Cuánto tiempo llevo', context()).text,
      contains('37 minutos'),
    );
    expect(
      engine.respond('No reanudes el monitoreo', context(paused: true)).action,
      isNull,
    );
    expect(
      engine
          .respond(
            'Oye por favor puedes reanudar el monitoreo',
            context(paused: true),
          )
          .action,
      VoiceCommand.resume,
    );
  });
  test('English recognition and response use the selected language', () {
    final engine = ConversationEngine();
    expect(
      engine
          .respond('Tell me something interesting', context(), language: 'en')
          .text,
      contains('octopus'),
    );
    expect(
      engine.respond('I feel sleepy', context(), language: 'en').action,
      VoiceCommand.rest,
    );
    expect(
      engine.respond('status', context(reliable: false), language: 'en').text,
      contains('insufficient'),
    );
  });
}
