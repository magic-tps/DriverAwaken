# MagicDrive Alert

App Flutter de alerta temprana para conductores somnolientos. Procesa la
camara frontal en tiempo real con Google ML Kit, reglas criticas y un modelo
TensorFlow Lite local. No graba video ni guarda imagenes.

> Sistema preventivo de alerta temprana, no sustituye la responsabilidad del
> conductor ni una evaluacion medica.

## Capacidades principales

- Camara frontal en tiempo real con throttling de frames.
- Deteccion facial con Google ML Kit Face Detection.
- Reglas criticas: ojos cerrados, rostro ausente, cabeza caida, distraccion,
  bostezos y PERCLOS.
- Motor de riesgo 0-100 con suavizado, histeresis y confirmacion temporal.
- Modelo TFLite local como segunda opinion; no reemplaza las reglas criticas.
- Deteccion basica de mala iluminacion para evitar falsos positivos agresivos.
- Calibracion personal guiada.
- Modo viaje con pausa, finalizacion y resumen.
- Historial local de eventos y metricas, sin imagenes ni video.
- Ajustes de sensibilidad, sonido, vibracion, modelo IA, panel tecnico y
  ventana PERCLOS.
- Alertas por niveles: visual, vibracion, alarma y peligro sostenido con
  boton "Estoy bien".
- Audio local real de alarma por canal nativo Android.
- Firma release APK/AAB con keystore local.
- Medicion de bateria, temperatura aproximada, carga, FPS y latencia de viaje.

## Ejecutar en Android

```powershell
cd D:\Escritorio\DriveAwake\driveawake
flutter pub get
flutter run
```

Para compilar APK debug:

```powershell
flutter build apk --debug
```

Para compilar APK/AAB release firmado:

```powershell
flutter build apk --release
flutter build appbundle --release
```

Ver detalles en `docs/RELEASE_SIGNING.md`.

APK generado:

```powershell
build\app\outputs\flutter-apk\app-debug.apk
```

## Pruebas

```powershell
flutter analyze
flutter test
flutter build apk --debug
```

## Flujo de prueba recomendado

1. Abre la app y entra en `Iniciar viaje`.
2. Pulsa `Calibrar` y sigue las instrucciones durante unos 26 segundos.
3. Prueba conduccion normal con buena iluminacion.
4. Cierra los ojos por mas de 1.5 s: debe subir a precaucion.
5. Cierra los ojos por mas de 3 s: debe subir a peligro.
6. Sal del encuadre: debe marcar rostro ausente.
7. Baja la cabeza o mira a un lado de forma sostenida.
8. Finaliza el viaje y revisa el resumen.
9. Entra a `Historial` para revisar eventos guardados.
10. Entra a `Ajustes` para cambiar sensibilidad, alertas y PERCLOS.
11. Usa `Probar alarma real` para validar el audio local.

## Privacidad

- Todo se procesa en el dispositivo.
- No se graban videos.
- No se guardan imagenes.
- El historial guarda solo eventos, fechas, niveles y metricas.
- El usuario puede borrar el historial desde Ajustes o Historial.

Politica completa: `docs/PRIVACY_POLICY.md`.

## Validacion

Protocolo de pruebas fisicas: `docs/VALIDATION_PROTOCOL.md`.
Resultado offline actual: `docs/VALIDATION_RESULTS_2026-05-24.md`.

Validacion offline de falsos positivos/falsos negativos con el dataset:

```powershell
cd D:\Escritorio\DriveAwake\app_conductores_ml
python src\validate_product_rules.py --csv data\features\fold5_features_enhanced.csv --model models\drowsiness_best_tabular.joblib
```

## Arquitectura actual

- `CameraService`: inicializacion y stream de camara.
- `FaceDetectionService`: Google ML Kit Face Detection.
- `DrowsinessService`: orquestacion de landmarks, suavizado, PERCLOS y modelo.
- `DrowsinessEngine`: score de riesgo, reglas, histeresis y niveles.
- `CalibrationService`: calibracion automatica y guiada.
- `AlertService`: sonido, vibracion, cooldown y niveles de alarma.
- `TripSessionService`: modo viaje y resumen.
- `LocalHistoryService`: eventos locales con SharedPreferences.
- `DrowsinessModelService`: carga, preprocesamiento e inferencia TFLite.
- `SettingsService`: preferencias del usuario.

## Siguiente fase recomendada

- Recolectar datos propios con celulares reales, sin guardar imagenes del
  usuario final salvo consentimiento explicito en un flujo separado.
- Mejorar el modelo con validacion por sujeto, no solo por ventanas.
- Entrenar modelos temporales como GRU, LSTM o Temporal CNN.
- Agregar audio local dedicado de alarma.
- Medir consumo de bateria, temperatura y falsos positivos en pruebas reales.
