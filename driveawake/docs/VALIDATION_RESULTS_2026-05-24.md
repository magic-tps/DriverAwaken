# Resultados de validacion offline - 2026-05-24

Fuente:

- `app_conductores_ml/data/features/fold5_features_enhanced.csv`
- `app_conductores_ml/models/drowsiness_best_tabular.joblib`
- Script: `app_conductores_ml/src/validate_product_rules.py`

Filas evaluadas: 11,339 ventanas temporales.

## Definicion de alerta

- Positivo real: `label > 0` (cansancio o somnoliento).
- Positivo predicho: `product_level > 0` (precaucion o peligro).

Resultados:

- Verdaderos negativos: 767
- Falsos positivos: 2,855
- Falsos negativos: 826
- Verdaderos positivos: 6,848
- Tasa de falsos positivos: 77.9%
- Tasa de falsos negativos: 10.8%

## Definicion de peligro

- Positivo real: `label == 2` (somnoliento).
- Positivo predicho: `product_level == 2` (peligro).

Resultados:

- Verdaderos negativos: 5,259
- Falsos positivos: 2,092
- Falsos negativos: 2,050
- Verdaderos positivos: 1,938
- Tasa de falsos positivos: 28.5%
- Tasa de falsos negativos: 51.4%

## Lectura del resultado

El motor hibrido prioriza seguridad y sensibilidad: detecta muchas ventanas de
cansancio/somnolencia, pero todavia genera demasiados falsos positivos cuando se
evalua con etiquetas de video. Esto confirma que:

- Las reglas criticas deben seguir mandando.
- El modelo no debe decidir solo.
- Se necesita validacion en telefono fisico con usuarios y escenas reales.
- Se debe recolectar data propia para bajar falsos positivos sin perder alarmas
  criticas.

Los CSV de errores quedaron en:

- `app_conductores_ml/reports/product_alert_false_positives.csv`
- `app_conductores_ml/reports/product_alert_false_negatives.csv`
- `app_conductores_ml/reports/product_danger_false_positives.csv`
- `app_conductores_ml/reports/product_danger_false_negatives.csv`
