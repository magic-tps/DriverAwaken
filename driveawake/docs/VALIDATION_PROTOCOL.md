# Protocolo de validacion - MagicDrive Alert

Objetivo: medir falsos positivos, falsos negativos, bateria y calentamiento en
un entorno reproducible, sin guardar imagenes ni video.

## Definiciones

- Falso positivo: la app emite precaucion o peligro cuando el conductor esta
  despierto y atento.
- Falso negativo: el conductor simula o presenta una senal de cansancio y la app
  no emite precaucion o peligro.
- Peligro critico correcto: ojos cerrados por mas de 3 segundos, rostro ausente
  sostenido o combinacion de ojos cerrados + cabeza caida.

## Prueba minima por telefono

1. Cargar bateria entre 70% y 100%.
2. Cerrar apps en segundo plano.
3. Abrir MagicDrive Alert.
4. Ejecutar calibracion guiada.
5. Iniciar viaje de prueba de 20 minutos.
6. Mantener buena iluminacion durante los primeros 10 minutos.
7. Probar estas escenas controladas:
   - conduccion normal simulada: 5 minutos;
   - mirar espejo brevemente: 10 repeticiones;
   - cerrar ojos 1.5 segundos: 5 repeticiones;
   - cerrar ojos 3 segundos: 3 repeticiones;
   - bostezar: 5 repeticiones;
   - rostro fuera de camara: 3 repeticiones;
   - poca luz: 2 minutos.
8. Finalizar viaje y registrar resumen.
9. Revisar Historial y contar falsos positivos/falsos negativos.

## Criterios iniciales de aceptacion

- Ojos cerrados > 3 s: deteccion esperada >= 95%.
- Rostro ausente > 2 s: deteccion esperada >= 95%.
- Mirar espejo brevemente: falsos positivos bajos.
- Poca luz: debe mostrar aviso de iluminacion, no peligro por si solo.
- Temperatura: no deberia subir mas de 8 C en 20 minutos en un telefono medio.
- Bateria: documentar consumo por hora estimado.

## Validacion offline con dataset

Desde `app_conductores_ml`:

```powershell
python src/validate_product_rules.py --csv data/features/fold5_features_enhanced.csv --model models/drowsiness_best_tabular.joblib
```

Salidas:

- `reports/product_validation_metrics.json`
- `reports/product_alert_false_positives.csv`
- `reports/product_alert_false_negatives.csv`
- `reports/product_danger_false_positives.csv`
- `reports/product_danger_false_negatives.csv`

El reporte offline sirve para comparar versiones del motor hibrido, pero no
reemplaza pruebas fisicas con telefono, soporte, iluminacion y usuarios reales.
