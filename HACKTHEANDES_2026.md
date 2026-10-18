# DriverAwaken Guardian · Hack the Andes 2026

Fecha de revisión y continuación: 17 de octubre de 2026, America/Lima. Rama `feat/guardian-mvp`. El workspace ya contenía cambios Guardian sin commit al iniciar esta revisión; se conservaron. La auditoría anterior registra como base `c5aaa8ca1d7e0fb1330056b6c4ac6b08ccd6ffa8`. El diff permite revisar el conjunto acumulado, pero no prueba por sí mismo autoría, elegibilidad ni fecha de desarrollo dentro de la competencia. No se ha hecho push, publicación ni entrega oficial.

## Funciones anteriores

Aplicación Flutter en español/inglés, ML Kit facial local, señales de cierre ocular, PERCLOS, bostezos e inclinación, reglas temporales, calibración, alertas sonoras/hápticas, watchdog, métricas de sesión, borradores, historial Drift y exportaciones. Cuentas Firebase opcionales y copias manuales personales. Pipeline Python y modelo TFLite histórico desactivado por incompatibilidad de características. Se conservan estas funciones.

## Cambios Guardian acumulados en el workspace

- Fix asíncrono del fallback del historial.
- Separación de falta de rostro frente a riesgo de fatiga.
- Dominio flota, membresías, vehículos, asignaciones y viajes.
- Pantalla Android de vinculación consentida, viaje elegido, estado de cola e incidentes.
- `IncidentClassifier` y `IncidentRepository` adaptan eventos existentes, filtran señal insuficiente y aplican cooldown persistente y escalamiento.
- Outbox Drift v2: payload inmutable, IDs SHA-256 estables, estados de entrega, cola limitada, FIFO, reintentos con backoff/jitter y comprobación de consentimiento. La migración conserva tablas anteriores.
- Reglas Firestore por empresa y rol, detecciones inmutables y acciones anexas. Reportes personales conservados.
- Bootstrap Admin y seed exclusivamente local del emulador; este emite el incidente como DRIVER mediante SDK cliente.
- Dashboard Next.js/TypeScript/Tailwind con login y membresía, datos de Firestore, gestión ADMIN y acciones OPERATOR.
- Demo web determinista aislada y pitch público; datos ficticios identificados permanentemente.
- Pruebas, jobs CI, hosting estático y documentación de validación, instalación, despliegue y competencia.

## Verificación

La fuente de verdad de comandos y resultados es [TECHNICAL_VALIDATION.md](TECHNICAL_VALIDATION.md). No confundir pruebas automatizadas y emuladores con una prueba física Android o un piloto con usuarios.

## Limitaciones conocidas

- Sin despliegue público ni URLs verificadas mientras no exista autorización para publicar.
- Sin prueba física del flujo Android → nube real → dashboard; sin medición de batería, cámara ni audio en hardware en esta sesión.
- Modelo histórico desactivado. No se presentan métricas históricas como validación independiente.
- La consulta inicial de asignaciones requiere internet. El enlace de una sesión recuperada debe elegirse explícitamente; no se reasocia automáticamente a una flota.
- La salud remota se infiere de la última confirmación del servidor, con caducidad visual. No garantiza disponibilidad continua en Android.
- Un fallo de permiso o un viaje cerrado externamente deja datos pendientes para revisión/retención; no se fuerza la subida saltándose reglas.
- El servidor no puede saber cuántos mensajes nunca recibió: la cola remota se marca desconocida en producción.
- La retención local se aplica también a pendientes y puede eliminarlos al vencer el plazo elegido. La flota debe establecer retención remota y procedimiento de solicitudes antes del piloto.
- Responsable legal, contacto de privacidad y canal de derechos siguen pendientes. No se inventaron identidades legales.
- La demo no prueba precisión del detector ni impacto. No hay entrevistas, usuarios externos, adopción o accidentes evitados verificados.

## Futuro

Prueba Android estacionaria, piloto consentido, métricas de señal y sincronización, recuperación de enlace de flota mejorada y evaluación por conductor con extractor equivalente. La geolocalización y navegación externa están implementadas; su verificación física sigue pendiente. Los modelos nuevos y la doble cámara permanecen fuera de P0. No hay intervención remota sobre el vehículo.

## Criterio de cierre

El P0 no debe marcarse completamente terminado mientras falten la prueba física integrada y una URL pública comprobada. Los estados se clasifican como VERIFICADO, IMPLEMENTADO SIN VERIFICACIÓN COMPLETA, BLOQUEADO o PENDIENTE en el reporte técnico.
