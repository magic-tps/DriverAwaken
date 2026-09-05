# Registro técnico de mejoras

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

- Cámara de Inicio apagada por defecto con comprobación temporal de 25 segundos.
- Muestreo adaptativo con histéresis térmica y reducción por batería baja.
- Nombre público canónico DriverAwake, tema central y colores semánticos.
- Backup Android deshabilitado, exclusiones de secretos/datasets y CI con Gitleaks.
- Documentación de auditoría, seguridad, ML, arquitectura, privacidad y organización.

## Cambios deliberadamente no realizados

- No se movió ni enumeró `Data/`.
- No se creó firma, secreto, identidad legal ni métrica de validación.
- No se activó el modelo TFLite histórico.
- No se hizo una migración Drift sin poder comprobar generación, rollback y compatibilidad en dispositivo.
- No se renombró el package ID `com.magicdrive.alert` ni las claves internas existentes, para evitar pérdida de actualizaciones/datos.
