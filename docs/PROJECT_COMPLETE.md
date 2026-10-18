# DriverAwaken Guardian — documentación completa del proyecto

> Documento consolidado del estado técnico, funcional y operativo del repositorio. La aplicación sigue siendo experimental y no es un dispositivo médico ni un sistema vehicular certificado.

## 1. Propósito

DriverAwaken detecta señales de somnolencia y fatiga durante la conducción mediante la cámara frontal del teléfono. Prioriza procesamiento local, alertas inmediatas y una decisión segura de detenerse. La plataforma Guardian añade sincronización consentida de incidentes y una central web para que una flota pueda revisar riesgos y registrar acciones humanas.

La navegación no forma parte del producto principal: Google Maps se abre como aplicación externa mediante URLs oficiales. No se utiliza Google Maps SDK, Places API, Routes API ni una clave de Google Maps.

## 2. Estructura del repositorio

| Ruta | Responsabilidad |
|---|---|
| `driveawake/` | Aplicación Flutter para Android y otras plataformas, cámara, detector, alertas, sesiones, Smart Rest, SQLite/Drift y sincronización opcional. |
| `dashboard/` | Aplicación web Next.js estática: landing, demo, pitch, central de flota y portal de conductor. |
| `backend/` | Reglas Firestore, pruebas de seguridad, funciones de notificación y scripts administrativos/emulador. |
| `shared/` | Contratos del modelo y vectores de prueba compartidos entre entrenamiento e inferencia. |
| `app_conductores_ml/` | Código y artefactos de investigación/validación del modelo; los datasets locales no se versionan. |
| `docs/` | Auditorías, arquitectura, privacidad, validación, operación y protocolos. |
| `.github/workflows/` | CI, publicación de GitHub Pages y proceso de release. |

## 3. Aplicación móvil

### Flujo principal

1. Inicio de sesión opcional o modo personal.
2. Preparación del viaje y selección de configuración.
3. Modo conducción con cámara frontal grande.
4. Procesamiento de rostro, ojos, bostezos, PERCLOS, orientación de cabeza y calidad de señal.
5. Clasificación temporal de riesgo y alertas visuales, sonoras y vibratorias.
6. Resumen del viaje, historial local y, con consentimiento, copia del informe en Firebase.

### Componentes relevantes

- `lib/features/drive/`: ciclo de vida del monitoreo, estado, recuperación controlada, watchdog y rendimiento.
- `lib/screens/drive_mode_screen.dart`: interfaz de conducción.
- `lib/utils/perclos_tracker.dart`: cálculo temporal de PERCLOS.
- `lib/utils/adaptive_frame_scheduler.dart`: programación adaptativa de frames.
- `lib/fleet/incident_classifier.dart`: clasificación de incidentes.
- `lib/fleet/fleet_service.dart`: vinculación a flota, viajes, asignaciones e incidentes.
- `lib/fleet/local_outbox.dart`: cola local, deduplicación y reintentos de sincronización.
- `lib/navigation/rest_recommendation_engine.dart`: recomendaciones de descanso sostenidas.
- `lib/navigation/smart_navigation.dart`: apertura voluntaria de Google Maps externo.
- `lib/data/database/`: base local SQLite/Drift.

### Smart Rest y Google Maps

Cuando se detectan señales sostenidas de fatiga, la app alerta localmente y presenta una recomendación de detenerse. La tarjeta puede ofrecer búsquedas externas de cafeterías, grifos, áreas de descanso, estacionamientos, restaurantes y hospedajes.

La apertura de Google Maps es voluntaria, no automática, y debe realizarse con el vehículo detenido. Antes de salir se informa que el monitoreo se pausará. Al regresar, la sesión queda pausada y exige reanudación explícita. No se solicita ubicación para integrar mapas internos.

## 4. Modelo de detección y límites

El sistema combina reglas temporales y métricas de cámara. El modelo TensorFlow Lite permanece desactivado por defecto hasta completar validación suficiente. El score es heurístico y no representa una probabilidad médica ni una garantía de evitar accidentes.

Señales principales:

- ojos cerrados y duración de cierre;
- PERCLOS;
- bostezos repetidos;
- cabeza inclinada o mirando hacia abajo;
- ausencia o baja calidad de rostro;
- interrupción del monitoreo;
- salud de señal y telemetría del dispositivo.

No se envían vídeo, fotografías, landmarks ni embeddings a la central.

## 5. Smart Rest, alertas y emergencia

La versión 1.1.2+4 incorpora [el copiloto conversacional local](conversational_copilot.md): diálogo por turnos con contexto inmediato, 100 intervenciones editables y alertas habladas activadas inicialmente. El micrófono y el altavoz se alternan; una alerta tiene prioridad sobre la charla. Las transcripciones solo se mantienen temporalmente en memoria.

La conversación mantiene el tema, recuerda temporalmente el último detalle contado y ofrece seguimiento para preferencias, recuerdos o un día difícil. Las alertas tienen variantes breves según la señal y conservan sus intervalos de repetición. La voz instalada se elige por disponibilidad sin conexión, acento y calidad; el timbre real requiere una prueba en Android. Se trata de un motor de diálogo local de alcance limitado, sin un modelo generativo de conversación abierta.

- La alarma local del conductor no depende de Internet.
- Los incidentes `WARNING` y `CRITICAL` pueden persistirse cuando existe viaje activo y consentimiento.
- La central muestra riesgo, señal, hora de detección y estado del viaje.
- El número de emergencia se configura por organización y se muestra para llamada voluntaria.
- El portal no realiza llamadas ni SMS automáticos.
- Las notificaciones web FCM están preparadas en código, pero su envío cloud requiere funciones desplegadas y facturación Blaze; no debe afirmarse entrega push automática en el estado actual.

## 6. Backend y seguridad

Firestore organiza los datos bajo `organizations/{org}`:

- `members`: roles `ADMIN`, `OPERATOR`, `DRIVER`;
- `vehicles`: vehículos activos de la flota;
- `assignments`: relación conductor–vehículo;
- `trips`: viajes y estado de monitoreo;
- `incidents`: señales de riesgo recibidas;
- `operatorActions`: respuestas humanas;
- `restSessions`: descansos declarados.

Las reglas de `backend/firestore.rules` validan organización, rol, estado, pertenencia, formato, rangos y transiciones. Un conductor no puede elevar su rol, crear organizaciones, inventar asignaciones ni leer datos de otros conductores. El bootstrap privilegiado se encuentra en `backend/scripts/bootstrap.mjs`.

Firebase Authentication usa correo y contraseña. Las credenciales de servicio, archivos `google-services.json`, `.env.local`, keystores y datasets locales están excluidos del repositorio.

## 7. Portal web

La aplicación `dashboard/` se exporta como sitio estático con base `/DriverAwaken` para GitHub Pages.

Rutas públicas:

- `/`: presentación y acceso al APK alojado en la carpeta de Google Drive configurada por el propietario;
- `/demo/`: demostración con datos sintéticos;
- `/pitch/`: presentación del proyecto.

Rutas autenticadas:

- `/dashboard/`: central de administración y operación;
- `/dashboard/incidents/`: incidentes y acciones;
- `/dashboard/drivers/`: conductores y último estado;
- `/dashboard/fleet/`: vehículos;
- `/dashboard/trips/`: viajes y asignaciones;
- `/dashboard/rest/`: descansos;
- `/dashboard/reports/`: informes y CSV;
- `/dashboard/settings/`: organización, emergencia y membresías;
- `/driver/`: portal personal del conductor.

## 8. Publicación actual

- Web: <https://magic-tps.github.io/DriverAwaken/>
- Repositorio: <https://github.com/magic-tps/DriverAwaken>
- Carpeta de descarga configurada: <https://drive.google.com/drive/folders/1NjN0jGmj71hKqM0LcRYwEPFRaxBtJ92T?hl=es>
- APK de prueba previamente generado: `driveawake/build/app/outputs/flutter-apk/app-debug.apk`.

El APK publicado es una compilación debug de prueba. Para una entrega formal se necesita configurar un keystore y producir una compilación release firmada.

## 9. Cuentas de prueba de Firebase

Existen dos cuentas de prueba en la organización `driverawaken`: una con rol `ADMIN` y otra con rol `DRIVER`. Las contraseñas se entregaron directamente al propietario y no se guardan en este documento ni en Git.

El administrador debe usar el panel web; el conductor debe usar el portal de conductor y la aplicación Android. Las cuentas utilizan alias del buzón del propietario, no buzones independientes.

## 10. Pruebas y comandos

### Flutter

```powershell
cd driveawake
flutter pub get
dart format --output=none --set-exit-if-changed lib test
flutter analyze
flutter test
flutter build apk --debug
```

### Web

```powershell
cd dashboard
npm.cmd ci
npm.cmd run typecheck
npm.cmd run lint
npm.cmd test
npm.cmd run build
```

### Backend

```powershell
cd backend
npm.cmd ci
npm.cmd test
npm.cmd run test:emulator
```

Las suites registradas incluyen pruebas Flutter, Vitest web, reglas Firestore, funciones de clasificación y pruebas E2E con emuladores. Las pruebas locales no sustituyen una prueba de campo estacionaria ni una validación clínica.

## 11. Rendimiento y operación segura

El watchdog registra frames descartados, latencia, disponibilidad de rostro y salud de cámara. La optimización debe actuar sobre scheduler, procesamiento facial, rebuilds, overlays y memoria; nunca ocultar fallos desactivando controles de seguridad.

La cámara debe probarse con el vehículo detenido. Si se pierde la señal, el estado debe indicar señal insuficiente o monitoreo interrumpido, no riesgo normal. Las acciones de Smart Rest y Google Maps no deben bloquear el detector ni abrir navegación automáticamente.

## 12. Pendientes conocidos

- Compilación release firmada para distribución formal.
- Carga del APK en la carpeta de Google Drive y sustitución por un enlace de archivo directo si se desea descarga inmediata.
- Despliegue y prueba real de FCM/Web Push, sujeto a plan Firebase compatible.
- Pruebas de sesión real con administrador y conductor en dispositivo autorizado.
- Validación de campo controlada de cámara, FPS, temperatura, batería y calidad de señal.
- Revisión periódica de privacidad, retención y consentimiento con el responsable de la flota.

## 13. Documentación relacionada

- [README](../README.md)
- [Despliegue](../DEPLOYMENT.md)
- [Arquitectura](architecture.md)
- [Configuración Firebase](firebase_setup.md)
- [Auditoría Guardian](guardian_audit.md)
- [Validación técnica](../TECHNICAL_VALIDATION.md)
- [Privacidad](../PRIVACY.md)
- [Mapas externos](maps_setup.md)
- [Protocolo de pruebas de dispositivo](device_test_protocol.md)
