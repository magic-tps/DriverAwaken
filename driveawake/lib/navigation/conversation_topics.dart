enum ConversationTopic {
  everyday,
  travel,
  music,
  nature,
  science,
  peru,
  technology,
  culture,
  questions,
  wellbeing,
}

/// Continuations stay on the current subject instead of starting an interview
/// with an unrelated prompt after every answer.
const conversationFollowups = <ConversationTopic, List<(String, String)>>{
  ConversationTopic.everyday: [
    ('¿Cómo te hizo sentir eso?', 'How did that make you feel?'),
    (
      '¿Fue algo distinto a lo habitual?',
      'Was that different from your usual day?',
    ),
    (
      '¿Qué te gustaría hacer después?',
      'What would you like to do afterwards?',
    ),
  ],
  ConversationTopic.music: [
    (
      '¿Hay alguna banda o cantante que te guste especialmente?',
      'Is there a band or singer you especially enjoy?',
    ),
    (
      '¿Qué canción elegirías de su repertorio?',
      'Which of their songs would you choose?',
    ),
    (
      '¿Qué es lo que te gusta de esa música?',
      'What do you enjoy about that music?',
    ),
  ],
  ConversationTopic.travel: [
    ('¿Qué te atrae de ese lugar?', 'What draws you to that place?'),
    ('¿Te gustaría ir con alguien?', 'Would you like to go with someone?'),
    (
      '¿Qué te gustaría hacer allí con tiempo?',
      'What would you like to do there with time to spare?',
    ),
  ],
  ConversationTopic.nature: [
    (
      '¿Qué es lo que más te llama la atención de eso?',
      'What interests you most about that?',
    ),
    ('¿Lo has visto de cerca alguna vez?', 'Have you ever seen it up close?'),
    ('¿Qué te gustaría conocer mejor?', 'What would you like to know better?'),
  ],
  ConversationTopic.science: [
    (
      '¿Qué te da más curiosidad de ese tema?',
      'What makes you most curious about that topic?',
    ),
    ('¿Cómo empezó ese interés?', 'How did that interest start?'),
    (
      '¿Quieres una curiosidad o seguimos hablando de lo que te interesa?',
      'Would you like a fact or shall we keep talking about your interests?',
    ),
  ],
  ConversationTopic.peru: [
    (
      '¿Qué es lo que más te gusta de ese lugar o costumbre?',
      'What do you enjoy most about that place or tradition?',
    ),
    ('¿Lo compartes con tu familia?', 'Do you share it with your family?'),
    (
      '¿Qué recomendarías a alguien que quiera conocerlo?',
      'What would you suggest to someone who wants to discover it?',
    ),
  ],
  ConversationTopic.technology: [
    (
      '¿En qué te ayuda en tu día a día?',
      'How does it help in your everyday life?',
    ),
    (
      '¿Qué te gustaría que fuera más sencillo?',
      'What would you like to be simpler?',
    ),
    ('¿Cómo lo hacías antes?', 'How did you do that before?'),
  ],
  ConversationTopic.culture: [
    ('¿Qué fue lo que más te gustó?', 'What did you enjoy most?'),
    (
      '¿Te recordó alguna otra historia?',
      'Did it remind you of another story?',
    ),
    ('¿Se lo recomendarías a alguien?', 'Would you recommend it to someone?'),
  ],
  ConversationTopic.questions: [
    ('¿Qué te llevó a elegir eso?', 'What led you to choose that?'),
    ('¿Siempre lo has visto así?', 'Have you always seen it that way?'),
    (
      '¿Quieres otra pregunta o seguimos con esta?',
      'Would you like another question or shall we stay with this one?',
    ),
  ],
  ConversationTopic.wellbeing: [
    ('¿Qué es lo que te ayuda a desconectar?', 'What helps you switch off?'),
    (
      '¿Sueles reservar un momento para eso?',
      'Do you usually make time for that?',
    ),
    (
      '¿Hay algo sencillo que te gustaría hacer en tu próximo descanso?',
      'Is there something simple you would like to do on your next break?',
    ),
  ],
};

/// Editable, short prompts. Questions make no factual or medical claims.
/// Text is held in memory only; it is never sent to Firebase.
const conversationPrompts = <ConversationTopic, List<(String, String)>>{
  ConversationTopic.everyday: [
    ('¿Cómo te ha ido hoy?', 'How has your day been?'),
    ('¿Qué fue lo mejor de tu día?', 'What was the best part of your day?'),
    (
      '¿Qué te gusta hacer en tus días libres?',
      'What do you enjoy on days off?',
    ),
    ('¿Tienes algún plan que te ilusione?', 'Any plans you are excited about?'),
    (
      '¿Prefieres madrugar o empezar con calma?',
      'Do you like an early or a slow start?',
    ),
    ('¿Qué comida te recuerda a casa?', 'What food reminds you of home?'),
    (
      '¿Hay algo que quieras aprender?',
      'Is there something you want to learn?',
    ),
    (
      '¿Qué pequeña cosa te alegra el día?',
      'What small thing brightens your day?',
    ),
    (
      '¿Con quién te gusta compartir una buena noticia?',
      'Who do you like sharing good news with?',
    ),
    (
      '¿De qué te gustaría conversar ahora?',
      'What would you like to talk about now?',
    ),
  ],
  ConversationTopic.travel: [
    (
      '¿Qué lugar te gustaría conocer con tiempo?',
      'What place would you like to explore?',
    ),
    (
      '¿Prefieres un viaje a la costa o a la sierra?',
      'Would you choose the coast or the mountains?',
    ),
    ('¿Qué viaje recuerdas con cariño?', 'What trip do you remember fondly?'),
    ('¿Te gusta viajar acompañado?', 'Do you like travelling with company?'),
    (
      '¿Qué paisaje te llama más la atención?',
      'What kind of landscape interests you?',
    ),
    ('¿Qué llevas siempre en un viaje?', 'What do you always take on a trip?'),
    (
      '¿Te gusta probar la comida de cada lugar?',
      'Do you like trying local food?',
    ),
    (
      '¿Qué lugar recomendarías para pasear?',
      'What place would you recommend visiting?',
    ),
    (
      '¿Prefieres conocer una ciudad o la naturaleza?',
      'Would you explore a city or nature?',
    ),
    (
      '¿Hay algún destino al que quieras volver?',
      'Is there a place you would return to?',
    ),
  ],
  ConversationTopic.music: [
    ('¿Qué música te gusta escuchar?', 'What music do you enjoy?'),
    (
      '¿Hay una canción que te recuerde a alguien?',
      'Does a song remind you of someone?',
    ),
    (
      '¿Prefieres música instrumental o con letra?',
      'Do you prefer instrumental music or songs?',
    ),
    (
      '¿Has ido a algún concierto que recuerdes?',
      'Do you remember a special concert?',
    ),
    (
      '¿Qué instrumento te gustaría aprender?',
      'What instrument would you learn?',
    ),
    ('¿Te gusta cantar cuando estás en casa?', 'Do you enjoy singing at home?'),
    (
      '¿Qué artista escuchabas de pequeño?',
      'What artist did you listen to growing up?',
    ),
    (
      '¿Qué música pondrías para una reunión?',
      'What music would you choose for a gathering?',
    ),
    (
      '¿Te gusta descubrir artistas nuevos?',
      'Do you like discovering new artists?',
    ),
    (
      '¿Qué canción te trae un buen recuerdo?',
      'What song brings back a good memory?',
    ),
  ],
  ConversationTopic.nature: [
    (
      '¿Prefieres el mar, el bosque o la montaña?',
      'Do you prefer the sea, forest or mountains?',
    ),
    (
      '¿Qué animal te parece más curioso?',
      'What animal do you find interesting?',
    ),
    ('¿Te gusta cuidar plantas?', 'Do you enjoy caring for plants?'),
    (
      '¿Qué paisaje natural recuerdas mejor?',
      'What natural landscape do you remember best?',
    ),
    (
      '¿Has visto un amanecer que te sorprendiera?',
      'Have you seen a memorable sunrise?',
    ),
    (
      '¿Tienes una estación del año favorita?',
      'Do you have a favourite season?',
    ),
    (
      '¿Qué sonido de la naturaleza te gusta?',
      'What sound of nature do you like?',
    ),
    (
      '¿Te gustaría conocer un parque natural?',
      'Would you like to visit a nature reserve?',
    ),
    ('¿Qué te gusta de estar al aire libre?', 'What do you enjoy outdoors?'),
    ('¿Has tenido alguna mascota?', 'Have you ever had a pet?'),
  ],
  ConversationTopic.science: [
    (
      '¿Te da más curiosidad el espacio o el océano?',
      'Are you more curious about space or the ocean?',
    ),
    (
      '¿Qué te gustaría preguntarle a un astronauta?',
      'What would you ask an astronaut?',
    ),
    (
      '¿Qué invento te parece más útil?',
      'What invention do you find most useful?',
    ),
    (
      '¿Te gustaría visitar un museo de ciencia?',
      'Would you visit a science museum?',
    ),
    (
      '¿Qué tema científico te gustaría entender?',
      'What science topic would you like to understand?',
    ),
    (
      '¿Has mirado el cielo con un telescopio?',
      'Have you looked through a telescope?',
    ),
    (
      '¿Qué invento te gustaría ver en el futuro?',
      'What invention would you like to see?',
    ),
    (
      '¿Te interesa más la astronomía o la biología?',
      'Do you prefer astronomy or biology?',
    ),
    (
      '¿Recuerdas algún experimento de la escuela?',
      'Do you remember a school experiment?',
    ),
    (
      '¿Qué descubrimiento te ha sorprendido?',
      'What discovery has surprised you?',
    ),
  ],
  ConversationTopic.peru: [
    (
      '¿Qué lugar del Perú te gustaría conocer?',
      'What place in Peru would you like to visit?',
    ),
    (
      '¿Qué plato peruano recomendarías?',
      'What Peruvian dish would you recommend?',
    ),
    (
      '¿Qué tradición de tu ciudad te gusta?',
      'What tradition from your city do you like?',
    ),
    (
      '¿Qué recuerdo tienes de tu tierra?',
      'What do you remember about your hometown?',
    ),
    (
      '¿Has viajado por la selva peruana?',
      'Have you visited the Peruvian Amazon?',
    ),
    (
      '¿Qué fiesta local te gustaría visitar?',
      'What local celebration would you visit?',
    ),
    (
      '¿Qué paisaje peruano recuerdas más?',
      'What Peruvian landscape stands out to you?',
    ),
    (
      '¿Qué comida probarías en tu próximo descanso?',
      'What food would you try on your next break?',
    ),
    (
      '¿Qué artesanía de tu región conoces?',
      'What crafts from your region do you know?',
    ),
    (
      '¿Qué te gusta contar de tu ciudad?',
      'What do you like telling people about your city?',
    ),
  ],
  ConversationTopic.technology: [
    (
      '¿Qué tecnología te facilita el trabajo?',
      'What technology makes your work easier?',
    ),
    (
      '¿Qué función te gustaría tener en el teléfono?',
      'What phone feature would you like?',
    ),
    ('¿Recuerdas tu primer celular?', 'Do you remember your first phone?'),
    (
      '¿Qué invento cotidiano agradeces más?',
      'What everyday invention do you appreciate?',
    ),
    (
      '¿Te gusta aprender a usar herramientas nuevas?',
      'Do you like learning new tools?',
    ),
    ('¿Qué tarea te gustaría automatizar?', 'What task would you automate?'),
    (
      '¿Prefieres leer en papel o en pantalla?',
      'Do you prefer paper or a screen for reading?',
    ),
    (
      '¿Qué aplicación usas más fuera del trabajo?',
      'What app do you use outside work?',
    ),
    (
      '¿Qué mejorarías de las aplicaciones que usas?',
      'What would you improve in the apps you use?',
    ),
    (
      '¿Qué tecnología te sorprendió al conocerla?',
      'What technology surprised you?',
    ),
  ],
  ConversationTopic.culture: [
    (
      '¿Qué película te gustaría volver a ver?',
      'What film would you watch again?',
    ),
    (
      '¿Hay un libro que recomendarías?',
      'Is there a book you would recommend?',
    ),
    (
      '¿Qué historia te contaban de pequeño?',
      'What stories did you hear growing up?',
    ),
    (
      '¿Te gustan más las comedias o las aventuras?',
      'Do you prefer comedy or adventure?',
    ),
    ('¿Qué museo te gustaría conocer?', 'What museum would you like to visit?'),
    (
      '¿Hay un personaje histórico que te interese?',
      'Is there a historical figure that interests you?',
    ),
    (
      '¿Qué costumbre familiar quieres conservar?',
      'What family tradition would you keep?',
    ),
    (
      '¿Qué serie te ha gustado últimamente?',
      'What series have you enjoyed lately?',
    ),
    ('¿Te gusta escuchar historias cortas?', 'Do you enjoy short stories?'),
    (
      '¿Qué palabra de tu región te gusta usar?',
      'What local word do you like using?',
    ),
  ],
  ConversationTopic.questions: [
    (
      'Si tuvieras un día libre, ¿qué harías?',
      'What would you do with a free day?',
    ),
    ('¿Elegirías cocinar o salir a comer?', 'Would you cook or eat out?'),
    ('¿Qué habilidad te gustaría aprender?', 'What skill would you learn?'),
    ('¿Prefieres el frío o el calor?', 'Do you prefer cool or warm weather?'),
    (
      '¿Qué te gustaría hacer un fin de semana?',
      'What would you do at the weekend?',
    ),
    ('¿Qué consejo útil recuerdas?', 'What useful advice do you remember?'),
    (
      '¿Qué lugar te hace sentir en casa?',
      'What place feels like home to you?',
    ),
    ('¿Qué afición te gustaría retomar?', 'What hobby would you return to?'),
    (
      '¿Qué detalle te gusta de tu trabajo?',
      'What do you enjoy about your work?',
    ),
    (
      '¿Qué te gustaría celebrar este año?',
      'What would you like to celebrate this year?',
    ),
  ],
  ConversationTopic.wellbeing: [
    ('¿Cómo te sientes en este momento?', 'How do you feel right now?'),
    (
      '¿Qué te gusta hacer cuando ya descansaste?',
      'What do you enjoy after resting?',
    ),
    (
      '¿Qué hace agradable una pausa para ti?',
      'What makes a break pleasant for you?',
    ),
    (
      '¿Qué te ayuda a desconectar del trabajo?',
      'What helps you switch off after work?',
    ),
    (
      '¿Tienes un lugar tranquilo favorito?',
      'Do you have a favourite quiet place?',
    ),
    (
      '¿Con quién disfrutas pasar tus días libres?',
      'Who do you enjoy your days off with?',
    ),
    (
      '¿Cómo te gusta organizar tu tiempo libre?',
      'How do you like spending free time?',
    ),
    (
      '¿Qué actividad tranquila disfrutas?',
      'What quiet activity do you enjoy?',
    ),
    (
      '¿Qué te gustaría hacer después de descansar?',
      'What would you like to do after resting?',
    ),
    (
      '¿Prefieres una charla breve o un momento de silencio?',
      'Would you prefer a short chat or some quiet?',
    ),
  ],
};

const conversationFacts = <(String, String, String)>[
  (
    'Un pulpo tiene tres corazones: dos llevan la sangre a las branquias y otro al resto del cuerpo.',
    'An octopus has three hearts: two send blood to its gills and one to the rest of its body.',
    'https://ocean.si.edu/ocean-life/invertebrates/octopuses-squids-and-relatives',
  ),
  (
    'Venus tarda unos 243 días terrestres en girar sobre sí mismo y unos 225 en dar una vuelta al Sol.',
    'Venus takes about 243 Earth days to rotate once and about 225 to orbit the Sun.',
    'https://science.nasa.gov/venus/venus-facts/',
  ),
  (
    'Caral, en el valle de Supe, conserva una ciudad de unos cinco mil años de antigüedad.',
    'Caral, in the Supe Valley, preserves a city dating back about five thousand years.',
    'https://whc.unesco.org/en/list/1269/',
  ),
];
