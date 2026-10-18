# Copiloto conversacional y alertas habladas — 1.1.2+4

## Experiencia implementada

En la pantalla de conducción, **Copiloto → Conversa conmigo** inicia una sesión de conversación por turnos. El asistente saluda, espera una respuesta final de Android, responde con voz y vuelve a escuchar al terminar el audio. No hace falta volver a pulsar el micrófono en cada intervención. Una pausa sin respuesta termina la escucha; el botón permite iniciarla otra vez.

El motor local conserva el tema, la última pregunta y el contexto inmediato. Entiende saludos, cómo se siente el conductor, curiosidades y sus continuaciones, cambios de tema, agradecimientos, preguntas de estado o tiempo registrado y solicitudes de descanso. Incluye 100 preguntas editables en español e inglés, agrupadas en diez temas. Las curiosidades con afirmaciones factuales incluyen sus fuentes en `conversation_topics.dart`:

- [Corazones de los cefalópodos — Smithsonian](https://ocean.si.edu/ocean-life/invertebrates/octopuses-squids-and-relatives).
- [Rotación y órbita de Venus — NASA](https://science.nasa.gov/venus/venus-facts/).
- [Antigüedad de Caral — UNESCO](https://whc.unesco.org/en/list/1269/).

Ejemplo de secuencia funcional: «Cuéntame algo interesante» → dato del pulpo → «No sabía eso» → respuesta contextual → «Sí, otro» → dato de Venus. Las curiosidades no se repiten al agotar el banco en esa sesión. El motor ofrece otro tema.

La conversación incluye continuaciones específicas por tema y una memoria temporal del último detalle contado. Por ejemplo: «Hablemos de música» → «Me gusta el rock de los ochenta» → pregunta por bandas → «Me recuerda mi juventud» → pregunta por el recuerdo. «¿Qué te dije?» recupera ese último detalle mientras el panel sigue abierto. Un día difícil recibe una respuesta de escucha y seguimiento; «no sé» ofrece una alternativa y «no gracias» termina la conversación. Las preguntas fuera del alcance reciben una respuesta explícita, sin inventar información.

Este modo usa interpretación local de intenciones y recursos editables; tiene un alcance temático limitado. No se ha configurado un modelo generativo de conversación abierta ni se envían conversaciones a un servicio de IA. La reproducción de música no está integrada; el asistente informa de ello y permite hablar sobre música.

## Alertas y prioridad

Las alertas habladas están activadas por defecto y la elección se conserva en preferencias locales. El sonido general de las alertas mantiene su ajuste existente. El panel incluye un interruptor de voz y una prueba de altavoz.

La voz explica cierres prolongados de ojos, somnolencia elevada, bostezos, desviación de cabeza o pérdida de rostro. Una alerta interrumpe una respuesta recreativa y cancela primero el micrófono. La charla no modifica niveles, contadores ni resultados del detector, ni reconoce o resuelve incidentes. Las alarmas acústicas y vibratorias conservan su funcionamiento independiente.

Los textos están en `driveawake/lib/navigation/spoken_safety_alert.dart`, con variantes breves en español e inglés para cada señal. Las variantes comparten el mismo intervalo de repetición. La primera alerta de ojos cerrados dice: «Atención. Detecto un cierre prolongado de ojos. Detente en un lugar seguro y descansa». La repetición explica que la alerta continúa. Declarar «me estoy quedando dormida», «estoy agotado» o «no puedo mantener los ojos abiertos» también muestra la recomendación de descanso.

En peligro se suspenden las curiosidades y se insiste en detenerse de forma segura. Decir «voy a parar» expresa intención; no pausa el detector ni confirma que el vehículo esté detenido. Solicitar descanso muestra Smart Rest sin inventar un incidente del detector. Google Maps y SOS conservan sus confirmaciones de pantalla.

Los avisos de peligro pueden volver a hablar después de 30 segundos si persiste el riesgo; los de precaución o señal usan 60 segundos. Un fallo de voz no bloquea el procesamiento de cámara. La configuración y reproducción de TTS tienen límites de espera.

## Reconocimiento y recursos

Se corrigió el uso de los callbacks de `speech_to_text`: Android conserva los de la primera inicialización. Ahora apuntan al turno activo y se inicializa una sola instancia. Las transcripciones tardías de turnos cancelados se descartan. Se espera un margen corto cuando Android notifica `done` antes del resultado final.

La conversación solo procesa transcripciones finales; una hipótesis parcial no reanuda el monitoreo ni abre aplicaciones. Se selecciona el idioma de reconocimiento según el idioma de la app. El TTS prioriza voces instaladas sin red y acentos latinoamericanos para español; la disponibilidad y el timbre dependen del teléfono.

Dentro de los acentos preferidos, se prioriza la calidad declarada por la voz instalada antes de exigir un acento exacto. Android recibe atributos de audio de voz guiada, de acuerdo con [la API de flutter_tts](https://pub.dev/documentation/flutter_tts/latest/flutter_tts/FlutterTts-class.html). Si falta la voz sin conexión, el panel indica que debe instalarse desde los ajustes de texto a voz de Android y permite volver a probar. Un fallo de reproducción no consume el intervalo que impediría reintentar.

La escucha se cancela antes de hablar y se deja un margen de 400 ms después del audio para evitar que el micrófono capte la propia respuesta. Un error o silencio no reinicia la escucha en bucle. Cerrar el panel o pasar la app al fondo termina la sesión y libera el micrófono. Se conservan como máximo doce mensajes en memoria y se borran al cerrar; no se escriben transcripciones ni audio en SQLite, archivos o Firebase.

## Validación

Revisión local del 18 de octubre de 2026: **173 pruebas Flutter aprobadas** y `flutter analyze --no-pub` sin observaciones. Incluye la configuración del canal TTS, seguimiento de conversación, reconocimiento por turnos, intervalos de alertas, prioridades y aviso hablado desde Smart Rest. Estas comprobaciones no certifican que el altavoz o micrófono de un teléfono concreto funcionen correctamente.

Se compiló el APK debug actualizado con `flutter build apk --debug --no-pub`, disponible en `driveawake/build/app/outputs/flutter-apk/app-debug.apk`. La compilación local no actualiza por sí sola el archivo publicado en Google Drive.

Las pruebas automatizadas cubren contexto en varios turnos, cambio de tema, respuestas en inglés, negaciones, señales insuficientes, solicitudes de descanso, prioridad de peligro, cancelación del micrófono, rechazo de hipótesis parciales y callbacks reutilizados en varias escuchas.

La prueba de integración `driveawake/integration_test/voice_device_test.dart` comprueba síntesis de voz española y preparación/cancelación repetida del reconocimiento en un Android conectado. El resultado de una sesión de validación no equivale a comprobar reconocimiento de cada acento, ruido del vehículo o comprensión abierta de cualquier tema.

Para comprobar el audio real, con el vehículo detenido: abre **Copiloto → Probar voz**, después **Conversa conmigo** y prueba la secuencia de música anterior y «necesito descansar». Si la app indica que falta una voz, instala el paquete español sin conexión del motor de texto a voz y repite la prueba. No se debe simular somnolencia conduciendo. La verificación de esta revisión no pudo incluir audio físico: no había ningún dispositivo Android conectado por ADB.
