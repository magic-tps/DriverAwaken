# Inglés y español

La versión `1.1.0+2` permite elegir **Español**, **English** o **Idioma del teléfono** desde el login y desde Ajustes. La preferencia se guarda localmente y se restaura antes de mostrar la app. En modo automático se respeta el primer idioma compatible del teléfono; si no hay ninguno, se usa español.

El cambio actualiza las pantallas abiertas sin reiniciar el navegador, cerrar la sesión ni descartar campos del formulario. Incluye monitoreo, alertas, calibración, historial, resúmenes, nube, validaciones, privacidad, descripciones de accesibilidad y exportaciones PDF/PNG. Los controles Material y las fechas utilizan el idioma seleccionado. La recuperación de contraseña solicita a Firebase el mismo idioma.

## Implementación

- `lib/l10n/locale_controller.dart`: preferencia `app_language` en SharedPreferences, resolución del idioma del teléfono y notificación de cambios.
- `lib/l10n/app_strings.dart`: delegado de Localizations y traducción de mensajes completos. Los textos existentes en español funcionan como claves para conservar compatibilidad con notas de informes anteriores.
- `lib/l10n/messages.dart`: catálogo inglés y correcciones de texto español. Las plantillas numeradas `{0}`, `{1}` preservan valores dinámicos. Se resuelven primero las coincidencias exactas y después las plantillas más específicas; los valores desconocidos se conservan.
- `lib/l10n/localized_text.dart`: texto reactivo al delegado incluso dentro de widgets constantes. Etiquetas de formularios y errores usan este mismo componente; tooltips utilizan `context.tr`.
- `lib/widgets/language_selector.dart`: selector compartido entre login y Ajustes.

La traducción ocurre al mostrar o exportar. No modifica códigos de eventos, notas almacenadas, claves de SQLite, IDs de documentos, correo del usuario ni campos de Firestore. El JSON técnico conserva su esquema para mantener compatibilidad con herramientas de análisis.

Al añadir un mensaje visible, registrar su equivalente en el catálogo, conservar todos sus parámetros y usar `LocalizedText` o `context.tr`. No introducir traducciones en el motor de detección ni en los modelos persistidos.

## Comprobaciones

- Preferencia persistida, variantes regionales y alternativa cuando el idioma del teléfono no es compatible.
- Login que cambia de idioma conservando el correo escrito y los errores de validación.
- Conservación de la ruta abierta y traducción de secciones constantes.
- Tarjeta de cuenta y advertencias en pantalla estrecha en ambos idiomas.
- Integridad de todos los parámetros del catálogo y traducción de mensajes dinámicos.
- Contenido real de PDF en ambos idiomas, incluidas notas previamente almacenadas en español, sin modificar el evento original.

Referencia: [internacionalización de Flutter](https://docs.flutter.dev/ui/internationalization).
