# Informe completo de DriverAwaken Guardian

**Fecha de corte:** 17 de octubre de 2026, America/Lima.  
**Repositorio examinado:** workspace `DriveAwake`, rama `feat/guardian-mvp`, HEAD `c5aaa8c`.  
**Versión móvil declarada:** `1.1.0+2`.  
**Objeto:** describir el producto, el código, los datos, las herramientas y los artefactos que existen en este workspace, incluyendo sus limitaciones.

El repositorio ya contiene cambios locales sin commit. Este informe incluye ese estado acumulado y no atribuye todo el trabajo a una persona, a esta revisión o al periodo del concurso. Se revisaron código y configuraciones; los resultados de ejecución se toman de las comprobaciones anteriores de esta conversación y de los logs conservados. Para preparar este documento no se volvieron a ejecutar entrenamientos, pruebas remotas, despliegues ni operaciones con cuentas reales.

**Lectura principal:** este documento. **Detalle por archivo y símbolos:** [catálogo de archivos](INVENTARIO_ARCHIVOS_GUARDIAN.md). **Inventario consultable por programas:** [JSON técnico](INVENTARIO_TECNICO_GUARDIAN.json). **Evidencia de ejecución y aceptación:** [TECHNICAL_VALIDATION.md](../TECHNICAL_VALIDATION.md).

## Índice

1. Qué es y qué productos contiene.
2. Identidad, versiones y plataformas.
3. Tamaño e inventario del código.
4. Arquitectura y recorrido de información.
5. Todas las pantallas móviles.
6. Recorrido de uso personal.
7. Cámara y procesamiento de imágenes.
8. Señales faciales y calidad.
9. PERCLOS.
10. Motor de riesgo y umbrales.
11. Alertas locales.
12. Calibración.
13. Sesiones, recuperación y rendimiento.
14. Modelos de datos y SQLite.
15. Viajes, eventos, historial y exportación.
16. Autenticación y copias personales.
17. Idiomas, temas y componentes visuales.
18. GPS, mapas, destinos y navegación.
19. Smart Rest.
20. Descansos declarados.
21. Asistente de voz.
22. SOS y contacto de emergencia.
23. Flotas, organizaciones y roles.
24. Incidentes y sincronización offline.
25. Dashboard web y reportes.
26. Simulador público.
27. Presentación y materiales de competencia.
28. Pipeline Python de machine learning.
29. Contrato ML, vectores y assets.
30. Integración Android y plataformas adicionales.
31. Dependencias y configuración.
32. CI, firma, hosting y scripts.
33. Pruebas y evidencia disponible.
34. Privacidad y flujo de datos.
35. Documentación, IDE, datos y archivos generados.
36. Funciones ausentes, bloqueos y deuda técnica.
37. Operación y reproducción local.
38. Estado global y glosario.

## 1. Qué es y qué productos contiene

DriverAwaken Guardian es una plataforma experimental de asistencia preventiva para conductores y flotas. La cámara observa señales faciales, un motor local aplica reglas temporales, el teléfono avisa al conductor y, cuando existe autorización empresarial, conserva y sincroniza incidentes para que una central documente su respuesta.

El proyecto tiene siete conjuntos principales:

| Conjunto | Carpeta | Qué contiene |
| --- | --- | --- |
| App móvil | `driveawake/` | Flutter, cámara, detección, alarmas, viajes, historial, cuentas, mapas y vínculo con flotas. |
| Inteligencia local | `driveawake/lib/services/`, `features/drive/` | Extracción de señales, PERCLOS, riesgo, calibración, watchdog y coordinación del monitoreo. |
| Navegación y descanso | `driveawake/lib/navigation/` | GPS, mapas OSM, destinos, proveedores, recomendaciones, voz y descansos. |
| Backend y control de acceso | `backend/` | Firestore Rules, bootstrap administrativo, fixtures y pruebas de emuladores. |
| Web | `dashboard/` | Landing, demo, pitch y central autenticada en Next.js. |
| Investigación ML | `app_conductores_ml/` | Procesamiento de vídeos, extracción MediaPipe, entrenamiento, evaluación y exportación TFLite. |
| Contratos y soporte | `shared/`, `scripts/`, `docs/`, `.github/` | Esquemas, vectores, comprobaciones, documentación, CI y release. |

Hay tres experiencias diferentes: **uso personal local**, **uso de flota con consentimiento** y **simulación pública**. Sus datos y garantías no son intercambiables. La demo no ejecuta la cámara ni certifica la precisión del detector.

## 2. Identidad, versiones y plataformas

| Elemento | Valor observado |
| --- | --- |
| Nombre de presentación | DriverAwaken Guardian; algunas constantes y etiquetas conservan DriverAwake. |
| Eslogan | «Conduce seguro, llega siempre». |
| Paquete Flutter | `driveawake`. |
| Versión y build móvil | `1.1.0+2`. |
| Clase de aplicación | `AppConductoresApp`. |
| Application ID Android | `driver_.awaken`. |
| Namespace Kotlin | `com.magicdrive.alert`. |
| Android mínimo | API 24. |
| Dart declarado | `^3.9.2`. |
| Entorno de la validación móvil anterior | Flutter 3.35.3 / Dart 3.9.2. |
| Plataforma móvil objetivo | Android. |
| Idiomas base | Español e inglés, o selección según idioma del teléfono. |
| Paquete web | `driverawaken-guardian-dashboard`, versión declarada `1.0.0`. |
| Modelo experimental | `experimental-2026-05-23`, extractor histórico `legacy-mediapipe-v1`. |
| Esquema local | Drift/SQLite versión 3. |

Existen carpetas de iOS, Linux, macOS, Windows y web del proyecto Flutter. Su existencia corresponde al andamiaje de plataforma y a registros de plugins; no demuestra que el monitoreo y los canales nativos estén implementados o verificados en todas ellas. La central Next.js sí es una aplicación web separada.

## 3. Tamaño e inventario del código

Conteo de archivos de la instantánea anterior a generar estos nuevos informes:

| Área | Archivos |
| --- | ---: |
| Flutter `lib/` | 90 |
| Pruebas Flutter `test/` | 30 |
| Pipeline Python `src/` | 17 |
| Pruebas Python | 2 |
| Código web `dashboard/src/` | 27 |
| Pruebas unitarias web | 4 |
| Archivos E2E web | 2 |
| Backend, configuración y lockfile | 8 |
| Scripts de la raíz | 2 |
| Contrato y vectores compartidos | 10 |
| Documentos previos en `docs/` | 16 |

Los 90 archivos Dart incluyen `driver_awake_database.g.dart`, generado por Drift. La cantidad de archivos o líneas no es una medida de calidad, precisión o preparación para producción.

El catálogo anexo enumera individualmente los archivos de producto, configuración, documentación, pruebas y recursos que Git conoce o que son nuevos no ignorados. Registra tamaño, líneas cuando corresponde y declaraciones identificables. El JSON añade SHA-256. Cachés, dependencias instaladas, datasets privados y credenciales locales se describen por categoría sin copiar su contenido.

## 4. Arquitectura y recorrido de información

```text
Cámara frontal → conversión de imagen → ML Kit → señales y calidad
             → DrowsinessService → DrowsinessEngine → estado de riesgo
             → alarma / vibración / interfaz / recomendación breve
             → viaje y evento local → SQLite
             → outbox, solo con autorización → Firestore → central
             → reconocimiento / acción / resolución del operador
```

La navegación consume el estado existente y el tiempo del viaje. No reemplaza el detector ni necesita consultar internet para decidir una alerta crítica.

En modo conducción la coordinación principal está separada en:

| Pieza | Responsabilidad |
| --- | --- |
| `DriveModeScreen` | Presentación, observación del estado y envío de acciones de usuario. |
| `DriveSessionController` | Inicio, pausa, reanudación, finalización y transiciones. |
| `DriveState` | Estado de sesión, cámara, stream, alarma, salud, métricas, errores y resumen. |
| `FlutterDriveSessionResources` | Coordinación de cámara, detector, alarma, repositorios y recursos Flutter. |
| `drive_ports.dart` y `drive_repositories.dart` | Contratos para separar la lógica y permitir fakes en pruebas. |
| `service_adapters.dart` | Adaptación de servicios existentes a esos contratos. |
| `DriftTripRepository` | Persistencia de viajes, eventos y borradores mediante transacciones. |
| `SmartNavigation` | Estado y acciones de navegación/descanso. |
| `FleetService` | Asignaciones, consentimiento empresarial, captura y entrega de eventos autorizados. |

La arquitectura es modular, pero sigue utilizando varios servicios singleton. No existe una plataforma de microservicios independiente ni un backend Next.js necesario para la exportación estática.

## 5. Todas las pantallas móviles

Hay doce archivos de pantalla bajo `driveawake/lib/screens/`.

| Pantalla | Qué permite |
| --- | --- |
| `app_entry_screen.dart` | Resolver la sesión de cuenta y escoger el acceso inicial. |
| `login_screen.dart` | Iniciar sesión, registrar cuenta, recuperar contraseña, escoger idioma y continuar sin cuenta. |
| `home_screen.dart` | Vista inicial, escaneo/cámara, estado del detector, recuperación de borrador y accesos a conducción, historial, cuenta, ajustes y módulos Guardian. |
| `drive_mode_screen.dart` | Monitoreo durante el viaje, estado de señal/riesgo, cámara grande, métricas, mapa, voz, SOS, pausa, calibración y finalización confirmada. |
| `navigation_screen.dart` | Confirmar estacionamiento, autorizar mapas/GPS, buscar y escoger destinos, favoritos, recientes, lugares, navegación externa y descansos. |
| `fleet_screen.dart` | Consultar la organización y viajes asignados, vincular con consentimiento, revisar la cola y desvincular. |
| `history_screen.dart` | Consultar eventos locales, filtrar y acceder a exportación y viajes guardados. |
| `saved_trips_screen.dart` | Listar viajes completados y abrir sus resúmenes persistidos. |
| `trip_summary_screen.dart` | Mostrar duración, alertas, riesgo, señales y telemetría del viaje; ofrecer acciones de informe y copia cuando corresponde. |
| `cloud_reports_screen.dart` | Consultar, subir, abrir y eliminar copias personales; gestionar sesión y eliminación de cuenta con reautenticación. |
| `settings_screen.dart` | Sensibilidad, sonido, vibración, retención, ventana PERCLOS, panel técnico, preferencia de modelo, idioma y borrado/restablecimiento. |
| `privacy_policy_screen.dart` | Aviso de tratamiento local, nube, flotas, mapas/GPS, voz, SOS, descansos y datos legales pendientes. |

El botón de configuración de conducción abre Ajustes. El menú técnico muestra métricas y permite iniciar calibración. El mapa abre un flujo que pausa el monitoreo y exige configurar con el vehículo detenido. Finalizar permite continuar, guardar o descartar; el descarte requiere una confirmación adicional.

La navegación utiliza principalmente `Navigator` y `MaterialPageRoute`; no hay un router declarativo central que describa todas las rutas móviles por URL.

## 6. Recorrido de uso personal

1. La inicialización configura Flutter, abre/migra la base y restaura la preferencia de idioma.
2. La entrada intenta restaurar la cuenta; el uso local no depende de obtener una sesión remota.
3. Inicio permite la vista previa después de resolver recuperación de borrador y permisos.
4. Al iniciar conducción se crea un viaje local o se restaura su borrador.
5. Los frames admitidos producen métricas y decisiones temporales.
6. La interfaz muestra riesgo cuando hay señal suficiente y disponibilidad cuando no la hay.
7. La alarma y vibración siguen las preferencias y el nivel interno de alerta.
8. Pausar o salir de primer plano detiene el monitoreo activo y las alertas.
9. Reanudar requiere acción explícita y una cuenta regresiva de tres segundos.
10. Guardar finaliza el viaje y abre el resumen. Descartar elimina su borrador y datos asociados según la operación del repositorio.
11. El historial se mantiene en el dispositivo y puede exportarse o copiarse manualmente a la cuenta.

No se inicia ni se completa un descanso por el solo hecho de elegir un destino. Tampoco se declara monitoreo continuo al abrir otra aplicación de navegación.

## 7. Cámara y procesamiento de imágenes

`CameraService` solicita permiso, libera controladores anteriores, consulta cámaras y selecciona una frontal. Si no existe, genera un error controlado. No hace fallback silencioso a la trasera para etiquetarla como frontal.

La cámara se abre con audio deshabilitado. El intento de apagar flash no invalida por sí solo una sesión de cámara que haya inicializado correctamente. Se dispone de inicio/detención del stream y liberación del controlador.

`InputImageConverter` realiza conversión hacia `InputImage` de ML Kit:

- Android NV21 y conversión desde YUV420 de tres planos.
- Respeto de separación de filas y píxeles al reconstruir crominancia.
- Rotación basada en sensor, orientación y dirección de cámara.
- Ruta BGRA8888 para el código de conversión iOS, sin afirmar validación completa de iOS.
- Rechazo recuperable cuando el formato o la metadata no permiten una conversión válida.

`FaceDetectionService` configura ML Kit en modo rápido con contornos, landmarks, clasificación y tracking. Estos datos describen la geometría de un rostro; no se utilizan para identificar quién es la persona.

Existe un widget de overlay facial y un visor con guía de alineación. Su existencia no significa que el visor de conducción dibuje una malla densa completa. No se emplea una fotografía estática para representar una cámara activa.

Android Camera2 permite consultar si el hardware declara alguna combinación frontal/trasera concurrente. La respuesta distingue esa capacidad de `appConcurrentEnabled=false`. No hay preview simultáneo real habilitado ni verificación de sesiones concurrentes, temperatura o estabilidad de doble cámara.

## 8. Señales faciales y calidad

El detector local obtiene o calcula:

| Señal | Fuente y uso |
| --- | --- |
| Rostro detectado | Resultado de ML Kit; habilita observación válida. |
| Apertura ocular | Probabilidades de ojos de ML Kit cuando están disponibles. |
| EAR | Relación geométrica aproximada de contornos oculares. |
| MAR | Relación geométrica de apertura de boca. |
| Ojos cerrados / parpadeo prolongado | Estado más duración observada. |
| Bostezo | MAR y condición temporal; se conservan ocurrencias en una ventana. |
| Cabeza inclinada | Ángulo X frente a umbral calibrado. |
| Desvío de cabeza | Ángulo Y sostenido; no es seguimiento certificado de la mirada. |
| Ausencia de rostro | Tiempo sin observación; informa señal insuficiente. |
| Brillo | Estimación de luminancia para evaluar luz insuficiente. |
| Tamaño relativo del rostro | Área facial respecto de la imagen. |
| Calidad de señal | Heurística que reúne disponibilidad geométrica, tamaño y luz. |

La calidad comienza en 0,22; añade contribuciones por EAR, MAR, probabilidad ocular y tamaño del rostro, y se reduce con mala iluminación. Se limita a 0–1. Es un indicador técnico heurístico, no una probabilidad clínica ni una medida de precisión estadística.

Los landmarks se consideran fiables en la lógica de señales con calidad suficiente y sin baja luz. Los umbrales pueden ajustarse a la calibración. La ausencia de rostro reinicia riesgo temporal y produce `SIGNAL_UNAVAILABLE`; el valor numérico interno cero de ese caso no significa ausencia real de fatiga.

## 9. PERCLOS

`PerclosTracker` calcula la proporción temporal observada de ojos cerrados dentro del tiempo válido:

```text
PERCLOS = tiempo válido con ojos cerrados / tiempo válido observado
```

No es un promedio simple del número de frames. Se pondera por intervalos entre muestras, se recorta la ventana temporal y se evita convertir huecos grandes de cámara en tiempo observado.

Parámetros de la implementación:

| Parámetro | Valor por defecto |
| --- | --- |
| Ventana | 30 segundos; preferencia configurable de 10 a 90. |
| Separación máxima admitida entre muestras | 600 ms. |
| Tiempo válido mínimo | 10 segundos. |
| Cobertura mínima | 0,55. |
| Precaución | PERCLOS ≥ 0,20 cuando la señal está preparada. |
| Peligro | PERCLOS ≥ 0,35 cuando la señal está preparada. |

Timestamps no crecientes se rechazan. El valor solo debe utilizarse como señal del motor cuando existe cobertura suficiente. La constante histórica de mínimo de muestras en el archivo de umbrales no sustituye las condiciones temporales efectivas de `PerclosTracker`.

## 10. Motor de riesgo y umbrales

`DrowsinessEngine` devuelve un `RiskDecision`: nivel, riesgo por reglas, aporte de modelo, riesgo total, motivo, mensaje, tier y duración de peligro sostenido. El flujo funcional actual depende de reglas; el modelo empaquetado continúa rechazado.

| Condición | Parámetro / efecto del código |
| --- | --- |
| Apertura ocular considerada cerrada | Score < 0,35, con condiciones de señal. |
| EAR base de cierre | 0,16; la calibración puede ajustarlo. |
| Ojos cerrados sin duración prolongada | Base de regla 25. |
| Cierre de al menos 1,5 s | Base 56, parpadeo prolongado. |
| Cierre de al menos 3 s | Base 96 y peligro forzado. |
| Ojos cerrados + cabeza inclinada sostenida | Base 92 y peligro forzado. |
| MAR base de bostezo | 0,55; puede calibrarse. |
| Bostezo aislado | Base 30. |
| Tres bostezos en 60 s | Base 76. |
| Cabeza abajo base | 22° y al menos 750 ms; base de riesgo 42. |
| Desvío lateral base | 28° y al menos 1.400 ms; base 41. |
| PERCLOS ≥ 0,20 | Base 44. |
| PERCLOS ≥ 0,35 | Base 78. |
| Luz muy baja | Brillo < 34; base de regla 22. |
| Luz débil | Umbral de brillo 48 para atenuar calidad. |
| Calidad < 0,32 sin peligro forzado | Limita la contribución de reglas a 48. |
| Ausencia de rostro | No genera diagnóstico de fatiga: reinicia y devuelve indisponibilidad de señal. |

El motor toma la condición de mayor riesgo; no suma indiscriminadamente todos los valores. El objetivo se ajusta por sensibilidad cuando no hay peligro forzado: baja 0,88, media 1,00 y alta 1,12.

El suavizado usa coeficiente 0,48 al subir y 0,16 al bajar. Peligro comienza en 70 y precaución en 40; la histéresis mantiene peligro mientras el riesgo no baja de 62 y mantiene precaución hasta bajar de 34. Un cierre crítico puede forzar peligro sin esperar ese suavizado.

Hay una ruta de aporte experimental del clasificador y combinación con reglas. Su existencia en el código no implica que el modelo incompatible esté ejecutándose. El índice 0–100 es heurístico y no representa probabilidad de accidente.

## 11. Alertas locales

| Tier | Comportamiento principal |
| --- | --- |
| 0 | Normal; detiene alertas y reinicia reconocimiento temporal. |
| 1 | Precaución visual; no inicia la alarma fuerte. |
| 2 | Vibración corta si está habilitada, con cooldown de precaución. |
| 3 | Alarma local y patrón de vibración fuerte según preferencias. |
| 4 | Peligro sostenido al menos 14 s; repetición de audio y vibración más intensa. |

Cooldowns base: 18 segundos para precaución y 7 segundos para peligro. Reconocer peligro detiene los actuadores y aplica una ventana de reconocimiento de 30 segundos. Las preferencias de sonido y vibración se respetan; por tanto, el usuario puede silenciar canales.

`AlertActuator` permite probar la lógica con un actuador falso. `DeviceAlertActuator` usa vibración y `DeviceTelemetryService` para audio nativo. Kotlin reproduce el WAV con `MediaPlayer`, libera recursos y limita repetición. Existe fallback de sonido del sistema cuando no está disponible el canal nativo.

Las alertas locales no esperan consultas de mapas ni sincronización Firebase. La voz es un canal adicional separado.

## 12. Calibración

La calibración principal actual es `CalibrationService`, con almacenamiento versionado y fallback de preferencias históricas. También existe `PersonalCalibrationService`, implementación histórica que permanece en el árbol; su presencia no implica dos calibraciones simultáneas independientes durante una sesión.

La calibración automática exige al menos 45 muestras y 10 segundos, con filtros de calidad y postura/apertura adecuados. Se estiman referencias de ojos, boca, cabeza y tamaño facial.

La calibración guiada dura 26 segundos y presenta fases:

| Intervalo | Instrucción |
| --- | --- |
| 0–5 s | Mirar al frente. |
| 5–10 s | Mantener ojos abiertos. |
| 10–14 s | Parpadear normalmente. |
| 14–18 s | Cerrar ojos por un segundo. |
| 18–22 s | Abrir la boca una vez. |
| 22–26 s | Mover ligeramente la cabeza. |

Este recorrido corresponde exclusivamente a pruebas con el vehículo estacionado. No constituye una instrucción para ejecutarlo mientras se conduce.

El EAR de cierre puede derivarse del punto medio entre referencias de abierto/cerrado o de una fracción del baseline abierto, con clamps. El umbral de bostezo combina baseline normal y de boca abierta. Cabeza y distracción se ajustan a sus baselines manteniendo mínimos. Hay opciones de reinicio, cancelación y restablecimiento.

## 13. Sesiones, recuperación y rendimiento

Las fases declaradas son `idle`, `starting`, `active`, `paused`, `resuming`, `finishing`, `completed`, `recoverableError` y `fatalError`.

Los estados de cámara, stream, procesamiento, alarma y carga térmica están separados. Esto permite distinguir una sesión existente de una cámara que realmente produce observaciones válidas.

`PerformanceMonitor` conserva mediciones técnicas por etapas, FPS real, descartes y percentiles. `MonitoringWatchdog` evalúa salud `healthy`, `degraded`, `recovering` o `unavailable` con criterios como:

- Frame válido antiguo: 3 segundos para degradación y 8 para indisponibilidad crítica.
- FPS real mínimo de referencia: 2.
- Ratio máximo de descartes: 0,55.
- P95 total máximo de referencia: 700 ms.
- Tres fallos consecutivos como umbral de fallo persistente.
- Hasta tres intentos de recuperación con base de backoff de 500 ms.

Son límites de configuración, no benchmarks medidos ni garantías de latencia.

La recuperación detiene alertas, reinicia estado temporal, libera/reinicializa cámara y espera un frame válido. Tokens de generación evitan reactivar operaciones obsoletas tras pausa, finalización o background. Las operaciones de inicio/reanudación/finalización tienen protección frente a llamadas duplicadas.

El planificador adaptativo solicita los siguientes intervalos:

| Condición | Intervalo | FPS solicitado aproximado |
| --- | ---: | ---: |
| Normal | 220 ms | 4,55 |
| Precaución, peligro o calibración | 110 ms | 9,09 |
| Batería ≤ 15 %, sin cargar | 300 ms | 3,33 |
| Temperatura de batería elevada, referencia 40 °C | 400 ms | 2,50 |
| Temperatura crítica, referencia 44 °C | 500 ms | 2,00 |

La histéresis térmica es de 2 °C. Se usa temperatura de batería, no temperatura de CPU ni un diagnóstico completo de estado térmico Android. La prioridad de calor/batería prevalece sobre aumentar muestreo por riesgo. El FPS real puede ser inferior al solicitado.

No se procesan frames de forma ilimitada en paralelo: se descartan los que llegan durante trabajo ocupado o antes del intervalo objetivo. No se han documentado aquí nuevas mediciones físicas de consumo, temperatura, memoria o precisión.

## 14. Modelos de datos y SQLite

La base principal es `driverawake.sqlite` en el directorio de documentos de la aplicación, con `NativeDatabase.createInBackground` y claves foráneas activas. No se observa cifrado específico de SQLite en esta implementación.

Hay ocho tablas:

| Tabla lógica | Campos y responsabilidad |
| --- | --- |
| `Trips` | ID, inicio/fin, estado, duración, alertas, bostezos, ausencia de rostro, muestras por nivel, suma/máximo de riesgo, tiempo ocular cerrado, batería/temperatura inicial/final/máxima, carga y fechas de creación/actualización. |
| `TripEvents` | ID, viaje, fecha, nivel, tipo, duración, riesgo, PERCLOS, predicción/confianza opcionales, notas y creación. |
| `SessionDrafts` | Viaje, snapshot JSON, inicio, actualización y marca de incompleto. |
| `Calibrations` | ID, versión, payload JSON y actualización. |
| `AppSettings` | ID, versión, payload JSON y actualización. |
| `ModelMetadata` | ID, payload JSON y actualización; también soporta metadata operativa/migración/consentimiento. |
| `FleetOutbox` | Identidad, empresa, propietario, viajes local/remoto, clase de mensaje, payload, estado de sincronización, intentos, próximo intento, fechas y último error. |
| `RestSessions` | ID, viaje local, inicio/fin, duración, motivo, confirmación voluntaria y binding empresarial JSON opcional. |

Migraciones: 1→2 crea `FleetOutbox`; 2→3 crea `RestSessions`. No se reemplazan las tablas originales. Los descansos referencian viajes con borrado en cascada. El inventario JSON detalla nombres y tipos de columnas.

Los principales modelos de dominio son `DrowsinessState`, `DrowsinessFrameMetrics`, `DrowsinessEvent`, `MlPrediction`, `AppSettings`, `DeviceTelemetrySnapshot`, `TripSessionDraft`, `TripSessionSummary`, `TechnicalSessionReport` y `CloudTripReport`. Las clases de datos generadas por Drift representan las filas/compañeros de inserción de cada tabla.

`DatabaseBootstrap` y `LegacyPreferencesMigrator` migran borradores, eventos, viajes, ajustes y calibraciones desde claves históricas. La migración registra finalización transaccional, evita duplicados y conserva las preferencias originales como fallback. Los elementos corruptos se registran y se omiten cuando la política del migrador lo permite.

## 15. Viajes, eventos, historial y exportación

`TripSessionService` inicia, restaura, pausa, reanuda, observa, finaliza y descarta viajes. Acumula tiempo mediante observaciones válidas en el ciclo de sesión; no debe interpretarse como tiempo de movimiento confirmado exclusivamente por GPS.

Conserva muestras normales/precaución/peligro, alertas, bostezos, episodios de falta de rostro, riesgo agregado y tiempo con ojos cerrados. Registra telemetría inicial/final y temperatura máxima observada.

Tipos de evento local presentes:

- `alerta_precaucion` y `alarma_critica` para cambios de nivel.
- `bostezo`, `rostro_ausente`, `ojos_cerrados_prolongados`.
- `cabeza_caida`, `distraccion`, `perclos_alto`.
- `modelo_somnolencia`, ruta experimental condicionada a disponibilidad real del modelo.
- `monitoreo_interrumpido` por pausa.
- `sos_manual` por solicitud opcional del usuario, sin diagnosticar fatiga.

Existen cooldowns de eventos y de incidentes empresariales diferentes. Los eventos agregados de alarma no se vuelven a convertir automáticamente en incidentes duplicados.

`LocalHistoryService` aplica retención, consulta eventos/viajes y conserva fallback histórico. Su `loadEvents` usa `await` dentro del `try` para capturar errores asíncronos y poder recurrir al fallback. El servicio impone además un límite de eventos del historial; la lógica observada usa 600 como máximo de referencia.

La retención configurable es 7, 30 o 90 días, o sin borrado automático; el valor por defecto es 30 días. La eliminación/retención local no elimina por sí sola las copias remotas personales ni documentos empresariales ya recibidos.

Exportaciones disponibles:

| Formato | Contenido / mecanismo |
| --- | --- |
| PDF diario | Eventos y resúmenes seleccionados, etiquetas localizadas y apertura de hoja de compartir. |
| PNG diario | Representación visual de informe para compartir. |
| JSON técnico | Informe de sesión sanitizado, observabilidad y estado, con confirmación previa de exportación. |
| Copia personal Firestore | Resumen estructurado versionado del viaje, tras confirmación. |
| CSV web | Incidentes recibidos filtrados y estado operativo derivado. |

Compartir un archivo lo entrega a la aplicación/destinatario elegido. No se observa una nube automática de imágenes faciales.

## 16. Autenticación y copias personales

Firebase Authentication gestiona cuentas opcionales con correo y contraseña. La app tiene registro, validación de formularios/confirmación de contraseña, login, recuperación por correo, restauración de sesión, logout y eliminación de cuenta con reautenticación.

El acceso local sin cuenta permanece disponible. La inicialización o un fallo Firebase no debe impedir el detector local.

Las copias personales viven en:

```text
users/{uid}/reports/{reportId}
```

`CloudTripReport` usa esquema versionado y datos de tiempo, conteos de alertas, riesgo y telemetría. No contiene frames ni ubicación continua. El ID estable permite copiar de nuevo el mismo viaje sin crear un informe diferente.

`CloudReportService` consulta hasta 100 informes desde servidor, muestra última consulta confirmada y distingue error de lista vacía. El caché persistente Firestore está deshabilitado en ese servicio. Los timeouts observados son 20 segundos para lecturas/borrado y 30 para commits de copia.

Si vence una escritura, el mensaje reconoce que podría completarse posteriormente; no afirma que se haya cancelado. Borrar cuenta revoca primero la vinculación empresarial local y elimina copias personales conforme al procedimiento del servicio. No elimina silenciosamente incidentes empresariales remotos.

No hay aquí un sistema de pago, suscripción cobrada, verificación documental de conductores o directorio Auth administrativo expuesto en el navegador.

## 17. Idiomas, temas y componentes visuales

`LocaleController` restaura la selección `es`, `en` o `system` y escucha cambios de idioma del dispositivo. `AppStrings` traduce textos exactos y plantillas con slots; `LocalizedText` permite aplicarlo a textos constantes. `messages.dart` contiene catálogo inglés y correcciones españolas históricas.

El cambio de idioma no debe cerrar la cuenta ni perder el contenido del formulario o la ruta abierta. Las pruebas cubren esos casos y exportaciones. Los datos persistidos, códigos de evento y campos Firestore no se renombran al traducir la interfaz.

La cobertura inglesa no es exhaustiva en todos los textos Guardian nuevos: navegación/SOS y la central web conservan textos españoles en distintos puntos. La voz selecciona el idioma efectivo de la app cuando hay una voz offline correspondiente.

El tema principal es oscuro, Material 3, con variante de alto contraste. Existe `RiskTheme` para colores semánticos. La conducción utiliza superficies oscuras, azul/cian, verde, ámbar y rojo, tarjetas redondeadas y controles grandes. El cuerpo adapta su distribución y permite scroll en vistas pequeñas.

Widgets incluidos: cuenta, selector de idioma, estado de riesgo, overlay de alerta, overlay facial, métricas técnicas, lectura de navegación y tarjeta de mapa/paradas. Estos widgets no constituyen pantallas adicionales por sí solos.

## 18. GPS, mapas, destinos y navegación

Las interfaces desacopladas son `LocationProvider`, `MapProvider`, `DestinationSearchProvider`, `NearbyPlacesProvider` y `RoutingProvider`. Modelos asociados: `GeoPoint`, `LocationFix`, `Destination`, `NearbyPlace` y `RoadRoute`.

`DeviceLocationProvider` usa Geolocator. La ubicación requiere activación explícita, servicio Android disponible y permiso. No se declara permiso de ubicación en segundo plano. Se solicita precisión alta y filtro de distancia de 20 metros.

Estados GPS: `disabled`, `denied`, `permanentlyDenied`, `waiting`, `active`, `stale` y `unavailable`.

Un fix se considera utilizable solo con coordenadas válidas, precisión finita entre 0 y 100 metros y antigüedad no negativa de hasta 30 segundos. Velocidad desconocida permanece desconocida; no se inventa una velocidad. La UI convierte m/s a km/h cuando hay valor disponible.

`GuardianMap` integra `flutter_map`: tiles HTTPS, atribución OSM, marcador GPS, destino, lugares, recentrado, zoom y selección por pulsación larga en el flujo habilitado. Su vista inicial general de Perú no se presenta como ubicación personal. La tarjeta de conducción restringe interacción y remite al flujo de configuración.

Proveedores por defecto y límites:

| Función | Implementación y límites |
| --- | --- |
| Tiles | `tile.openstreetmap.org`; plantilla configurable con `NAV_TILE_URL`. |
| Destinos | Nominatim, `/search`, Perú, hasta 5 resultados; botón explícito sin autocomplete. |
| Protección de búsqueda | Separación mínima de 2 s, caché 24 h y tamaño acotado. |
| Lugares | Overpass, radio 3 km, máximo 30 elementos y búsqueda bajo demanda. |
| Protección de lugares | Una consulta por minuto, caché 15 min; distancias recalculadas desde el punto actual. |
| Timeout HTTP | 12 segundos en el adaptador. |
| Host de búsqueda | Configurable con `NAV_SEARCH_HOST`. |
| Host de lugares | Configurable con `NAV_NEARBY_HOST`. |

Categorías consultadas: combustible, estacionamiento, cafetería, restaurante, estación de buses, área de descanso, área de servicio, hotel, motel y hostal, según tags OSM. La UI muestra nombre, categoría, distancia en línea recta, horarios declarados si existen y datos conocidos de acceso.

Hay hasta 20 favoritos y 10 destinos recientes locales, con eliminación explícita. El historial local de destinos no es historial remoto de ubicación.

El proveedor de rutas predeterminado es `NoInternalRouting`: devuelve ausencia de ruta. No se dibuja una recta como ruta transitable ni se fabrica distancia por carretera o ETA. La acción real de navegación usa una URL de Google Maps con destino, modo de conducción y petición de iniciar navegación; puede abrir la app o navegador disponible.

Antes de salir se informa que el monitoreo queda pausado. Las rutas de automóvil externas no certifican gálibos, restricciones o accesos para buses y camiones. La marca de acceso OSM no equivale a una inspección física.

En la última validación, Nominatim y tiles respondieron y Overpass devolvió 502 por saturación. Ese resultado es evidencia de aquella consulta, no una medición permanente de disponibilidad. No se habilitaron Google Maps SDK, Google Places ni Google Routes facturables.

## 19. Smart Rest

`RestRecommendationEngine` consume `DrowsinessState` y tiempo de conducción desde el último descanso. No crea un segundo score de somnolencia.

| Motivo interno | Regla y respuesta |
| --- | --- |
| `SIGNAL_UNAVAILABLE` | Sin rostro o calidad < 0,32: revisar cámara al detenerse; no diagnostica fatiga. |
| `CRITICAL_SIGNAL` | Peligro del motor: detenerse en lugar seguro cuanto antes, sin esperar búsqueda de café. |
| `REPEATED_CLOSURE` | Tres cierres prolongados registrados en cinco minutos, separados al menos 30 s para no duplicar un mismo episodio. |
| `SUSTAINED_WARNING` | Precaución sostenida al menos 20 s. |
| `DRIVING_DURATION` | Intervalo de conducción configurado alcanzado. |
| `MANUAL` | Consulta manual de opciones cuando se está estacionado. |

El recordatorio por tiempo se inicia en dos horas y puede configurarse entre 15 y 240 minutos. No es una afirmación de límite legal de conducción. La disponibilidad de GPS/lugares no retrasa el consejo crítico. No se dice que tomar café elimine la somnolencia.

La búsqueda de lugares es una operación aparte y explícita. No existe recomendación de paradas certificadas mediante un motor de accesibilidad vial ni consulta de lugares a lo largo de una ruta interna calculada.

## 20. Descansos declarados

`RestRepository` persiste inicio y fin, exige un viaje local y evita dos intervalos abiertos. El identificador deriva de información del viaje, tiempo y aleatoriedad segura mediante SHA-256. Se normaliza el tiempo a segundos para coherencia del registro.

La finalización calcula duración, rechaza un reloj que retroceda respecto al inicio y es idempotente si el intervalo ya se cerró. Se consulta historial de hasta 100 descansos en la app.

Cada descanso tiene confirmación voluntaria. Iniciar navegación no crea un descanso y finalizarlo no reanuda por sí solo la cámara. El viaje puede cerrar un intervalo declarado abierto como parte de la operación de finalización.

Compartir descansos exige consentimiento empresarial específico adicional. El binding conserva qué organización, conductor y viaje estaban autorizados. Los intervalos se envían finalizados y las reglas validan tiempo, duración y vínculo. La central consulta hasta 200 sesiones recientes.

No se deduce descanso fisiológico, sueño reparador ni aptitud para conducir a partir de GPS o duración registrada.

## 21. Asistente de voz

`VoiceAssistant` coordina mensajes y depende de `VoiceOutput`; `LocalVoiceOutput` adapta `flutter_tts`.

- Desactivado por defecto en su estado inicial.
- Selección del idioma efectivo español/inglés.
- Búsqueda de voz instalada que declare `network_required` falso o cero.
- Si no existe, se comunica indisponibilidad y se mantienen los canales locales de alarma.
- Configuración serializada, velocidad de habla 0,45 y volumen TTS 1 en el adaptador.
- Espera de finalización de la locución para coordinar su prioridad.
- Cooldown por motivo de dos minutos y separación global de 20 s para avisos no críticos.
- Mensaje crítico con prioridad; puede desplazar un aviso inferior y evita interrupción por uno no crítico.
- Token de generación para impedir hablar después de una cancelación, aunque la configuración siga resolviéndose.
- Pausa, background, fin de viaje o desactivación cancelan habla pendiente.

Los mensajes de recomendación también respetan la habilitación de sonido del flujo que los solicita. No hay reconocimiento de voz, micrófono grabando ni chatbot conversacional en conducción.

## 22. SOS y contacto de emergencia

El panel permite un número opcional, con formato de 6–15 dígitos y `+` inicial opcional. Se conserva en preferencias locales y puede eliminarse dejando el campo vacío.

Al confirmar se pausa el monitoreo y se abre el marcador Android con `ACTION_DIAL`. Un número inválido no se convierte en una cadena arbitraria de marcación. Si no hay número configurado se abre el marcador vacío.

La opción de registrar solicitud manual crea `sos_manual` en el historial local, relacionado con el viaje cuando está disponible. Su nota aclara que no es detección de fatiga ni evidencia de llamada realizada. No se transforma automáticamente en un incidente empresarial remoto.

No hay llamada automática, transmisión automática de posición, integración con policía/ambulancia, número de emergencia universal hardcodeado ni despacho de una asistencia real.

## 23. Flotas, organizaciones y roles

El modo personal puede funcionar sin empresa. El modo flota requiere identidad Firebase, organización activa, membresía, asignación y selección de viaje.

Entidades implementadas mediante documentos y relaciones: organización, membresía, vehículo, asignación de conductor, viaje, incidente, acción del operador y descanso. «Conductor» se representa principalmente por el UID y la membresía DRIVER; no hay una ficha profesional completa con licencias/documentos verificados.

| Rol | Operaciones implementadas |
| --- | --- |
| ADMIN | Gestionar membresías permitidas, vehículos, asignaciones y alta de viajes; consultar y documentar incidentes. |
| OPERATOR | Consultar datos autorizados de la organización, reconocer incidentes, registrar seguimiento y resolución. |
| DRIVER | Consultar sus asignaciones/viajes; emitir estados, incidentes y descansos autorizados mediante la app. No entra a la central de operadores. |

La primera organización y su primer ADMIN se preparan mediante script privilegiado de bootstrap. El cliente no se autoasigna ADMIN ni crea una organización privilegiada. El script comprueba argumentos, usuario existente y que no se sobrescriba una organización. La escritura exige el flag de aplicación; la preparación puede revisarse sin escribir.

El alta administrativa web recibe UIDs de cuentas existentes. No incluye un directorio Firebase Admin en navegador ni envío automático de invitaciones por correo.

La primera consulta de asignaciones necesita conexión. Una sesión local recuperada no se reasocia silenciosamente a una empresa: debe seleccionarse el vínculo de nuevo según el flujo disponible.

## 24. Incidentes y sincronización offline

### 24.1 Clasificación

`IncidentClassifier` adapta eventos ya producidos por el detector:

| Evento local | Incidente empresarial |
| --- | --- |
| `ojos_cerrados_prolongados` | `PROLONGED_EYE_CLOSURE` |
| `perclos_alto` | `HIGH_PERCLOS` |
| `bostezo` con repetición suficiente | `REPEATED_YAWNING` |
| `cabeza_caida` | `SUSTAINED_HEAD_DOWN` |
| `distraccion` | `POSSIBLE_DISTRACTION` |
| `rostro_ausente` con duración suficiente | `SIGNAL_UNAVAILABLE` |
| `monitoreo_interrumpido` | `MONITORING_INTERRUPTED` |

Severidades: INFO, WARNING y CRITICAL. Falta de señal e interrupción son informativas, con calidad insuficiente y valor numérico contractual cero. El dashboard las muestra como «No evaluable». Los incidentes de fatiga requieren señal fiable según el filtro y condiciones existentes.

El ID estable combina organización, viaje, conductor y evento original mediante SHA-256. `IncidentRepository` persiste detección e intención de entrega en una transacción. Aplica cooldown persistente de referencia de 30 s por tipo y permite escalar de WARNING a CRITICAL.

### 24.2 Outbox

Estados declarados: `LOCAL_ONLY`, `QUEUED`, `SYNCING`, `SYNCED` y `FAILED`; la cola persistente utiliza los estados de entrega que corresponden a cada operación.

- Máximo de referencia de 2.000 pendientes.
- Payload de detección inmutable; cambian metadatos de entrega.
- Un worker por instancia, sin vaciados simultáneos.
- Orden FIFO y lotes de hasta diez mensajes por flush.
- Timeout de envío de 15 s.
- Backoff exponencial desde 5 s con techo de base de 900 s y jitter adicional.
- Revisión de autorización y de que el mensaje siga pendiente antes de enviar.
- Reintentos idempotentes: un timeout no implica que el servidor no haya escrito.
- Detención del lote tras fallo para conservar orden.
- El cierre remoto del viaje permanece detrás de sus mensajes pendientes.

`FleetService` programa intentos periódicos de referencia cada 15 s y envía estados de salud con limitación de frecuencia. No existe una garantía de proceso Android permanente en segundo plano.

Cerrar sesión, revocar consentimiento o eliminar la cuenta detiene envíos futuros y borra cola local según el flujo. Una transacción ya enviada puede completarse. La retención local también puede eliminar mensajes aún pendientes al vencer el plazo elegido.

### 24.3 Firestore

```text
organizations/{orgId}
  members/{uid}
  vehicles/{vehicleId}
  assignments/{uid}
  trips/{tripId}
  incidents/{incidentId}
  operatorActions/{actionId}
  restSessions/{restId}
```

Las reglas comprueban autenticación, organización/membresía activa, rol, propiedad/asignación, campos permitidos, tipos, tiempos y relaciones. Los incidentes no tienen actualización/borrado por cliente. Las acciones son anexas e inmutables, con actor y timestamp de servidor.

Las acciones permitidas son `ACKNOWLEDGED`, `ACTION_RECORDED` y `RESOLVED`; las notas están acotadas a 1.000 caracteres y son obligatorias en las acciones que lo exigen. El estado del incidente se deriva de esas acciones, sin reescribir la detección original.

Las reglas protegen acceso y formato, pero no prueban que un cliente no haya falsificado una observación. No hay certificación de autenticidad física de la telemetría.

## 25. Dashboard web y reportes

Hay once rutas de producto: tres públicas y ocho de central, más páginas/artefactos del framework. El último build informó trece páginas estáticas generadas; ese contador de build no debe confundirse con once funcionalidades de ruta.

| Ruta | Contenido |
| --- | --- |
| `/` | Landing de producto, explicación y acceso a demo/pitch/central. |
| `/demo/` | Simulador público determinista e independiente. |
| `/pitch/` | Presentación interactiva de diez diapositivas. |
| `/dashboard/` | Resumen de operación de la organización. |
| `/dashboard/trips/` | Viajes, asignación administrativa, estado de monitoreo y descansos. |
| `/dashboard/incidents/` | Incidentes, selección, detalle, reconocimiento y seguimiento. |
| `/dashboard/fleet/` | Vehículos y alta administrativa. |
| `/dashboard/drivers/` | Membresías DRIVER, viaje operativo/último conocido, última señal e índice recibido. |
| `/dashboard/rest/` | Descansos finalizados compartidos. |
| `/dashboard/reports/` | Filtros, indicadores, gráfico por día, tabla y CSV. |
| `/dashboard/settings/` | Gestión de membresías y configuración operativa disponible. |

La central valida sesión y membresía ADMIN/OPERATOR. Sin configuración muestra un estado pendiente y sin datos inventados. Una cuenta DRIVER no recibe acceso al panel de operación. La selección de organización se recuerda en sesión del navegador por usuario y se vuelve a validar.

`onSnapshot` recibe documentos autorizados. La interfaz distingue caché/datos pendientes de confirmación y exige estado de servidor de las colecciones para anunciar confirmación. Se limpian suscripciones/datos ante cambios de cuenta, empresa, permisos o error.

Ventanas máximas de consulta actuales:

| Colección | Documentos de la ventana |
| --- | ---: |
| Viajes | 200 |
| Incidentes | 300 |
| Acciones | 1.000 |
| Vehículos | 300 |
| Membresías | 300 |
| Descansos | 200 |

Los KPI describen esas ventanas: viajes activos, monitoreos con señal reciente, nuevos incidentes, reconocidos/atendidos y otros resúmenes derivados. Monitoreo reciente exige viaje activo y señal dentro de dos minutos; una membresía o un viaje por sí solos no demuestran cámara activa. La central no puede contar mensajes que nunca recibió de un dispositivo desconectado.

La tabla de conductores usa UIDs reales; no fabrica nombres ni coordenadas. El índice se asocia al viaje y a la detección, y se distingue recepción tardía de observación reciente. Un viaje completado/asignado no se muestra como monitoreo en marcha.

Reportes permiten combinar fecha desde/hasta en America/Lima, vehículo, conductor, viaje, severidad y tipo. Gráfico, métricas de incidentes, tabla y CSV usan el mismo conjunto filtrado. La relación con vehículo depende de que el viaje esté en la ventana disponible.

El tiempo medio a reconocimiento toma el primer ACKNOWLEDGED válido posterior a la detección e incluye demora de conectividad. Sin muestra válida se muestra ausencia de dato, no un cero inventado. El CSV cita los campos y neutraliza prefijos de fórmula de hoja de cálculo. Incluye ID, viaje, tipo, severidad, detección, recepción, riesgo y estado.

No hay paginación histórica completa de una flota ilimitada ni un data warehouse. Tampoco hay mapa empresarial con GPS continuo compartido, dado que ese dato no se transmite en este contrato.

## 26. Simulador público

La demo tiene estado propio, reducer determinista y persistencia de navegador separada. Sus personas, vehículo, destinos, lugares e incidentes son ficticios y están rotulados como DEMO — DATOS SIMULADOS.

Permite:

- Escoger destino simulado e iniciar viaje.
- Simular conducción normal, precaución y cierre ocular crítico.
- Perder/restaurar conectividad.
- Mantener un incidente en cola, recargar y conservarlo.
- Sincronizar el mismo ID sin duplicarlo.
- Seleccionar incidente, reconocer y registrar una acción humana.
- Generar una recomendación simulada de parada, escoger un lugar ficticio y confirmar voluntariamente un descanso.
- Pausar las acciones de conducción mientras existe descanso activo.
- Finalizar y ver duración lógica, incidentes, acciones, descansos y pendientes.
- Reiniciar exclusivamente el estado de la demo.

Cada interacción relevante avanza un reloj lógico de 30 segundos. Existe deduplicación por ID/intento y cooldown. El timeline está acotado; el contenido persistido se valida y se recupera a un estado inicial si es incompatible. Si el almacenamiento está bloqueado se informa y se conserva sesión en memoria cuando el flujo lo permite.

La demo no usa datos privados, no escribe datos sintéticos en la flota de producción y no prueba ML Kit, cámara o GPS. La integración de emuladores es un recorrido técnico distinto, realizado con SDK cliente autenticado y reglas reales locales.

## 27. Presentación y materiales de competencia

`Pitch` contiene diez capítulos: problema, personas, propuesta, funcionamiento, demostración, arquitectura, diferenciación, validación, adopción y siguiente etapa.

Hay controles anterior/siguiente, puntos de selección, teclado con flechas/PageUp/PageDown/Inicio/Fin, enlace a demo y avance automático de 18 segundos por diapositiva. El material indica tres minutos como recorrido objetivo; una ejecución real puede variar si se abre la demo o se pausa.

Archivos de entrega: `HACKTHEANDES_2026.md`, `proyecto.md`, `DEMO_GUIDE.md`, `PITCH_SCRIPT.md`, `DEPLOYMENT.md`, `TECHNICAL_VALIDATION.md` y `PRIVACY.md`.

El guion incluye preguntas sobre precisión, conectividad, privacidad, costos, Smart Rest, fallos de cámara y utilidad empresarial. Hay una plantilla vacía de feedback para registrar evidencia real; no presenta fixtures como pilotos o clientes.

No hay constancia en esta revisión de una entrega oficial realizada ni de URLs públicas de demo/pitch. Los requisitos y fuentes de la competencia se documentan como consulta previa, sin convertir una plantilla en comprobante de participación o elegibilidad.

## 28. Pipeline Python de machine learning

El pipeline investiga clasificación de ventanas de vídeo de UTA-RLDD. El código utiliza OpenCV y MediaPipe FaceMesh para features; ese extractor no tiene paridad verificada con ML Kit móvil.

| Archivo de `app_conductores_ml/src/` | Función |
| --- | --- |
| `config.py` | Carpetas, clases, etiquetas, umbrales y parámetros de extracción. |
| `dataset_utils.py` | Descubrimiento y metadata de vídeos, etiquetas y sujetos. |
| `inspect_dataset.py` | Inventario de dataset y detección de vídeos no etiquetados. |
| `landmark_utils.py` | Geometría de ojos/boca/cabeza a partir de landmarks. |
| `extract_features.py` | Lectura/muestreo de vídeo en memoria y features por ventana. |
| `feature_engineering.py` | Ampliación temporal, deltas, interacciones y rolling windows. |
| `splitting.py` | Holdout y validación agrupada por sujeto, comprobación de ausencia de fuga. |
| `train_random_forest.py` | Entrenamiento/evaluación de Random Forest y artefactos. |
| `train_model_zoo.py` | Comparación de varios clasificadores tabulares. |
| `train_logistic_search.py` | Búsqueda/entrenamiento logístico. |
| `train_mlp_tflite.py` | MLP Keras, preprocesamiento, evaluación y exportación TFLite. |
| `predict_sample.py` | Predicción de una fila/ventana de características. |
| `export_flutter_assets.py` | Preparación de modelo y metadata de integración. |
| `run_all_phase2.py` | Orquestación del pipeline de fase 2. |
| `validate_model_contract.py` | Hash, shapes, orden y vectores del contrato. |
| `validate_product_rules.py` | Evaluación experimental/histórica de reglas; no equivale a la ejecución Dart física. |
| `__init__.py` | Inicialización del paquete Python. |

Parámetros base: 5 FPS de muestreo, ventanas de 10 s, ancho máximo de referencia 640, seis workers de extracción, EAR 0,16 y MAR 0,55. Las etiquetas de dataset 0/5/10 se traducen a clases 0 despierto, 1 cansancio y 2 somnoliento.

El conjunto inicial de features incluye ratio de rostro, EAR/MAR agregados, PERCLOS, parpadeos, duración ocular máxima, bostezos y proxies de pose. La ampliación genera diferencias e indicadores temporales, rolling de 3/6/12 ventanas, sumas y acumulaciones. El contrato empaquetado contiene 181 entradas.

El árbol local contiene modelos `.joblib`, `.keras` y `.tflite`, metadata y reportes/matrices/curvas históricos. Su presencia no significa que se hayan entrenado durante esta tarea ni que sus métricas validen el producto actual.

El README ML conserva resultados antiguos obtenidos con separación por vídeo. La documentación de validación identifica fuga de sujetos en evaluación histórica y falta de paridad. Por eso este informe no presenta esas accuracies como precisión defendible con conductores nuevos. El código de splitting fue corregido para exigir agrupación por sujeto; aún hace falta reentrenar/evaluar con el extractor adecuado y un conjunto final independiente.

No se guardan frames como imágenes en el flujo de extracción descrito. Sí pueden existir vídeos locales de entrada y CSV de características; no forman parte de la app instalada ni de las pruebas unitarias ligeras.

## 29. Contrato ML, vectores y assets

El contrato compartido fija versión, hash de modelo, extractor, formas, orden de características, clases, preprocesamiento y política de fallo.

| Dato | Valor |
| --- | --- |
| Input | `[1, 181]`. |
| Output | `[1, 3]`. |
| Clases, orden | despierto, cansancio, somnoliento. |
| Paridad | `parity_verified=false`. |
| Estado | `disabled_by_default`. |
| SHA-256 TFLite | `e29e3b6017ad897a319afe7968b5bca3213f12a5551a3853b9e3cb5671f1c34f`. |
| Preprocesamiento | Imputación por mediana y normalización tipo StandardScaler con metadata ordenada. |

`DrowsinessModelService` comprueba contrato/manifiesto, hash, compatibilidad, orden y tensores. `ModelInputPreprocessor` rechaza longitudes incompatibles, reemplaza entradas ausentes/no finitas por medianas, maneja desviaciones inválidas y rechaza resultados no finitos. La app no habilita el modelo incompatible por pulsar simplemente su preferencia de Ajustes.

Los siete archivos de vectores son `manifest.json`, `raw_features.json`, `frame_metrics.json`, `expected_base_features.json`, `expected_temporal_features.json`, `expected_scaled_input.json` y `expected_probabilities.json`. Permiten comparación numérica entre implementaciones, sin demostrar equivalencia entre los detectores MediaPipe y ML Kit.

Assets declarados en Flutter:

| Recurso | Tamaño observado | Uso |
| --- | ---: | --- |
| `assets/logo.png` | 1.072.116 bytes | Marca visual. |
| `assets/audio/magicdrive_alarm.wav` | 211.724 bytes | Alarma local. |
| `assets/models/drowsiness_mlp.tflite` | 37.552 bytes | Modelo experimental empaquetado, rechazado por incompatibilidad. |
| `assets/models/preprocessing_metadata.json` | 18.410 bytes | Orden, imputación y escalado. |
| `assets/models/model_manifest.json` | 510 bytes | Compatibilidad/hash/shapes/clases. |

Hay además iconos, splash y recursos propios de las carpetas de plataforma. No son nuevos modelos ni pantallas funcionales.

## 30. Integración Android y plataformas adicionales

El canal `com.magicdrive.alert/device` expone:

| Método | Acción |
| --- | --- |
| `openDialer` | Abrir marcador, con número validado opcional. |
| `cameraCapabilities` | Consultar combinación concurrente declarada y estado de habilitación en la app. |
| `getBatteryThermal` | Batería, temperatura de batería, voltaje, estado de carga, timestamp, fabricante/modelo, Android y memoria PSS. |
| `playAlarm` | Reproducir recurso local con repetición limitada. |
| `stopAlarm` | Detener/liberar audio. |
| `setKeepScreenAwake` | Activar/desactivar mantenimiento de pantalla encendida. |

Permisos declarados: CAMERA, INTERNET, VIBRATE, ACCESS_FINE_LOCATION y ACCESS_COARSE_LOCATION. Cámara y cámara frontal se declaran opcionales para controlar fallos en equipos incompatibles. Backup Android automático está deshabilitado.

El manifiesto incluye visibilidad de intents HTTPS, servicio TTS y procesamiento de texto. No hay permiso RECORD_AUDIO ni CALL_PHONE ni un permiso de ubicación background declarado en el manifiesto principal examinado. Abrir el dialer no equivale a solicitar llamada automática.

Gradle: AGP 8.9.1, plugin Kotlin 2.3.21, Google Services 4.4.4 y Gradle wrapper configurado para 8.12. Java y Kotlin apuntan a JVM 11; el runtime de build usado puede ser más nuevo. `compileSdk` y `targetSdk` se toman de Flutter, por lo que no se inventa aquí una cifra fija.

Google Services solo se aplica cuando existe el JSON Android correspondiente. El modo local puede compilar sin ese archivo. Release exige propiedades/keystore reales y no sustituye silenciosamente su firma por debug.

## 31. Dependencias y configuración

### 31.1 Flutter

Dependencias de producto declaradas: `camera`, `camera_android`, `cupertino_icons`, `google_mlkit_commons`, `google_mlkit_face_detection`, `permission_handler`, `vibration`, `tflite_flutter`, `shared_preferences`, `intl`, `pdf`, `path_provider`, `share_plus`, `crypto`, `drift`, `sqlite3_flutter_libs`, `path`, `firebase_core`, `firebase_auth`, `cloud_firestore`, `flutter_map`, `latlong2`, `geolocator`, `http`, `url_launcher`, `flutter_tts`, Flutter y sus localizaciones.

Desarrollo: `flutter_test`, `flutter_lints`, `build_runner` y `drift_dev`. Los lockfiles fijan versiones resueltas; los rangos de `pubspec.yaml` no deben confundirse con las versiones instaladas exactas.

### 31.2 Web

Versiones resueltas observadas en `package-lock.json`: Next.js 16.4.2, React/React DOM 19.3.1, Firebase 12.19.0, TypeScript 5.9.3, Tailwind CSS 4.3.3, Vitest 3.2.7 y Playwright 1.64.1. Son datos de este lockfile, no una recomendación de actualización.

También hay ESLint y reglas Next, tipos Node/React y PostCSS. La exportación estática permite servir la web sin un proceso Next de producción.

### 31.3 Python y backend

Python declara OpenCV, MediaPipe, NumPy, pandas, scikit-learn, matplotlib, joblib, tqdm, TensorFlow, seaborn, PyYAML y protobuf. El entorno de desarrollo añade pytest y Ruff. Varias versiones están fijadas por compatibilidad del pipeline histórico.

Backend usa `firebase-admin` para scripts privilegiados y `@firebase/rules-unit-testing`/Firebase cliente para pruebas. No se incorpora Admin SDK al APK ni al bundle web.

### 31.4 Opciones de compilación y entorno

| Opción / familia | Propósito |
| --- | --- |
| `DRIVERAWAKE_TECHNICAL_FEATURES` | Habilitación de características técnicas por build. |
| `GUARDIAN_USE_EMULATORS` | Selección de integración móvil de pruebas. |
| `GUARDIAN_EMULATOR_HOST` | Host local autorizado para Android/emulador. |
| `NAV_TILE_URL`, `NAV_SEARCH_HOST`, `NAV_NEARBY_HOST` | Proveedores de mapa/geocodificación/lugares. |
| `NEXT_PUBLIC_FIREBASE_*` | Configuración pública de cliente Firebase web. |
| `NEXT_PUBLIC_USE_EMULATORS` y puertos públicos de emulador | Build web de integración local. |
| `GUARDIAN_EMULATOR_PROJECT`, puertos y `FIREBASE_E2E` | Harness local de pruebas web. |
| `GUARDIAN_BROWSER_EXECUTABLE`, `GUARDIAN_PREVIEW_PORT` | Navegador instalado y puerto de preview de pruebas. |
| `NAV_LIVE_TESTS` | Test opt-in con solicitudes reales acotadas a proveedores públicos. |

No se incluyen valores de claves, tokens, contraseñas privadas o material de firma. Las variables públicas del cliente no son un lugar para guardar credenciales administrativas.

## 32. CI, firma, hosting y scripts

### 32.1 Integración continua

`.github/workflows/ci.yml` tiene cinco jobs:

| Job | Checks declarados |
| --- | --- |
| Flutter | Dependencias, formato, análisis, tests y APK debug. |
| Python | Dependencias de desarrollo, Ruff, pytest y validación del contrato. |
| Repository safety | Gitleaks y comprobación de higiene de archivos versionados. |
| Dashboard | npm ci, typecheck, lint, unit tests y build. |
| Firestore security | Node 22, Java 21, Firebase CLI y pruebas del emulador. |

No se observa un job E2E de navegador en este CI; esos recorridos se ejecutaron localmente. El workflow usa Flutter estable, sin congelar exactamente el SDK de la máquina local. Una definición YAML y checks locales no prueban un run remoto verde.

### 32.2 Release

`release.yml` es manual y usa environment `production`. Valida existencia de secretos de firma, reconstruye keystore temporal, ejecuta dependencias/tests y genera AAB release con SHA-256. Publica artefacto del workflow y elimina material temporal incluso al fallar. No contiene una publicación automática a Google Play.

### 32.3 Hosting

`firebase.json` apunta a `dashboard/out`, aplica clean URLs/trailing slash y cabeceras como nosniff, protección de framing, referrer policy y permissions policy restrictiva de cámara/micrófono/geolocalización web. Esa política afecta a la web servida, no a permisos de la app Android.

No se ejecutó despliegue remoto en el trabajo documentado. La landing, demo y pitch son exportables; la central necesita configuración Firebase y membresías reales autorizadas para datos operativos.

### 32.4 Scripts

| Script | Qué hace y alcance |
| --- | --- |
| `scripts/check_repository_hygiene.py` | Revisa nombres/rutas versionados prohibidos: firma, `.env` privado y datasets. No es por sí solo un scanner exhaustivo de secretos en contenido. |
| `scripts/firebase_smoke_test.mjs` | Prueba remota opt-in `--live`: crea dos cuentas sintéticas temporales, prueba copia/acceso y hace limpieza; escribe en el proyecto configurado, por lo que no se ejecuta como una lectura inocua. |
| `backend/scripts/bootstrap.mjs` | Preparación/escritura administrativa de organización y primer ADMIN bajo control explícito. |
| `backend/scripts/seed-emulators.mjs` | Fixture ficticio local; valida loopback/proyecto demo y emite evento mediante SDK DRIVER. |
| `dashboard/scripts/emulator.mjs` | Build/test con variables de emulador y puertos/proyecto validados. |
| `dashboard/scripts/serve.mjs` | Servidor estático de preview loopback, tipos MIME, protección de path y respuesta 404. |

Configuraciones de emulador:

| Uso | Proyecto | Puertos |
| --- | --- | --- |
| Desarrollo/manual | `demo-guardian` | Firestore 8085 y Auth 9098. |
| Suite de reglas | `demo-guardian-security` | Firestore 8185, websocket 9185, hub 4415, logging 4515. |
| Suite web aislada | `demo-guardian-web` | Firestore 8285, Auth 9298, websocket 9285, hub 4425, logging 4525. |

La separación permite probar sin limpiar la base de otro recorrido. Los emuladores de la validación aislada se detuvieron al terminar; no se modificó el que ya existía en los puertos de desarrollo.

## 33. Pruebas y evidencia disponible

La evidencia registrada durante el trabajo anterior de esta conversación es:

| Comprobación | Resultado registrado |
| --- | --- |
| Flutter dependencies y formato | Correctos. |
| Flutter analyze | Sin incidencias. |
| Suite Flutter | 136 aprobadas; una prueba de red opt-in omitida en el recorrido normal. |
| Privacidad/localización después de ampliar aviso | 7 aprobadas en comprobación específica; son un subconjunto de la cobertura, no siete funciones nuevas. |
| APK debug | Compilación correcta, incluido aviso de privacidad final. |
| Ruff | Correcto. |
| pytest | 11 aprobadas. |
| Contrato ML | Hash/181 features/compatibilidad comprobados; modelo desactivado y sin paridad. |
| Firestore Rules | 15 aprobadas en emulador aislado. |
| TypeScript y ESLint | Correctos. |
| Vitest | 24 aprobadas. |
| E2E público | 14 aprobadas entre escritorio y Pixel 7 emulado. |
| E2E autenticado | 10 aprobadas, incluidos roles, descansos y lectura del CSV descargado. |
| Build web | Correcto; exportación normal restaurada sin activar emuladores. |
| Higiene y diff check | Correctos con configuración normal de Git. |
| Lugares en vivo | Fallo de proveedor Overpass, HTTP 502 por saturación. |
| Dispositivo Android conectado | No se encontró en la comprobación anterior. |
| CI remoto / release / despliegue público | No ejecutados o no verificados en esta revisión. |

Los 30 archivos de prueba Flutter cubren muestreo adaptativo, cooldowns, actuadores, contrato de copias cloud, recuperación, controlador/pantalla de conducción, SQLite, motor, outbox, SOS, retención, cámara de Inicio, fallback de historial, idiomas/exportaciones, preprocesamiento ML, watchdog, proveedores, PERCLOS, métricas, privacidad, integración de recuperación/alarma, ajustes, calidad de señal, Smart Rest, informe técnico, borradores, voz y arranque/autenticación de widgets. El catálogo anexo enumera todos por nombre y recoge declaraciones de tests cuando se pueden extraer estáticamente.

Python tiene archivos de tests de splitting y contrato. Web tiene tests de demo, descansos, reportes y modelos de operación. Las suites E2E separan escenario público de integración con emuladores.

No se ejecutaron de nuevo esas suites para redactar el presente informe. Que exista una prueba no demuestra que cubra todas las condiciones físicas de cámara, gafas, iluminación, ruido, temperatura o conectividad real.

Artefacto Android observado: `driveawake/build/app/outputs/flutter-apk/app-debug.apk`, 242.518.875 bytes. SHA-256 de la última entrega comprobada: `a7898fce0b4bd9c9e5f0a84bd298f254662ceef6fda323293573148ad5868224`. Es un build debug de pruebas, no un release comercial firmado.

## 34. Privacidad y flujo de datos

| Dato | Destino por diseño del código |
| --- | --- |
| Frames, contornos y observaciones faciales | Procesamiento local; no se incluyen en payload cloud de Guardian. |
| Viajes/eventos/calibración/telemetría | SQLite local y exportaciones autorizadas. |
| Correo/credenciales de cuenta | Firebase Authentication. |
| Resumen personal | Firestore únicamente al confirmar copia. |
| Incidentes/estados empresariales | Organización autorizada mediante outbox y reglas. |
| Descansos | Local; sincronización empresarial si hay consentimiento específico. |
| GPS | Sesión local autorizada; proveedor externo al buscar lugares/mapas según operación. |
| Consulta de dirección | Nominatim/proveedor de búsqueda. |
| Zona cartográfica | Proveedor de tiles. |
| Destino externo | App/navegador de navegación al confirmar. |
| Contacto SOS | Preferencias locales y marcador al confirmar; no se envía a la flota. |
| Voz | TTS instalado que declara no requerir red; no captura voz del usuario. |
| Datos demo | Almacenamiento aislado del navegador, sintético. |

Hay controles de retención, eliminación local, desvinculación, copias remotas y exportación. Los ciclos de borrado local/personal/empresarial son distintos. Una flota debe definir cómo atiende eliminación de sus documentos recibidos; el teléfono no los borra silenciosamente al desvincularse.

La política visible y documentos declaran pendientes responsable, contacto de privacidad y procedimientos antes de publicación. Este informe no certifica cumplimiento legal ni sustituye esa definición. No se añadieron Analytics o Crashlytics como parte del conjunto descrito.

El código no controla frenos, dirección, velocidad ni otros actuadores del vehículo. Tampoco realiza reconocimiento facial de identidad o una decisión médica de aptitud.

## 35. Documentación, IDE, datos y archivos generados

### 35.1 Documentación

| Documento / familia | Uso |
| --- | --- |
| `README.md` | Entrada general al repositorio. |
| Este informe y catálogo/JSON | Inventario transversal del estado actual. |
| `TECHNICAL_VALIDATION.md` | Aceptación, comandos, resultados y bloqueos de la entrega local. |
| `docs/architecture.md` | Capas, sesión, persistencia y Guardian. |
| `docs/guardian_audit.md` | Auditoría de ampliación y decisiones. |
| `docs/localization.md` | Idioma, catálogo y pruebas. |
| `docs/maps_setup.md` | Proveedores, límites, configuración y costos potenciales. |
| `PRIVACY.md` y plantilla legal | Tratamiento implementado y campos por definir. |
| `docs/performance_observability.md` | Métricas, salud y observabilidad. |
| `docs/device_test_protocol.md` | Protocolo de pruebas físicas. |
| `docs/ml_validation_report.md` | Fuga histórica, incompatibilidad y límites ML. |
| `docs/firebase_setup.md` | Configuración y ampliación de nube. |
| `docs/release_process.md` | Firma y distribución. |
| `docs/initial_audit.md`, `phase_1_safety_report.md`, `repository_migration_plan.md` | Contexto y revisiones anteriores. |
| `docs/change_log.md` | Evolución técnica. |
| `docs/pilot_feedback_template.md` | Plantilla sin resultados inventados. |
| README de móvil, ML, dashboard y contrato | Instrucciones de cada componente. |
| Documentos de competencia de la raíz | Demo, pitch, proyecto y despliegue. |

`docs/APP_ESPECIFICACION_COMPLETA.md` es una especificación histórica fechada en julio. Contiene afirmaciones ya superadas: versión 1.0.0, solo español y ausencia de cuentas, internet, cloud o GPS. Debe leerse como antecedente, no como fuente vigente frente al código y este informe. El README ML también mezcla instrucciones/resultados históricos con código de splitting posteriormente corregido.

### 35.2 Archivos que aparecen en el IDE

Los archivos abiertos en esta consulta pertenecen a configuración local del IDE:

| Archivo | Función |
| --- | --- |
| `driveawake/.idea/workspace.xml` | Estado del workspace, selección y preferencias locales del IDE. |
| `.idea/modules.xml` | Declaración de módulos del proyecto para el IDE. |
| `.idea/libraries/Dart_SDK.xml` | Referencia del SDK Dart para indexación. |
| `.idea/libraries/KotlinJavaRuntime.xml` | Referencias del runtime Java/Kotlin. |
| `.idea/runConfigurations/main_dart.xml` | Configuración de lanzamiento del entrypoint Dart. |
| Archivos `.iml` | Metadata de módulos. |

No son el motor de detección, reglas Firebase o pantallas de la app. `.idea/` y `.iml` están ignorados por Git. El informe no copia el contenido de `workspace.xml`, que puede contener rutas y estado personales.

### 35.3 Datos, herramientas y artefactos locales

- `Data/` contiene carpetas locales Fold1 a Fold5, con partes 1 y 2. Está excluido de Git. No se examinó ni reprodujo contenido individual de vídeos personales para este informe.
- `app_conductores_ml/data/raw`, `processed` y `features` son entradas/resultados locales de ML; no son dependencias necesarias de una instalación normal del APK.
- `models/` y `reports/` de ML conservan artefactos de investigación. Hay matrices, curvas, métricas JSON/CSV y modelos; varios binarios/datasets están ignorados.
- `driveawake/build/`, `dashboard/out/` y `.next/` contienen compilaciones/exportaciones; son regenerables y no equivalen al código fuente.
- `.dart_tool/`, `.dart-tool/`, caches de pytest/Ruff y archivos `.flutter*` son metadata local de herramientas.
- `node_modules/` contiene dependencias instaladas. Los lockfiles sí describen resolución reproducible; no se incluye una enumeración de todos los archivos internos de cada dependencia.
- `test-results/`, trazas y logs son evidencia local de verificación, pueden regenerarse y no se deben confundir con datos de producción.
- `.git/` conserva historial/control de versiones; `.agents/` y `.codex/` son soporte local del agente cuando existen.
- `google-services.json`, `.env*` privados, `local.properties`, keystores y claves son configuración local excluida. No se copia su contenido al inventario público. `.env.example` es la plantilla sin credenciales privadas que sí se conserva.

La existencia local de datasets o configuración de Firebase no significa que esos archivos estén publicados en GitHub.

## 36. Funciones ausentes, bloqueos y deuda técnica

Lo siguiente no debe anunciarse como terminado o validado:

1. Modelo de somnolencia con paridad MediaPipe/ML Kit demostrada y accuracy independiente por conductor.
2. Preview simultáneo real frontal/trasero, validado en dispositivos compatibles.
3. Rutas internas por carretera, ETA propia o navegación giro a giro interna.
4. Rutas certificadas para transporte pesado y verificación física de accesibilidad de paradas.
5. Búsqueda de lugares garantizada sobre una ruta o disponibilidad de infraestructura pública de mapas.
6. Mapas offline descargables del producto.
7. Monitoreo garantizado con cámara en segundo plano o un servicio Android permanente de cámara validado.
8. Reconocimiento de voz o asistente conversacional completo.
9. Llamadas/SMS automáticos, integración con centros de emergencia o control del vehículo.
10. OBD, CAN, Android Auto, CarPlay o una analítica predictiva vehicular avanzada.
11. Panel de ubicación de flota en tiempo real, dado que el contrato no envía GPS continuo.
12. Directorio completo de conductores con documentos/licencias verificados, invitaciones por correo y gestión de cuentas Auth desde navegador.
13. Histórico empresarial ilimitado/paginación global, warehouse o exportación de toda la organización sin la ventana descrita.
14. Cifrado específico de SQLite implementado y atestación infalsificable de telemetría física.
15. Cobertura de traducción completa de todos los nuevos textos Guardian y central web multilingüe.
16. Publicación de dashboard/demo/pitch con URL pública comprobada durante la ejecución documentada.
17. Release comercial, publicación en tienda y CI remoto íntegramente verificado para estos cambios locales.
18. Pilotos, entrevistas, clientes, testimonios, reducción medida de accidentes o tracción demostrada.
19. Política legal definitiva con responsable y procesos completos.
20. Prueba física integral reciente de Android → nube real → operador → historial, incluyendo consumo, temperatura y casos de iluminación/gafas.

Son límites distintos: algunos son opcionales, otros requieren decisiones de proveedor o autorización, y otros necesitan hardware/datos. No todos son fallos del mismo tipo ni deben bloquear el uso local experimental.

## 37. Operación y reproducción local

### 37.1 Android

Desde `driveawake/`:

```powershell
flutter pub get
dart format --output=none --set-exit-if-changed lib test
flutter analyze
flutter test
flutter build apk --debug
```

Salida debug: `build/app/outputs/flutter-apk/app-debug.apk`. Release requiere firma válida, propiedades privadas y un build release separado. Los comandos de dependencias/build pueden necesitar acceso a SDK y cachés del equipo.

### 37.2 Web sin datos de producción

Desde `dashboard/`:

```powershell
npm.cmd ci
npm.cmd run typecheck
npm.cmd run lint
npm.cmd test
npm.cmd run build
python -m http.server 3000 --bind 127.0.0.1 --directory out
```

Abrir `/demo/` y `/pitch/`. Esa dirección es local. Sin configuración Firebase/membresía, `/dashboard/` no presenta una flota inventada.

### 37.3 Python

En el entorno Python correspondiente y desde `app_conductores_ml/`:

```powershell
python -m ruff check .
python -m pytest -q
python src/validate_model_contract.py
```

El entrenamiento completo es otra operación, consume recursos y depende de datos locales. No es necesario para leer el informe ni para ejecutar la suite ligera del contrato.

### 37.4 Firebase y publicación

Las pruebas de reglas se ejecutan desde `backend/` con Java 21 y Firebase CLI mediante `npm.cmd run test:emulator`. El recorrido web aislado usa la configuración y puertos documentados en `dashboard/README.md`.

Antes de compartir una exportación, un build normal debe reemplazar el build de emulador. La publicación de hosting/reglas, el bootstrap privilegiado remoto y el smoke test `--live` no son operaciones de lectura: requieren el proyecto correcto y autorización. Sus instrucciones revisables están en [DEPLOYMENT.md](../DEPLOYMENT.md); este informe no las ejecuta.

## 38. Estado global y glosario

El resultado existente es una plataforma experimental integrada con app Android, backend de acceso/datos, central web, simulador y pipeline de investigación. Tiene código ejecutable y evidencia automática importante, junto con límites físicos, de proveedor y de despliegue que siguen abiertos. Compilar y pasar tests no equivale a validación clínica o certificación vehicular.

| Término | Significado en este repositorio |
| --- | --- |
| PERCLOS | Fracción de tiempo ocular cerrado dentro de observación válida. |
| EAR / MAR | Relaciones geométricas aproximadas de ojos y boca. |
| ML Kit | Detector facial utilizado por la app. |
| MediaPipe | Extractor del pipeline histórico Python. |
| TFLite | Formato del clasificador experimental empaquetado. |
| Outbox | Cola local persistente de mensajes autorizados aún por confirmar. |
| Idempotencia | Reintentar una operación sin duplicar el documento/evento lógico. |
| Drift | Capa Dart para esquema, consultas y transacciones SQLite. |
| Snapshot | Estado observado de documentos o borrador de sesión según contexto. |
| Tier | Intensidad interna de alerta; diferente del nivel de riesgo. |
| P95 | Percentil 95 de una medición de latencia; no una precisión del detector. |
| Señal insuficiente | No hay datos fiables para observar; no es riesgo bajo. |
| Descanso declarado | Intervalo confirmado por usuario, sin inferencia fisiológica. |
| Demo | Simulación identificada, con reloj y datos ficticios. |

Para verificar una afirmación de implementación, consultar su archivo en el [catálogo](INVENTARIO_ARCHIVOS_GUARDIAN.md). Para distinguir implementación de comprobación efectiva, consultar [el informe de validación](../TECHNICAL_VALIDATION.md). No se han modificado funciones de la aplicación para redactar este documento.
