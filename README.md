# DriverAwaken Guardian

Plataforma preventiva para flotas de transporte regional: detección y alertas locales en Android, incidentes persistentes con sincronización consentida y central web para documentar acciones humanas. Conserva el modo personal sin flota.

**Inicio para jurado:** [DEMO_GUIDE.md](DEMO_GUIDE.md). **Instalación y publicación:** [DEPLOYMENT.md](DEPLOYMENT.md). **Resultados ejecutados y límites:** [TECHNICAL_VALIDATION.md](TECHNICAL_VALIDATION.md). **Trabajo previo y cambios de esta sesión:** [HACKTHEANDES_2026.md](HACKTHEANDES_2026.md). Descripción de competencia: [proyecto.md](proyecto.md); guion de tres minutos: [PITCH_SCRIPT.md](PITCH_SCRIPT.md).

La web vive en `dashboard/` y se publica mediante GitHub Pages en [magic-tps.github.io/DriverAwaken](https://magic-tps.github.io/DriverAwaken/). La portada enlaza el APK de prueba desde GitHub Releases. Demo y pitch funcionan sin cuenta; sus datos sintéticos están identificados y aislados. `/dashboard/` exige Firebase Auth y una membresía ADMIN/OPERATOR activa; `/driver/` exige una membresía DRIVER activa y muestra solo los registros propios. El administrador puede configurar un número de emergencia de flota, visible para llamada voluntaria desde el portal del conductor. Los avisos push automáticos permanecen desactivados porque la función de envío requiere el plan Blaze de Firebase; la central en vivo sí consulta Firestore.

Guardian agrega reglas multiempresa en `backend/`, bootstrap privilegiado y pruebas de emulador; SQLite/Drift v2 incorpora una outbox con deduplicación y reintentos. No se envían imágenes, landmarks o embeddings. El score es heurístico; la falta de rostro significa señal insuficiente. El modelo incompatible continúa desactivado. Consultar [auditoría](docs/guardian_audit.md).

La conducción prioriza la cámara frontal y Smart Rest. La búsqueda de paradas y la navegación se abren voluntariamente en Google Maps mediante URLs oficiales, con el vehículo detenido y el monitoreo pausado hasta reanudarlo. La app no solicita ubicación ni integra mapas internos. Drift v3 registra descansos declarados. Ver [Google Maps externo](docs/maps_setup.md), [privacidad técnica](PRIVACY.md) y el informe de validación antes de presentar. El dashboard añade conductores, descansos y exportación CSV filtrada.

La app está disponible en **español e inglés**. Puedes elegir el idioma en el login o en **Ajustes → Idioma / Language**, o usar el idioma del teléfono. La preferencia se conserva al reabrirla. Ver [documentación de idiomas](docs/localization.md).

Aplicación Flutter experimental para detectar señales de somnolencia mediante cámara frontal, reglas temporales y un modelo TensorFlow Lite local desactivado por defecto hasta completar su validación.

No es un sistema médico ni vehicular certificado y no sustituye la atención o responsabilidad del conductor. Úsese únicamente en desarrollo y pruebas internas controladas.

## Componentes

- `driveawake/`: aplicación Flutter/Android.
- `app_conductores_ml/`: entrenamiento y validación Python.
- `shared/`: contrato y vectores compartidos del modelo.
- `dashboard/`: central Next.js, simulador público y pitch web exportables a hosting estático.
- `backend/`: Firestore Rules, pruebas de aislamiento y scripts administrativos/emulador.
- `docs/`: auditorías, arquitectura, privacidad y validación.
- `Data/`: datos locales excluidos; no modificar ni versionar.

## Archivos publicados

Se versionan el código, las pruebas, la documentación, las dependencias y los
recursos necesarios de la aplicación, incluido el modelo TFLite de inferencia.
Los datasets, las características extraídas de videos, los reportes por video,
los entornos locales, las compilaciones y las credenciales quedan excluidos.
Para entrenar modelos se necesitan datos locales propios; no se incluyen en este
repositorio. Las métricas agregadas y los vectores de prueba sí se conservan.

Consulte `docs/initial_audit.md`, `docs/phase_1_safety_report.md`, `docs/ml_validation_report.md` y `docs/architecture.md` antes de preparar pruebas.

La referencia funcional y técnica del estado actual está en [el informe completo de Guardian](docs/INFORME_COMPLETO_DRIVERAWAKEN_GUARDIAN.md), acompañado de [un catálogo por archivo](docs/INVENTARIO_ARCHIVOS_GUARDIAN.md) y [un inventario JSON](docs/INVENTARIO_TECNICO_GUARDIAN.json). `docs/APP_ESPECIFICACION_COMPLETA.md` conserva una especificación histórica de julio, anterior a varias funciones actuales.

La configuración Firebase y el uso de copias de informes están documentados en
[`docs/firebase_setup.md`](docs/firebase_setup.md). Las funciones locales no requieren cuenta.
