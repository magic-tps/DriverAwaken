# DriverAwaken Guardian — validación y entrega local

Actualización móvil posterior: [correcciones del 18 de octubre](docs/mobile_fixes_2026-10-18.md), con la solución del bloqueo de pausa, simplificación del GPS y comandos de voz. El resto de este documento conserva la comprobación del día 17.

Revisión histórica: 17 de octubre de 2026, America/Lima. El workspace ya contenía trabajo Guardian sin commit; se preservó. Este informe separa implementación, comprobación automática, servicios externos y pruebas físicas. La publicación posterior del 18 de octubre se documenta en [DEPLOYMENT.md](DEPLOYMENT.md); no se cambió la facturación ni se hizo entrega oficial a una competencia.

## 1. Resumen ejecutivo

La app Android conserva el detector local, reglas, calibración, alarmas, historial y recuperación. Se completó la interfaz de conducción, cancelación de voz/GPS, navegación consentida y SOS. La plataforma web incluye organizaciones, incidentes, acciones, conductores, viajes, descansos, informes filtrados, demo aislada y pitch. P0 no está cerrado: faltan validación física integrada, disponibilidad de lugares y publicación autorizada.

## 2. Funciones completadas en código

- Pantalla adaptable: estado real, índice heurístico, calidad, métricas, cámara frontal real, mapa y controles. La finalización y el descarte exigen confirmación.
- Cámara frontal prioritaria. Si no existe una frontal, se informa error; no se presenta una trasera como frontal. La doble cámara no está habilitada.
- GPS con consentimiento y comprobación de antigüedad/precisión; las respuestas tardías de permisos y cambios de lifecycle no reactivan una operación cancelada.
- Búsqueda explícita de destinos, selección en mapa, favoritos y recientes locales, enlace confirmado a navegación externa y mensaje de monitoreo pausado.
- Smart Rest usa el estado del motor existente y duración. Ante señal crítica aconseja parar sin esperar a internet. Los descansos son intervalos declarados, separados de pulsar Navegar.
- Voz offline según idioma, cooldown, prioridad crítica y cancelación durante configuración. Sin voz instalada se mantienen las alarmas locales.
- SOS con contacto local opcional, registro manual local y apertura confirmada del marcador. No llama ni envía ubicación automáticamente.
- Drift v3 con viajes, eventos, outbox y descansos; sincronización autorizada con IDs estables y confirmación de servidor.
- Firestore por organización y rol. Incidentes inmutables, acciones humanas anexas y reportes personales conservados.
- Dashboard con Conductores y Descansos, filtros por fecha Lima/vehículo/conductor/viaje/severidad/tipo y CSV con el mismo alcance. Señal insuficiente se muestra como no evaluable.
- Demo determinista con datos simulados aislados y resumen final; pitch web con teclado y enlace a demo.

## 3. Funciones pendientes y bloqueos

| Elemento | Estado | Evidencia o condición pendiente |
| --- | --- | --- |
| Compilación Flutter y análisis | VERIFICADO | APK debug generado; análisis sin incidencias. |
| Tests críticos del motor, alarmas, persistencia y navegación | VERIFICADO | Suite Flutter automática; no equivale a hardware físico. |
| Cámara frontal, permisos, rotación, FPS, audio y vibración físicos | IMPLEMENTADO NO VERIFICADO | `adb devices` no mostró dispositivos conectados. |
| Monitoreo activo / señal insuficiente / pausa | VERIFICADO | Pruebas de estado y widgets; falta recorrido en Android físico. |
| GPS en dispositivo | IMPLEMENTADO NO VERIFICADO | Se probaron fakes y cancelación; falta adquisición de GPS real autorizada. |
| Tiles y búsqueda Nominatim reales | VERIFICADO | HTTP 200 para PNG y JSON; la búsqueda Dart obtuvo cuatro destinos. |
| Búsqueda de lugares reales | BLOQUEADO | Overpass público devolvió HTTP 502 por capacidad agotada. No se falsificó éxito. |
| Selección de destino y apertura de navegación | IMPLEMENTADO NO VERIFICADO | Contrato, URI y flujo comprobados; falta abrir app externa en Android físico. |
| Smart Rest y descansos | VERIFICADO | Pruebas de recomendaciones/persistencia y lectura web de fixture DRIVER. |
| Incidentes, outbox, permisos y deduplicación | VERIFICADO | Pruebas SQLite y 15 casos de Firestore local. |
| Android → Firebase real → dashboard | IMPLEMENTADO NO VERIFICADO | No se usó producción ni dispositivo físico. |
| Dashboard de datos autorizados y acciones | VERIFICADO | SDK DRIVER → reglas → navegador OPERATOR/ADMIN en emuladores. |
| Demo aislada y presentación local | VERIFICADO | Pruebas públicas de navegador; sin usuarios privados ni Firebase en demo. |
| Publicación y URLs accesibles para jurado | BLOQUEADO | Requieren autorización y configuración de hosting. |
| Modelo histórico | VERIFICADO | Contrato mantiene `parity_verified=false`; sigue desactivado. |
| Reglas y jobs CI escritos | VERIFICADO | Configuración revisada y checks locales ejecutados. |
| Ejecución remota completa de GitHub Actions / Gitleaks | PENDIENTE | No se hizo push ni se afirma CI remoto verde. |
| Doble cámara, rutas internas, ETA y lugares sobre ruta | PENDIENTE | Capacidades preparadas/abstraídas; sin sesión concurrente ni proveedor de rutas validado. |
| Release firmado y distribución formal | PENDIENTE | Se entrega debug; no se sustituyó firma release por debug. |
| Privacidad legal y piloto | PENDIENTE | Completar responsable/retención/procedimiento y validar con personas que consientan. |

## 4. Archivos principales modificados

El árbol incluye cambios previos y esta continuación; no se atribuye todo el diff al periodo de competencia.

- Android: `driveawake/lib/screens/drive_mode_screen.dart`, `navigation_screen.dart`, `widgets/status_card.dart`, `widgets/navigation_readout.dart`, `widgets/guardian_navigation_card.dart`.
- Servicios: `navigation/voice_assistant.dart`, `navigation/smart_navigation.dart`, `navigation/navigation_providers.dart`, `navigation/rest_repository.dart`, `services/camera_service.dart`, `services/emergency_service.dart`, `services/device_telemetry_service.dart`, `services/trip_session_service.dart`, `services/local_history_service.dart`.
- Datos: `driveawake/lib/data/`, `driveawake/lib/fleet/`, migraciones/generado Drift, `pubspec.yaml` y lockfile.
- Android nativo: `AndroidManifest.xml` y `MainActivity.kt`.
- Web: `dashboard/src/components/operations.tsx`, `operational-reports.tsx`, `incidents.tsx`, `demo-app.tsx`, `ui.tsx`, `src/lib/operations-model.ts`, `reports.ts`, `firebase.ts`, rutas `dashboard/drivers` y `dashboard/rest`, estilos, pruebas y scripts.
- Backend/CI: `backend/firestore.rules`, `backend/tests/firestore.test.mjs`, configuraciones de emuladores aislados, bootstrap/seed y `.github/workflows/ci.yml`.
- Pruebas Android: `drive_mode_screen_test.dart`, `voice_assistant_test.dart`, `emergency_service_test.dart`, `smart_navigation_test.dart`, más pruebas ya presentes de outbox, motor e historial.
- Documentación: README, arquitectura, auditoría, mapa/costos, privacidad, despliegue, guía demo, guion y plantilla de feedback.

## 5. Tests y resultados ejecutados

| Comando / alcance | Resultado |
| --- | --- |
| `flutter pub get` | Correcto; sin actualización masiva de dependencias. |
| `dart format lib test` | Correcto. |
| `flutter analyze --no-pub` | Sin incidencias. |
| `flutter test --no-pub --reporter expanded` | 136 pruebas aprobadas; 1 opt-in de red omitida en la suite normal. |
| `flutter build apk --debug --no-pub` | Correcto, salida 0; APK final incluye ajuste de lifecycle y aviso de privacidad. Tamaño: 242.518.875 bytes. |
| Python: Ruff | Correcto. |
| Python: pytest | 11 pruebas aprobadas. |
| `python src/validate_model_contract.py` | Correcto: 181 características, hash coincidente, modelo desactivado y sin paridad. |
| Backend: `npm run test:emulator` | 15 pruebas aprobadas, proyecto `demo-guardian-security`, Firestore 8185. |
| Web: TypeScript / lint / Vitest | Correcto; 24 unitarias aprobadas en la comprobación final. |
| Web: build estático | Correcto, 13 rutas exportadas; artefacto normal sin configuración activa del emulador. |
| Web público: Playwright escritorio/móvil | 14 pruebas aprobadas mediante Chrome instalado. |
| Web autenticado: Playwright + Auth/Firestore | 10 pruebas aprobadas, salida 0, escritorio y Pixel 7 emulado. Incluye lectura del CSV descargado. |
| Proveedores externos: prueba opt-in Dart | FALLÓ: Nominatim respondió; Overpass no disponible. |
| HTTP diagnóstico de Overpass | 502, servidor saturado; no es un resultado de lugares válido. |
| `python scripts/check_repository_hygiene.py` | Correcto. |
| `git diff --check` | Correcto; advertencias de conversión LF/CRLF no son fallos. |

Los primeros intentos expusieron claves duplicadas de traducción, avisos de estilo, una espera indefinida del spinner en un test y selectores E2E demasiado estrictos. Se corrigieron y se repitieron los checks afectados. No se ocultan los intentos fallidos del proveedor externo.

La revisión estática de diseño detectó textos móviles de 7–9 px. Se aumentaron a 11 px en estados operativos y 10 px en etiquetas, con ajustes de wrap. El aviso de privacidad visible en Android se amplió a ubicación, mapas, voz, contacto SOS y descansos, con traducción inglesa. Después pasaron las 7 pruebas específicas de privacidad/localización y las 14 pruebas públicas de navegador contra el CSS actualizado, incluidas anchura responsive y foco de teclado.

Los emuladores no usaron producción: seguridad en 8185 y web en 8285/9298, con proyectos `demo-*`. Se preservó el emulador que ya existía en 8085/9098. El simulador público no sustituye estas pruebas de integración.

## 6. APK

`driveawake/build/app/outputs/flutter-apk/app-debug.apk`. Es debug instalable para pruebas; no una publicación release. La compilación no demuestra funcionamiento físico de cámara o GPS. No contiene una integración de cámara trasera simultánea habilitada.

## 7–9. URLs

Dashboard, demo y pitch: **sin despliegue ni URL pública verificada**. La exportación está en `dashboard/out/`; rutas locales `/dashboard/`, `/demo/` y `/pitch/`. Ver [DEPLOYMENT.md](DEPLOYMENT.md) para la publicación revisable. No entregar localhost al concurso.

## 10. Servicios de mapas

[Configuración y políticas](docs/maps_setup.md). No se habilitaron Google Maps SDK, Places ni Routes. Tiles, búsquedas y lugares usan proveedores configurables; los públicos son un prototipo limitado. Sin ruta interna se ofrece navegación externa, sin ETA ni restricciones de vehículo pesado inventadas.

## 11. Firebase

[Configuración Firebase](docs/firebase_setup.md) y [despliegue](DEPLOYMENT.md). Se conservan los reportes personales. Bootstrap requiere Admin autorizado fuera del navegador; el dashboard requiere configuración pública web, Auth y membresía ADMIN/OPERATOR. Las reglas locales fueron comprobadas y se publicaron posteriormente, el 18 de octubre de 2026.

## 12. Costos potenciales

No se activó facturación ni infraestructura de pago. Los planes Firebase/hosting y proveedores de mapas pueden generar consumo. La integración Google futura requiere revisar SKUs, cuotas y presupuesto vigentes antes de autorización. No se anuncia gratuidad ilimitada.

## 13. Problemas conocidos

Overpass público está saturado. Sin proveedor de producción no se garantiza búsqueda de paradas. No hay prueba física, métricas independientes de precisión ni benchmarks de consumo/temperatura. El índice es heurístico. La cámara se pausa al salir de la app. Los descansos no prueban recuperación fisiológica. La central consulta ventanas acotadas y no observa la cola de un dispositivo desconectado. La política legal necesita completar responsable y procedimientos. Algunas pantallas nuevas de navegación/SOS mantienen texto español aunque la app base soporte inglés; la voz y controles principales respetan el idioma.

## 14. Pasos restantes para presentar

1. Probar APK en Android estacionario: permisos, rostro/luz, alarma, pausa, GPS, navegación externa, descanso y recuperación.
2. Elegir proveedor de lugares con capacidad suficiente y repetir la comprobación en vivo.
3. Completar configuración web y privacidad del proyecto autorizado.
4. Autorizar/publicar hosting y reglas, y verificar demo/pitch en ventana privada desde otro equipo.
5. Confirmar la rúbrica vigente con la organización: guía y onboarding consultados muestran ponderaciones diferentes. Ambos requieren enlaces accesibles y pitch de tres minutos.
6. Enviar únicamente tras autorización explícita. Se comprobó `andes project submit --help`; no se ejecutó `submit` ni se publicaron avances.

Fuentes de competencia: [sitio oficial](https://hacktheandes.com/), [guía](https://hacktheandes.com/guide), [onboarding](https://hacktheandes.com/deck/onboarding). Guía y deck se reconsultaron mediante HTTP durante esta revisión. [Guion](PITCH_SCRIPT.md), [demo](DEMO_GUIDE.md), [privacidad técnica](PRIVACY.md), [feedback sin datos inventados](docs/pilot_feedback_template.md).
