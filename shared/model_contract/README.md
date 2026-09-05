# Contrato de modelo DriverAwake

Este directorio define el contrato verificable entre el pipeline Python y Flutter.
El modelo historico permanece desactivado por defecto porque fue entrenado con
MediaPipe y la app produce señales con ML Kit. El contrato preserva el orden y
preprocesamiento actuales para detectar regresiones, pero no afirma paridad del
detector ni validez de las metricas historicas.

Los campos con valor null representan informacion que no puede inferirse de
forma confiable y debe completarse al reentrenar con datos producidos por Android.

