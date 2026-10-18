# Auditoría inicial — DriverAwaken Guardian

Fecha de trabajo: 17 de octubre de 2026 (America/Lima). Base registrada en la auditoría previa: `c5aaa8ca1d7e0fb1330056b6c4ac6b08ccd6ffa8`. Rama: `feat/guardian-mvp`. Al continuar esta revisión ya había cambios Guardian sin commit; se conservaron junto con datasets y configuración local. Esta base permite revisar el conjunto acumulado, pero no certifica cuándo fue desarrollado cada commit histórico ni atribuye todo el trabajo al evento.

## Hallazgos verificados en código

- Flutter ya integra ML Kit, reglas temporales, PERCLOS, calibración, alarmas, watchdog, borradores recuperables, viajes e historial Drift, exportaciones y cuentas/copias personales opcionales.
- `LocalHistoryService.loadEvents` retornaba el Future sin await dentro del try: un error asíncrono eludía el fallback. Corregido.
- La aplicación y el contrato compartido tienen `parity_verified=false`. El modelo histórico no es equivalente al extractor ML Kit. Se conserva desactivado; no se reentrena ni se afirma accuracy nueva.
- Firestore inicialmente solo autorizaba `users/{uid}/reports/{id}`. No existían entidades de flota ni dashboard.
- La ausencia prolongada de rostro elevaba el motor a peligro. Guardian la separa como indisponibilidad de señal, con score de fatiga cero; el cierre ocular fiable conserva alarma crítica.
- Flutter 3.35.3 / Dart 3.9.2, Python 3.11, Node, Java, Firebase CLI y Andes CLI disponibles. No se actualizan masivamente dependencias existentes.

## Fuente de la competencia

[Sitio oficial](https://hacktheandes.com/) y [guía para equipos](https://hacktheandes.com/guide) consultados durante el trabajo. El navegador de búsqueda inicialmente no pudo leer la guía; una consulta HTTP directa sí permitió leerla. Track 02 `transport`: movilidad en Lima y transporte de pasajeros, conectividad entre localidades, carga y distribución en regiones. No apareció un brief más detallado en los archivos del repositorio. La guía exige URLs accesibles desde el equipo de la organización, tres minutos de pitch y dos de preguntas; pondera tracción 30%, esfuerzo técnico 40% y pitch 30%. No tenemos evidencia externa de tracción y no se inventa. `andes project submit --help` confirma los flags deployment-url, presentation-url, github-url y file. No se ejecutó submit.

## Plan aplicado

1. Corregir base y validar Python/Flutter.
2. Añadir dominio de flota separado, adaptador de eventos y outbox Drift sin duplicar detector ni resúmenes personales.
3. Aplicar reglas multiempresa, bootstrap privilegiado y pruebas del emulador.
4. Añadir dashboard Next.js estático, demo determinista aislada y pitch público, con estados reales/autenticados separados.
5. Compilar, probar, documentar evidencia y bloqueos. No publicar sin autorización.

## Decisiones

- Los incidentes son inmutables; las acciones humanas se anexan. Su estado operativo se deriva de esas acciones.
- La cola incluye mensajes de salud/ciclo de viaje, procesados FIFO. El fin remoto espera a los incidentes pendientes. Firebase no participa en la alarma local.
- Las transacciones comprueban membresía/viaje y documento existente para reintentos idempotentes; SQLite gestiona la cola, no el caché Firestore.
- Sin geolocalización continua, frames, landmarks, embeddings ni reconocimiento facial de identidad.
- La demo es un simulador independiente y no valida el detector. Una publicación estática permite hosting Firebase sin backend Next.js ni infraestructura de pago adicional.
- La membresía inicial ADMIN exige Admin SDK con credenciales autorizadas. Ningún cliente puede crear una organización privilegiada.

El [onboarding oficial](https://hacktheandes.com/deck/onboarding) también pudo leerse con navegador. Reitera transporte regional, entrega pública y pitch de tres minutos; muestra una rúbrica distinta de la guía (75% técnico / 25% producto más puntos de tracción). No asumimos cuál ponderación prevalece. No se incluyen credenciales de logística del evento en los artefactos.

Resultados finales y comandos: `TECHNICAL_VALIDATION.md` en la raíz.
