# Registro técnico de mejoras

## Simplificación de conducción (2026-10-18)

- Cámara frontal ampliada; métricas de ojos, bostezos, PERCLOS, cabeza, señal, riesgo y duración visibles durante el monitoreo.
- Eliminados mapa interno, tiles OSM, Nominatim, Overpass, GPS y permisos Android de ubicación. Las búsquedas y rutas usan URLs oficiales de Google Maps mediante `url_launcher`.
- Smart Rest conserva recomendaciones y descansos persistidos. La consulta de paradas exige confirmación de vehículo detenido; la sesión queda pausada hasta reanudación explícita.
- Reducida una emisión de estado por frame y acotado el muestreo de luminancia. Los drops intencionales del scheduler se distinguen de los drops por procesamiento ocupado.
- Verificación: `flutter analyze` y `flutter test` sin fallos; APK debug compilado e instalado en un dispositivo Android. El rendimiento físico sostenido requiere medición adicional en ruta controlada.

## Guardian — implementación local (2026-10-17)

- Continuación sobre cambios locales Guardian existentes; base registrada `c5aaa8c`, rama `feat/guardian-mvp`, sin descartar trabajo previo.
- Fix de `loadEvents` con await para capturar errores asíncronos.
- Dominio flota y vinculación consentida Android; persistencia/cola Drift v2, cooldown persistente, IDs estables y reintentos autorizados.
- Falta de rostro diferenciada de somnolencia; modelo incompatible conservado desactivado.
- Firestore multiempresa y acciones anexas, bootstrap seguro, pruebas emulador y fixture local.
- Dashboard Next.js, demo independiente y pitch, exportación estática y jobs CI.
- Documentos de competencia y despliegue. Resultados y estado final en `TECHNICAL_VALIDATION.md`; no hay push, publicación ni entrega oficial en esta sesión.
- Interfaz de conducción adaptable con cámara real, tarjeta de mapa, controles de voz y confirmación al finalizar; falta de cámara frontal deja un error explícito.
- Navegación OSM consentida, favoritos y recientes locales, Smart Rest, descansos Drift v3 y navegación externa sin ETA inventada.
- Voz offline según idioma, prioridad crítica y cancelación de operaciones pendientes al pausar. Protección frente a permisos GPS y cambios de lifecycle que responden tarde.
- SOS con contacto local opcional, registro manual y marcador confirmado; no realiza llamadas automáticas.
- Dashboard de conductores y descansos, filtros de reportes compartidos con CSV y emuladores de seguridad/web separados.

## Inglés y español — 1.1.0+2 (2026-09-05)

- Selector en login y Ajustes: español, inglés o idioma del teléfono, con preferencia persistida.
- Traducción de pantallas, alertas, calibración, mensajes de nube, formularios, privacidad y exportaciones PDF/PNG.
- Cambio de idioma sin cerrar sesión ni reiniciar la navegación; los informes existentes conservan sus datos originales.
- Fechas localizadas y recuperación de contraseña en el idioma elegido.
- Pruebas de persistencia, cambio de idioma, formularios, navegación, plantillas, pantallas estrechas y contenido de PDF.
- Validación automática: `flutter analyze` sin incidencias y 95 pruebas aprobadas.
- APK `1.1.0` (código 2) instalado mediante actualización en Samsung SM-S938U1. Comprobación en dispositivo del selector, login en inglés y opciones de retención traducidas; sin modificar credenciales ni informes.

## Acceso y nube visibles (2026-09-05)

- Pantalla inicial dedicada a login/registro, recuperación de contraseña y opción de continuar sin cuenta.
- Restauración de sesión y tarjeta de cuenta visible antes de la cámara en Inicio.
- Acceso con texto a la nube desde Historial y subida del informe seleccionado desde su resumen.
- Conteo de informes y hora de última consulta confirmada por el servidor; el fallo de consulta no se muestra como ausencia de informes.
- Pruebas de autenticación, invitado, validación de registro, fallo de red y tarjetas en pantallas estrechas.
- Validación: `flutter analyze` sin incidencias y 87 pruebas aprobadas. APK debug actualizado e instalado en Samsung SM-S938U1 conservando datos.
- Comprobación en dispositivo: sesión iniciada, consulta al servidor con 0 informes y botones de subida/consulta visibles. Inicio muestra tarjeta de cuenta, cámara activa y rostro detectado. No se subieron informes personales durante esta comprobación.

## Firebase y cuentas opcionales (2026-09-05)

- Integración Android del JSON suministrado y cambio autorizado del application ID a `driver_.awaken`.
- Firebase Auth con correo/contraseña habilitado y reglas Firestore publicadas en `driverawaken`.
- Pantalla de copias con registro, acceso, recuperación de contraseña, copia manual, consulta, borrado y eliminación de cuenta con reautenticación.
- SQLite conserva el funcionamiento local; no se suben frames ni se interrumpe el monitoreo por errores de red.
- Prueba remota con dos cuentas sintéticas: operaciones del propietario aceptadas y accesos ajenos rechazados; datos de prueba eliminados.

## Inicio de cámara e informes guardados (2026-09-05)

- Inicio activa la cámara después de resolver borradores; se elimina el temporizador de 25 segundos.
- Apertura/cierre serializados, pausa en segundo plano y restauración al volver a Inicio.
- El cierre en background no espera un fotograma de UI; los diálogos de permisos no duplican solicitudes.
- Riesgo sin lectura válida representado por `--`.
- La capa de landmarks ignora eventos táctiles para que Reintentar reciba los toques.
- Historial permite abrir resúmenes SQLite sin depender de alertas ni de internet; se mantiene retención/borrado.
- Pruebas de arranque, permisos, ciclo de vida y lectura de informes persistidos. Cámara física pendiente de probar en dispositivo.

## Observabilidad y resiliencia de monitoreo (2026-07-18)

- Baseline Git creado antes de la iteración; artefactos locales de Flutter/Dart añadidos a exclusiones.
- Monitor inyectable con reloj monotónico, buffers circulares, contadores de frames, FPS y P50/P90/P95/P99 por etapa.
- Watchdog configurable con estados `healthy`, `degraded`, `recovering` y `unavailable`.
- Recuperación automática limitada, backoff creciente, confirmación por frame válido y cancelación por generación.
- Alarmas detenidas durante recuperación y UI sin estado `NORMAL` cuando el monitoreo no es confiable.
- Reporte técnico JSON sanitizado, protegido por `DRIVERAWAKE_TECHNICAL_FEATURES`, confirmación previa y limpieza temporal.
- Pruebas de percentiles, buffer, reset, drops, reloj, watchdog, sanitización y controlador.
- Documentos `performance_observability.md` y `device_test_protocol.md` añadidos.

## Seguridad funcional

- PERCLOS integra únicamente intervalos válidos, rompe segmentos por rostro ausente o huecos mayores a 600 ms, ignora timestamps no crecientes y publica cobertura/duración observada.
- La pausa detiene stream, procesamiento, alarmas, telemetría y estado temporal; la reanudación requiere cuenta regresiva y foco de la aplicación.
- La salida del viaje exige finalizar, continuar o confirmar un descarte.
- Las sesiones se guardan incrementalmente y pueden recuperarse sin activar cámara ni alarmas.
- Alertas encapsuladas tras un actuador comprobable y detención idempotente.
- Release no usa firma debug y exige configuración de firma.

## Machine learning

- Splits agrupados por `subject_id`, validación de intersecciones y CV agrupado.
- Contrato de 181 features y fixtures de escalado compartidos.
- Validación de hash, shapes, clases y probabilidades del modelo.
- Modelo histórico marcado experimental, incompatible con el extractor Flutter actual y desactivado por defecto.

## Plataforma y calidad

- Comportamiento anterior: cámara de Inicio apagada por defecto con comprobación temporal de 25 segundos; sustituido el 2026-09-05.
- Muestreo adaptativo con histéresis térmica y reducción por batería baja.
- Nombre público canónico DriverAwake, tema central y colores semánticos.
- Backup Android deshabilitado, exclusiones de secretos/datasets y CI con Gitleaks.
- Documentación de auditoría, seguridad, ML, arquitectura, privacidad y organización.

## Cambios deliberadamente no realizados

- No se movió ni enumeró `Data/`.
- No se creó firma, secreto, identidad legal ni métrica de validación.
- No se activó el modelo TFLite histórico.
- No se hizo una migración Drift sin poder comprobar generación, rollback y compatibilidad en dispositivo.
- Inicialmente se conservó `com.magicdrive.alert`; el 2026-09-05 se cambió el application ID a `driver_.awaken` por autorización del usuario para integrar su JSON de Firebase. Se conservaron namespace y claves internas.
