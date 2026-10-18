# DriverAwaken Guardian

**Track 02 · transport · Hack the Andes 2026.** Plataforma preventiva para flotas de transporte regional de pasajeros y carga. Su alcance encaja con la conectividad entre localidades y el transporte regional descritos en la [guía oficial](https://hacktheandes.com/guide).

## Problema y personas

La hipótesis que abordamos es la dificultad de coordinar una respuesta humana ante señales de fatiga cuando la conectividad es intermitente. Usuarios previstos: conductores, operadores de central y administradores de flotas regionales. No se han documentado entrevistas ni clientes que validen todavía esta hipótesis.

## Solución y funcionamiento

Conductor → observación facial local → reglas temporales → alerta local → incidente persistente → sincronización autorizada → central → acción humana documentada.

La aplicación Flutter existente conserva PERCLOS, calibración, historial, watchdog y alarmas. Guardian añade selección de viajes empresariales con consentimiento, adaptación de eventos sin un segundo detector y cola SQLite con IDs estables. La central web Next.js distingue viaje de monitoreo, muestra detección y recepción y anexa reconocimiento y notas del operador. Los particulares mantienen uso local sin flota.

Smart Rest transforma la decisión del motor y el tiempo de conducción en recomendaciones breves de pausa. Android permite activar GPS y mapas, elegir destinos y abrir navegación externa; los descansos son confirmados por el usuario y pueden compartirse con su flota. No se inventan rutas o ETA. El servicio público de lugares presentó saturación durante la validación; debe sustituirse por un proveedor con capacidad adecuada antes de prometer disponibilidad.

## Diferenciación

- Funcionamiento local independiente de internet y reintentos persistentes con límites.
- Aislamiento organizacional y roles aplicados mediante Firestore Rules.
- Detecciones originales inmutables y acciones humanas anexas.
- Ausencia de rostro tratada como señal insuficiente, sin concluir somnolencia.
- Sin envío de imágenes, landmarks, embeddings ni ubicación continua.
- Demo determinista identificada como simulación y separada de producción.

## Arquitectura

Flutter/ML Kit/reglas → Drift/SQLite → Firebase Auth + Firestore → Next.js/TypeScript/Tailwind. Hosting estático compatible con Firebase. No se añaden microservicios, Kubernetes ni componentes de pago obligatorios para la demo. La creación inicial de una organización exige bootstrap administrativo con credenciales autorizadas.

## Resultados verificables

Los comandos, resultados, estado del APK y limitaciones se registran en `TECHNICAL_VALIDATION.md`. Las pruebas automatizadas cubren motor, lifecycle existente, persistencia, deduplicación, reconexión y seguridad de flotas. El emulador prueba publicación autenticada e intervención del operador. No se presenta la simulación como validación de cámara ni como evidencia de impacto.

## Cómo probar

Publicación pendiente de autorización; no hay URLs públicas verificadas en esta ejecución. Desde `dashboard/`: `npm ci`, `npm run build` y `python -m http.server 3000 --directory out`. Abrir `/demo/` y `/pitch/` sin cuenta. El recorrido offline → incidente → reconexión → reconocimiento → nota se detalla en `DEMO_GUIDE.md`. Firebase local y Android: `DEPLOYMENT.md`.

## Limitaciones

No es un sistema certificado ni garantiza prevenir accidentes. El modelo TFLite histórico permanece desactivado (`parity_verified=false`). No hay métricas nuevas de accuracy, benchmarks Android físicos, entrevistas o tracción demostradas. El flujo en hardware y nube real, la publicación pública y las políticas operativas de la flota necesitan verificación/autorización. El modo flota requiere conexión para consultar inicialmente asignaciones; una sesión recuperada no se vincula automáticamente de nuevo. No hay servicio Android de ejecución continua ni garantía de monitoreo en segundo plano.

## Próxima etapa

Piloto consentido y estacionario/simulado primero, con medición de falsos positivos y retrasos de sincronización. Completar responsables y retención de datos. Hipótesis comercial: suscripción por vehículo activo, sin precio ni demanda validados todavía.
