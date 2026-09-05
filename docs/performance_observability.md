# Observabilidad de rendimiento

## Objetivo y alcance

Esta capa mide el pipeline local de DriverAwake sin conservar contenido biométrico ni alterar reglas, umbrales de riesgo o frecuencia de alertas. `PerformanceMonitor` se inyecta en `FlutterDriveSessionResources`, publica snapshots inmutables y limita cada serie a un buffer circular de 240 muestras.

## Flujo actual y puntos de medición

```text
CameraImage
→ conversión InputImage
→ ML Kit
→ selección de rostro
→ métricas faciales
→ PERCLOS
→ motor de riesgo
→ alertas
→ persistencia
→ DriveState
→ UI
```

| Etapa | Implementación actual | Punto de medición | Observación |
|---|---|---|---|
| Frame recibido/planificación | callback de `CameraRepository.startStream` | inicio de `_processFrame` | Cuenta todos los callbacks antes de evaluar busy/scheduler. |
| Conversión | `InputImageConverter.fromCameraImage` | alrededor de la llamada síncrona | No copia ni conserva bytes adicionales. |
| ML Kit | `FaceDetectionRepository.detect` | alrededor del `Future` | Incluye el tiempo del detector, no el scheduler. |
| Selección de rostro | `_largestFace` en `DrowsinessService` | alrededor de la selección síncrona | Comparte el monitor inyectado por los recursos. |
| Métricas faciales | `DrowsinessService.analyze` | alrededor del analizador | Actualmente se publica como `featureExtraction` agregado. |
| PERCLOS | `PerclosTracker` | alrededor de actualización y cálculo | No se registran muestras de ojos ni timestamps individuales. |
| Motor/modelo | `DrowsinessEngine` y `DrowsinessModelService` | categorías `riskEngine` y `modelInference` | Se publican como series independientes además del agregado del analizador. |
| Alertas | `AlarmController` | fuera de latencia de inferencia | La recuperación siempre detiene audio y vibración antes de reiniciar cámara. |
| Persistencia | `TripRepository.observe` → Drift/SQLite | alrededor del `Future` | Los fallos consecutivos alimentan el watchdog; no se registra el contenido persistido. |
| Estado | `_emit`/`DriveState.copyWith` | `stateUpdate` | Las métricas se adjuntan al snapshot técnico, sin `setState` por contador. |
| Total | frame aceptado hasta `finally` | reloj monotónico | Incluye conversión, análisis, persistencia, alertas y publicación. |
| UI | listener del controlador | fuera del frame | La UI recibe snapshots consolidados; los detalles viven en el panel técnico. |

No se agregan llamadas de ML Kit, inferencias, escrituras Drift ni conversiones adicionales para observar el sistema.

## Reloj y agregación

- Las duraciones usan un `Stopwatch` monotónico mediante `MonotonicClock.nowMicros()`; `DateTime.now()` no mide latencia.
- La hora civil se conserva solamente para semántica de sesión, PERCLOS existente y presentación del último frame válido.
- Cada etapa mantiene hasta 240 duraciones en microsegundos. Al llenarse, sobrescribe la muestra más antigua.
- El snapshot calcula cantidad, promedio, P50, P90, P95, P99 y máximo sobre la ventana acotada.
- FPS real se calcula con timestamps monotónicos de frames procesados; FPS solicitado promedia la frecuencia pedida al scheduler.
- Los contadores distinguen recibidos, aceptados, procesados, sin rostro, fallidos, descartados por busy y descartados por scheduler.
- `reset()` se ejecuta al preparar una sesión, no por frame, y elimina contadores, timestamps y buffers.

## Impacto esperado

La memoria es constante: diez buffers de 240 enteros más ventanas pequeñas de FPS. El coste por frame consiste en lecturas monotónicas y escrituras O(1); ordenar hasta 240 valores ocurre al solicitar un snapshot técnico o evaluar el watchdog, no durante la extracción facial. La UI se actualiza con el estado operativo ya existente y con el tick consolidado del watchdog, nunca con un `setState()` por métrica.

## Debug y release

- En debug, el monitor completo facilita tests y panel técnico.
- En release normal, `DRIVERAWAKE_TECHNICAL_FEATURES` permanece en `false`: no se ofrece exportación ni controles técnicos al usuario.
- Una compilación técnica se activa explícitamente con `--dart-define=DRIVERAWAKE_TECHNICAL_FEATURES=true`.
- El monitor admite `enabled: false` y una capacidad menor para builds restringidas; el watchdog conserva únicamente los contadores mínimos necesarios para seguridad funcional.
- La observabilidad no cambia los umbrales de somnolencia ni habilita el modelo experimental.

## Datos que nunca deben registrarse

- Imágenes, video o bytes de cámara.
- Landmarks completos, geometría facial reconstruible o vectores de features/modelo.
- Nombres, emails, teléfonos, cuentas o identificadores permanentes del dispositivo.
- IMEI, Android ID, número de serie, advertising ID o tokens.
- GPS, rutas, coordenadas, domicilios o lugares privados.
- Audio, contenido de alertas o datos de otras aplicaciones.
- Excepciones sin sanitizar que puedan incluir rutas privadas o valores de usuario.

El reporte usa un ID efímero/anónimo de sesión y campos técnicos con nombres permitidos; su exportación requiere confirmación y borra el archivo temporal al terminar el diálogo de compartir.
