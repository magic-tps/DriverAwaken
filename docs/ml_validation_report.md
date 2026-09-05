# Estado de validacion de machine learning

Fecha: 2026-07-17

## Metricas verificadas

No se generan nuevas metricas de rendimiento del clasificador en esta fase. Se
verifico estructuralmente que los nuevos splits no mezclan sujetos y que el
contrato coincide con el orden de 181 features y el hash del TFLite desplegado.

## Metricas historicas no confiables

Los resultados existentes fueron obtenidos con splits agrupados por video. Una
reproduccion del split historico encontro que el 100% de los sujetos del test
tambien aparecia en entrenamiento. La validacion de reglas tambien evaluaba el
modelo sobre el CSV completo y no reproducía exactamente el motor Dart.

Esas metricas se conservan como historial, pero no deben usarse para afirmar
rendimiento con conductores nuevos ni preparacion para piloto.

## Fuga de sujetos eliminada

Los cuatro entrenamientos principales ahora exigen `subject_id`, seleccionan el
holdout entre multiples semillas candidatas, validan interseccion cero y usan
validacion cruzada estratificada por grupos donde corresponde. Los tests cubren
reproducibilidad, semillas distintas, clases y errores por metadata insuficiente.

## Contrato y paridad

`shared/model_contract/` define version, hash, shapes, orden, clases y politica
de fallo. `shared/test_vectors/` contiene un golden numerico usado por Python y
Dart para validar orden, imputacion y escalado con tolerancia `1e-4`.

La paridad del detector sigue pendiente: entrenamiento usa MediaPipe y Flutter
usa ML Kit con formulas distintas. El contrato lo declara explicitamente y la
app rechaza el modelo historico.

## Limitaciones

- No hay datos de features exportadas desde Android para reentrenar.
- No hay conjunto final independiente creado bajo el nuevo protocolo.
- No hay metadata de condiciones como gafas, iluminacion o dispositivo.
- No existe Git, por lo que el manifiesto no puede registrar un commit de
  entrenamiento verificable.

## Recomendacion

Mantener el modelo desactivado. Recolectar features numericas generadas por ML
Kit bajo consentimiento, reentrenar con holdout por sujeto y solo entonces
actualizar `parity_verified`, version, hash y metricas retenidas.
