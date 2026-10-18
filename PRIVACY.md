# Privacidad técnica de Guardian

Estado: prototipo sin publicación autorizada. Este documento describe el tratamiento implementado; la [plantilla de política](docs/privacy_policy_template.md) contiene los datos del responsable y decisiones legales que deben completarse antes de distribuirlo.

La cámara frontal, las señales faciales y las reglas temporales se procesan en el teléfono. No se graban imágenes o vídeos por defecto, no se suben frames ni landmarks y no se realiza identificación facial. El modelo experimental incompatible continúa desactivado.

Los viajes, eventos, descansos declarados y telemetría técnica se conservan en SQLite. La retención configurable y la eliminación del historial incluyen datos locales pendientes de envío. El contacto de emergencia es una preferencia local y puede eliminarse dejando su campo vacío. Las versiones anteriores pudieron guardar favoritos y destinos recientes localmente; la interfaz actual no los consulta ni sincroniza.

DriverAwaken no solicita permiso de ubicación ni consulta servicios de mapa. Al confirmar una búsqueda o ruta externa, se comparte el texto de la categoría o destino con Google Maps o un navegador compatible. El monitoreo se pausa al salir de la app y requiere reanudación explícita al regresar. No se envía GPS a Firebase.

Las indicaciones habladas seleccionan una voz instalada que declare no requerir red; si no existe, muestran indisponibilidad y conservan las alarmas locales. Pausar, finalizar o enviar la aplicación al fondo cancela el habla pendiente.

La conversación se inicia voluntariamente con «Conversa conmigo». El micrófono escucha por turnos después de cada respuesta hablada. El silencio, terminar la charla, cerrar el panel o enviar la app al fondo cancela la escucha. Android puede procesar el reconocimiento por Internet. Se conservan como máximo 12 mensajes en memoria y se borran al cerrar el panel; no se guardan audio ni transcripciones en el historial o Firebase. El comando SOS abre el mismo diálogo de confirmación manual. Las alertas habladas están activadas inicialmente, con preferencia local persistente; las alarmas acústicas y vibratorias conservan sus controles.

Firebase Auth es opcional para el modo personal. Las copias personales son manuales. La sincronización empresarial exige cuenta, membresía activa, viaje asignado y consentimiento específico. Comparte identificadores y eventos numéricos, incluidos descansos declarados, sin imágenes ni ubicación continua. Las acciones humanas se anexan a las detecciones. La cola local y los datos recibidos por una organización tienen ciclos de eliminación distintos; desvincular no borra automáticamente los documentos empresariales remotos.

SOS abre el marcador tras confirmación; no llama ni contacta servicios automáticamente. Su registro manual opcional es local y no equivale a una detección de fatiga o a una llamada efectuada. El número configurado no se sincroniza con la flota.

La demo usa un almacenamiento independiente con datos simulados. Los emuladores de pruebas usan proyectos `demo-*` y puertos locales. No se usaron credenciales Admin en el navegador ni se publicaron reglas en producción.

Antes de lanzamiento: completar responsable, contacto de privacidad, finalidades, retención remota, procedimiento de solicitudes y condiciones de proveedores en la plantilla. No hay una identidad legal inventada ni una afirmación de certificación de seguridad vehicular.
