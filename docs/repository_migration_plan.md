# Plan de organización del repositorio

Se conservan `driveawake/` y `app_conductores_ml/` para no romper imports, automatizaciones ni el historial. No se mueve `Data/`.

Migración futura propuesta: validar primero CI; renombrar `driveawake/` a `mobile/` en un cambio aislado; renombrar `app_conductores_ml/` a `ml/`; actualizar rutas de CI y documentación; verificar hashes de modelos; mantener `shared/`, `docs/` y `scripts/` en raíz. Los movimientos deben hacerse con Git disponible para conservar trazabilidad.
