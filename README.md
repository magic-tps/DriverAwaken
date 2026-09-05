# DriverAwaken

Aplicación Flutter experimental para detectar señales de somnolencia mediante cámara frontal, reglas temporales y un modelo TensorFlow Lite local desactivado por defecto hasta completar su validación.

No es un sistema médico ni vehicular certificado y no sustituye la atención o responsabilidad del conductor. Úsese únicamente en desarrollo y pruebas internas controladas.

## Componentes

- `driveawake/`: aplicación Flutter/Android.
- `app_conductores_ml/`: entrenamiento y validación Python.
- `shared/`: contrato y vectores compartidos del modelo.
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

La referencia funcional y técnica exhaustiva del estado actual está en `docs/APP_ESPECIFICACION_COMPLETA.md`.
