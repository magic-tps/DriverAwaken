# MagicDrive Alert - Fase 2 ML

Pipeline en Python para entrenar un modelo propio de deteccion de somnolencia
con videos de UTA-RLDD Fold5, sin guardar frames como imagenes.

El flujo completo es:

```text
Videos Fold5
-> inspeccion del dataset
-> lectura de frames en memoria
-> MediaPipe FaceMesh
-> EAR, MAR, PERCLOS y proxies de cabeza
-> ventanas temporales de 10 segundos
-> CSV tabular
-> features temporales enriquecidas
-> comparacion de modelos tabulares
-> MLP Keras con features enriquecidas
-> TensorFlow Lite
-> assets listos para Flutter
```

## Estructura

```text
app_conductores_ml/
  data/
    raw/
      uta_rldd/
        fold5/
    processed/
    features/
  models/
  reports/
  src/
  notebooks/
  README.md
  requirements.txt
```

## Crear entorno virtual en Windows PowerShell

Desde la carpeta `app_conductores_ml`:

```powershell
python -m venv venv
.\venv\Scripts\activate
python -m pip install --upgrade pip
pip install -r requirements.txt
```

Este proyecto fue probado con Python 3.11 en Windows. Las versiones de
`requirements.txt` estan fijadas para mantener compatible MediaPipe FaceMesh
clasico con TensorFlow Lite.

## Donde colocar Fold5

Descomprime los ZIP de Fold5 dentro de:

```text
data/raw/uta_rldd/fold5/
```

El parser soporta estructuras como:

```text
fold5/
  0/
  5/
  10/
```

```text
fold5/
  subject_01_0.mp4
  subject_01_5.mp4
  subject_01_10.mp4
```

```text
fold5/
  Fold5_part1/
    50/
      0.mp4
      5.mp4
      10_1.mp4
  Fold5_part2/
    60/
      0.mov
      5.mov
      10.mov
```

Etiquetas:

- `0` se convierte a `label 0 = despierto`
- `5` se convierte a `label 1 = cansancio`
- `10` se convierte a `label 2 = somnoliento`

## 1. Inspeccionar dataset

```powershell
python src/inspect_dataset.py --input data/raw/uta_rldd/fold5
```

Genera:

- `reports/dataset_inspection.csv`
- `reports/unlabeled_videos.csv`

Si aparece:

```text
No pude inferir etiquetas. Revisa nombres de carpetas/archivos.
```

abre `reports/unlabeled_videos.csv` y ajusta nombres o parser.

## 2. Extraer features

```powershell
python src/extract_features.py --input data/raw/uta_rldd/fold5 --output data/features/fold5_features.csv --sample_fps 5 --window_seconds 10 --max_frame_width 640 --workers 6 --ear_threshold 0.16 --mar_threshold 0.55 --sampling_mode grab
```

El script no guarda frames. Lee el video con OpenCV, muestrea frames en memoria
y calcula features con MediaPipe FaceMesh.

Notas:

- `--max_frame_width 640` reduce el tamano antes de FaceMesh para acelerar el procesamiento.
- `--workers 6` procesa videos en paralelo. Si tu PC se calienta demasiado, usa `--workers 2` o `--workers 4`.
- `--ear_threshold 0.16` fue util en esta corrida porque `0.20` producia PERCLOS demasiado alto.
- `--sampling_mode grab` recorre el video secuencialmente; `seek` existe como alternativa, pero puede ser mas lento en algunos `.mov`.

Genera:

- `data/features/fold5_features.csv`
- `reports/feature_extraction_summary.json`

Columnas principales:

- `face_ratio`, `no_face_ratio`
- `ear_mean`, `ear_min`, `ear_max`, `ear_std`
- `mar_mean`, `mar_max`, `mar_std`
- `perclos`
- `blink_count`, `max_eye_closed_duration`
- `yawn_count`, `yawn_ratio`
- `yaw_proxy_mean`, `yaw_proxy_max_abs`
- `pitch_proxy_mean`, `pitch_proxy_max`

## 3. Entrenar Random Forest

```powershell
python src/train_random_forest.py --csv data/features/fold5_features_enhanced.csv --search_iter 0 --cv_splits 4
```

Usa `GroupShuffleSplit` por `video_id`, para evitar que ventanas del mismo video
caigan en train y test al mismo tiempo.
Puede usar `RandomizedSearchCV` con `GroupKFold` si pasas `--search_iter`,
pero con las features enriquecidas puede tardar bastante. Para iterar rapido,
usa `--search_iter 0`.

Genera:

- `models/drowsiness_random_forest.joblib`
- `reports/random_forest_classification_report.json`
- `reports/random_forest_confusion_matrix.png`
- `reports/random_forest_metrics.json`
- `reports/feature_importance.csv`
- `reports/feature_importance.png`

Interpreta especialmente:

- `recall` de `somnoliento`
- matriz de confusion entre `cansancio` y `somnoliento`
- importancia de `perclos`, `ear_min`, `max_eye_closed_duration`, `mar_max`

## 4. Entrenar MLP y exportar TensorFlow Lite

```powershell
python src/train_mlp_tflite.py --csv data/features/fold5_features_enhanced.csv --epochs 500 --learning_rate 0.00025 --patience 70 --min_final_epochs 100
```

Genera:

- `models/drowsiness_mlp.keras`
- `models/drowsiness_mlp.tflite`
- `models/preprocessing_metadata.json`
- `reports/mlp_classification_report.json`
- `reports/mlp_confusion_matrix.png`
- `reports/mlp_metrics.json`
- `reports/training_history.png`

`preprocessing_metadata.json` contiene:

- orden exacto de features
- medianas para imputacion
- medias y desviaciones estandar para normalizacion
- nombres de clases

Flutter debe aplicar ese mismo preprocesamiento antes de llamar al modelo.

El modelo TFLite actual usa features enriquecidas, incluyendo rolling windows
y deltas temporales. En Flutter debes mantener un buffer de ventanas de 10
segundos para calcularlas igual que en Python.

## 4.1. Comparar modelos tabulares

```powershell
python src/train_model_zoo.py --csv data/features/fold5_features_enhanced.csv --n_estimators 700
python src/train_logistic_search.py --csv data/features/fold5_features_enhanced.csv --cv_splits 4
```

Genera:

- `models/drowsiness_best_tabular.joblib`
- `models/drowsiness_logistic_search.joblib`
- `reports/model_zoo_metrics.csv`
- `reports/best_tabular_metrics.json`
- `reports/best_tabular_confusion_matrix.png`

El mejor modelo tabular actual es `logistic_search`.

## 5. Probar una prediccion

```powershell
python src/predict_sample.py --csv data/features/fold5_features.csv --model models/drowsiness_random_forest.joblib --row 0
```

Tambien puedes usar:

```powershell
python src/predict_sample.py --csv data/features/fold5_features.csv --video_id TU_VIDEO_ID
```

## 6. Exportar assets para Flutter

```powershell
python src/export_flutter_assets.py
```

Genera:

```text
flutter_assets/
  assets/
    models/
      drowsiness_mlp.tflite
      preprocessing_metadata.json
  README_FLUTTER_INTEGRATION.md
```

## 7. Ejecutar todo el pipeline

```powershell
python src/run_all_phase2.py --input data/raw/uta_rldd/fold5
```

Opcional:

```powershell
python src/run_all_phase2.py --input data/raw/uta_rldd/fold5 --sample_fps 5 --window_seconds 10 --workers 6 --max_frame_width 640 --ear_threshold 0.16 --mar_threshold 0.55 --sampling_mode grab --rf_search_iter 0 --mlp_epochs 500 --mlp_learning_rate 0.00025 --mlp_patience 70 --mlp_min_final_epochs 100
```

Si ya existe `data/features/fold5_features.csv` y solo quieres repetir entrenamiento/exportacion:

```powershell
python src/run_all_phase2.py --input data/raw/uta_rldd/fold5 --skip_existing_features
```

Para repetir solo el MLP mas conservador usado en la ultima corrida:

```powershell
python src/feature_engineering.py --input data/features/fold5_features.csv --output data/features/fold5_features_enhanced.csv --ear_threshold 0.16 --mar_threshold 0.55
python src/train_model_zoo.py --csv data/features/fold5_features_enhanced.csv --n_estimators 700
python src/train_logistic_search.py --csv data/features/fold5_features_enhanced.csv --cv_splits 4
python src/train_mlp_tflite.py --csv data/features/fold5_features_enhanced.csv --epochs 500 --batch_size 32 --learning_rate 0.00025 --patience 70 --min_final_epochs 100
python src/export_flutter_assets.py
```

## Resultados actuales

Con 180 videos y 11,339 ventanas:

- Mejor tabular (`logistic_search`): `accuracy 0.4507`, `balanced_accuracy 0.4032`, `recall somnoliento 0.5520`.
- MLP + TFLite enriquecido: `accuracy 0.3982`, `balanced_accuracy 0.3890`.
- Random Forest enriquecido sin busqueda: `accuracy 0.3435`, `balanced_accuracy 0.4025`, `recall somnoliento 0.567`.

La mejora vino principalmente de las features temporales, no de aumentar epocas.

## Como interpretar resultados

En `reports/random_forest_metrics.json` y `reports/mlp_metrics.json` revisa:

- `accuracy`
- `precision_weighted`
- `recall_weighted`
- `f1_weighted`

En los reportes de clasificacion revisa cada clase:

- `0 = despierto`
- `1 = cansancio`
- `2 = somnoliento`

Para un sistema de seguridad vial, el `recall` de `somnoliento` es critico:
conviene detectar somnolencia aunque existan algunos falsos positivos.

## Integracion futura con Flutter

La app debe ser hibrida:

- Si ojos cerrados mas de 3 segundos: alarma por regla.
- Si no hay rostro mas de 2 segundos: alerta por regla.
- Si el modelo predice `somnoliento` con alta confianza: alarma.
- Si el modelo predice `cansancio`: subir nivel junto con PERCLOS, bostezos y cabeza caida.

La Fase 2 no reemplaza las reglas criticas de Fase 1; las complementa.
